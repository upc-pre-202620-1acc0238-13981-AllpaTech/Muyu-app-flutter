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

  @override
  String get homeMoreOptions => 'Más opciones';

  @override
  String get navCatalog => 'Catálogo';

  @override
  String get navMyPlots => 'Mis parcelas';

  @override
  String get navAlerts => 'Alertas';

  @override
  String get navPayments => 'Pagos';

  @override
  String get navPayment => 'Pago';

  @override
  String get navProfile => 'Perfil';

  @override
  String get merchantTabSoon => 'Esta sección llega a continuación.';

  @override
  String get merchantWelcome => 'Bienvenido,';

  @override
  String get merchantSearch => 'Buscar parcelas o GPS…';

  @override
  String get merchantSearchIcon => 'Buscar';

  @override
  String get merchantFilterAll => 'Todos';

  @override
  String get merchantFilterNear => 'Cerca de mí';

  @override
  String get merchantFilterRecommended => 'Recomendados';

  @override
  String get merchantVerified => 'Agricultor verificado';

  @override
  String get merchantMilestones => '94% de hitos aprobados';

  @override
  String get merchantNoPlots => 'Aún no hay parcelas disponibles';

  @override
  String get farmerCountryPeru => 'PERÚ';

  @override
  String get farmerFlagPeru => 'Bandera de Perú';

  @override
  String get roleMerchantShort => 'Comerciante';

  @override
  String get profileVerified => 'Verificado';

  @override
  String get profileContactDetails => 'DATOS DE CONTACTO';

  @override
  String get profileEditContact => 'Editar contacto';

  @override
  String get profileChangePhoto => 'Cambiar foto';

  @override
  String get profileSaveContact => 'Guardar';

  @override
  String get profileCancel => 'Cancelar';

  @override
  String get profileCompanyNameLabel => 'Razón social';

  @override
  String get profileActivityLabel => 'Actividad';

  @override
  String get profileRucLabel => 'RUC';

  @override
  String get profileLocationLabel => 'Ciudad';

  @override
  String get profileEmailLabel => 'Correo';

  @override
  String get profileNotificationPrefs => 'PREFERENCIAS DE NOTIFICACIÓN';

  @override
  String get profileWeatherAlertsQuestion => '¿Cómo te enviamos las alertas climáticas?';

  @override
  String get profileChannelCall => 'Llamada';

  @override
  String get profileChannelPush => 'Push';

  @override
  String get profileChannelWhatsapp => 'WhatsApp';

  @override
  String get profilePayment => 'PAGO';

  @override
  String get profileSavedMethods => 'Métodos de pago guardados';

  @override
  String get profileSecurityHelp => 'SEGURIDAD Y AYUDA';

  @override
  String get profileChangePassword => 'Cambiar contraseña';

  @override
  String get profileLegal => 'LEGAL';

  @override
  String get profileTerms => 'Términos y condiciones';

  @override
  String get profilePrivacy => 'Política de privacidad';

  @override
  String get profileLogout => 'Cerrar sesión';

  @override
  String get profileNewPlotAlerts => 'Alertas de parcelas nuevas';

  @override
  String get profileComingSoon => 'Esta sección llega a continuación.';

  @override
  String get paymentNoCard => 'Sin tarjeta registrada';

  @override
  String get profileRegisterCard => 'Registrar tarjeta';

  @override
  String get profileChangeCard => 'Cambiar tarjeta';

  @override
  String get profileNoWallet => 'Sin Yape ni Plin vinculado';

  @override
  String get profileChangeWallet => 'Cambiar';

  @override
  String get bankAccountYape => 'Yape';

  @override
  String get bankAccountPlin => 'Plin';

  @override
  String get bankAccountVisaLogo => 'Logo de Visa';

  @override
  String get addCardTitle => 'Agregar tarjeta';

  @override
  String get addCardDataTitle => 'Datos de la tarjeta';

  @override
  String get addCardNumber => 'Número de tarjeta';

  @override
  String get addCardNumberHint => '0000  0000  0000  0000';

  @override
  String get addCardNumberError => 'Ingresa un número Visa o Mastercard válido';

  @override
  String get addCardHolder => 'Nombre del titular';

  @override
  String get addCardHolderHint => 'Como aparece en la tarjeta';

  @override
  String get addCardExpiration => 'Fecha de vencimiento';

  @override
  String get addCardExpirationHint => 'MM/AA';

  @override
  String get addCardCvv => 'CVV';

  @override
  String get addCardType => 'Tipo de tarjeta';

  @override
  String get addCardDebit => 'Débito';

  @override
  String get addCardCredit => 'Crédito';

  @override
  String get addCardPrimary => 'Guardar como tarjeta principal';

  @override
  String get addCardSecurity => 'Tus datos están protegidos y se almacenan de forma segura.';

  @override
  String get addCardSave => 'Guardar tarjeta';

  @override
  String get addCardUnknownBrand => 'Marca de tarjeta no reconocida';

  @override
  String get yapeEditTitle => 'Editar Yape';

  @override
  String get yapeLinked => 'Vinculado';

  @override
  String get yapeNotLinked => 'No vinculado';

  @override
  String get yapeNoPhone => 'Sin número registrado';

  @override
  String get yapeAccountData => 'Datos de la cuenta';

  @override
  String get yapePhoneLabel => 'Número de celular';

  @override
  String get yapePhoneError => 'Ingresa un número celular válido de 9 dígitos';

  @override
  String get yapeVerifyPhone => 'Verificar número';

  @override
  String get yapePhoneVerified => 'Número verificado';

  @override
  String get yapeHolderLabel => 'Titular';

  @override
  String get yapeSaveChanges => 'Guardar cambios';

  @override
  String get yapeUnlink => 'Desvincular Yape';

  @override
  String get plinEditTitle => 'Editar Plin';

  @override
  String get plinUnlink => 'Desvincular Plin';

  @override
  String get merchantWalletPaymentInfo =>
      'Muyu cobrará el financiamiento a este número. Confirmarás el pago en tu app.';

  @override
  String get passwordCurrent => 'Contraseña actual';

  @override
  String get passwordNewTitle => 'Nueva contraseña';

  @override
  String get passwordRulesTitle => 'Requisitos sugeridos';

  @override
  String get passwordRuleLength => '8 o más caracteres';

  @override
  String get passwordRuleNumber => 'Al menos un número';

  @override
  String get passwordRuleUppercase => 'Al menos una letra mayúscula';

  @override
  String get passwordConfirmationHint =>
      'La confirmación debe coincidir exactamente con la nueva contraseña.';

  @override
  String get passwordMismatch => 'Las contraseñas no coinciden.';

  @override
  String get passwordHeroDescription => 'Personaje Muyu junto a un formulario de contraseña';

  @override
  String get passwordBackProfile => 'Volver al perfil';

  @override
  String get passwordFlowCompleteTitle => 'Todo listo para continuar';

  @override
  String get passwordFlowCompleteBody =>
      'Has completado la vista previa del flujo de contraseña. Tu contraseña actual no ha cambiado.';

  @override
  String get passwordChangeFailed => 'No se pudo cambiar la contraseña. Inténtalo de nuevo.';

  @override
  String get legalUpdated => 'Última actualización: 10 de octubre de 2026';

  @override
  String get legalUnderstood => 'Entendido';

  @override
  String get navHome => 'Inicio';

  @override
  String get navPlot => 'Parcela';

  @override
  String get navSync => 'Sincronizar';

  @override
  String get roleFarmerShort => 'Agricultor';

  @override
  String get farmerStatPlots => 'N.º de\nparcelas';

  @override
  String get farmerStatMilestones => 'Hitos\ncompletados';

  @override
  String get farmerStatCrop => 'Cultivo\nactivo';

  @override
  String get profilePhoneLabel => 'Teléfono';

  @override
  String get profileSync => 'SINCRONIZACIÓN';

  @override
  String get profileSyncWifi => 'Sincronizar evidencias solo por Wi-Fi';

  @override
  String get actionYes => 'Sí';

  @override
  String get actionNo => 'No';

  @override
  String get profileBankAccount => 'Cuenta bancaria';

  @override
  String get profileBankAccountBody => 'Configura dónde recibir tus desembolsos';

  @override
  String get profileChangePin => 'Cambiar PIN';

  @override
  String get profileCallSupport => 'Llamar a soporte técnico';

  @override
  String get profileSupportPhone => '967990437';

  @override
  String get profileReportIssue => 'Reportar incidencia';

  @override
  String get profileRateContract => 'Calificar un contrato completado';

  @override
  String get yapePrimary => 'Usar Yape como billetera predeterminada';

  @override
  String get plinPrimary => 'Usar Plin como billetera predeterminada';

  @override
  String get yapeDisbursementInfo => 'Los desembolsos se enviarán al número vinculado.';

  @override
  String get plinNotLinked => 'No vinculado';

  @override
  String get bankAccountTitle => 'Cuenta bancaria';

  @override
  String get bankAccountBack => 'Volver al perfil';

  @override
  String get bankAccountDebitLabel => 'DÉBITO';

  @override
  String get bankAccountCreditLabel => 'CRÉDITO';

  @override
  String bankAccountExpirationValue(String date) {
    return 'Vence $date';
  }

  @override
  String get bankAccountCvvMasked => 'CVV •••';

  @override
  String bankAccountBalance(String amount) {
    return 'Saldo $amount';
  }

  @override
  String get bankAccountAddCard => 'Agregar nueva tarjeta';

  @override
  String get bankAccountReplaceCard => 'Cambiar tarjeta';

  @override
  String get bankAccountDetails => 'Datos de cuenta';

  @override
  String get bankAccountDigitalWallets => 'Billeteras digitales';

  @override
  String get bankAccountNoCardTitle => 'Sin tarjeta registrada';

  @override
  String get bankAccountNoCardBody =>
      'Agrega una tarjeta de débito o crédito para recibir tus desembolsos.';

  @override
  String get bankAccountNoDetails => 'Registra una tarjeta para ver dónde llegan tus pagos.';

  @override
  String get bankAccountHolderLabel => 'Titular';

  @override
  String get bankAccountCardLabel => 'Tarjeta';

  @override
  String bankAccountYapeLinkedValue(String phone) {
    return 'Vinculado a $phone';
  }

  @override
  String bankAccountYapeLinkedDefaultValue(String phone) {
    return 'Vinculado a $phone · Cuenta predeterminada';
  }

  @override
  String get bankAccountWalletLimitNote =>
      'Yape y Plin mueven hasta S/ 500 por transferencia. Los desembolsos mayores se envían a la cuenta de tu tarjeta.';

  @override
  String get changePinTitle => 'Nuevo PIN de seguridad';

  @override
  String get changePinConfirmTitle => 'Confirmar PIN';

  @override
  String get changePinHeading => 'Ingresa tu nuevo PIN de 4 cifras';

  @override
  String get changePinConfirmHeading => 'Ingresa el mismo PIN otra vez';

  @override
  String get changePinContinue => 'Continuar';

  @override
  String get changePinConfirm => 'Confirmar PIN';

  @override
  String get changePinEdit => 'Editar PIN';

  @override
  String get changePinCancel => 'Cancelar';

  @override
  String get changePinMismatch => 'Los PIN no coinciden. Inténtalo nuevamente.';

  @override
  String changePinDigitLabel(int index) {
    return 'Cifra $index de 4 del PIN';
  }

  @override
  String get changePinDemoNotice => 'Vista previa del flujo. Tu PIN actual no se modificará.';

  @override
  String get changePinCompleteTitle => 'Vista previa completada';

  @override
  String get changePinCompleteBody =>
      'Has completado la vista previa del cambio de PIN. Tu PIN actual no ha cambiado.';

  @override
  String get reportTitle => 'Reportar incidencia';

  @override
  String get ratingNoContracts => 'Aún no tienes contratos finalizados para calificar.';

  @override
  String get reportUnavailable =>
      'Todava no se pueden enviar reportes desde la app. Llama a soporte tcnico y te ayudaremos.';

  @override
  String get reportDescriptionLabel => 'Descripción';

  @override
  String get ratingTitle => 'Calificar al comprador';

  @override
  String get ratingSection => 'Calificación';

  @override
  String ratingContractEnded(String date) {
    return 'Contrato finalizado · $date';
  }

  @override
  String ratingBuyer(String name) {
    return 'Comprador: $name';
  }

  @override
  String get ratingQuestion => '¿Cómo calificarías la experiencia?';

  @override
  String ratingSelected(int score) {
    return 'Tu calificación: $score de 5';
  }

  @override
  String get ratingCommentTitle => 'Comentario (opcional)';

  @override
  String get ratingCommentHint => 'Escribe un comentario sobre tu experiencia...';

  @override
  String get ratingSubmit => 'Enviar calificación';

  @override
  String ratingStarDescription(int score) {
    return '$score de 5 estrellas';
  }

  @override
  String get ratingPreviewNotice => 'Solo demostración. Esta calificación no se envía al servidor.';

  @override
  String get ratingSubmittedTitle => 'Calificación enviada';

  @override
  String ratingLaterStage(String date) {
    return 'Etapa final · $date · Ciclo terminado';
  }

  @override
  String get ratingThanks => 'Gracias por tu calificación';

  @override
  String ratingThanksBody(String name) {
    return 'Tu calificación de $name fue enviada.';
  }

  @override
  String ratingSubmittedValue(int score) {
    return 'Calificación enviada: $score de 5';
  }

  @override
  String ratingSubmittedBy(String farmer, String buyer, String company) {
    return 'Enviado por $farmer a $buyer de $company.';
  }

  @override
  String get ratingNoComment => 'Sin comentarios adicionales.';

  @override
  String get ratingBackProfile => 'Volver al perfil';

  @override
  String profileRolePlace(String role, String place) {
    return '$role · $place';
  }
}

/// The translations for Spanish Castilian, as used in Latin America and the Caribbean (`es_419`).
class AppLocalizationsEs419 extends AppLocalizationsEs {
  AppLocalizationsEs419() : super('es_419');
}
