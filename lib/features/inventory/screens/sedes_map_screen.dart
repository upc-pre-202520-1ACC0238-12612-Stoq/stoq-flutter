import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/branch_model.dart';
import '../../../shared/constants/app_constants.dart';

class SedesMapScreen extends StatefulWidget {
  final List<Branch> branches;

  const SedesMapScreen({
    super.key,
    required this.branches,
  });

  @override
  State<SedesMapScreen> createState() => _SedesMapScreenState();
}

class _SedesMapScreenState extends State<SedesMapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(-12.0464, -77.0428);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
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
          'Sedes y Sucursales',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 12.0,
        ),
        markers: _createMarkers(),
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }

  Set<Marker> _createMarkers() {
    return widget.branches.map((branch) {
      return Marker(
        markerId: MarkerId(branch.name),
        position: LatLng(branch.latitude, branch.longitude),
        infoWindow: InfoWindow(
          title: branch.name,
          snippet: 'Haz tap para seleccionar',
        ),
        onTap: () {
          // Retornar la sede seleccionada
          Navigator.pop(context, branch);
        },
      );
    }).toSet();
  }
}