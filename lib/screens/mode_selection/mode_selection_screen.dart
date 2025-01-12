import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/screens/game/game_styles.dart';

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
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Game Mode',
          style: AppTextStyles.heading(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: AppDecorations.gradientBackground,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.padding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Player Mode Selection
                Text(
                  'Select Players',
                  style: AppTextStyles.heading(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spacing(context)),
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
                    SizedBox(width: AppDimensions.spacing(context)),
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
                SizedBox(height: AppDimensions.spacing(context) * 1.5),

                // Game Mode Selection
                Text(
                  'Select Game Mode',
                  style: AppTextStyles.heading(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spacing(context)),
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
                    SizedBox(width: AppDimensions.spacing(context)),
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
                SizedBox(height: AppDimensions.spacing(context) * 1.5),

                // Limit Selection
                Text(
                  selectedMode == GameMode.timeLimit
                      ? 'Select Time Limit'
                      : 'Select Score Target',
                  style: AppTextStyles.heading(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: AppDimensions.spacing(context)),
                Wrap(
                  spacing: AppDimensions.spacing(context) * 0.5,
                  runSpacing: AppDimensions.spacing(context) * 0.5,
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
                  SizedBox(height: AppDimensions.spacing(context) * 1.5),
                  Text(
                    'Select Difficulty',
                    style: AppTextStyles.heading(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: AppDimensions.spacing(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLimitButton(
                        'Easy',
                        selectedDifficulty == 1,
                        () => setState(() => selectedDifficulty = 1),
                      ),
                      SizedBox(width: AppDimensions.spacing(context) * 0.5),
                      _buildLimitButton(
                        'Normal',
                        selectedDifficulty == 2,
                        () => setState(() => selectedDifficulty = 2),
                      ),
                      SizedBox(width: AppDimensions.spacing(context) * 0.5),
                      _buildLimitButton(
                        'Hard',
                        selectedDifficulty == 3,
                        () => setState(() => selectedDifficulty = 3),
                      ),
                    ],
                  ),
                ],

                SizedBox(height: AppDimensions.spacing(context) * 2),

                // Start Button
                SizedBox(
                  height: AppDimensions.buttonHeight(context),
                  child: ElevatedButton(
                    onPressed: _startGame,
                    style: GameStyles.buttonStyle(context),
                    child: Text(
                      'Start Game',
                      style: AppTextStyles.button(context),
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.spacing(context)),
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
    final screenSize = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: AppDimensions.padding(context)),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [AppColors.accent, AppColors.accent.withOpacity(0.8)]
                : [Colors.white24, Colors.white10],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: AppDimensions.borderRadius(context) * 0.5,
                    spreadRadius: AppDimensions.borderRadius(context) * 0.1,
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
              size: screenSize.width * 0.08,
            ),
            SizedBox(height: AppDimensions.spacing(context) * 0.5),
            Text(
              text,
              style: AppTextStyles.button(context),
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
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.padding(context) * 1.5,
          vertical: AppDimensions.padding(context) * 0.75,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [AppColors.accent, AppColors.accent.withOpacity(0.8)]
                : [Colors.white24, Colors.white10],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: AppDimensions.borderRadius(context) * 0.5,
                    spreadRadius: AppDimensions.borderRadius(context) * 0.1,
                  )
                ]
              : [],
        ),
        child: Text(
          text,
          style: AppTextStyles.button(context),
        ),
      ),
    );
  }
} 