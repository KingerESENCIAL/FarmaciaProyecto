import "package:pdf/widgets.dart" as pw;
import "package:printing/printing.dart";

class PdfService {
  static Future<void> generarInventario(
    List<Map<String, dynamic>> medicamentos,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            children: [
              pw.Text(
                "Inventario de Farmacia",
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),

              pw.TableHelper.fromTextArray(
                headers: ["Nombre", "Laboratorio", "Cantidad", "Caducidad"],
                data: medicamentos
                    .map(
                      (m) => [
                        m["nombre"].toString(),
                        m["laboratorio"].toString(),
                        m["cantidad"].toString(),
                        m["fecha_caducidad"].toString(),
                      ],
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }
}
