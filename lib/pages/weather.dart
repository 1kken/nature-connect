import 'package:flutter/material.dart';
class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weather Page')),
      body: const Center(
          child: Center(
                      child: Text('Put here dets louie'),
                    )),
    );
  }
}
