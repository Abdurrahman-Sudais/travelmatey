import 'package:flutter/material.dart';

/// A saved withdrawal bank account.
class BankAccount {
  final String accountName;
  final String bankName;
  final String accountNumber;
  bool isPrimary;

  BankAccount({
    required this.accountName,
    required this.bankName,
    required this.accountNumber,
    this.isPrimary = false,
  });
}

/// Shared in-memory store of the user's saved bank accounts.
/// In a real app this would be backed by an API / local DB.
class BankAccountStore {
  BankAccountStore._();
  static final BankAccountStore instance = BankAccountStore._();

  final ValueNotifier<List<BankAccount>> accounts =
      ValueNotifier<List<BankAccount>>([]);

  void add(BankAccount account) {
    final list = List<BankAccount>.from(accounts.value);
    if (list.isEmpty) {
      account.isPrimary = true;
    }
    list.add(account);
    accounts.value = list;
  }

  void remove(BankAccount account) {
    final list = List<BankAccount>.from(accounts.value);
    final wasPrimary = account.isPrimary;
    list.remove(account);
    if (wasPrimary && list.isNotEmpty) {
      list.first.isPrimary = true;
    }
    accounts.value = list;
  }

  void setPrimary(BankAccount account) {
    final list = List<BankAccount>.from(accounts.value);
    for (final a in list) {
      a.isPrimary = a == account;
    }
    accounts.value = list;
  }

  BankAccount? get primary {
    for (final a in accounts.value) {
      if (a.isPrimary) return a;
    }
    return accounts.value.isEmpty ? null : accounts.value.first;
  }
}

const List<String> kNigerianBanks = [
  "Access Bank",
  "Guaranty Trust Bank (GTBank)",
  "Zenith Bank",
  "First Bank of Nigeria",
  "United Bank for Africa (UBA)",
  "Fidelity Bank",
  "Union Bank",
  "Sterling Bank",
  "Wema Bank",
  "Polaris Bank",
  "Ecobank Nigeria",
  "Stanbic IBTC Bank",
  "Kuda Bank",
  "Opay",
  "Palmpay",
];