import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import '../../inventory/screens/create_inventory_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _lowStockAlerts = true;
  bool _expiryReminders = true;
  bool _pushNotifications = true;
  bool _autoBackup = false;
  bool _darkMode = false;

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  void _configureInventory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateInventoryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ajustes',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección: Sistema de Notificaciones
            _buildSectionTitle('Sistema de Notificaciones'),
            _buildNotificationOption(
              title: 'Alertas de stock bajo',
              description: 'Recibir notificaciones cuando el stock esté bajo',
              value: _lowStockAlerts,
              onChanged: (value) => setState(() => _lowStockAlerts = value),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildNotificationOption(
              title: 'Recordatorios de productos próximos a vencer',
              description: 'Alertas para productos cerca de su fecha de vencimiento',
              value: _expiryReminders,
              onChanged: (value) => setState(() => _expiryReminders = value),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildNotificationOption(
              title: 'Notificaciones push',
              description: 'Recibir notificaciones push en tiempo real',
              value: _pushNotifications,
              onChanged: (value) => setState(() => _pushNotifications = value),
            ),

            const SizedBox(height: AppSizes.paddingExtraLarge),

            // Sección: Preferencias de la App
            _buildSectionTitle('Preferencias de la App'),
            _buildNotificationOption(
              title: 'Modo oscuro',
              description: 'Activar el tema oscuro en la aplicación',
              value: _darkMode,
              onChanged: (value) => setState(() => _darkMode = value),
            ),
            const SizedBox(height: AppSizes.paddingMedium),
            _buildNotificationOption(
              title: 'Copia de seguridad automática',
              description: 'Realizar backup automático de los datos',
              value: _autoBackup,
              onChanged: (value) => setState(() => _autoBackup = value),
            ),

            const SizedBox(height: AppSizes.paddingExtraLarge),

            // Sección: Gestión de Inventarios
            _buildSectionTitle('Gestión de Inventarios'),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configuración de Inventarios',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingSmall),
                  Text(
                    'Gestiona tus sedes, sucursales y configuración de inventarios',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSizes.paddingMedium),
                  SizedBox(
                    width: double.infinity,
                    height: AppSizes.buttonHeight,
                    child: ElevatedButton(
                      onPressed: _configureInventory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.beigeSecondary, 
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                         Icon(Icons.inventory_2, size: 20, color: AppColors.darkGray),
                          SizedBox(width: AppSizes.paddingSmall),
                          Text(
                            'Configurar Inventario',
                            style: TextStyle(
                              color: AppColors.darkGray, 
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSizes.paddingExtraLarge),

            // Botón de guardar configuración
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                ),
                child: const Text(
                  'Guardar Configuración',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSizes.paddingLarge),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.redAccent,
        ),
      ),
    );
  }

  Widget _buildNotificationOption({
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}