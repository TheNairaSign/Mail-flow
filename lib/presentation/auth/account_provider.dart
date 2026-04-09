import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_snaarp/domain/entities/user_entity.dart';

final accountProvider = StateNotifierProvider<AccountNotifier, AccountState>((ref) {
  return AccountNotifier();
});

class AccountState {
  final UserEntity activeUser;
  final List<UserEntity> otherUsers;

  const AccountState({
    required this.activeUser,
    required this.otherUsers,
  });

  AccountState copyWith({
    UserEntity? activeUser,
    List<UserEntity>? otherUsers,
  }) {
    return AccountState(
      activeUser: activeUser ?? this.activeUser,
      otherUsers: otherUsers ?? this.otherUsers,
    );
  }
}

class AccountNotifier extends StateNotifier<AccountState> {
  AccountNotifier()
      : super(
          const AccountState(
            activeUser: UserEntity(
              id: '1',
              name: 'Tonye Bob - Manuel',
              email: 'tonyebobmanuel2@gmail.com',
              avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Tonye',
            ),
            otherUsers: [
              UserEntity(
                id: '2',
                name: 'Work Account',
                email: 'tonye@company.com',
                avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=Work',
              ),
            ],
          ),
        );

  void switchAccount(String userId) {
    if (state.activeUser.id == userId) return;

    final currActive = state.activeUser;
    final otherUsers = List<UserEntity>.from(state.otherUsers);
    
    final newActiveIndex = otherUsers.indexWhere((u) => u.id == userId);
    if (newActiveIndex != -1) {
      final newActiveUser = otherUsers.removeAt(newActiveIndex);
      otherUsers.add(currActive);
      state = state.copyWith(activeUser: newActiveUser, otherUsers: otherUsers);
    }
  }

  void addAccount(String email) {
    if (email.trim().isEmpty) return;

    final name = email.split('@').first;
    final seed = DateTime.now().millisecondsSinceEpoch.toString();
    final newUser = UserEntity(
      id: seed,
      name: name,
      email: email.trim(),
      avatarUrl: 'https://api.dicebear.com/7.x/avataaars/png?seed=$seed',
    );

    final otherUsers = List<UserEntity>.from(state.otherUsers)..add(newUser);
    state = state.copyWith(otherUsers: otherUsers);
  }
}

