import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/models/game_settings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Consumer<GameSettings>(
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
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildVolumeSlider(GameSettings settings) {
    return ListTile(
      leading: const Icon(Icons.volume_up),
      title: const Text('Volume'),
      subtitle: Slider(
        value: settings.volume,
        onChanged: settings.setVolume,
        min: 0.0,
        max: 1.0,
      ),
    );
  }
} 