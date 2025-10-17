import 'package:flutter/material.dart';
import 'logo_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Responsive sizes
  double _logoSize(BuildContext context) => (MediaQuery.of(context).size.width * 0.36).clamp(88.0, 220.0);

  @override
  Widget build(BuildContext context) {
    final logoSize = _logoSize(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 28),
              // Top-right small settings icon (placeholder)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.settings),
                  onPressed: () {
                    // Placeholder for Settings / Account page
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings coming soon')));
                  },
                ),
              ),

              const SizedBox(height: 8),
              // Logo
              Center(
                child: Hero(
                  tag: 'sprachio-logo',
                  child: AppLogo(size: logoSize),
                ),
              ),

              const SizedBox(height: 20),
              Text(
                'Sprachio',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Speak with a friendly AI. Start practicing German — then add more languages anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, height: 1.4),
              ),

              const Spacer(),

              // CTA
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.mic),
                  label: const Text('Start Practice'),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/practice');
                  },
                ),
              ),

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  child: const Text('Practice Settings'),
                  onPressed: () {
                    // small secondary action
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Practice settings not implemented yet')));
                  },
                ),
              ),

              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
