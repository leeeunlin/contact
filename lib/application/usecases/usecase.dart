import '../../domain/entities/contact.dart';
import '../../domain/repositories/contact_repository.dart';

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
