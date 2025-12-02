import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../shared/constants/app_constants.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart';

class AddBranchModal extends StatefulWidget {
  final Function(Branch)? onBranchAdded;

  const AddBranchModal({
    super.key,
    this.onBranchAdded,
  });

  @override
  State<AddBranchModal> createState() => _AddBranchModalState();
}

class _AddBranchModalState extends State<AddBranchModal> {
  final BranchService _branchService = BranchService();
  final _formKey = GlobalKey<FormState>();
  
  // Controllers para los campos del formulario
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _typeController = TextEditingController();
  
  // Variables de estado
  LatLng? _selectedLocation;
  bool _isLoading = false;
  GoogleMapController? _mapController;
  final LatLng _defaultCenter = const LatLng(-12.0464, -77.0428);

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _typeController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _saveBranch() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Por favor selecciona una ubicación en el mapa'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final branch = await _branchService.createBranch(
        name: _nameController.text,
        type: _typeController.text.isEmpty ? 'sucursal' : _typeController.text,
        address: _addressController.text,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
      );

      if (branch != null) {
        widget.onBranchAdded?.call(branch);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sucursal "${branch.name}" creada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        _showErrorMessage('Error al crear la sucursal');
      }
    } catch (e) {
      _showErrorMessage('Error al crear la sucursal: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Header del modal
          Container(
            padding: const EdgeInsets.all(AppSizes.paddingMedium),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
                const Expanded(
                  child: Text(
                    'Agregar Nueva Sucursal',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),
          
          // Formulario y mapa
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSizes.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre
                    const Text(
                      'Nombre de la Sucursal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: 'Ej: Sucursal Centro',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Tipo
                    const Text(
                      'Tipo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _typeController.text.isEmpty ? 'sucursal' : _typeController.text,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'central', child: Text('Central')),
                        DropdownMenuItem(value: 'sucursal', child: Text('Sucursal')),
                        DropdownMenuItem(value: 'almacen', child: Text('Almacén')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _typeController.text = value;
                        }
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Dirección
                    const Text(
                      'Dirección',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Ej: Av. Principal 123',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'La dirección es obligatoria';
                        }
                        return null;
                      },
                    ),
                    
                    const SizedBox(height: AppSizes.paddingMedium),
                    
                    // Mapa para seleccionar ubicación
                    const Text(
                      'Selecciona la ubicación en el mapa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 300,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            _mapController = controller;
                          },
                          initialCameraPosition: CameraPosition(
                            target: _selectedLocation ?? _defaultCenter,
                            zoom: 12.0,
                          ),
                          markers: _selectedLocation != null
                              ? {
                                  Marker(
                                    markerId: const MarkerId('selected'),
                                    position: _selectedLocation!,
                                  ),
                                }
                              : {},
                          onTap: (LatLng position) {
                            setState(() {
                              _selectedLocation = position;
                            });
                          },
                          myLocationEnabled: false,
                          myLocationButtonEnabled: false,
                        ),
                      ),
                    ),
                    
                    if (_selectedLocation != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Ubicación seleccionada: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    
                    const SizedBox(height: AppSizes.paddingLarge),
                    
                    // Botón de guardar
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveBranch,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.redAccent,
                          foregroundColor: AppColors.textLight,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSizes.radiusMedium),
                          ),
                        ),
                        child: _isLoading
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text('Guardando...'),
                                ],
                              )
                            : const Text(
                                'Guardar Sucursal',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

