import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:ueo_app/services/stripe_services.dart';

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

  Future<void> _saveRegistrationToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.collection('registrations').add({
        'userId': user?.uid,
        'name': _nameController.text,
        'email': _emailController.text,
        'eventTitle': widget.eventTitle,
        'price': widget.price,
        'registrationDate': FieldValue.serverTimestamp(),
        'paymentStatus': 'success',
      });
      print("Registration saved to Firestore");
    } catch (e) {
      print("Error saving registration: $e");
    }
  }

  void _showPaymentSummary() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Registration Summary"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Event: ${widget.eventTitle}", style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Name: ${_nameController.text}"),
            Text("Email: ${_emailController.text}"),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total Price:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text("Rs ${widget.price}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Edit Details"),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              navigator.pop();
              
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (loadingContext) => const Center(child: CircularProgressIndicator()),
              );

              try {
                String numericPrice = widget.price.replaceAll(RegExp(r'[^0-9]'), '');
                int amount = int.tryParse(numericPrice) ?? 0;
                
                bool success = await StripeServices.instance.makePayment(amount, "pkr");

                if (mounted) {
                   navigator.pop();
                }

                if (success) {
                  // SAVE TO FIREBASE HERE
                  await _saveRegistrationToFirestore();

                  if (mounted) {
                    navigator.push(
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
                } else {
                  if (mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text("Payment failed or cancelled.")),
                    );
                  }
                }
              } catch (e) {
                if (mounted && Navigator.canPop(context)) navigator.pop();
                print("Error during payment: $e");
              }
            },
            child: const Text("Pay & Register"),
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _showPaymentSummary();
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
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _printReceipt,
                      icon: const Icon(Icons.print),
                      label: const Text("Print"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(context, '/MainPage', (route) => false);
                      },
                      child: const Text("Home"),
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
          const SizedBox(width: 10),
          Expanded(child: Text(value, textAlign: TextAlign.right, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}
