import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nature_connect/custom_search_delegate.dart';
import 'package:nature_connect/custom_widgets/payment_popup.dart'; // Import the PaymentPopup widget

class CheckoutPage extends StatefulWidget {
  final Map<String, dynamic>
      checkoutData; // Map containing either subscription or product details

  CheckoutPage({
    required this.checkoutData, // Passing a map for both subscription or product
  });

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final TextEditingController _paymentInputController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  String _selectedPaymentMethod = 'Gcash';
  String? _paymentDetails;
  bool _isPopUpVisible = false;
  bool isLoading = false;

  void _showPaymentPopUp() {
    setState(() {
      _isPopUpVisible = true;
    });
  }

  void _closePopUp() {
    setState(() {
      _isPopUpVisible = false;
    });
  }

  void _onPaymentMethodChanged(String newMethod) {
    setState(() {
      _selectedPaymentMethod = newMethod;
    });
  }

  void _onAddPayment(String paymentDetails) {
    // Store the added payment details
    setState(() {
      _paymentDetails = paymentDetails;
    });
    _closePopUp();
  }

  // For product details
  List<Map<String, dynamic>> _getProductDetails(List<int> itemIds) {
    // Placeholder logic for product items
    return itemIds.map((id) {
      return {
        'name': 'Product $id',
        'price': 100,
        'quantity': 1,
      };
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
        title: Text('Checkout', textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Conditional Card for Subscription or Product
            if (widget.checkoutData['isSubscription'])
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/scan.png', // Replace with actual image
                        width: 50,
                        height: 50,
                      ),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.checkoutData['subscriptionType'],
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(widget.checkoutData['plan'],
                              style: TextStyle(fontSize: 14)),
                        ],
                      ),
                      Spacer(),
                      Text(
                        '\Php ${widget.checkoutData['cost']}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              )
            else
              // Product Checkout List
              ..._getProductDetails(widget.checkoutData['item_ids'])
                  .map((product) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/your_product_image.png', // Replace with actual product image
                          width: 50,
                          height: 50,
                        ),
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product['name'],
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                                '\Php ${product['price']} x ${product['quantity']}',
                                style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        Spacer(),
                        Text(
                          '\Php ${product['price'] * product['quantity']}',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),

            // Address Card for Products (Only for Products)
            if (!widget.checkoutData['isSubscription'])
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text('Shipping Address',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      TextField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: 'Enter your address',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Total Amount for Products (Only for Products)
            if (!widget.checkoutData['isSubscription'])
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Text('Total Amount',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Spacer(),
                      Text(
                        '₱${(_getProductDetails(widget.checkoutData['item_ids']).fold(0.0, (total, product) => total + (product['price'] * product['quantity']))).toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

            // Payment Method Card
            if (_paymentDetails == null)
              Card(
                child: ListTile(
                  title: Text('Payment Method'),
                  trailing: IconButton(
                    icon: Icon(Icons.add),
                    onPressed: _showPaymentPopUp,
                  ),
                ),
              )
            else
              // Show the payment details instead
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      // Icon for payment method
                      Icon(Icons.payment, color: Colors.green),
                      SizedBox(width: 16), // Space between icon and text

                      // Payment details section (Stacked vertically)
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Change Button
                            TextButton(
                              onPressed: _showPaymentPopUp,
                              child: Text('Change',
                                  style: TextStyle(color: Colors.blue)),
                            ),

                            // Payment Method Text
                            Text(
                              'Payment Method: $_selectedPaymentMethod',
                              style: TextStyle(fontSize: 16),
                            ),
                            SizedBox(
                                height:
                                    8), // Add space between method and details text

                            // Payment Details Text
                            Text(
                              'Payment Details: $_paymentDetails',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Pay Button
            Spacer(),
            if (isLoading) CircularProgressIndicator(),
            ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoading = true; // Start loading animation
                });

                // Delay for 1.5 seconds to show the loading animation
                await Future.delayed(Duration(seconds: 3));

                setState(() {
                  isLoading = false; // Stop loading animation
                });
                if (widget.checkoutData['isSubscription']) {
                  if (widget.checkoutData['subscriptionType'] == 'Scan') {
                    context.go('/cam_scanner');
                  }
                }
              },
              child: Text('Pay'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 50),
              ),
            ),
          ],
        ),
      ),
      bottomSheet: _isPopUpVisible
          ? PaymentPopup(
              selectedPaymentMethod: _selectedPaymentMethod,
              paymentInputController: _paymentInputController,
              onPaymentMethodChanged: _onPaymentMethodChanged,
              onAddPayment: _onAddPayment,
              onClosePopup: _closePopUp,
            )
          : null,
    );
  }
}
