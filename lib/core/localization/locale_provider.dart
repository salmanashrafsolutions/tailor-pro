import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LocaleState {
  final Locale locale;
  final bool useUrduNumerals;

  const LocaleState({
    required this.locale,
    this.useUrduNumerals = false,
  });

  bool get isUrdu => locale.languageCode == 'ur';
  TextDirection get textDirection => isUrdu ? TextDirection.rtl : TextDirection.ltr;

  LocaleState copyWith({
    Locale? locale,
    bool? useUrduNumerals,
  }) {
    return LocaleState(
      locale: locale ?? this.locale,
      useUrduNumerals: useUrduNumerals ?? this.useUrduNumerals,
    );
  }
}

class LocaleNotifier extends StateNotifier<LocaleState> {
  LocaleNotifier() : super(const LocaleState(locale: Locale('ur', 'PK')));

  void setLocale(Locale locale) {
    state = state.copyWith(locale: locale);
  }

  void toggleLanguage() {
    if (state.locale.languageCode == 'ur') {
      state = state.copyWith(locale: const Locale('en', 'US'));
    } else {
      state = state.copyWith(locale: const Locale('ur', 'PK'));
    }
  }

  void toggleUrduNumerals() {
    state = state.copyWith(useUrduNumerals: !state.useUrduNumerals);
  }

  String formatNumber(dynamic value) {
    if (value == null) return '';
    final str = value.toString();
    if (!state.useUrduNumerals) return str;

    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const urdu = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

    String result = str;
    for (int i = 0; i < 10; i++) {
      result = result.replaceAll(western[i], urdu[i]);
    }
    return result;
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, LocaleState>((ref) {
  return LocaleNotifier();
});

