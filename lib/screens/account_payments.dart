import 'package:flutter/material.dart';
// import 'package:flutter/foundation.dart';
import '../core/responsive_utils.dart';
import '../services/esewa_payment_service.dart';

/// Payment Screen with eSewa Integration
///
/// This screen provides a complete UI for handling payments in the Hostel Finder app.
/// Fully integrated with eSewa payment gateway for secure transactions.
///
/// Features:
/// - Real-time eSewa payment processing
/// - Transaction verification via eSewa API
/// - Comprehensive error handling
/// - Payment history and status tracking
///
/// Features:
/// - Payment summary dashboard
/// - Multiple payment types (Booking, Advance, Fine)
/// - Pending bookings display
/// - Secure eSewa payment integration
/// - Transaction verification
class AccountPaymentsScreen extends StatefulWidget {
  const AccountPaymentsScreen({super.key});

  @override
  State<AccountPaymentsScreen> createState() => _AccountPaymentsScreenState();
}

class _AccountPaymentsScreenState extends State<AccountPaymentsScreen> {
  bool _isLoading = false;
  String _selectedPaymentType = 'booking';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Sample booking data - in real app, this would come from your booking service
  final List<Map<String, dynamic>> _pendingBookings = [
    {
      'id': 'BK001',
      'hostelName': 'Sunrise Hostel',
      'amount': '2500',
      'dueDate': '2025-11-15',
      'status': 'pending'
    },
    {
      'id': 'BK002',
      'hostelName': 'Green Valley Hostel',
      'amount': '3000',
      'dueDate': '2025-11-20',
      'status': 'pending'
    },
  ];

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final responsive = ResponsiveUtils(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Payments',
          style: TextStyle(
            fontSize: responsive.getResponsiveFontSize(20),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(responsive.getResponsivePadding(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Summary Card
            _buildPaymentSummaryCard(theme, responsive),

            SizedBox(height: responsive.getResponsivePadding(24)),

            // Payment Type Selection
            _buildPaymentTypeSelector(theme, responsive),

            SizedBox(height: responsive.getResponsivePadding(24)),

            // Payment Form
            _buildPaymentForm(theme, responsive),

            SizedBox(height: responsive.getResponsivePadding(24)),

            // Pending Bookings
            if (_selectedPaymentType == 'booking') _buildPendingBookings(theme, responsive),

            SizedBox(height: responsive.getResponsivePadding(32)),

            // Pay Now Button
            _buildPayNowButton(theme, responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummaryCard(ThemeData theme, ResponsiveUtils responsive) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.getResponsiveBorderRadius(12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(responsive.getResponsivePadding(16)),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: theme.primaryColor,
                  size: responsive.getResponsiveIconSize(24),
                ),
                SizedBox(width: responsive.getResponsivePadding(12)),
                Text(
                  'Payment Summary',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.getResponsiveFontSize(18),
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.getResponsivePadding(16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Pending:',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: responsive.getResponsiveFontSize(16),
                  ),
                ),
                Text(
                  'Rs. 5,500',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: responsive.getResponsiveFontSize(18),
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive.getResponsivePadding(8)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This Month:',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: responsive.getResponsiveFontSize(14),
                  ),
                ),
                Text(
                  'Rs. 2,500',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: responsive.getResponsiveFontSize(14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelector(ThemeData theme, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Type',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: responsive.getResponsiveFontSize(16),
          ),
        ),
        SizedBox(height: responsive.getResponsivePadding(12)),
        Row(
          children: [
            _buildPaymentTypeChip('Booking', 'booking', theme, responsive),
            SizedBox(width: responsive.getResponsivePadding(12)),
            _buildPaymentTypeChip('Advance', 'advance', theme, responsive),
            SizedBox(width: responsive.getResponsivePadding(12)),
            _buildPaymentTypeChip('Fine', 'fine', theme, responsive),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentTypeChip(String label, String value, ThemeData theme, ResponsiveUtils responsive) {
    final isSelected = _selectedPaymentType == value;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : theme.primaryColor,
          fontSize: responsive.getResponsiveFontSize(14),
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedPaymentType = value;
        });
      },
      backgroundColor: theme.cardColor,
      selectedColor: theme.primaryColor,
      checkmarkColor: Colors.white,
    );
  }

  Widget _buildPaymentForm(ThemeData theme, ResponsiveUtils responsive) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive.getResponsiveBorderRadius(12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(responsive.getResponsivePadding(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: responsive.getResponsiveFontSize(16),
              ),
            ),
            SizedBox(height: responsive.getResponsivePadding(16)),

            // Amount Field
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Amount (NPR)',
                prefixIcon: Icon(
                  Icons.currency_rupee,
                  size: responsive.getResponsiveIconSize(20),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(responsive.getResponsiveBorderRadius(8)),
                ),
                hintText: 'Enter amount',
              ),
              style: TextStyle(fontSize: responsive.getResponsiveFontSize(16)),
            ),

            SizedBox(height: responsive.getResponsivePadding(16)),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(responsive.getResponsiveBorderRadius(8)),
                ),
                hintText: 'Payment description or notes',
              ),
              style: TextStyle(fontSize: responsive.getResponsiveFontSize(16)),
            ),

            SizedBox(height: responsive.getResponsivePadding(16)),

            // Payment Method Info
            Container(
              padding: EdgeInsets.all(responsive.getResponsivePadding(12)),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.getResponsiveBorderRadius(8)),
                border: Border.all(color: theme.primaryColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: theme.primaryColor,
                    size: responsive.getResponsiveIconSize(20),
                  ),
                  SizedBox(width: responsive.getResponsivePadding(12)),
                  Expanded(
                    child: Text(
                      'Secure payment powered by eSewa',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.primaryColor,
                        fontWeight: FontWeight.w500,
                        fontSize: responsive.getResponsiveFontSize(14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingBookings(ThemeData theme, ResponsiveUtils responsive) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pending Bookings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: responsive.getResponsiveFontSize(16),
          ),
        ),
        SizedBox(height: responsive.getResponsivePadding(12)),
        ..._pendingBookings.map((booking) => _buildBookingCard(booking, theme, responsive)),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, ThemeData theme, ResponsiveUtils responsive) {
    return Card(
      margin: EdgeInsets.only(bottom: responsive.getResponsivePadding(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.primaryColor.withOpacity(0.1),
          child: Icon(
            Icons.hotel,
            color: theme.primaryColor,
            size: responsive.getResponsiveIconSize(20),
          ),
        ),
        title: Text(
          booking['hostelName'],
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: responsive.getResponsiveFontSize(14),
          ),
        ),
        subtitle: Text(
          'Due: ${booking['dueDate']} • ID: ${booking['id']}',
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: responsive.getResponsiveFontSize(12),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Rs. ${booking['amount']}',
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: responsive.getResponsiveFontSize(14),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: responsive.getResponsivePadding(6),
                vertical: responsive.getResponsivePadding(2),
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(responsive.getResponsiveBorderRadius(4)),
              ),
              child: Text(
                'Pending',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: responsive.getResponsiveFontSize(10),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          setState(() {
            _amountController.text = booking['amount'];
            _descriptionController.text = 'Payment for ${booking['hostelName']} (Booking ID: ${booking['id']})';
          });
        },
      ),
    );
  }

  Widget _buildPayNowButton(ThemeData theme, ResponsiveUtils responsive) {
    return SizedBox(
      width: double.infinity,
      height: responsive.getResponsiveHeight(56),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handlePayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(responsive.getResponsiveBorderRadius(12)),
          ),
          elevation: 4,
        ),
        child: _isLoading
            ? SizedBox(
                height: responsive.getResponsiveHeight(24),
                width: responsive.getResponsiveHeight(24),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.payment,
                    size: responsive.getResponsiveIconSize(20),
                  ),
                  SizedBox(width: responsive.getResponsivePadding(8)),
                  Text(
                    'Pay with eSewa',
                    style: TextStyle(
                      fontSize: responsive.getResponsiveFontSize(16),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handlePayment() async {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = _amountController.text.trim();
    final description = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : 'Hostel payment';

    setState(() {
      _isLoading = true;
    });

    try {
      await EsewaPaymentService.initiatePayment(
        productId: 'PAY_${DateTime.now().millisecondsSinceEpoch}',
        productName: description,
        amount: amount,
        context: context,
        onSuccess: (result) {
          setState(() {
            _isLoading = false;
          });
          _showSuccessDialog(result);
        },
        onFailure: (error) {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog('Payment failed: $error');
        },
        onCancellation: (data) {
          setState(() {
            _isLoading = false;
          });
          _showErrorDialog('Payment was cancelled');
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error initiating payment: $e');
    }
  }

  void _showSuccessDialog(dynamic result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Successful'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your payment has been processed successfully!'),
            SizedBox(height: 8),
            Text(
              'Transaction ID: ${result?.refId ?? 'N/A'}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              'Amount: Rs. ${result?.totalAmount ?? 'N/A'}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            SizedBox(height: 4),
            Text(
              'Product: ${result?.productName ?? 'N/A'}',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Clear form
              _amountController.clear();
              _descriptionController.clear();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Payment Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}