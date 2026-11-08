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
  String get registerEmailInvalid => 'Ingresa un correo de Gmail válido.';

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
  String get plotsPublish => 'Publicar';

  @override
  String get plotsSearchHint => 'Buscar parcelas';

  @override
  String get plotsFilterAll => 'Todas';

  @override
  String get plotsFilterFunded => 'Financiadas';

  @override
  String get plotsFilterAvailable => 'Disponibles';

  @override
  String get plotsNoMatch => 'Ninguna parcela coincide con tu búsqueda o filtro.';

  @override
  String get plotsLoadError => 'No se pudieron cargar las parcelas. Inténtalo de nuevo.';

  @override
  String get plotsRetry => 'Reintentar';

  @override
  String plotHarvest(String date) {
    return 'Cosecha: $date';
  }

  @override
  String get publishTitle => 'Publicar';

  @override
  String publishStep(int current, int total) {
    return 'PASO $current DE $total';
  }

  @override
  String get publishStepInfo => 'INFORMACIÓN DE LA PARCELA';

  @override
  String get publishStepLocation => 'UBICACIÓN DE LA PARCELA';

  @override
  String get publishStepFinancing => 'FINANCIAMIENTO';

  @override
  String get publishPlotName => 'Nombre de la parcela';

  @override
  String get publishCrop => 'Tipo de cultivo';

  @override
  String get publishArea => 'Área (hectáreas)';

  @override
  String get publishHarvest => 'Cosecha estimada';

  @override
  String get publishHarvestHint => 'Selecciona una fecha';

  @override
  String get publishNextLocation => 'Siguiente: ubicación';

  @override
  String get publishRegion => 'Región';

  @override
  String get publishProvince => 'Provincia';

  @override
  String get publishDistrict => 'Distrito';

  @override
  String get publishAddress => 'Dirección o referencia';

  @override
  String get publishNextFinancing => 'Siguiente: financiamiento';

  @override
  String get publishTotal => 'Monto total del financiamiento (S/)';

  @override
  String get publishCycle => 'Duración del ciclo';

  @override
  String publishCycleMonths(int months) {
    return '$months meses';
  }

  @override
  String get publishMilestones => 'Hitos de pago: 4';

  @override
  String get publishPlan => 'Plan de desembolsos';

  @override
  String get publishPlanPlanting => 'Siembra';

  @override
  String get publishPlanIrrigation => 'Riego';

  @override
  String get publishPlanFertilization => 'Fertilización';

  @override
  String get publishPlanHarvest => 'Cosecha';

  @override
  String get publishFundsHeld =>
      'Los fondos permanecerán en custodia y se liberarán después de aprobar cada hito.';

  @override
  String get publishAcceptCustody => 'He leído y acepto el acuerdo de custodia (escrow)';

  @override
  String get publishConfirm => 'Publicar parcela';

  @override
  String get publishSuccess => '¡Tu parcela está publicada!';

  @override
  String get publishRequired => 'Completa este campo.';

  @override
  String get publishNumberInvalid => 'Ingresa un monto mayor que cero.';

  @override
  String get publishRejected => 'No pudimos publicar la parcela. Inténtalo de nuevo.';

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
