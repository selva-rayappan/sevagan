import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import '../../models/service_request.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PaymentScreen extends StatefulWidget {
  final ServiceRequest job;

  const PaymentScreen({super.key, required this.job});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _razorpay = Razorpay();
  bool _isLoading = false;
  String? _paymentId; // Internal payment ID from backend

  @override
  void initState() {
    super.initState();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  Future<void> _initiatePayment() async {
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final apiService = ApiService();

      // 1. Create Order on Backend
      final paymentData = await apiService.createPayment(
        authProvider.token!,
        widget.job.id,
        'UPI', // Defaulting to UPI/Online for Razorpay
      );

      _paymentId = paymentData['id'];
      final orderId = paymentData['razorpayOrderId'];
      final amount = (widget.job.finalPrice! * 100).toInt(); // Amount in paise

      // 2. Open Razorpay Checkout
      var options = {
        'key': ApiConfig.razorpayKeyId,
        'amount': amount,
        'name': 'Sevagan Services',
        'description': 'Payment for ${widget.job.serviceCategory.nameEn}',
        'order_id': orderId,
        'prefill': {
          'contact': authProvider.user?.phone ?? '', 
          'email': authProvider.user?.email ?? 'customer@example.com'
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      _razorpay.open(options);

    } catch (e) {
      print('Error initiating payment: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to init payment: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final apiService = ApiService();

      await apiService.verifyPayment(
        authProvider.token!,
        _paymentId!,
        response.paymentId!,
        response.signature!,
      );

      if (mounted) {
        Fluttertoast.showToast(msg: "Payment Successful!");
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      print('Error verifying payment: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment verification failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    Fluttertoast.showToast(msg: "Payment Failed: ${response.message}");
    setState(() => _isLoading = false);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "External Wallet: ${response.walletName}");
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final amount = widget.job.finalPrice ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Total Amount to Pay', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(
                      '₹$amount',
                      style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                    ),
                    const Divider(height: 32),
                     Text('Service: ${widget.job.serviceCategory.nameEn}'),
                  ],
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _initiatePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('PAY NOW'),
            ),
          ],
        ),
      ),
    );
  }
}
