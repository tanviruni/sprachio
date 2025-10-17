import 'package:flutter/material.dart';
import 'logo_widget.dart';

class GermanPracticeScreen extends StatelessWidget {
  const GermanPracticeScreen({super.key});

  Widget _placeholderCard(String title, String subtitle) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double logoSmall = (MediaQuery.of(context).size.width * 0.20).clamp(56.0, 110.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('German Practice'),
        leading: Navigator.canPop(context)
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop())
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 14.0),
          child: Column(
            children: [
              Row(
                children: [
                  AppLogo(size: logoSmall),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Deutsch — A1', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        SizedBox(height: 4),
                        Text('Practice speaking with short prompts. Gentle corrections.'),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              _placeholderCard('Quick Start', 'Tap and speak. The assistant will reply and give short corrections.'),
              const SizedBox(height: 12),
              _placeholderCard('Pronunciation', 'Get basic hints about sounds you can improve.'),
              const SizedBox(height: 12),
              _placeholderCard('Progress', 'Track minutes spoken and vocabulary practiced.'),

              const Spacer(),

              // Big record CTA placeholder
              ElevatedButton.icon(
                icon: const Icon(Icons.mic_none),
                label: const Text('Hold to Record (Task 2)'),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Recording will be implemented as Task 2')));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
