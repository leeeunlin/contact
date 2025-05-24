import 'package:contact/domain/entities/contact.dart';
import 'package:contact/domain/repositories/contact_repository.dart';

class AddContact {
  final ContactRepository repository;
  AddContact(this.repository);

  Future<void> call(Contact contact) async {
    await repository.insertContact(contact);
  }
}

class UpdateContact {
  final ContactRepository repository;
  UpdateContact(this.repository);

  Future<void> call(Contact contact) async {
    await repository.updateContact(contact);
  }
}

class DeleteContact {
  final ContactRepository repository;
  DeleteContact(this.repository);

  Future<void> call(int seq) async {
    await repository.deleteContact(seq);
  }
}

class SearchContacts {
  final ContactRepository repository;
  SearchContacts(this.repository);

  Future<List<Contact>> call(String keyword) async {
    return await repository.searchContacts(keyword);
  }
}
