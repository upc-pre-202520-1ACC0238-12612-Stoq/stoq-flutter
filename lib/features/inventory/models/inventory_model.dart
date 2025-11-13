import 'branch_model.dart'; 

class Inventory {
  final String id;
  final String name;
  final String description;
  final Branch branch;
  final DateTime createdAt;

  const Inventory({
    required this.id,
    required this.name,
    required this.description,
    required this.branch,
    required this.createdAt,
  });

  // Método toMap para guardar en SharedPreferences
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'branch_name': branch.name,
      'branch_latitude': branch.latitude,
      'branch_longitude': branch.longitude,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  // Método fromMap para cargar desde SharedPreferences
  static Inventory fromMap(Map<String, dynamic> map) {
    return Inventory(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      branch: Branch(
        id: map['branch_name'] ?? '1',
        name: map['branch_name'],
        type: 'central',
        latitude: map['branch_latitude'],
        longitude: map['branch_longitude'],
        stockTotal: 0,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }
}