class Branch {
  final String name;
  final double latitude;
  final double longitude;

  const Branch({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  // Sedes de ejemplo
  static List<Branch> get sampleBranches => [
    Branch(
      name: 'Sucursal Central',
      latitude: -12.0464,
      longitude: -77.0428,
    ),
    Branch(
      name: 'Sucursal Norte', 
      latitude: -12.0264,
      longitude: -77.0328,
    ),
    Branch(
      name: 'Sucursal Sur',
      latitude: -12.0664, 
      longitude: -77.0528,
    ),
  ];
}