import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutView extends StatelessWidget {
  const AboutView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tentang Aplikasi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Header Simple
            const Icon(Icons.apps, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 16),
            Text(
              'Flutter Learning Hub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Portofolio Aplikasi Flutter',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Quick Overview - SIMPLE
            _buildFeatureCard(
              icon: Icons.countertops,
              title: 'Counter App',
              description: 'State Management dengan BLoC',
              isDarkMode: isDarkMode,
            ),
            _buildFeatureCard(
              icon: Icons.checklist,
              title: 'Todo App', 
              description: 'CRUD Operations + Hive DB',
              isDarkMode: isDarkMode,
            ),
            _buildFeatureCard(
              icon: Icons.newspaper,
              title: 'News App',
              description: 'API Integration + Bookmark',
              isDarkMode: isDarkMode,
            ),
            _buildFeatureCard(
              icon: Icons.cloud,
              title: 'Weather App',
              description: 'Real-time Data + Geolocation',
              isDarkMode: isDarkMode,
            ),
            
            const SizedBox(height: 30),
            
            // Tech Stack - SIMPLE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Teknologi yang Digunakan',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildTechChip('Flutter', isDarkMode),
                      _buildTechChip('Dart', isDarkMode),
                      _buildTechChip('BLoC', isDarkMode),
                      _buildTechChip('Hive', isDarkMode),
                      _buildTechChip('REST API', isDarkMode),
                      _buildTechChip('Dio', isDarkMode),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Call to Action - PENTING!
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.deepPurple[800]!.withOpacity(0.3) : Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    'Ingin Lihat Kode Sumber?',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Kunjungi repository GitHub untuk dokumentasi lengkap dan source code',
                    style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _launchURL('https://github.com/username/repository'),
                    icon: const Icon(Icons.code),
                    label: const Text('View on GitHub'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Simple Footer
            Text(
              'Dibuat dengan Flutter 💙',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Untuk Tujuan Pembelajaran',
              style: TextStyle(
                color: isDarkMode ? Colors.grey[500] : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required bool isDarkMode,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepPurple),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          description,
          style: TextStyle(
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildTechChip(String tech, bool isDarkMode) {
    return Chip(
      label: Text(tech),
      backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
      labelStyle: TextStyle(
        color: isDarkMode ? Colors.white : Colors.black87,
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}