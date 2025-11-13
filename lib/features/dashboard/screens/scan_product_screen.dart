import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

class ScanProductScreen extends StatefulWidget {
  @override
  State<ScanProductScreen> createState() => _ScanProductScreenState();
}

class _ScanProductScreenState extends State<ScanProductScreen> {
  File? imageFile;
  List<String> detectedLabels = [];
  bool isLoading = false;

  // TOMAR FOTO
  Future<void> takePhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);

    if (picked != null) {
      imageFile = File(picked.path);
      setState(() {});
      _analyzeImage(imageFile!);
    }
  }

  // ANALIZAR IMAGEN CON ML KIT
  Future<void> _analyzeImage(File file) async {
    setState(() => isLoading = true);

    final inputImage = InputImage.fromFile(file);

    final options = ImageLabelerOptions(
      confidenceThreshold: 0.5,
    );

    final labeler = ImageLabeler(options: options);
    final labels = await labeler.processImage(inputImage);

    detectedLabels = labels.map((e) => e.label).toList();

    await labeler.close();

    setState(() => isLoading = false);

    if (detectedLabels.isNotEmpty) {
      _openConfirmationModal();
    }
  }

  // MODAL DE CONFIRMACIÓN (Elegir producto + cantidad + ubicación)
  void _openConfirmationModal() {
    String selectedLabel = detectedLabels.first;
    TextEditingController qtyCtrl = TextEditingController();
    TextEditingController locationCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5E6D3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Confirmar Producto",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Color(0xFF3E2723),
                ),
              ),

              const SizedBox(height: 20),

              // Selección de etiqueta detectada
              DropdownButtonFormField<String>(
                value: selectedLabel,
                decoration: const InputDecoration(labelText: "Etiqueta sugerida"),
                items: detectedLabels
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) {
                  selectedLabel = v!;
                },
              ),

              const SizedBox(height: 15),

              // Cantidad
              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Cantidad"),
              ),

              const SizedBox(height: 15),

              // Ubicación
              TextField(
                controller: locationCtrl,
                decoration: const InputDecoration(labelText: "Ubicación en el almacén"),
              ),

              const SizedBox(height: 30),

              // GUARDAR
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        "Guardado: $selectedLabel • Cant: ${qtyCtrl.text} • Ubicación: ${locationCtrl.text}",
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text("Guardar", style: TextStyle(color: Colors.white)),
              )
            ],
          ),
        );
      },
    );
  }

  // REINICIAR
  void resetScan() {
    setState(() {
      imageFile = null;
      detectedLabels = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),

      appBar: AppBar(
        title: const Text(
          "Escanear Producto",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // PREVIEW
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: imageFile != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(imageFile!, fit: BoxFit.cover),
              )
                  : const Icon(Icons.photo, size: 80, color: Colors.grey),
            ),

            const SizedBox(height: 20),

            // REINTENTAR
            if (imageFile != null)
              OutlinedButton.icon(
                icon: const Icon(Icons.refresh, color: Color(0xFF5D4037)),
                label: const Text(
                  "Reintentar escaneo",
                  style: TextStyle(color: Color(0xFF5D4037)),
                ),
                onPressed: resetScan,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF5D4037)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

            if (isLoading) ...[
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Colors.brown),
            ],

            const Spacer(),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5D4037),
        onPressed: takePhoto,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}
