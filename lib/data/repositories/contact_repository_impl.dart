import 'package:contact/data/datasources/contact_database.dart';
import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';

class ContactRepositoryImpl implements ContactRepository {
  @override
  Future<void> insertContact(Contact contact) async {
    await ContactDatabase.instance.insertContact(contact.toJson());
  }

  @override
  Future<void> updateContact(Contact contact) async {
    await ContactDatabase.instance.updateContact(contact.toJson());
  }

  @override
  Future<void> deleteContact(int seq) async {
    await ContactDatabase.instance.deleteContact(seq);
  }

  @override
  Future<List<Contact>> getContacts() async {
    final maps = await ContactDatabase.instance.getContacts();
    return maps.map((e) => Contact.fromJson(e)).toList();
  }

  @override
  Future<List<Contact>> searchContacts(String keyword) async {
    final result = await ContactDatabase.instance.searchContacts(keyword);
    return result.map((e) => Contact.fromJson(e)).toList();
  }
}
