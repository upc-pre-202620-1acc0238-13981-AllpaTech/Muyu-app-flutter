/// The plot status the backend stores, in the words the Kotlin app shows to
/// farmers and merchants (`farmer_status_*`, `merchant_available`).
String plotStatusLabel(String status, {required bool es}) => switch (status.trim().toLowerCase()) {
  'available' => es ? 'Disponible' : 'Available',
  'published' || 'listed' => es ? 'Publicada' : 'Published',
  'pending' => es ? 'Pendiente' : 'Pending',
  'funded' => es ? 'Financiada' : 'Funded',
  'approved' => es ? 'Aprobado' : 'Approved',
  'completed' || 'finished' => es ? 'Finalizada' : 'Finished',
  '' => '—',
  final other => other[0].toUpperCase() + other.substring(1),
};

/// The stage title Kotlin writes on the plot ("Planting", "Irrigation"…),
/// shown in the user's language.
String plotStageLabel(String stage, {required bool es}) => switch (stage.trim().toLowerCase()) {
  'planting' => es ? 'Siembra' : 'Planting',
  'irrigation' => es ? 'Riego' : 'Irrigation',
  'fertilization' => es ? 'Fertilización' : 'Fertilization',
  'harvest' => es ? 'Cosecha' : 'Harvest',
  'published' || 'listed' => es ? 'Publicada' : 'Published',
  '' => '—',
  _ => stage.trim(),
};
