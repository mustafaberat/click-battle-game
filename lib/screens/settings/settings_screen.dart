import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/screens/game/game_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue[900],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[900]!,
              Colors.blue[600]!,
            ],
          ),
        ),
        child: Consumer<GameSettings>(
          builder: (context, settings, child) {
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildSwitchTile(
                  title: 'Sound Effects',
                  value: settings.isSoundEnabled,
                  onChanged: (value) => settings.toggleSound(),
                  icon: Icons.volume_up,
                ),
                _buildSwitchTile(
                  title: 'Background Music',
                  value: settings.isMusicEnabled,
                  onChanged: (value) => settings.toggleMusic(),
                  icon: Icons.music_note,
                ),
                _buildSwitchTile(
                  title: 'Vibration',
                  value: settings.isVibrationEnabled,
                  onChanged: (value) => settings.toggleVibration(),
                  icon: Icons.vibration,
                ),
                const SizedBox(height: 20),
                _buildVolumeSlider(settings),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.green,
        ),
      ),
    );
  }

  Widget _buildVolumeSlider(GameSettings settings) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.volume_up,
                color: Colors.white,
              ),
              const SizedBox(width: 16),
              const Text(
                'Volume',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          Slider(
            value: settings.volume,
            onChanged: settings.setVolume,
            activeColor: Colors.green,
            inactiveColor: Colors.white.withOpacity(0.3),
          ),
        ],
      ),
    );
  }
} 