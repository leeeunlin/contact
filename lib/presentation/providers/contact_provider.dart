import 'package:contact/application/usecases/usecase.dart';
import 'package:contact/data/datasources/contact_database.dart';
import 'package:contact/data/repositories/contact_repository_impl.dart';
import 'package:contact/domain/entities/contact.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Repository Provider
final contactRepositoryProvider = Provider((ref) => ContactRepositoryImpl());
// UseCase Provider
final addContactProvider = Provider(
  (ref) => AddContact(ref.read(contactRepositoryProvider)),
);
final updateContactProvider = Provider(
  (ref) => UpdateContact(ref.read(contactRepositoryProvider)),
);
final deleteContactProvider = Provider(
  (ref) => DeleteContact(ref.read(contactRepositoryProvider)),
);

// StateNotifierProvider 예시 (리스트 관리)
class ContactNotifier extends StateNotifier<List<Contact>> {
  final AddContact addContactUseCase;
  final UpdateContact updateContactUseCase;
  final DeleteContact deleteContactUseCase;

  ContactNotifier(
    this.addContactUseCase,
    this.updateContactUseCase,
    this.deleteContactUseCase,
  ) : super([]);

  Future<void> addContact(Contact contact) async {
    await addContactUseCase(contact);
    await fetchContacts(); // 저장 후 전체 리스트 갱신
  }

  Future<void> updateContact(Contact contact) async {
    await updateContactUseCase(contact);
    await fetchContacts(); // 수정 후 전체 리스트 갱신
  }

  Future<void> deleteContact(int seq) async {
    await deleteContactUseCase(seq);
    await fetchContacts(); // 삭제 후 리스트 갱신
  }

  Future<void> fetchContacts() async {
    final contacts = await addContactUseCase.repository.getContacts();
    if (page == 1) {
      state = contacts;
    } else {
      state = [...state, ...contacts];
    }
    if (hasNext) {
      page++;
    }
  }
}

final contactNotifierProvider =
    StateNotifierProvider<ContactNotifier, List<Contact>>(
      (ref) => ContactNotifier(
        ref.read(addContactProvider),
        ref.read(updateContactProvider),
        ref.read(deleteContactProvider),
      ),
    );
