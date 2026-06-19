import "dart:convert";
import "package:flutter/material.dart";
import "package:http/http.dart" as http;
import "agregar_medicamento_screen.dart";
import "editar_medicamento_screen.dart";
import "pdf_service.dart";

class InventarioScreen extends StatefulWidget {
  const InventarioScreen({super.key});

  @override
  State<InventarioScreen> createState() => _InventarioScreenState();
}

class _InventarioScreenState extends State<InventarioScreen> {
  List<Map<String, dynamic>> medicamentos = [];

  final TextEditingController buscarController = TextEditingController();

  final String apiUrl = "http://192.168.1.93:5247";

  @override
  void initState() {
    super.initState();
    cargarMedicamentos();
  }

  @override
  void dispose() {
    buscarController.dispose();
    super.dispose();
  }

  Future<void> cargarMedicamentos() async {
    try {
      final response = await http.get(Uri.parse("$apiUrl/medicamentos"));

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final List datos = jsonDecode(response.body);

        setState(() {
          medicamentos = List<Map<String, dynamic>>.from(datos);
        });
      }
    } catch (e) {
      print("ERROR CARGAR MEDICAMENTOS: $e");
    }
  }

  Future<void> buscarMedicamento(String nombre) async {
    if (nombre.trim().isEmpty) {
      await cargarMedicamentos();
      return;
    }

    try {
      final response = await http.get(
        Uri.parse("$apiUrl/buscarMedicamento?nombre=$nombre"),
      );

      if (response.statusCode == 200) {
        final List datos = jsonDecode(response.body);

        setState(() {
          medicamentos = List<Map<String, dynamic>>.from(datos);
        });
      }
    } catch (e) {
      debugPrint("Error al buscar: $e");
    }
  }

  Future<void> eliminarMedicamento(int id) async {
    try {
      final response = await http.delete(
        Uri.parse("$apiUrl/eliminarMedicamento?id=$id"),
      );

      if (response.statusCode == 200) {
        await cargarMedicamentos();

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Medicamento eliminado correctamente")),
        );
      }
    } catch (e) {
      debugPrint("Error al eliminar: $e");
    }
  }

  int get totalExistencias {
    return medicamentos.fold(
      0,
      (suma, item) =>
          suma + (int.tryParse(item["cantidad"]?.toString() ?? "0") ?? 0),
    );
  }

  int get medicamentosStockBajo {
    return medicamentos.where((m) {
      return (int.tryParse(m["cantidad"]?.toString() ?? "0") ?? 0) < 10;
    }).length;
  }

  int get medicamentosPorVencer {
    int contador = 0;

    for (var medicamento in medicamentos) {
      try {
        final fecha = DateTime.parse(medicamento["fecha_caducidad"].toString());

        final diferencia = fecha.difference(DateTime.now()).inDays;

        if (diferencia <= 30) {
          contador++;
        }
      } catch (_) {}
    }

    return contador;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F5FF),

      appBar: AppBar(
        title: const Text("Inventario"),
        centerTitle: true,
        backgroundColor: const Color(0xFF5E35B1),
        foregroundColor: Colors.white,

        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              PdfService.generarInventario(medicamentos);
            },
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.medication,
                          size: 40,
                          color: Color(0xFF5E35B1),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          medicamentos.length.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Medicamentos"),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.warning_amber,
                          color: Colors.orange,
                          size: 40,
                        ),

                        const SizedBox(height: 10),

                        Text(
                          medicamentosPorVencer.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const Text("Por vencer"),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.inventory_2,
                          size: 40,
                          color: Color(0xFF5E35B1),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          totalExistencias.toString(),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Existencias"),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            TextField(
              controller: buscarController,
              onChanged: buscarMedicamento,
              decoration: InputDecoration(
                hintText: "Buscar medicamento...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: medicamentos.isEmpty
                  ? const Center(child: Text("No hay medicamentos registrados"))
                  : ListView.builder(
                      itemCount: medicamentos.length,
                      itemBuilder: (context, index) {
                        final medicamento = medicamentos[index];

                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFEDE7F6),
                              child: Icon(
                                Icons.medication,
                                color: Color(0xFF5E35B1),
                              ),
                            ),

                            title: Text(
                              medicamento["nombre"].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 5),

                                Text(
                                  "Laboratorio: ${medicamento["laboratorio"] ?? "Sin registro"}",
                                ),

                                Text(
                                  (int.tryParse(
                                                medicamento["cantidad"]
                                                        ?.toString() ??
                                                    "0",
                                              ) ??
                                              0) <
                                          10
                                      ? "Cantidad: ${medicamento["cantidad"]} ⚠️ STOCK BAJO"
                                      : "Cantidad: ${medicamento["cantidad"]}",
                                  style: TextStyle(
                                    color:
                                        (int.tryParse(
                                                  medicamento["cantidad"]
                                                          ?.toString() ??
                                                      "0",
                                                ) ??
                                                0) <
                                            10
                                        ? Colors.red
                                        : Colors.black,
                                    fontWeight:
                                        (int.tryParse(
                                                  medicamento["cantidad"]
                                                          ?.toString() ??
                                                      "0",
                                                ) ??
                                                0) <
                                            10
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),

                                Text(
                                  "Caducidad: ${medicamento["fecha_caducidad"] ?? "Sin registro"}",
                                ),

                                Text(
                                  "Ubicación: ${medicamento["ubicacion"] ?? "Sin registro"}",
                                ),
                              ],
                            ),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () async {
                                    final actualizado = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => EditarMedicamentoScreen(
                                          medicamento: medicamento,
                                        ),
                                      ),
                                    );

                                    if (actualizado == true) {
                                      await cargarMedicamentos();
                                    }
                                  },
                                ),

                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () async {
                                    final confirmar = await showDialog<bool>(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text(
                                            "Eliminar medicamento",
                                          ),
                                          content: const Text(
                                            "¿Deseas eliminar este medicamento?",
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context, false);
                                              },
                                              child: const Text("Cancelar"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                Navigator.pop(context, true);
                                              },
                                              child: const Text("Eliminar"),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmar == true) {
                                      await eliminarMedicamento(
                                        medicamento["id"],
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5E35B1),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AgregarMedicamentoScreen()),
          );

          await cargarMedicamentos();
        },
      ),
    );
  }
}
