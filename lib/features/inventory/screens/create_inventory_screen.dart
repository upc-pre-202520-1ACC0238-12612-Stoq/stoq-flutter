import 'package:flutter/material.dart';
import '../models/branch_model.dart';
import 'sedes_map_screen.dart';
import 'inventory_management_screen.dart';
import '../../../shared/constants/app_constants.dart';
import '../../../shared/widgets/logo_widget.dart';
import '../services/inventory_service.dart';
import '../models/inventory_model.dart';

class CreateInventoryScreen extends StatefulWidget {
  const CreateInventoryScreen({super.key});

  @override
  State<CreateInventoryScreen> createState() => _CreateInventoryScreenState();
}

class _CreateInventoryScreenState extends State<CreateInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  Branch? _selectedBranch;
  bool _isCreating = false;

  Future<void> _selectLocation() async {
    final branch = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SedesMapScreen(
          branches: Branch.sampleBranches,
        ),
      ),
    );

    if (branch != null && branch is Branch) {
      setState(() {
        _selectedBranch = branch;
      });
    }
  }

  Future<void> _createInventory() async {
  if (_formKey.currentState!.validate() && _selectedBranch != null) {
    setState(() {
      _isCreating = true;
    });

    // Crear el objeto Inventory
    final inventory = Inventory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      branch: _selectedBranch!,
      createdAt: DateTime.now(),
    );

    // Guardar en SharedPreferences
    await InventoryService.saveInventory(inventory);

    if (mounted) {
      setState(() {
        _isCreating = false;
      });
      
      // Navegar a la pantalla de gestión de inventario
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => InventoryManagementScreen(
            inventoryName: inventory.name,
            branch: inventory.branch,
          ),
        ),
      );
    }
  } else if (_selectedBranch == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Por favor selecciona una ubicación en el mapa'),
        backgroundColor: AppColors.warning,
      ),
    );
  }
}

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
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
        title: const LogoWidget(size: 40),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSizes.paddingExtraLarge),
                decoration: BoxDecoration(
                  color: AppColors.beigeSecondary,
                  borderRadius: BorderRadius.circular(AppSizes.radiusExtraLarge),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inventory_2,
                      size: 60,
                      color: AppColors.darkGray,
                    ),
                    const SizedBox(height: AppSizes.paddingMedium),
                    const Text(
                      'Crear Inventario',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSizes.paddingSmall),
                    Text(
                      'Configura tu espacio de trabajo',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.darkGray, 
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSizes.paddingLarge),

              // Formulario
              Container(
                padding: const EdgeInsets.all(AppSizes.paddingLarge),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Campo Nombre
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nombre del Inventario',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: 'Ej: Mi Tienda Principal',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: AppSizes.paddingMedium,
                              vertical: AppSizes.paddingMedium,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Por favor ingresa un nombre';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // Campo Ubicación
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ubicación',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                readOnly: true,
                                decoration: InputDecoration(
                                  hintText: _selectedBranch?.name ?? 'Selecciona una sede en el mapa',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: AppSizes.paddingMedium,
                                    vertical: AppSizes.paddingMedium,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSizes.paddingSmall),
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: AppColors.secondary,
                                borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                              ),
                              child: IconButton(
                                onPressed: _selectLocation,
                                icon: Icon(
                                  Icons.location_on,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSizes.paddingLarge),

                    // Campo Descripción
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Descripción (Opcional)',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: AppSizes.paddingSmall),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: 'Describe el propósito de este inventario...',
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

                    // Botón Crear
                    SizedBox(
                      width: double.infinity,
                      height: AppSizes.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _isCreating ? null : _createInventory,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusLarge),
                          ),
                        ),
                        child: _isCreating
                            ? const CircularProgressIndicator(color: AppColors.textLight)
                            : const Text(
                                'Crear Inventario',
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
            ],
          ),
        ),
      ),
    );
  }
}