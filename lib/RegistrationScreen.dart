import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class RegistrationScreen extends StatefulWidget {
  final String eventTitle;
  final String price;
  const RegistrationScreen({super.key, required this.eventTitle, required this.price});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptScreen(
            name: _nameController.text,
            email: _emailController.text,
            eventTitle: widget.eventTitle,
            price: widget.price,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Event Registration")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Register for: ${widget.eventTitle}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text("Ticket Price: Rs ${widget.price}", style: const TextStyle(fontSize: 16, color: Colors.deepPurple, fontWeight: FontWeight.w600)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Full Name", border: OutlineInputBorder()),
                validator: (value) => value == null || value.isEmpty ? "Please enter your name" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Gmail Address", border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return "Please enter your email";
                  if (!value.endsWith("@gmail.com")) return "Please enter a valid Gmail address";
                  return null;
                },
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                  child: const Text("Submit Registration"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ReceiptScreen extends StatelessWidget {
  final String name;
  final String email;
  final String eventTitle;
  final String price;

  const ReceiptScreen({
    super.key,
    required this.name,
    required this.email,
    required this.eventTitle,
    required this.price,
  });

  Future<void> _printReceipt() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Column(
              children: [
                pw.Text("Event Registration Receipt", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text("Event: $eventTitle"),
                pw.Text("Name: $name"),
                pw.Text("Email: $email"),
                pw.Text("Price Paid: Rs $price"),
                pw.Text("Date: ${DateTime.now().toString().split('.')[0]}"),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.Text("This is a valid proof of registration.", style: pw.TextStyle(fontStyle: pw.FontStyle.italic)),
              ],
            ),
          );
        },
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Registration Receipt")),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 10)],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                const Text("Registration Successful!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const Divider(height: 40),
                _buildReceiptRow("Event:", eventTitle),
                _buildReceiptRow("Price:", "Rs $price"),
                _buildReceiptRow("Name:", name),
                _buildReceiptRow("Email:", email),
                _buildReceiptRow("Date:", DateTime.now().toString().split('.')[0]),
                const Divider(height: 40),
                const Text("Keep this receipt for entry proof.", style: TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _printReceipt,
                      icon: const Icon(Icons.print),
                      label: const Text("Print Receipt"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // Pop back to the main page (the first route)
                        Navigator.of(context).popUntil((route) => route.isFirst);
                      },
                      child: const Text("Back to Home"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value),
        ],
      ),
    );
  }
}
