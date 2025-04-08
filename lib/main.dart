import 'package:flutter/material.dart';

void main() {
  runApp(const VedicAstrologyApp());
}

class VedicAstrologyApp extends StatelessWidget {
  const VedicAstrologyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vedic Astrology',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter', // Add later with font setup
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vedic Astrology'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Charts'),
            Tab(text: 'Dasha'),
            Tab(text: 'Strengths'),
            Tab(text: 'Transits'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          Center(child: Text('Rasi & Navamsa Charts')),
          Center(child: Text('Vimshottari Dasha')),
          Center(child: Text('Planetary Strengths')),
          Center(child: Text('Current Transits')),
        ],
      ),
    );
  }
}