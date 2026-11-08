// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Muyu';

  @override
  String get splashLogo => 'MUYU';

  @override
  String get splashTagline => 'Conectando el campo';

  @override
  String get languageCode => 'ES';

  @override
  String get languageToggleLabel => 'Cambiar idioma a inglés';

  @override
  String get back => 'Volver';

  @override
  String get loginTitle => 'Iniciar sesión';

  @override
  String get loginHero => 'Personaje de Muyu con una credencial';

  @override
  String get loginEmail => 'Correo';

  @override
  String get loginPassword => 'Contraseña';

  @override
  String get loginShowPassword => 'Mostrar contraseña';

  @override
  String get loginHidePassword => 'Ocultar contraseña';

  @override
  String get loginButton => 'Iniciar sesión';

  @override
  String get loginNoAccount => '¿No tienes una cuenta?';

  @override
  String get loginRegister => 'Registrarse';

  @override
  String get loginInvalid => 'Correo o contraseña no válidos';

  @override
  String get loginNetworkError =>
      'No pudimos conectar con Muyu. Revisa tu conexión e inténtalo de nuevo.';

  @override
  String get loginLoading => 'Iniciando sesión';

  @override
  String get registerTitle => 'Crear cuenta';

  @override
  String get registerName => 'Nombre';

  @override
  String get registerPhone => 'Número de teléfono';

  @override
  String get registerDni => 'DNI';

  @override
  String get registerBirthdate => 'Fecha de nacimiento';

  @override
  String get registerBirthdateHint => 'Selecciona una fecha';

  @override
  String get registerConfirmPassword => 'Confirmar contraseña';

  @override
  String get registerButton => 'Registrarse';

  @override
  String get registerHaveAccount => '¿Ya tienes una cuenta?';

  @override
  String get registerAcceptTerms => 'He leído y acepto los términos y condiciones';

  @override
  String get registerNameInvalid => 'Ingresa un nombre válido de 2 a 60 letras.';

  @override
  String get registerEmailInvalid => 'Ingresa un correo electrónico válido.';

  @override
  String get registerPhoneInvalid => 'Ingresa un número válido.';

  @override
  String get registerDniInvalid => 'Ingresa un DNI válido de 8 dígitos.';

  @override
  String get registerBirthdateRequired => 'Selecciona tu fecha de nacimiento.';

  @override
  String get registerBirthdateInvalid => 'Debes tener entre 18 y 90 años.';

  @override
  String get registerPasswordInvalid =>
      'La contraseña debe tener 8+ caracteres, mayúscula, minúscula, número y carácter especial.';

  @override
  String get registerPasswordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get registerTermsRequired => 'Acepta los términos y condiciones para continuar.';

  @override
  String get registerRuleLength => 'Mínimo 8 caracteres';

  @override
  String get registerRuleUppercase => 'Una letra mayúscula';

  @override
  String get registerRuleLowercase => 'Una letra minúscula';

  @override
  String get registerRuleNumber => 'Un número';

  @override
  String get registerRuleSpecial => 'Un carácter especial, como * ! @ #';

  @override
  String get registerRuleNoSpaces => 'Sin espacios';

  @override
  String get registerRuleMet => 'Cumplida';

  @override
  String get registerRuleMissing => 'Pendiente';

  @override
  String get registerError => 'No se pudo crear la cuenta';

  @override
  String get registerSuccess => 'Cuenta creada. Inicia sesión para continuar.';

  @override
  String get roleQuestion => '¿Cómo usarás MUYU?';

  @override
  String get roleSubtitle => 'Elige tu rol para personalizar tu experiencia.';

  @override
  String get roleFarmerTitle => 'Soy agricultor';

  @override
  String get roleFarmerBody =>
      'Publica tus parcelas, registra hitos de cultivo y recibe pagos seguros';

  @override
  String get roleFarmerImage => 'Agricultor';

  @override
  String get roleMerchantTitle => 'Soy comerciante';

  @override
  String get roleMerchantBody =>
      'Explora el catálogo de parcelas, financia cosechas y aprueba hitos de forma segura';

  @override
  String get roleMerchantImage => 'Comerciante';

  @override
  String get roleNext => 'Siguiente';

  @override
  String homeGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String get farmerHomeTitle => 'Mis parcelas';

  @override
  String get farmerHomeEmpty => 'Aún no has publicado parcelas.';

  @override
  String get merchantHomeTitle => 'Catálogo de parcelas';

  @override
  String get merchantHomeEmpty => 'Todavía no hay parcelas para financiar.';

  @override
  String get homeChangeRole => 'Cambiar rol';

  @override
  String get homeLogout => 'Cerrar sesión';
}

/// The translations for Spanish Castilian, as used in Latin America and the Caribbean (`es_419`).
class AppLocalizationsEs419 extends AppLocalizationsEs {
  AppLocalizationsEs419() : super('es_419');
}
