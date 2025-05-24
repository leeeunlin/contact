import '../entities/contact.dart';

abstract class ContactRepository {
  Future<void> insertContact(Contact contact);
  Future<void> updateContact(Contact contact);
  Future<void> deleteContact(int seq);
  Future<List<Contact>> searchContacts(String keyword);
  Future<List<Contact>> getContacts();
}
