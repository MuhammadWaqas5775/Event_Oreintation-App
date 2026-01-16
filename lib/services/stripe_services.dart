import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StripeServices {
  StripeServices._();
  static final StripeServices instance = StripeServices._();

  Future<bool> makePayment(int amount, String currency) async {
    try {
      String? clientSecret = await _createPaymentIntent(amount, currency);
      if (clientSecret == null) return false;

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: "UEO App",
        ),
      );

      return await _displayPaymentSheet();
    } catch (e) {
      print("Error in makePayment: $e");
      return false;
    }
  }

  Future<bool> _displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      print("Payment successful");
      return true;
    } on StripeException catch (e) {
      print("Stripe Error: ${e.error.localizedMessage}");
      return false;
    } catch (e) {
      print("General Error: $e");
      return false;
    }
  }

  String _calculateAmount(int amount) {
    final calculatedAmount = amount * 100;
    return calculatedAmount.toString();
  }

  Future<String?> _createPaymentIntent(int amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        'amount': _calculateAmount(amount),
        'currency': currency,
      };

      String? stripeSecretKey = dotenv.env['stripeSecretKey'] ?? dotenv.env['stripeSecretkey'];

      if (stripeSecretKey == null || stripeSecretKey.isEmpty) {
        print("Error: stripeSecretKey not found in .env file");
        return null;
      }

      var response = await dio.post(
        "https://api.stripe.com/v1/payment_intents",
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            "Authorization": "Bearer $stripeSecretKey",
            "Content-Type": "application/x-www-form-urlencoded",
          },
        ),
      );

      if (response.data != null) {
        return response.data['client_secret'];
      }
      return null;
    } catch (e) {
      print("Error creating Payment Intent: $e");
    }
    return null;
  }
}
