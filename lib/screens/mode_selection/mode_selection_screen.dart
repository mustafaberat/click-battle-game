import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

enum GameMode { timeLimit, scoreLimit }
enum PlayerMode { singlePlayer, twoPlayer }

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  GameMode selectedMode = GameMode.timeLimit;
  PlayerMode selectedPlayerMode = PlayerMode.twoPlayer;
  int selectedTimeLimit = 10; // Default 60 seconds
  int selectedScoreLimit = 10; // Default 100 clicks
  int selectedDifficulty = 2; // Default normal difficulty (1=easy, 2=normal, 3=hard)

  final List<int> timeLimits = [10, 30, 60]; // in seconds
  final List<int> scoreLimits = [10, 50,100];

  void _startGame() {
    Navigator.pushNamed(
      context,
      '/game',
      arguments: {
        'mode': selectedMode.toString(),
        'playerMode': selectedPlayerMode.toString(),
        'timeLimit': selectedTimeLimit,
        'scoreLimit': selectedScoreLimit,
        'difficulty': selectedDifficulty,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Game Mode'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Player Mode Selection
                Text(
                  'Select Players',
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeButton(
                        'Single Player',
                        Icons.person,
                        isSelected: selectedPlayerMode == PlayerMode.singlePlayer,
                        onTap: () => setState(() => selectedPlayerMode = PlayerMode.singlePlayer),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildModeButton(
                        'Two Players',
                        Icons.people,
                        isSelected: selectedPlayerMode == PlayerMode.twoPlayer,
                        onTap: () => setState(() => selectedPlayerMode = PlayerMode.twoPlayer),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Game Mode Selection
                Text(
                  'Select Game Mode',
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildModeButton(
                        'Time Limit',
                        Icons.timer,
                        isSelected: selectedMode == GameMode.timeLimit,
                        onTap: () => setState(() => selectedMode = GameMode.timeLimit),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildModeButton(
                        'Score Limit',
                        Icons.score,
                        isSelected: selectedMode == GameMode.scoreLimit,
                        onTap: () => setState(() => selectedMode = GameMode.scoreLimit),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Limit Selection
                Text(
                  selectedMode == GameMode.timeLimit
                      ? 'Select Time Limit'
                      : 'Select Score Target',
                  style: AppTextStyles.heading,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: selectedMode == GameMode.timeLimit
                      ? timeLimits.map((time) => _buildLimitButton(
                          '${time}s',
                          time == selectedTimeLimit,
                          () => setState(() => selectedTimeLimit = time),
                        )).toList()
                      : scoreLimits.map((score) => _buildLimitButton(
                          score.toString(),
                          score == selectedScoreLimit,
                          () => setState(() => selectedScoreLimit = score),
                        )).toList(),
                ),

                // Difficulty Selection (Single Player Only)
                if (selectedPlayerMode == PlayerMode.singlePlayer) ...[
                  const SizedBox(height: 30),
                  Text(
                    'Select Difficulty',
                    style: AppTextStyles.heading,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLimitButton(
                        'Easy',
                        selectedDifficulty == 1,
                        () => setState(() => selectedDifficulty = 1),
                      ),
                      const SizedBox(width: 10),
                      _buildLimitButton(
                        'Normal',
                        selectedDifficulty == 2,
                        () => setState(() => selectedDifficulty = 2),
                      ),
                      const SizedBox(width: 10),
                      _buildLimitButton(
                        'Hard',
                        selectedDifficulty == 3,
                        () => setState(() => selectedDifficulty = 3),
                      ),
                    ],
                  ),
                ],

                const Spacer(),

                // Start Button
                ElevatedButton(
                  onPressed: _startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Start Game',
                    style: AppTextStyles.button,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton(String text, IconData icon, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [AppColors.accent, AppColors.accent.withOpacity(0.8)]
                : [Colors.white24, Colors.white10],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 32,
            ),
            const SizedBox(height: 10),
            Text(
              text,
              style: AppTextStyles.button,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLimitButton(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [AppColors.accent, AppColors.accent.withOpacity(0.8)]
                : [Colors.white24, Colors.white10],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Text(
          text,
          style: AppTextStyles.button.copyWith(
            fontSize: 18,
          ),
        ),
      ),
    );
  }
} 