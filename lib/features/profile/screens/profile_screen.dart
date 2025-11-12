import 'package:flutter/material.dart';
import '../../../shared/constants/app_constants.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userName;
  final String userRole;

  const ProfileScreen({
    super.key,
    required this.userName,
    required this.userRole,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String _name;
  late String _jobTitle;

  @override
  void initState() {
    super.initState();
    _name = widget.userName;
    _jobTitle = widget.userRole;
  }

  void _updateProfile() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil actualizado: $_name - $_jobTitle'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 241, 236),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SettingsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingExtraLarge),
        child: Column(
          children: [
            // Imagen de perfil
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person,
                size: 60,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: AppSizes.paddingExtraLarge),
            
            // Campos del formulario
            Column(
              children: [
                // Campo Nombre
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nombre:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    TextFormField(
                      initialValue: _name,
                      onChanged: (value) => _name = value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                          vertical: AppSizes.paddingMedium,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSizes.paddingLarge),
                
                // Campo Título Laboral
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Título Laboral:',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    TextFormField(
                      initialValue: _jobTitle,
                      onChanged: (value) => _jobTitle = value,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppSizes.paddingMedium,
                          vertical: AppSizes.paddingMedium,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const Spacer(),
            
            // Botón Actualizar perfil
            SizedBox(
              width: double.infinity,
              height: AppSizes.buttonHeight,
              child: ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  ),
                ),
                child: const Text(
                  'Actualizar perfil',
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
}