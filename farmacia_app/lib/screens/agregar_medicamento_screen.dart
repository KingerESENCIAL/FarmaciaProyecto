import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AgregarMedicamentoScreen extends StatefulWidget {
  const AgregarMedicamentoScreen({super.key});

  @override
  State<AgregarMedicamentoScreen> createState() =>
      _AgregarMedicamentoScreenState();
}

class _AgregarMedicamentoScreenState extends State<AgregarMedicamentoScreen> {
  final nombreController = TextEditingController();
  final laboratorioController = TextEditingController();
  final cantidadController = TextEditingController();
  final fechaController = TextEditingController();
  final ubicacionController = TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    laboratorioController.dispose();
    cantidadController.dispose();
    fechaController.dispose();
    ubicacionController.dispose();
    super.dispose();
  }

  Future<void> guardarMedicamento() async {
    try {
      final response = await http.get(
        Uri.parse(
          "http://192.168.1.93:5247/agregarMedicamento"
          "?nombre=${Uri.encodeComponent(nombreController.text)}"
          "&laboratorio=${Uri.encodeComponent(laboratorioController.text)}"
          "&cantidad=${cantidadController.text}"
          "&fecha_caducidad=${fechaController.text}"
          "&ubicacion=${Uri.encodeComponent(ubicacionController.text)}",
        ),
      );

      if (!mounted) return;

      if (response.body.contains("Medicamento agregado")) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Medicamento agregado correctamente")),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(response.body)));
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar medicamento"),
        backgroundColor: const Color(0xFF5E35B1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: laboratorioController,
              decoration: const InputDecoration(labelText: "Laboratorio"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: cantidadController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Cantidad"),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: fechaController,
              decoration: const InputDecoration(
                labelText: "Fecha (AAAA-MM-DD)",
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: ubicacionController,
              decoration: const InputDecoration(labelText: "Ubicación"),
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: guardarMedicamento,
                child: const Text("GUARDAR"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
