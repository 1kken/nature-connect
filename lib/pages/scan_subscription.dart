import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class ScanSubscription extends StatefulWidget {
  const ScanSubscription({super.key});

  @override
  _ScanSubscriptionState createState() => _ScanSubscriptionState();
}

class _ScanSubscriptionState extends State<ScanSubscription> {
  String? selectedPlan;
  double planAmount = 0;
  DateTime endDate = DateTime.now().add(Duration(days: 30));

  @override
  Widget build(BuildContext context) {
    // Set up date information
    final currentDate = DateTime.now();
    final dateFormat = DateFormat('yyyy-MM-dd');

    return Scaffold(
      body: Container(
        color: Colors.white, // Set the body background color to white
        child: Stack(
          children: [
            Column(
              children: [
                // Logo at the center top
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo.png', // Replace with your logo path
                      width: 150,
                      height: 150,
                    ),
                  ),
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    width: double
                        .infinity, // Make the card fill the screen's width
                    padding: const EdgeInsets.symmetric(
                        vertical: 40.0, horizontal: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "With NatureScan you can take a picture of over a thousand plant and animal species, giving you their information!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 20),
                        // Scrollable container for subscription plan cards
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              subscriptionPlanCard('Monthly', 99, 30),
                              SizedBox(width: 10),
                              subscriptionPlanCard('2 Months', 149, 60),
                              SizedBox(width: 10),
                              subscriptionPlanCard('Semi-annual', 249, 180),
                              SizedBox(width: 10),
                              subscriptionPlanCard('Annual', 349, 365),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        // Subscription details
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Amount:"),
                            Text("Php ${planAmount.toStringAsFixed(2)}"),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Begins:"),
                            Text(dateFormat.format(currentDate)),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Ends:"),
                            Text(dateFormat.format(endDate)),
                          ],
                        ),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Cancel Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor:
                                    Colors.white, // Set text color to white
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () {
                                // Debug print for cancel button
                                context.go('/home');
                              },
                              child: Text("Cancel"),
                            ),
                            // Subscribe Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor:
                                    Colors.white, // Set text color to white
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              // Modify the "Subscribe" button onPressed method
                              onPressed: () {
                                if (selectedPlan != null) {
                                  // Prepare the data
                                  final Map<String, dynamic> checkoutData = {
                                    'isSubscription': true,
                                    'subscriptionType': 'Scan', // You can change this if needed
                                    'plan': selectedPlan,
                                    'cost': planAmount,
                                  };

                                  // Navigate to the '/checkout' route and pass data
                                  context.go(
                                    '/checkout', // Path to the checkout page
                                   
                                    extra:
                                        checkoutData, // Passing the complex data as 'extra'
                                  );
                                } else {
                                  // Show a message if no plan is selected
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Please select a subscription plan.')),
                                  );
                                }
                              },

                              child: Text("Subscribe"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget subscriptionPlanCard(String planName, double price, int days) {
    bool isSelected = selectedPlan == planName;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPlan = planName;
          planAmount = price;
          endDate =
              DateTime.now().add(Duration(days: days)); // Update 'Ends' date
        });
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: isSelected
              ? BorderSide(color: Colors.green, width: 2)
              : BorderSide.none,
        ),
        child: Container(
          width: 90,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.green, spreadRadius: 2, blurRadius: 5)
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                planName,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                "Php $price",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
