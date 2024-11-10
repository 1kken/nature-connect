import 'package:flutter/material.dart';

class PaymentPopup extends StatelessWidget {
  final String selectedPaymentMethod;
  final TextEditingController paymentInputController;
  final Function(String) onPaymentMethodChanged;
  final Function(String) onAddPayment;
  final Function onClosePopup;

  PaymentPopup({
    required this.selectedPaymentMethod,
    required this.paymentInputController,
    required this.onPaymentMethodChanged,
    required this.onAddPayment,
    required this.onClosePopup,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      insetPadding: EdgeInsets.all(16),
      backgroundColor: Colors.white, // Default white background color
      child: Stack(
        children: [
          SingleChildScrollView( // Added to make the content scrollable
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButton<String>(
                    value: selectedPaymentMethod,
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        onPaymentMethodChanged(newValue);
                      }
                    },
                    items: <String>['Gcash', 'Maya', 'Credit Card', 'Bank']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: paymentInputController,
                    decoration: InputDecoration(labelText: 'Enter payment details'),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      onAddPayment(paymentInputController.text);
                    },
                    child: Text('Add'),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.red),
              onPressed: () {
                onClosePopup();
              },
            ),
          ),
        ],
      ),
    );
  }
}
