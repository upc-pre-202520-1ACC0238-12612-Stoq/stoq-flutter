import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationAlerts = true;
  bool _multiFormatNotifications = false;
  bool _specificAlertConfig = true;
  bool _minorRolesAlerts = false;

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 243, 238, 232),
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
        padding: const EdgeInsets.all(AppSizes.paddingExtraLarge),
        child: Column(
          children: [
            const SizedBox(height: AppSizes.paddingLarge),
            
            // Configuraciones de notificaciones
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Configuración de Notificaciones',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSizes.paddingLarge),
                
                // Opción 1
                _buildNotificationOption(
                  title: 'Permiso de notificación de alertas',
                  description: 'Alertas automáticas',
                  value: _notificationAlerts,
                  onChanged: (value) => setState(() => _notificationAlerts = value),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                
                // Opción 2
                _buildNotificationOption(
                  title: 'Permiso de envío de notificaciones en múltiples formatos',
                  description: 'Recibir alertas en diferentes formatos',
                  value: _multiFormatNotifications,
                  onChanged: (value) => setState(() => _multiFormatNotifications = value),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                
                // Opción 3
                _buildNotificationOption(
                  title: 'Permiso de configuración específica de alerta',
                  description: 'Personalizar tipos de alertas',
                  value: _specificAlertConfig,
                  onChanged: (value) => setState(() => _specificAlertConfig = value),
                ),
                const SizedBox(height: AppSizes.paddingMedium),
                
                // Opción 4
                _buildNotificationOption(
                  title: 'Roles menores pueden recibir las alertas',
                  description: 'Extender notificaciones a roles menores',
                  value: _minorRolesAlerts,
                  onChanged: (value) => setState(() => _minorRolesAlerts = value),
                ),
              ],
            ),
            
            const SizedBox(height: AppSizes.paddingExtraLarge),
            
            // Botón de guardar configuración
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                ),
                child: const Text(
                  'Cambiar plan',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
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