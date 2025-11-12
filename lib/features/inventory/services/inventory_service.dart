import 'dart:convert'; 
import 'package:shared_preferences/shared_preferences.dart';
import '../models/inventory_model.dart';

class InventoryService {
  static const String _inventoryKey = 'current_inventory';

  // Guardar inventario
  static Future<void> saveInventory(Inventory inventory) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_inventoryKey, json.encode(inventory.toMap()));
  }

  // Cargar inventario
  static Future<Inventory?> loadInventory() async {
    final prefs = await SharedPreferences.getInstance();
    final inventoryData = prefs.getString(_inventoryKey);
    
    if (inventoryData != null) {
      try {
        final map = json.decode(inventoryData);
        return Inventory.fromMap(map);
      } catch (e) {
        print('Error loading inventory: $e');
        return null;
      }
    }
    return null;
  }

  // Verificar si existe inventario
  static Future<bool> hasInventory() async {
    final inventory = await loadInventory();
    return inventory != null;
  }

  // Eliminar inventario
  static Future<void> clearInventory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_inventoryKey);
  }
}