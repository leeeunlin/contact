import 'package:contact/data/datasources/contact_database.dart';
import 'package:contact/domain/entities/contact.dart';
import 'package:contact/presentation/providers/contact_provider.dart';
import 'package:contact/presentation/theme/textstyle.dart';
import 'package:contact/presentation/widgets/contact_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactPage extends ConsumerWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contacts = ref.watch(contactNotifierProvider);
    if (contacts.isEmpty && !isFirstLoading) {
      Future.microtask(() {
        ref.read(contactNotifierProvider.notifier).fetchContacts();
        isFirstLoading = true;
      });
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Text('연락처'),
            const SizedBox(width: 20),
            InkWell(
              onTap: () async {
                await ContactDatabase.instance.testDataSet();
                await ref
                    .read(contactNotifierProvider.notifier)
                    .fetchContacts();
              },
              child: Text(
                textAlign: TextAlign.center,
                '데이터\n추가세팅',
                style: textButton(),
              ),
            ),
            const SizedBox(width: 20),
            InkWell(
              onTap: () async {
                await ContactDatabase.instance.deleteAllContacts();

                // 삭제 후 리스트 갱신
                await ref
                    .read(contactNotifierProvider.notifier)
                    .fetchContacts();
              },
              child: Text(
                textAlign: TextAlign.center,
                '데이터\n전체 삭제',
                style: textButton(),
              ),
            ),
            const Spacer(),
            InkWell(
              onTap: () async {
                final result = await showModalBottomSheet<Contact>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => ContactBottomSheet(contact: Contact()),
                );
                if (result != null) {
                  await ref
                      .read(contactNotifierProvider.notifier)
                      .addContact(result);
                }
              },
              child: Icon(Icons.add),
            ),
          ],
        ),
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: NotificationListener(
              onNotification: (n) {
                if (n is ScrollUpdateNotification) {
                  if (n.metrics.axis == Axis.vertical) {
                    if (hasNext && n.metrics.extentAfter < 500) {
                      ref
                          .read(contactNotifierProvider.notifier)
                          .fetchContacts();
                    }
                  }
                }
                return true;
              },
              child: RefreshIndicator(
                onRefresh: () async {
                  page = 1;
                  await ref
                      .read(contactNotifierProvider.notifier)
                      .fetchContacts();
                },
                child: Scrollbar(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 17),
                    itemCount: contacts.length,
                    itemBuilder: (context, index) {
                      final contact = contacts[index];
                      return InkWell(
                        onTap: () async {
                          final result = await showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (_) => ContactBottomSheet(
                              contact: contact,
                              modify: true,
                            ),
                          );
                          if (result != null) {
                            if (result is Contact) {
                              await ref
                                  .read(contactNotifierProvider.notifier)
                                  .updateContact(result);
                            } else {
                              await ref
                                  .read(contactNotifierProvider.notifier)
                                  .deleteContact(result);
                            }
                          }
                        },
                        child: Container(
                          alignment: Alignment.centerLeft,
                          height: 50,
                          decoration: BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                          ),
                          child: Text(
                            contact.name,
                            style: headerText(color: Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
