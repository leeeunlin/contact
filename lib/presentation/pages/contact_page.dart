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
    final ScrollController _mainScrollCtl = ScrollController();
    final ScrollController _searchScrollCtl = ScrollController();
    final contacts = ref.watch(contactNotifierProvider);
    if (contacts.isEmpty && !isFirstLoading) {
      Future.microtask(() {
        ref.read(contactNotifierProvider.notifier).fetchContacts();
        isFirstLoading = true;
      });
    }
    final searchResults = ref.watch(searchResultProvider);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
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
                  await Future.delayed(
                    Duration(microseconds: 500),
                  ).then((value) => FocusScope.of(context).unfocus());

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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 17),
              child: TextFormField(
                // controller: searchCtl,
                onChanged: (value) async {
                  ref.read(searchTextProvider.notifier).state = value;
                  if (value == '') {
                    ref.read(searchResultProvider.notifier).state = [];
                  } else {
                    final results = await ref
                        .read(searchContactsProvider)
                        .call(value);
                    ref.read(searchResultProvider.notifier).state = results;
                  }
                },
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 2),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: NotificationListener(
                      onNotification: (n) {
                        if (n is ScrollUpdateNotification) {
                          if (n.metrics.axis == Axis.vertical) {
                            FocusScope.of(context).unfocus();
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
                          controller: _mainScrollCtl,
                          child: ListView.builder(
                            padding: EdgeInsets.all(17),
                            controller: _mainScrollCtl,
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
                                  await Future.delayed(
                                    Duration(microseconds: 500),
                                  ).then(
                                    (value) => FocusScope.of(context).unfocus(),
                                  );
                                  if (result != null) {
                                    if (result is Contact) {
                                      await ref
                                          .read(
                                            contactNotifierProvider.notifier,
                                          )
                                          .updateContact(result);
                                    } else {
                                      await ref
                                          .read(
                                            contactNotifierProvider.notifier,
                                          )
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
                  if (ref.watch(searchTextProvider) != '')
                    Positioned.fill(
                      child: Container(
                        color: Colors.white,
                        child: searchResults.isEmpty
                            ? Center(child: Text('검색 결과가 없습니다.'))
                            : NotificationListener(
                                onNotification: (n) {
                                  if (n is ScrollUpdateNotification) {
                                    if (n.metrics.axis == Axis.vertical) {
                                      FocusScope.of(context).unfocus();
                                    }
                                  }
                                  return true;
                                },
                                child: Scrollbar(
                                  controller: _searchScrollCtl,
                                  child: ListView.builder(
                                    controller: _searchScrollCtl,
                                    padding: EdgeInsets.all(17),
                                    itemCount: searchResults.length,
                                    itemBuilder: (context, index) {
                                      final contact = searchResults[index];
                                      return InkWell(
                                        onTap: () async {
                                          // searchCtl.clear();
                                          final result =
                                              await showModalBottomSheet(
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (_) =>
                                                    ContactBottomSheet(
                                                      contact: contact,
                                                      modify: true,
                                                    ),
                                              );
                                          await Future.delayed(
                                            Duration(microseconds: 500),
                                          ).then(
                                            (value) => FocusScope.of(
                                              context,
                                            ).unfocus(),
                                          );
                                          if (result != null) {
                                            if (result is Contact) {
                                              await ref
                                                  .read(
                                                    contactNotifierProvider
                                                        .notifier,
                                                  )
                                                  .updateContact(result);

                                              final results = await ref
                                                  .read(searchContactsProvider)
                                                  .call(
                                                    ref
                                                        .read(
                                                          searchTextProvider
                                                              .notifier,
                                                        )
                                                        .state,
                                                  );
                                              ref
                                                      .read(
                                                        searchResultProvider
                                                            .notifier,
                                                      )
                                                      .state =
                                                  results;
                                            } else {
                                              await ref
                                                  .read(
                                                    contactNotifierProvider
                                                        .notifier,
                                                  )
                                                  .deleteContact(result);
                                              final results = await ref
                                                  .read(searchContactsProvider)
                                                  .call(
                                                    ref
                                                        .read(
                                                          searchTextProvider
                                                              .notifier,
                                                        )
                                                        .state,
                                                  );
                                              ref
                                                      .read(
                                                        searchResultProvider
                                                            .notifier,
                                                      )
                                                      .state =
                                                  results;
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
                                            style: headerText(
                                              color: Colors.black,
                                            ),
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
            ),
          ],
        ),
      ),
    );
  }
}
