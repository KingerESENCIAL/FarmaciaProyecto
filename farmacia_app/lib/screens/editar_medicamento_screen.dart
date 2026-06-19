import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditarMedicamentoScreen extends StatefulWidget {
  final Map<String, dynamic> medicamento;

  const EditarMedicamentoScreen({super.key, required this.medicamento});

  @override
  State<EditarMedicamentoScreen> createState() =>
      _EditarMedicamentoScreenState();
}

class _EditarMedicamentoScreenState extends State<EditarMedicamentoScreen> {
  late TextEditingController nombreController;
  late TextEditingController laboratorioController;
  late TextEditingController cantidadController;
  late TextEditingController fechaController;
  late TextEditingController ubicacionController;

  final String apiUrl = "http://192.168.1.93:5247";

  @override
  void initState() {
    super.initState();

    nombreController = TextEditingController(
      text: widget.medicamento["nombre"]?.toString() ?? "",
    );

    laboratorioController = TextEditingController(
      text: widget.medicamento["laboratorio"]?.toString() ?? "",
    );

    cantidadController = TextEditingController(
      text: widget.medicamento["cantidad"]?.toString() ?? "0",
    );

    fechaController = TextEditingController(
      text: widget.medicamento["fecha_caducidad"]?.toString() ?? "",
    );

    ubicacionController = TextEditingController(
      text: widget.medicamento["ubicacion"]?.toString() ?? "",
    );
  }

  @override
  void dispose() {
    nombreController.dispose();
    laboratorioController.dispose();
    cantidadController.dispose();
    fechaController.dispose();
    ubicacionController.dispose();
    super.dispose();
  }

  Future<void> actualizarMedicamento() async {
    try {
      final response = await http.put(
        Uri.parse(
          "$apiUrl/actualizarMedicamento"
          "?id=${widget.medicamento["id"]}"
          "&nombre=${nombreController.text}"
          "&laboratorio=${laboratorioController.text}"
          "&cantidad=${cantidadController.text}"
          "&fecha_caducidad=${fechaController.text}"
          "&ubicacion=${ubicacionController.text}",
        ),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Medicamento actualizado correctamente"),
          ),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Error al actualizar")));
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Inventario"),
        centerTitle: true,
        backgroundColor: const Color(0xFF5E35B1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
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
                  labelText: "Fecha de caducidad",
                ),
              ),
              const SizedBox(height: 15),

              TextField(
                controller: ubicacionController,
                decoration: const InputDecoration(labelText: "Ubicación"),
              ),
              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: actualizarMedicamento,
                  child: const Text("Guardar cambios"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
