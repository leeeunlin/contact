import 'package:contact/domain/entities/contact.dart';
import 'package:contact/presentation/theme/textstyle.dart';
import 'package:flutter/material.dart';

class ContactBottomSheet extends StatefulWidget {
  final Contact contact;
  final bool modify;
  const ContactBottomSheet({
    required this.contact,
    this.modify = false,
    super.key,
  });

  @override
  State<ContactBottomSheet> createState() => _ContactBottomSheetState();
}

class _ContactBottomSheetState extends State<ContactBottomSheet> {
  late TextEditingController nameCtl;
  late TextEditingController numberCtl;
  late TextEditingController emailCtl;

  @override
  void initState() {
    super.initState();
    nameCtl = TextEditingController(text: widget.contact.name);
    numberCtl = TextEditingController(text: widget.contact.number);
    emailCtl = TextEditingController(text: widget.contact.email);
  }

  @override
  Widget build(BuildContext context) {
    TextField inputField({
      required TextEditingController ctl,
      required String label,
    }) {
      return TextField(
        controller: ctl,
        onChanged: (v) => setState(() {}),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey),
          floatingLabelStyle: TextStyle(color: Colors.blue),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey, width: 1),
          ),
        ),
      );
    }

    return FractionallySizedBox(
      heightFactor: 0.9, // 화
      child: Padding(
        padding: EdgeInsets.only(top: 17.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('취소', style: textButton(color: Colors.blue)),
                ),
                Text(widget.modify ? '연락처 수정' : '새로운 연락처', style: textButton()),
                TextButton(
                  onPressed:
                      nameCtl.text.isNotEmpty ||
                          numberCtl.text.isNotEmpty ||
                          emailCtl.text.isNotEmpty
                      ? () {
                          final contact = Contact(
                            seq: this.widget.contact.seq,
                            name: nameCtl.text,
                            number: numberCtl.text,
                            email: emailCtl.text,
                          );
                          Navigator.of(context).pop(contact);
                        }
                      : null,
                  child: Text(
                    widget.modify ? '수정' : '완료',
                    style: textButton(
                      color:
                          nameCtl.text.isNotEmpty ||
                              numberCtl.text.isNotEmpty ||
                              emailCtl.text.isNotEmpty
                          ? Colors.blue
                          : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(17),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  inputField(ctl: nameCtl, label: '이름'),
                  const SizedBox(height: 16),
                  inputField(ctl: numberCtl, label: '전화번호'),
                  const SizedBox(height: 16),
                  inputField(ctl: emailCtl, label: '이메일'),
                  if (widget.modify)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 34),

                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(widget.contact.seq);
                        },
                        child: Text(
                          '연락처 삭제',
                          style: textButton(color: Colors.red),
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
