import 'package:flutter/material.dart';

enum AppLanguage { ru, kz, en }

extension AppLanguageExtension on AppLanguage {
  String get displayName {
    switch (this) {
      case AppLanguage.ru: return 'Русский';
      case AppLanguage.kz: return 'Қазақша';
      case AppLanguage.en: return 'English';
    }
  }

  String get flag {
    switch (this) {
      case AppLanguage.ru: return '🇷🇺';
      case AppLanguage.kz: return '🇰🇿';
      case AppLanguage.en: return '🇬🇧';
    }
  }

  Locale get locale {
    switch (this) {
      case AppLanguage.ru: return const Locale('ru');
      case AppLanguage.kz: return const Locale('kk');
      case AppLanguage.en: return const Locale('en');
    }
  }
}

class AppLocalizations {
  final AppLanguage currentLanguage;

  const AppLocalizations(this.currentLanguage);

  static AppLocalizations of(AppLanguage lang) => AppLocalizations(lang);

  // ─── General ───
  String get appName => 'Timely';

  // ─── Login Screen ───
  String get welcomeBack {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Добро пожаловать обратно!';
      case AppLanguage.kz: return 'Қош келдіңіз!';
      case AppLanguage.en: return 'Welcome back!';
    }
  }
  
  String get email {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Email';
      case AppLanguage.kz: return 'Email';
      case AppLanguage.en: return 'Email';
    }
  }

  String get password {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Пароль';
      case AppLanguage.kz: return 'Құпия сөз';
      case AppLanguage.en: return 'Password';
    }
  }

  String get login {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Войти';
      case AppLanguage.kz: return 'Кіру';
      case AppLanguage.en: return 'Log in';
    }
  }

  String get noAccountRegister {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Нет аккаунта? Зарегистрироваться';
      case AppLanguage.kz: return 'Аккаунт жоқ па? Тіркелу';
      case AppLanguage.en: return 'No account? Register';
    }
  }

  String get forgotPassword {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Забыли пароль?';
      case AppLanguage.kz: return 'Құпия сөзді ұмыттыңыз ба?';
      case AppLanguage.en: return 'Forgot password?';
    }
  }

  // ─── Validation ───
  String get enterEmail {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Введите email';
      case AppLanguage.kz: return 'Email енгізіңіз';
      case AppLanguage.en: return 'Enter email';
    }
  }

  String get invalidEmail {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Некорректный email';
      case AppLanguage.kz: return 'Қате email';
      case AppLanguage.en: return 'Invalid email';
    }
  }

  String get enterPassword {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Введите пароль';
      case AppLanguage.kz: return 'Құпия сөзді енгізіңіз';
      case AppLanguage.en: return 'Enter password';
    }
  }

  String get passwordMin8 {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Минимум 8 символов';
      case AppLanguage.kz: return 'Кем дегенде 8 таңба';
      case AppLanguage.en: return 'Minimum 8 characters';
    }
  }

  // ─── Register Screen ───
  String get registration {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Регистрация';
      case AppLanguage.kz: return 'Тіркелу';
      case AppLanguage.en: return 'Registration';
    }
  }

  String get createAccount {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Создать аккаунт';
      case AppLanguage.kz: return 'Аккаунт құру';
      case AppLanguage.en: return 'Create account';
    }
  }

  String get registerSubtitle {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'После регистрации, ваша заявка будет\nрассмотрена администратором';
      case AppLanguage.kz: return 'Тіркелгеннен кейін сіздің өтінішіңізді\nәкімші қарайды';
      case AppLanguage.en: return 'After registration, your application\nwill be reviewed by an administrator';
    }
  }

  String get fullName {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'ФИО';
      case AppLanguage.kz: return 'Аты-жөні';
      case AppLanguage.en: return 'Full name';
    }
  }

  String get enterFullName {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Введите ФИО';
      case AppLanguage.kz: return 'Аты-жөніңізді енгізіңіз';
      case AppLanguage.en: return 'Enter full name';
    }
  }

  String get phone {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Телефон';
      case AppLanguage.kz: return 'Телефон';
      case AppLanguage.en: return 'Phone';
    }
  }

  String get phoneFormat {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Формат: +7XXXXXXXXXX';
      case AppLanguage.kz: return 'Формат: +7XXXXXXXXXX';
      case AppLanguage.en: return 'Format: +7XXXXXXXXXX';
    }
  }

  String get course {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Курс';
      case AppLanguage.kz: return 'Курс';
      case AppLanguage.en: return 'Year';
    }
  }

  String get selectCourse {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Укажите курс';
      case AppLanguage.kz: return 'Курсты таңдаңыз';
      case AppLanguage.en: return 'Select year';
    }
  }

  String get group {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Группа';
      case AppLanguage.kz: return 'Топ';
      case AppLanguage.en: return 'Group';
    }
  }

  String get selectGroup {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Укажите группу';
      case AppLanguage.kz: return 'Топты таңдаңыз';
      case AppLanguage.en: return 'Select group';
    }
  }

  String get register {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Зарегистрироваться';
      case AppLanguage.kz: return 'Тіркелу';
      case AppLanguage.en: return 'Register';
    }
  }

  // ─── Forgot Password ───
  String get passwordRecovery {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Восстановление пароля';
      case AppLanguage.kz: return 'Құпия сөзді қалпына келтіру';
      case AppLanguage.en: return 'Password recovery';
    }
  }

  String get forgotPasswordSubtitle {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Введите email, привязанный к вашему аккаунту. Мы отправим вам код подтверждения.';
      case AppLanguage.kz: return 'Аккаунтыңызға тіркелген email-ді енгізіңіз. Біз сізге растау кодын жібереміз.';
      case AppLanguage.en: return 'Enter the email linked to your account. We will send you a verification code.';
    }
  }

  String get sendCode {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Отправить код';
      case AppLanguage.kz: return 'Кодты жіберу';
      case AppLanguage.en: return 'Send code';
    }
  }

  String get backToLogin {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Вернуться к входу';
      case AppLanguage.kz: return 'Кіруге оралу';
      case AppLanguage.en: return 'Back to login';
    }
  }

  // ─── Verify Code Screen ───
  String get enterCode {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Введите код';
      case AppLanguage.kz: return 'Кодты енгізіңіз';
      case AppLanguage.en: return 'Enter code';
    }
  }

  String get codeSentTo {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Код отправлен на';
      case AppLanguage.kz: return 'Код жіберілді';
      case AppLanguage.en: return 'Code sent to';
    }
  }

  String get verify {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Подтвердить';
      case AppLanguage.kz: return 'Растау';
      case AppLanguage.en: return 'Verify';
    }
  }

  String get resendCode {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Отправить повторно';
      case AppLanguage.kz: return 'Қайта жіберу';
      case AppLanguage.en: return 'Resend code';
    }
  }

  // ─── Reset Password Screen ───
  String get newPassword {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Новый пароль';
      case AppLanguage.kz: return 'Жаңа құпия сөз';
      case AppLanguage.en: return 'New password';
    }
  }

  String get confirmPassword {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Подтвердите пароль';
      case AppLanguage.kz: return 'Құпия сөзді растаңыз';
      case AppLanguage.en: return 'Confirm password';
    }
  }

  String get passwordsDoNotMatch {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Пароли не совпадают';
      case AppLanguage.kz: return 'Құпия сөздер сәйкес келмейді';
      case AppLanguage.en: return 'Passwords do not match';
    }
  }

  String get resetPassword {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Сбросить пароль';
      case AppLanguage.kz: return 'Құпия сөзді қалпына келтіру';
      case AppLanguage.en: return 'Reset password';
    }
  }

  String get setNewPassword {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Установите новый пароль';
      case AppLanguage.kz: return 'Жаңа құпия сөз орнатыңыз';
      case AppLanguage.en: return 'Set new password';
    }
  }

  String get setNewPasswordSubtitle {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Придумайте надёжный пароль для вашего аккаунта';
      case AppLanguage.kz: return 'Аккаунтыңыз үшін сенімді құпия сөз ойлап табыңыз';
      case AppLanguage.en: return 'Create a strong password for your account';
    }
  }

  // ─── Status Screen ───
  String get waitingApproval {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Ожидание подтверждения';
      case AppLanguage.kz: return 'Растауды күту';
      case AppLanguage.en: return 'Waiting for approval';
    }
  }

  String get waitingApprovalBody {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Ваш аккаунт создан и находится на проверке у администратора. Вы получите уведомление, когда доступ будет открыт.';
      case AppLanguage.kz: return 'Сіздің аккаунтыңыз жасалды және әкімшінің тексеруінде. Кіру рұқсат етілгенде хабарлама аласыз.';
      case AppLanguage.en: return 'Your account has been created and is being reviewed by an administrator. You will be notified when access is granted.';
    }
  }

  String get applicationSent {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Заявка отправлена!';
      case AppLanguage.kz: return 'Өтініш жіберілді!';
      case AppLanguage.en: return 'Application sent!';
    }
  }

  String get applicationSentBody {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Ожидайте подтверждения администрацией. После одобрения вы сможете войти в приложение.';
      case AppLanguage.kz: return 'Әкімшіліктің растауын күтіңіз. Мақұлдағаннан кейін қолданбаға кіре аласыз.';
      case AppLanguage.en: return 'Wait for admin approval. After approval you will be able to log in.';
    }
  }

  String get goToLogin {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Перейти к входу';
      case AppLanguage.kz: return 'Кіруге өту';
      case AppLanguage.en: return 'Go to login';
    }
  }

  String get logout {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Выйти';
      case AppLanguage.kz: return 'Шығу';
      case AppLanguage.en: return 'Log out';
    }
  }

  String get logoutFromAccount {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Выйти из аккаунта';
      case AppLanguage.kz: return 'Аккаунттан шығу';
      case AppLanguage.en: return 'Log out of account';
    }
  }

  // ─── Bottom Nav ───
  String get feed {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Лента';
      case AppLanguage.kz: return 'Жаңалықтар';
      case AppLanguage.en: return 'Feed';
    }
  }

  String get schedule {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Расписание';
      case AppLanguage.kz: return 'Кесте';
      case AppLanguage.en: return 'Schedule';
    }
  }

  String get map {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Карта';
      case AppLanguage.kz: return 'Карта';
      case AppLanguage.en: return 'Map';
    }
  }

  String get profile {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Профиль';
      case AppLanguage.kz: return 'Профиль';
      case AppLanguage.en: return 'Profile';
    }
  }

  // ─── Profile Screen ───
  String get editProfile {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Редактировать профиль';
      case AppLanguage.kz: return 'Профильді өңдеу';
      case AppLanguage.en: return 'Edit profile';
    }
  }

  String get saveChanges {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Сохранить изменения';
      case AppLanguage.kz: return 'Өзгерістерді сақтау';
      case AppLanguage.en: return 'Save changes';
    }
  }

  String get academicInfo {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'АКАДЕМИЧЕСКАЯ ИНФОРМАЦИЯ';
      case AppLanguage.kz: return 'АКАДЕМИЯЛЫҚ АҚПАРАТ';
      case AppLanguage.en: return 'ACADEMIC INFORMATION';
    }
  }

  String get personalInfo {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'ЛИЧНАЯ ИНФОРМАЦИЯ';
      case AppLanguage.kz: return 'ЖЕКЕ АҚПАРАТ';
      case AppLanguage.en: return 'PERSONAL INFORMATION';
    }
  }

  String get university {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Учебное заведение';
      case AppLanguage.kz: return 'Оқу орны';
      case AppLanguage.en: return 'University';
    }
  }

  String get faculty {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Факультет';
      case AppLanguage.kz: return 'Факультет';
      case AppLanguage.en: return 'Faculty';
    }
  }

  String get specialty {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Специальность';
      case AppLanguage.kz: return 'Мамандық';
      case AppLanguage.en: return 'Specialty';
    }
  }

  String get phoneNumber {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Номер телефона';
      case AppLanguage.kz: return 'Телефон нөмірі';
      case AppLanguage.en: return 'Phone number';
    }
  }

  String get student {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Студент';
      case AppLanguage.kz: return 'Студент';
      case AppLanguage.en: return 'Student';
    }
  }

  String get administrator {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Администратор';
      case AppLanguage.kz: return 'Әкімші';
      case AppLanguage.en: return 'Administrator';
    }
  }

  String get status {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Статус';
      case AppLanguage.kz: return 'Мәртебе';
      case AppLanguage.en: return 'Status';
    }
  }

  String get active {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Активен';
      case AppLanguage.kz: return 'Белсенді';
      case AppLanguage.en: return 'Active';
    }
  }

  String get nextClass {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Следующее занятие';
      case AppLanguage.kz: return 'Келесі сабақ';
      case AppLanguage.en: return 'Next class';
    }
  }

  String get noClasses {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Нет занятий';
      case AppLanguage.kz: return 'Сабақтар жоқ';
      case AppLanguage.en: return 'No classes';
    }
  }

  String get noMoreClasses {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Занятий больше нет';
      case AppLanguage.kz: return 'Сабақтар аяқталды';
      case AppLanguage.en: return 'No more classes';
    }
  }

  String get loadingError {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Ошибка загрузки';
      case AppLanguage.kz: return 'Жүктеу қатесі';
      case AppLanguage.en: return 'Loading error';
    }
  }

  String get changeProfilePhoto {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Изменить фото профиля';
      case AppLanguage.kz: return 'Профиль суретін өзгерту';
      case AppLanguage.en: return 'Change profile photo';
    }
  }

  String get gallery {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Галерея';
      case AppLanguage.kz: return 'Галерея';
      case AppLanguage.en: return 'Gallery';
    }
  }

  String get camera {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Камера';
      case AppLanguage.kz: return 'Камера';
      case AppLanguage.en: return 'Camera';
    }
  }

  String get avatarUpdated {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Аватар успешно обновлён';
      case AppLanguage.kz: return 'Аватар сәтті жаңартылды';
      case AppLanguage.en: return 'Avatar updated successfully';
    }
  }

  String get profileSaved {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Профиль успешно сохранён';
      case AppLanguage.kz: return 'Профиль сәтті сақталды';
      case AppLanguage.en: return 'Profile saved successfully';
    }
  }

  // ─── Settings ───
  String get settings {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Настройки';
      case AppLanguage.kz: return 'Баптаулар';
      case AppLanguage.en: return 'Settings';
    }
  }

  String get language {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Язык';
      case AppLanguage.kz: return 'Тіл';
      case AppLanguage.en: return 'Language';
    }
  }

  String get notificationsAboutClasses {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Уведомления о занятиях';
      case AppLanguage.kz: return 'Сабақтар туралы хабарландырулар';
      case AppLanguage.en: return 'Class notifications';
    }
  }

  String get enableNotifications {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Включить уведомления';
      case AppLanguage.kz: return 'Хабарландыруларды қосу';
      case AppLanguage.en: return 'Enable notifications';
    }
  }

  String get reminderBeforeClass {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Напоминания перед началом пары';
      case AppLanguage.kz: return 'Сабақ басталар алдында еске салу';
      case AppLanguage.en: return 'Reminders before class';
    }
  }

  String get howLongBefore {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'За какое время уведомлять?';
      case AppLanguage.kz: return 'Қанша уақыт бұрын хабардар ету?';
      case AppLanguage.en: return 'How long before to notify?';
    }
  }

  String minutesBefore(int min) {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'За $min минут';
      case AppLanguage.kz: return '$min минут бұрын';
      case AppLanguage.en: return '$min minutes before';
    }
  }

  String hoursBefore(int hours) {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'За $hours час${hours > 1 ? 'а' : ''}';
      case AppLanguage.kz: return '$hours сағат бұрын';
      case AppLanguage.en: return '$hours hour${hours > 1 ? 's' : ''} before';
    }
  }

  String get quietHours {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Тихие часы (Do Not Disturb)';
      case AppLanguage.kz: return 'Тыныш сағаттар';
      case AppLanguage.en: return 'Quiet hours (Do Not Disturb)';
    }
  }

  String get doNotDisturbAtNight {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Не беспокоить ночью';
      case AppLanguage.kz: return 'Түнде мазаламау';
      case AppLanguage.en: return 'Do not disturb at night';
    }
  }

  String get startHour {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Начало (час)';
      case AppLanguage.kz: return 'Басталуы (сағат)';
      case AppLanguage.en: return 'Start (hour)';
    }
  }

  String get endHour {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Конец (час)';
      case AppLanguage.kz: return 'Аяқталуы (сағат)';
      case AppLanguage.en: return 'End (hour)';
    }
  }

  String get data {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Данные';
      case AppLanguage.kz: return 'Деректер';
      case AppLanguage.en: return 'Data';
    }
  }

  String get clearCache {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Очистить кэш';
      case AppLanguage.kz: return 'Кэшті тазалау';
      case AppLanguage.en: return 'Clear cache';
    }
  }

  String get clearCacheSubtitle {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Удалить сохраненные планы зданий и данные';
      case AppLanguage.kz: return 'Сақталған деректерді жою';
      case AppLanguage.en: return 'Delete saved floor plans and data';
    }
  }

  String get cacheCleared {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Кэш успешно очищен';
      case AppLanguage.kz: return 'Кэш сәтті тазаланды';
      case AppLanguage.en: return 'Cache cleared successfully';
    }
  }
  String get logoutConfirmTitle {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Выход';
      case AppLanguage.kz: return 'Шығу';
      case AppLanguage.en: return 'Log out';
    }
  }

  String get logoutConfirmBody {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Вы действительно хотите выйти из аккаунта?';
      case AppLanguage.kz: return 'Аккаунттан шығуды қалайсыз ба?';
      case AppLanguage.en: return 'Are you sure you want to log out?';
    }
  }

  String get cancel {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Отмена';
      case AppLanguage.kz: return 'Бас тарту';
      case AppLanguage.en: return 'Cancel';
    }
  }

  String get notSpecified {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Не указано';
      case AppLanguage.kz: return 'Көрсетілмеген';
      case AppLanguage.en: return 'Not specified';
    }
  }

  String courseLabel(String val) {
    switch (currentLanguage) {
      case AppLanguage.ru: return '$val курс';
      case AppLanguage.kz: return '$val курс';
      case AppLanguage.en: return 'Year $val';
    }
  }

  // ─── Password changed success ───
  String get passwordChanged {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Пароль успешно изменён';
      case AppLanguage.kz: return 'Құпия сөз сәтті өзгертілді';
      case AppLanguage.en: return 'Password changed successfully';
    }
  }

  String get passwordChangedSubtitle {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Теперь вы можете войти с новым паролем';
      case AppLanguage.kz: return 'Енді жаңа құпия сөзбен кіре аласыз';
      case AppLanguage.en: return 'You can now log in with your new password';
    }
  }

  // ─── Academic fields edit info ───
  String get academicFieldsNote {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Изменяется только администратором';
      case AppLanguage.kz: return 'Тек әкімші ғана өзгерте алады';
      case AppLanguage.en: return 'Can only be changed by administrator';
    }
  }

  // ─── Schedule Screen ───
  String get scheduleTitle {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Расписание';
      case AppLanguage.kz: return 'Кесте';
      case AppLanguage.en: return 'Schedule';
    }
  }

  String get mySchedule {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Мое Расписание';
      case AppLanguage.kz: return 'Менің кестем';
      case AppLanguage.en: return 'My Schedule';
    }
  }

  String get myGroup {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Моя группа';
      case AppLanguage.kz: return 'Менің тобым';
      case AppLanguage.en: return 'My group';
    }
  }

  String get teachers {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Преподаватели';
      case AppLanguage.kz: return 'Оқытушылар';
      case AppLanguage.en: return 'Teachers';
    }
  }

  String get teacher {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Преподаватель';
      case AppLanguage.kz: return 'Оқытушы';
      case AppLanguage.en: return 'Teacher';
    }
  }

  String get groupNotSpecified {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Группа не указана';
      case AppLanguage.kz: return 'Топ көрсетілмеген';
      case AppLanguage.en: return 'Group not specified';
    }
  }

  String get contactAdmin {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Обратитесь к администратору';
      case AppLanguage.kz: return 'Әкімшіге хабарласыңыз';
      case AppLanguage.en: return 'Contact the administrator';
    }
  }

  String get searchTeacherSchedule {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Поиск расписания преподавателя';
      case AppLanguage.kz: return 'Оқытушы кестесін іздеу';
      case AppLanguage.en: return 'Search teacher schedule';
    }
  }

  String get enterTeacherName {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Введите фамилию в поиск выше';
      case AppLanguage.kz: return 'Жоғарыдағы іздеуге тегіңізді енгізіңіз';
      case AppLanguage.en: return 'Enter surname in search above';
    }
  }

  String get teacherSurname {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Фамилия преподавателя';
      case AppLanguage.kz: return 'Оқытушының тегі';
      case AppLanguage.en: return 'Teacher surname';
    }
  }

  String get noClassesSchedule {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Нет занятий';
      case AppLanguage.kz: return 'Сабақтар жоқ';
      case AppLanguage.en: return 'No classes';
    }
  }

  String get retry {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Повторить';
      case AppLanguage.kz: return 'Қайталау';
      case AppLanguage.en: return 'Retry';
    }
  }

  String get classInProgress {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Идет пара';
      case AppLanguage.kz: return 'Сабақ жүріп жатыр';
      case AppLanguage.en: return 'Class in progress';
    }
  }

  String endsInMinutes(int min) {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Закончится через $min мин';
      case AppLanguage.kz: return '$min мин кейін аяқталады';
      case AppLanguage.en: return 'Ends in $min min';
    }
  }

  String get nextClassLabel {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Следующая пара';
      case AppLanguage.kz: return 'Келесі сабақ';
      case AppLanguage.en: return 'Next class';
    }
  }

  String startsInMinutes(int min) {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Начнется через $min мин';
      case AppLanguage.kz: return '$min мин кейін басталады';
      case AppLanguage.en: return 'Starts in $min min';
    }
  }

  String mapRoom(String code) {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Карта: $code';
      case AppLanguage.kz: return 'Карта: $code';
      case AppLanguage.en: return 'Map: $code';
    }
  }

  String get notAssigned {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Не указан';
      case AppLanguage.kz: return 'Көрсетілмеген';
      case AppLanguage.en: return 'Not assigned';
    }
  }

  // Day names
  List<String> get daysShort {
    switch (currentLanguage) {
      case AppLanguage.ru: return ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];
      case AppLanguage.kz: return ['ДС', 'СС', 'СР', 'БС', 'ЖМ', 'СН', 'ЖС'];
      case AppLanguage.en: return ['MO', 'TU', 'WE', 'TH', 'FR', 'SA', 'SU'];
    }
  }

  List<String> get daysFull {
    switch (currentLanguage) {
      case AppLanguage.ru: return ['Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'];
      case AppLanguage.kz: return ['Дүйсенбі', 'Сейсенбі', 'Сәрсенбі', 'Бейсенбі', 'Жұма', 'Сенбі', 'Жексенбі'];
      case AppLanguage.en: return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    }
  }

  // Class types
  String classType(String type) {
    switch (currentLanguage) {
      case AppLanguage.ru:
        return {'lecture': 'Лекция', 'practice': 'Практика', 'lab': 'Лаб. работа', 'seminar': 'Семинар'}[type] ?? type;
      case AppLanguage.kz:
        return {'lecture': 'Дәріс', 'practice': 'Практика', 'lab': 'Зертханалық', 'seminar': 'Семинар'}[type] ?? type;
      case AppLanguage.en:
        return {'lecture': 'Lecture', 'practice': 'Practice', 'lab': 'Lab', 'seminar': 'Seminar'}[type] ?? type;
    }
  }

  // ─── News Screen ───
  String get noNews {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Пока нет новостей';
      case AppLanguage.kz: return 'Әзірге жаңалықтар жоқ';
      case AppLanguage.en: return 'No news yet';
    }
  }

  String get newsWillAppear {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Новости появятся здесь, как только\nадминистратор их опубликует';
      case AppLanguage.kz: return 'Әкімші жариялағаннан кейін\nжаңалықтар осында пайда болады';
      case AppLanguage.en: return 'News will appear here once\nthe administrator publishes them';
    }
  }

  String get refresh {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Обновить';
      case AppLanguage.kz: return 'Жаңарту';
      case AppLanguage.en: return 'Refresh';
    }
  }

  String get failedToLoad {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Не удалось загрузить';
      case AppLanguage.kz: return 'Жүктеу мүмкін болмады';
      case AppLanguage.en: return 'Failed to load';
    }
  }

  String get checkConnection {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Проверьте подключение к интернету\nи попробуйте снова';
      case AppLanguage.kz: return 'Интернет қосылымын тексеріңіз\nжәне қайталап көріңіз';
      case AppLanguage.en: return 'Check your internet connection\nand try again';
    }
  }

  String get pinned {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Закреплено';
      case AppLanguage.kz: return 'Бекітілген';
      case AppLanguage.en: return 'Pinned';
    }
  }

  String get adminAuthor {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Администратор';
      case AppLanguage.kz: return 'Әкімші';
      case AppLanguage.en: return 'Administrator';
    }
  }

  // News categories
  String newsCategory(String cat) {
    switch (currentLanguage) {
      case AppLanguage.ru:
        return {'All': 'Все', 'Academic': 'Учеба', 'Announcements': 'Объявления', 'Events': 'События', 'Important': 'Важное', 'Urgent': 'Срочно'}[cat] ?? cat;
      case AppLanguage.kz:
        return {'All': 'Барлығы', 'Academic': 'Оқу', 'Announcements': 'Хабарландырулар', 'Events': 'Оқиғалар', 'Important': 'Маңызды', 'Urgent': 'Шұғыл'}[cat] ?? cat;
      case AppLanguage.en:
        return {'All': 'All', 'Academic': 'Academic', 'Announcements': 'Announcements', 'Events': 'Events', 'Important': 'Important', 'Urgent': 'Urgent'}[cat] ?? cat;
    }
  }

  // ─── Map Screen ───
  String get searchRoom {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Поиск аудитории...';
      case AppLanguage.kz: return 'Аудиторияны іздеу...';
      case AppLanguage.en: return 'Search room...';
    }
  }

  String get searchPlaceholder => searchRoom;

  String floor(int f) {
    switch (currentLanguage) {
      case AppLanguage.ru: return '$f этаж';
      case AppLanguage.kz: return '$f қабат';
      case AppLanguage.en: return 'Floor $f';
    }
  }

  String get roomTypeRoom {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Аудитория';
      case AppLanguage.kz: return 'Аудитория';
      case AppLanguage.en: return 'Room';
    }
  }

  String get roomTypeArea {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Помещение';
      case AppLanguage.kz: return 'Бөлме';
      case AppLanguage.en: return 'Area';
    }
  }

  String roomNotFound(String code) {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Аудитория "$code" не найдена на карте';
      case AppLanguage.kz: return '"$code" аудиториясы картадан табылмады';
      case AppLanguage.en: return 'Room "$code" not found on the map';
    }
  }

  String floorLabel(int floor, int count) {
    switch (currentLanguage) {
      case AppLanguage.ru: return '$floor этаж ($count)';
      case AppLanguage.kz: return '$floor қабат ($count)';
      case AppLanguage.en: return 'Floor $floor ($count)';
    }
  }

  String floorInfo(int floor, String type) {
    switch (currentLanguage) {
      case AppLanguage.ru: return '$floor этаж • ${type == 'area' ? 'Помещение' : 'Аудитория'}';
      case AppLanguage.kz: return '$floor қабат • ${type == 'area' ? 'Бөлме' : 'Аудитория'}';
      case AppLanguage.en: return 'Floor $floor • ${type == 'area' ? 'Area' : 'Room'}';
    }
  }

  String get zoomIn {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Приблизить';
      case AppLanguage.kz: return 'Жақындату';
      case AppLanguage.en: return 'Zoom in';
    }
  }

  String get zoomOut {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Отдалить';
      case AppLanguage.kz: return 'Алыстату';
      case AppLanguage.en: return 'Zoom out';
    }
  }

  String get resetZoom {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Сбросить';
      case AppLanguage.kz: return 'Қалпына келтіру';
      case AppLanguage.en: return 'Reset';
    }
  }

  // ─── Login Errors ───
  String get wrongCredentials {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Неверный email или пароль';
      case AppLanguage.kz: return 'Қате email немесе құпия сөз';
      case AppLanguage.en: return 'Wrong email or password';
    }
  }

  String get networkError {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Ошибка сети';
      case AppLanguage.kz: return 'Желі қатесі';
      case AppLanguage.en: return 'Network error';
    }
  }

  String get noConnection {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Нет соединения с сервером';
      case AppLanguage.kz: return 'Сервермен байланыс жоқ';
      case AppLanguage.en: return 'No connection to server';
    }
  }

  String get connectionTimeout {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Превышено время ожидания';
      case AppLanguage.kz: return 'Күту уақыты асып кетті';
      case AppLanguage.en: return 'Connection timed out';
    }
  }

  // ─── Biometric Auth ───
  String get biometricLogin {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Вход по биометрии';
      case AppLanguage.kz: return 'Биометрия арқылы кіру';
      case AppLanguage.en: return 'Biometric login';
    }
  }

  String get biometricSubtitle {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Используйте отпечаток пальца или Face ID';
      case AppLanguage.kz: return 'Саусақ ізі немесе Face ID пайдаланыңыз';
      case AppLanguage.en: return 'Use fingerprint or Face ID';
    }
  }

  String get biometricReason {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Подтвердите вход в приложение';
      case AppLanguage.kz: return 'Қолданбаға кіруді растаңыз';
      case AppLanguage.en: return 'Authenticate to log in';
    }
  }

  String get biometricNotAvailable {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Биометрия недоступна на устройстве';
      case AppLanguage.kz: return 'Құрылғыда биометрия қолжетімсіз';
      case AppLanguage.en: return 'Biometrics not available';
    }
  }

  String get enableBiometric {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Вход по биометрии';
      case AppLanguage.kz: return 'Биометрия бойынша кіру';
      case AppLanguage.en: return 'Biometric login';
    }
  }

  String get enableBiometricSubtitle {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Отпечаток пальца или Face ID';
      case AppLanguage.kz: return 'Саусақ ізі немесе Face ID';
      case AppLanguage.en: return 'Fingerprint or Face ID';
    }
  }

  // ─── Help & FAQ ───
  String get helpAndFaq {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Помощь и FAQ';
      case AppLanguage.kz: return 'Көмек және FAQ';
      case AppLanguage.en: return 'Help & FAQ';
    }
  }

  String get helpSubtitle {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Часто задаваемые вопросы';
      case AppLanguage.kz: return 'Жиі қойылатын сұрақтар';
      case AppLanguage.en: return 'Frequently asked questions';
    }
  }

  // FAQ items
  List<Map<String, String>> get faqItems {
    switch (currentLanguage) {
      case AppLanguage.ru: return [
        {'q': 'Как посмотреть расписание?', 'a': 'Перейдите на вкладку "Расписание" в нижней панели навигации. Расписание отображается по дням недели.'},
        {'q': 'Как найти аудиторию на карте?', 'a': 'Перейдите на вкладку "Карта" и введите номер аудитории в поиске. Также можно нажать на номер аудитории в расписании.'},
        {'q': 'Как изменить язык приложения?', 'a': 'Откройте "Профиль" → "Настройки" и выберите нужный язык в разделе языка.'},
        {'q': 'Как выйти из аккаунта?', 'a': 'Откройте "Профиль" → "Настройки" и нажмите "Выйти из аккаунта" внизу страницы.'},
        {'q': 'Я не могу войти в приложение', 'a': 'Убедитесь, что ваш аккаунт одобрен администратором. Если проблема сохраняется, обратитесь к администратору.'},
        {'q': 'Как включить биометрию?', 'a': 'В настройках включите "Вход по биометрии". Функция доступна только если ваше устройство поддерживает отпечаток пальца или Face ID.'},
      ];
      case AppLanguage.kz: return [
        {'q': 'Кестені қалай көруге болады?', 'a': 'Төменгі навигация панеліндегі "Кесте" қойындысына өтіңіз. Кесте апта күндері бойынша көрсетіледі.'},
        {'q': 'Аудиторияны картадан қалай табуға болады?', 'a': '"Карта" қойындысына өтіп, іздеуге аудитория нөмірін енгізіңіз. Сондай-ақ кестедегі аудитория нөмірін басуға болады.'},
        {'q': 'Тілді қалай өзгертуге болады?', 'a': '"Профиль" → "Баптаулар" бөлімін ашып, тіл бөлімінде қажетті тілді таңдаңыз.'},
        {'q': 'Аккаунттан қалай шығуға болады?', 'a': '"Профиль" → "Баптаулар" бөлімін ашып, беттің төменгі жағындағы "Аккаунттан шығу" батырмасын басыңыз.'},
        {'q': 'Қолданбаға кіре алмаймын', 'a': 'Аккаунтыңыз әкімші тарапынан мақұлданғанына көз жеткізіңіз. Мәселе шешілмесе, әкімшіге хабарласыңыз.'},
        {'q': 'Биометрияны қалай қосуға болады?', 'a': 'Баптауларда "Биометрия бойынша кіру" функциясын қосыңыз. Бұл функция құрылғыңыз саусақ ізі немесе Face ID қолдаса ғана қолжетімді.'},
      ];
      case AppLanguage.en: return [
        {'q': 'How to view the schedule?', 'a': 'Go to the "Schedule" tab in the bottom navigation bar. The schedule is displayed by days of the week.'},
        {'q': 'How to find a room on the map?', 'a': 'Go to the "Map" tab and enter the room number in search. You can also tap a room number in the schedule.'},
        {'q': 'How to change the app language?', 'a': 'Open "Profile" → "Settings" and select the desired language in the language section.'},
        {'q': 'How to log out?', 'a': 'Open "Profile" → "Settings" and tap "Log out of account" at the bottom of the page.'},
        {'q': 'I can\'t log in to the app', 'a': 'Make sure your account has been approved by the administrator. If the problem persists, contact the administrator.'},
        {'q': 'How to enable biometrics?', 'a': 'In settings, enable "Biometric login". This feature is only available if your device supports fingerprint or Face ID.'},
      ];
    }
  }

  // ─── Privacy Policy ───
  String get privacyPolicy {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Политика конфиденциальности';
      case AppLanguage.kz: return 'Құпиялылық саясаты';
      case AppLanguage.en: return 'Privacy Policy';
    }
  }

  String get privacyPolicyContent {
    switch (currentLanguage) {
      case AppLanguage.ru: return '''
⚠️ ДЕМО-ВЕРСИЯ

Данное приложение «Timely» является демонстрационной (демо) версией и не является официальным программным продуктом учебного заведения. Приложение разработано в учебных и демонстрационных целях.

1. СБОР ДАННЫХ
Приложение собирает следующие данные:
• ФИО, email и номер телефона при регистрации
• Данные о группе и курсе обучения
• Фотографию профиля (по желанию)

2. ИСПОЛЬЗОВАНИЕ ДАННЫХ
Собранные данные используются исключительно для:
• Авторизации и идентификации пользователя
• Отображения персонализированного расписания
• Функционирования приложения

3. ХРАНЕНИЕ ДАННЫХ
Данные хранятся на сервере разработчика и могут быть удалены по запросу пользователя или при прекращении работы демо-версии.

4. БЕЗОПАСНОСТЬ
Мы применяем базовые меры безопасности для защиты ваших данных, однако данная версия не прошла полный аудит безопасности.

5. ОТКАЗ ОТ ОТВЕТСТВЕННОСТИ
Разработчики не несут ответственности за потерю данных или сбои в работе приложения. Используйте приложение на свой страх и риск.

6. КОНТАКТЫ
По вопросам конфиденциальности обращайтесь к администратору приложения.

Последнее обновление: Март 2026
''';
      case AppLanguage.kz: return '''
⚠️ ДЕМО-НҰСҚА

Бұл «Timely» қолданбасы демонстрациялық (демо) нұсқа болып табылады және оқу орнының ресми бағдарламалық өнімі емес. Қолданба оқу және демонстрация мақсатында әзірленген.

1. ДЕРЕКТЕРДІ ЖУЫ
Қолданба келесі деректерді жинайды:
• Тіркелу кезіндегі аты-жөні, email және телефон нөмірі
• Топ және оқу курсы туралы мәліметтер
• Профиль фотосуреті (қалау бойынша)

2. ДЕРЕКТЕРДІ ПАЙДАЛАНУ
Жиналған деректер тек мыналар үшін пайдаланылады:
• Пайдаланушыны авторизациялау және сәйкестендіру
• Жекелендірілген кестені көрсету
• Қолданбаның жұмыс істеуі

3. ДЕРЕКТЕРДІ САҚТАУ
Деректер әзірлеуші серверінде сақталады және пайдаланушының сұрауы бойынша немесе демо-нұсқаның жұмысы тоқтатылған кезде жойылуы мүмкін.

4. ҚАУІПСІЗДІК
Деректеріңізді қорғау үшін базалық қауіпсіздік шараларын қолданамыз, алайда бұл нұсқа толық қауіпсіздік аудитінен өткен жоқ.

5. ЖАУАПКЕРШІЛІКТЕН БАС ТАРТУ
Әзірлеушілер деректердің жоғалуына немесе қолданба жұмысындағы ақауларға жауап бермейді.

6. БАЙЛАНЫС
Құпиялылық мәселелері бойынша қолданба әкімшісіне хабарласыңыз.

Соңғы жаңарту: Наурыз 2026
''';
      case AppLanguage.en: return '''
⚠️ DEMO VERSION

This "Timely" application is a demonstration (demo) version and is not an official software product of any educational institution. The application was developed for educational and demonstration purposes.

1. DATA COLLECTION
The application collects the following data:
• Full name, email, and phone number during registration
• Group and course information
• Profile photo (optional)

2. DATA USAGE
Collected data is used exclusively for:
• User authorization and identification
• Displaying personalized schedule
• Application functionality

3. DATA STORAGE
Data is stored on the developer's server and may be deleted upon user request or upon discontinuation of the demo version.

4. SECURITY
We apply basic security measures to protect your data, however this version has not undergone a full security audit.

5. DISCLAIMER
Developers are not responsible for data loss or application malfunctions. Use the application at your own risk.

6. CONTACT
For privacy concerns, please contact the application administrator.

Last updated: March 2026
''';
    }
  }

  // ─── Security section ───
  String get security {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Безопасность';
      case AppLanguage.kz: return 'Қауіпсіздік';
      case AppLanguage.en: return 'Security';
    }
  }

  // ─── About / Info ───
  String get about {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'О приложении';
      case AppLanguage.kz: return 'Қолданба туралы';
      case AppLanguage.en: return 'About';
    }
  }

  String get appVersion {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Версия';
      case AppLanguage.kz: return 'Нұсқа';
      case AppLanguage.en: return 'Version';
    }
  }

  String get demoVersion {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Демо-версия';
      case AppLanguage.kz: return 'Демо-нұсқа';
      case AppLanguage.en: return 'Demo version';
    }
  }

  String get errorOccurred {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Произошла ошибка';
      case AppLanguage.kz: return 'Қате орын алды';
      case AppLanguage.en: return 'Error occurred';
    }
  }

  String get updateFailed {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Ошибка обновления';
      case AppLanguage.kz: return 'Жаңарту қатесі';
      case AppLanguage.en: return 'Update failed';
    }
  }

  String get support {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Поддержка и инфо';
      case AppLanguage.kz: return 'Қолдау және ақпарат';
      case AppLanguage.en: return 'Support & info';
    }
  }

  String get useBiometrics {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Вход по биометрии';
      case AppLanguage.kz: return 'Биометрия арқылы кіру';
      case AppLanguage.en: return 'Biometric login';
    }
  }

  String get weak {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Слабый';
      case AppLanguage.kz: return 'Әлсіз';
      case AppLanguage.en: return 'Weak';
    }
  }

  String get medium {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Средний';
      case AppLanguage.kz: return 'Орташа';
      case AppLanguage.en: return 'Medium';
    }
  }

  String get strong {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Сильный';
      case AppLanguage.kz: return 'Күшті';
      case AppLanguage.en: return 'Strong';
    }
  }

  // ─── Notifications ───
  String lessonIn(String time) {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Занятие через $time';
      case AppLanguage.kz: return 'Сабақ $time кейін';
      case AppLanguage.en: return 'Lesson in $time';
    }
  }

  String get hourShort {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'ч.';
      case AppLanguage.kz: return 'сағ.';
      case AppLanguage.en: return 'h.';
    }
  }

  String get minuteShort {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'мин.';
      case AppLanguage.kz: return 'мин.';
      case AppLanguage.en: return 'min.';
    }
  }

  String lessonStarting(String name) {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Начинается пара: $name';
      case AppLanguage.kz: return 'Сабақ басталуда: $name';
      case AppLanguage.en: return 'Lesson starting: $name';
    }
  }

  String roomAtFloor(String room, int floor) {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Кабинет $room (этаж $floor)';
      case AppLanguage.kz: return '$room кабинеті ($floor қабат)';
      case AppLanguage.en: return 'Room $room (floor $floor)';
    }
  }

  String get timelyNews {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Новости Timely';
      case AppLanguage.kz: return 'Timely жаңалықтары';
      case AppLanguage.en: return 'Timely News';
    }
  }

  String get newPublications {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Уведомления о новых публикациях';
      case AppLanguage.kz: return 'Жаңа жарияланымдар туралы хабарламалар';
      case AppLanguage.en: return 'Notifications about new publications';
    }
  }

  String get lessonNotifications {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Уведомления о парах';
      case AppLanguage.kz: return 'Сабақтар туралы хабарламалар';
      case AppLanguage.en: return 'Lesson Notifications';
    }
  }

  String get lessonReminders {
    switch (currentLanguage) {
      case AppLanguage.ru: return 'Напоминания о начале занятий';
      case AppLanguage.kz: return 'Сабақтардың басталуы туралы ескертулер';
      case AppLanguage.en: return 'Reminders about lesson start';
    }
  }
}
