import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';

class ScanProductScreen extends StatefulWidget {
  @override
  State<ScanProductScreen> createState() => _ScanProductScreenState();
}

class _ScanProductScreenState extends State<ScanProductScreen> {
  File? imageFile;
  List<String> detectedLabels = [];
  bool isLoading = false;

  List<Map<String, dynamic>> savedProducts = [];

  Future<void> takePhoto() async {
    setState(() {
      detectedLabels.clear();
      isLoading = false;
    });
    final testImages = [
      'assets/images/aceite.jpg',
      'assets/images/gaseosa.jpg',
      'assets/images/leche.jpg',
      'assets/images/arveja.png',
      'assets/images/arroz.png',
      'assets/images/atun.png',
      'assets/images/sal.png',
      'assets/images/siyao.png',
      'assets/images/tallarin.png',
      'assets/images/vinagre.png',
    ];

    final random = Random();
    final path = testImages[random.nextInt(testImages.length)];
    final byteData = await rootBundle.load(path);
    final tempFile = File('${(await getTemporaryDirectory()).path}/simulated.png');
    await tempFile.writeAsBytes(byteData.buffer.asUint8List());

    imageFile = tempFile;

    setState(() {});

    _analyzeImage(imageFile!);
  }

  Future<void> _analyzeImage(File file) async {
    setState(() => isLoading = true);

    final inputImage = InputImage.fromFile(file);
    final options = ImageLabelerOptions(confidenceThreshold: 0.5);
    final labeler = ImageLabeler(options: options);

    final labels = await labeler.processImage(inputImage);
    detectedLabels = labels.map((e) => e.label).toList();

    await labeler.close();

    setState(() => isLoading = false);

    if (detectedLabels.isNotEmpty) {
      _openConfirmationModal();
    }
  }

  void _openConfirmationModal() {
    String selectedLabel = detectedLabels.first;
    TextEditingController qtyCtrl = TextEditingController();
    TextEditingController locationCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF5E6D3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
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

              DropdownButtonFormField<String>(
                value: selectedLabel,
                decoration: const InputDecoration(labelText: "Etiqueta sugerida"),
                items: detectedLabels
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => selectedLabel = v!,
              ),

              const SizedBox(height: 15),

              TextField(
                controller: qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Cantidad"),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: locationCtrl,
                decoration:
                const InputDecoration(labelText: "Ubicación en el almacén"),
              ),

              const SizedBox(height: 30),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFB86E44)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(
                          color: Color(0xFFB86E44),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        /// 🔥 GUARDAR PRODUCTO
                        savedProducts.add({
                          "producto": selectedLabel,
                          "cantidad": qtyCtrl.text,
                          "ubicacion": locationCtrl.text,
                          "imagen": imageFile?.path,
                          "fecha": DateTime.now().toIso8601String(),
                        });

                        setState(() {});

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
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text(
                        "Guardar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void resetScan() {
    setState(() {
      imageFile = null;
      detectedLabels.clear();
      isLoading = false;
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

            const SizedBox(height: 20),

            /// 🔥 LISTA DE PRODUCTOS GUARDADOS
            if (savedProducts.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: savedProducts.length,
                  itemBuilder: (context, index) {
                    final item = savedProducts[index];
                    return Card(
                      child: ListTile(
                        leading: item["imagen"] != null
                            ? Image.file(File(item["imagen"]), width: 40)
                            : const Icon(Icons.inventory),
                        title: Text(item["producto"]),
                        subtitle: Text(
                            "Cantidad: ${item["cantidad"]} • Ubicación: ${item["ubicacion"]}"),
                      ),
                    );
                  },
                ),
              )
            else
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
