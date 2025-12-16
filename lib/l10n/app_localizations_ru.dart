// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appName => 'Nun Аутентификация';

  @override
  String get homeTitle => 'Главная';

  @override
  String get profileTitle => 'Профиль';

  @override
  String get settingsTitle => 'Настройки';

  @override
  String get logoutTitle => 'Выйти';

  @override
  String get userNameDefault => 'Имя пользователя';

  @override
  String get emailDefault => 'Электронная почта недоступна';

  @override
  String get editProfile => 'Редактировать профиль';

  @override
  String get securityAccount => 'Безопасность и аккаунт';

  @override
  String get changePin => 'Изменить PIN-код';

  @override
  String get changePinSubtitle => 'Обновите 4-значный PIN для быстрого доступа.';

  @override
  String get changePassword => 'Сменить пароль';

  @override
  String get editProfileTitle => 'Редактировать профиль';

  @override
  String get displayNameLabel => 'Отображаемое имя (полное имя)';

  @override
  String get saveProfile => 'Сохранить профиль';

  @override
  String get uploadingAvatar => 'Загрузка аватара...';

  @override
  String get profileSaveSuccess => 'Профиль успешно сохранён и синхронизирован!';

  @override
  String get profileSaveFailed => 'Не удалось сохранить профиль: ';

  @override
  String get changePasswordTitle => 'Смена пароля';

  @override
  String get updateCredentialsText => 'Обновите данные для входа.';

  @override
  String get currentPasswordLabel => 'Текущий пароль';

  @override
  String get newPasswordLabel => 'Новый пароль';

  @override
  String get confirmNewPasswordLabel => 'Подтвердите новый пароль';

  @override
  String get enterCurrentPassword => 'Введите текущий пароль.';

  @override
  String get enterNewPassword => 'Введите новый пароль.';

  @override
  String get confirmNewPassword => 'Подтвердите новый пароль.';

  @override
  String get passwordsDoNotMatch => 'Пароли не совпадают.';

  @override
  String get passwordMismatch => 'Новые пароли не совпадают.';

  @override
  String get saveNewPassword => 'Сохранить новый пароль';

  @override
  String get passwordUpdateSuccess => 'Пароль успешно обновлён!';

  @override
  String get userEmailNotFound => 'Email пользователя не найден. Пожалуйста, войдите снова.';

  @override
  String get invalidCurrentPassword => 'Неверный текущий пароль.';

  @override
  String get updatePasswordFailed => 'Не удалось обновить пароль.';

  @override
  String get themeMode => 'Режим темы';

  @override
  String get lightMode => 'Светлая тема';

  @override
  String get darkMode => 'Тёмная тема';

  @override
  String get systemMode => 'Системная';

  @override
  String get primaryColor => 'Основной цвет приложения';

  @override
  String get language => 'Язык';

  @override
  String get languageName => 'Русский';
}
