import 'package:flutter/widgets.dart';

class LegalSection {
  const LegalSection(this.title, this.body);

  final String title;
  final String body;
}

/// Terms and privacy copy from the Kotlin app, selected by locale.
abstract final class LegalCopy {
  static List<LegalSection> terms(Locale locale) =>
      locale.languageCode == 'es' ? _termsEs : _termsEn;

  static List<LegalSection> privacy(Locale locale) =>
      locale.languageCode == 'es' ? _privacyEs : _privacyEn;

  static const _termsEn = [
    LegalSection(
      '1. Acceptance of the service',
      'When you create an account and use Muyu, you confirm that you have read and accepted these terms. Muyu helps coordinate farmers and merchants, plot registration, field evidence, milestones, alerts and financing agreements.',
    ),
    LegalSection(
      '2. Responsible account use',
      'You must provide truthful information, protect your credentials and use the platform lawfully. Impersonation, manipulating evidence, recording false information or using Muyu for fraud is not allowed.',
    ),
    LegalSection(
      '3. Evidence and location',
      'Photographs, date, time, GPS location, notes and technical information recorded as evidence must match the work performed. You authorize their storage and viewing by the parties linked to the agreement to validate milestone completion.',
    ),
    LegalSection(
      '4. Plots, agreements and payments',
      'Publishing a plot does not guarantee financing. Funds remain in custody and are released only according to the agreement and milestone approval. Muyu does not replace legal contracts, financial advice or professional inspections.',
    ),
    LegalSection(
      '5. Privacy and personal data',
      'Personal data is used to identify you, operate your account, show plots and facilitate agreements. Camera and location are requested only when a feature needs them. Muyu must apply reasonable security measures and must not sell personal data without authorization.',
    ),
    LegalSection(
      '6. Ownership and content',
      'You keep ownership of the content you record and grant Muyu permission to process it within the service. You are responsible for having authorization to publish photographs, documents and other information.',
    ),
    LegalSection(
      '7. Availability and limitations',
      'Availability may be affected by connectivity, maintenance or external services. In areas without connection, some records may stay pending until they sync. This academic version of Muyu is a prototype and must not be used for real financial operations.',
    ),
    LegalSection(
      '8. Ethics and professional responsibility',
      "Muyu's development is guided by honesty, transparency, privacy, quality and respect for users, in line with ACM/IEEE ethical principles and those of the Colegio de Ingenieros del Perú. The team keeps change traceability through version control and software engineering documentation.",
    ),
    LegalSection(
      '9. Changes and termination',
      'Muyu may update these terms as the product evolves. You may stop using the service and request account closure. Access may be suspended if fraud, abuse or a breach of these conditions is detected.',
    ),
    LegalSection(
      '10. Contact',
      'Privacy questions, requests or incident reports may be sent to the AllpaTech team through the support channels shown in the app.',
    ),
  ];

  static const _privacyEn = [
    LegalSection(
      '1. Who we are',
      'Muyu is operated by AllpaTech as an academic prototype. This policy explains how account, plot, evidence and support data are used inside the app.',
    ),
    LegalSection(
      '2. Data we collect',
      'We may collect your name, email, phone, role, profile photo, plot details, financing data, evidence photos, GPS coordinates, device language and the activity needed to operate your account.',
    ),
    LegalSection(
      '3. Why we use your data',
      'We use this information to create your session, show plots, coordinate farmers and merchants, validate milestones, send alerts, process fund custody in the prototype and provide support.',
    ),
    LegalSection(
      '4. Camera, photos and location',
      'Camera and location access are requested only for features such as evidence capture or plot location. Photos and GPS are stored to verify field work and may be visible to the other party in a linked agreement.',
    ),
    LegalSection(
      '5. Profile photo',
      'If you change your profile photo, it is stored on this device with your account so it can be shown in your farmer or merchant profile.',
    ),
    LegalSection(
      '6. Sharing',
      'We share plot, evidence and contact data with the other party in an agreement (farmer or merchant) when that is required to review milestones, visits or payments. We do not sell personal data.',
    ),
    LegalSection(
      '7. Storage and security',
      'In this prototype, data is stored locally on the device and may remain there until it syncs. We apply reasonable measures to protect it, but no system is completely risk-free.',
    ),
    LegalSection(
      '8. Retention and your rights',
      'We keep data while your account is active in the prototype. You may request access, correction or deletion of your personal data, including closing your account, through in-app support.',
    ),
    LegalSection(
      '9. Academic use',
      'This build is a university prototype. It must not be used for real financial operations or as a substitute for professional legal, financial or agronomic advice.',
    ),
    LegalSection(
      '10. Changes and contact',
      'We may update this policy when the product changes. Questions can be sent to the AllpaTech team through the support channels shown in the app.',
    ),
  ];

  static const _termsEs = [
    LegalSection(
      '1. Aceptación del servicio',
      'Al crear una cuenta y utilizar Muyu, el usuario declara haber leído y aceptado estos términos. Muyu facilita la coordinación entre agricultores y comerciantes, el registro de parcelas, evidencias de campo, hitos, alertas y acuerdos de financiamiento.',
    ),
    LegalSection(
      '2. Uso responsable de la cuenta',
      'El usuario debe proporcionar información verdadera, proteger sus credenciales y utilizar la plataforma de forma lícita. No está permitido suplantar identidades, manipular evidencias, registrar información falsa ni utilizar Muyu para actividades fraudulentas.',
    ),
    LegalSection(
      '3. Evidencias y ubicación',
      'Las fotografías, fecha, hora, ubicación GPS, notas e información técnica registradas como evidencia deben corresponder al trabajo realizado. El usuario autoriza su almacenamiento y visualización por las partes vinculadas al acuerdo para validar el cumplimiento de los hitos.',
    ),
    LegalSection(
      '4. Parcelas, acuerdos y pagos',
      'La publicación de una parcela no garantiza su financiamiento. Los fondos permanecen en custodia y solo se liberan según las condiciones del acuerdo y la aprobación de los hitos. Muyu no reemplaza contratos legales, asesoría financiera ni inspecciones profesionales.',
    ),
    LegalSection(
      '5. Privacidad y datos personales',
      'Los datos personales se utilizan para identificar al usuario, operar la cuenta, mostrar parcelas y facilitar los acuerdos. La cámara y la ubicación se solicitan únicamente cuando una función las necesita. Muyu debe aplicar medidas razonables de seguridad y no comercializar datos personales sin autorización.',
    ),
    LegalSection(
      '6. Propiedad y contenido',
      'El usuario conserva la titularidad del contenido que registra y concede a Muyu permiso para procesarlo dentro de las funciones del servicio. El usuario es responsable de contar con autorización para publicar fotografías, documentos y demás información.',
    ),
    LegalSection(
      '7. Disponibilidad y limitaciones',
      'La disponibilidad puede verse afectada por conectividad, mantenimiento o servicios externos. En zonas sin conexión, ciertos registros podrán mantenerse pendientes hasta su sincronización. La versión académica de Muyu es un prototipo y no debe utilizarse para operaciones financieras reales.',
    ),
    LegalSection(
      '8. Ética y responsabilidad profesional',
      'El desarrollo de Muyu se guía por honestidad, transparencia, privacidad, calidad y respeto hacia los usuarios, de acuerdo con los principios éticos de ACM/IEEE y del Colegio de Ingenieros del Perú. El equipo mantiene trazabilidad de los cambios mediante control de versiones y documentación del proceso de ingeniería de software.',
    ),
    LegalSection(
      '9. Cambios y terminación',
      'Muyu podrá actualizar estos términos cuando el producto evolucione. El usuario podrá dejar de utilizar el servicio y solicitar el cierre de su cuenta. El acceso podrá suspenderse cuando se detecte fraude, abuso o incumplimiento de estas condiciones.',
    ),
    LegalSection(
      '10. Contacto',
      'Las consultas, solicitudes de privacidad o reportes de incidencias podrán dirigirse al equipo de AllpaTech mediante los canales de soporte indicados en la aplicación.',
    ),
  ];

  static const _privacyEs = [
    LegalSection(
      '1. Quiénes somos',
      'Muyu es operado por AllpaTech como prototipo académico. Esta política explica cómo se usan en la aplicación los datos de cuenta, parcelas, evidencias y soporte.',
    ),
    LegalSection(
      '2. Datos que recopilamos',
      'Podemos recopilar nombre, correo, teléfono, rol, foto de perfil, datos de parcelas, información de financiamiento, fotos de evidencia, coordenadas GPS, idioma del dispositivo y la actividad necesaria para operar la cuenta.',
    ),
    LegalSection(
      '3. Para qué usamos tus datos',
      'Usamos esta información para crear tu sesión, mostrar parcelas, coordinar a agricultores y comerciantes, validar hitos, enviar alertas, procesar la custodia de fondos en el prototipo y brindar soporte.',
    ),
    LegalSection(
      '4. Cámara, fotos y ubicación',
      'El acceso a la cámara y a la ubicación se solicita solo para funciones como capturar evidencias o ubicar una parcela. Las fotos y el GPS se guardan para verificar el trabajo de campo y pueden ser visibles para la otra parte de un acuerdo vinculado.',
    ),
    LegalSection(
      '5. Foto de perfil',
      'Si cambias tu foto de perfil, se almacena en este dispositivo con tu cuenta para mostrarla en el perfil de agricultor o comerciante.',
    ),
    LegalSection(
      '6. Compartir información',
      'Compartimos datos de parcela, evidencia y contacto con la otra parte de un acuerdo (agricultor o comerciante) cuando hace falta para revisar hitos, visitas o pagos. No vendemos datos personales.',
    ),
    LegalSection(
      '7. Almacenamiento y seguridad',
      'En este prototipo los datos se guardan de forma local en el dispositivo y pueden permanecer ahí hasta sincronizarse. Aplicamos medidas razonables de protección, aunque ningún sistema está libre de riesgo.',
    ),
    LegalSection(
      '8. Conservación y derechos',
      'Conservamos los datos mientras tu cuenta esté activa en el prototipo. Puedes solicitar acceso, corrección o eliminación de tus datos personales, incluido el cierre de la cuenta, a través del soporte de la aplicación.',
    ),
    LegalSection(
      '9. Uso académico',
      'Esta versión es un prototipo universitario. No debe usarse para operaciones financieras reales ni como sustituto de asesoría legal, financiera o agronómica profesional.',
    ),
    LegalSection(
      '10. Cambios y contacto',
      'Podemos actualizar esta política cuando el producto cambie. Las consultas pueden enviarse al equipo de AllpaTech por los canales de soporte indicados en la aplicación.',
    ),
  ];
}
