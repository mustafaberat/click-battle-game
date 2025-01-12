import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool isSinglePlayer = true;
  bool isTimeMode = true;
  int timeLimit = 10;
  int scoreLimit = 10;
  int difficulty = 1;

  final List<int> timeLimits = [10, 30, 60];
  final List<int> scoreLimits = [10, 50, 100];
  final List<Map<String, dynamic>> difficulties = [
    {'name': 'Easy', 'value': 1},
    {'name': 'Normal', 'value': 3},
    {'name': 'Hard', 'value': 9},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Game Mode',
          style: AppTextStyles.title(context),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.background,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.padding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Player Mode Selection
                _buildSectionHeader('Player Mode'),
                _buildModeToggle(
                  value: isSinglePlayer,
                  onChanged: (value) => setState(() => isSinglePlayer = value),
                  trueText: 'Single Player',
                  falseText: 'Two Players',
                  trueIcon: Icons.person,
                  falseIcon: Icons.people,
                ),

                // Game Mode Selection
                _buildSectionHeader('Game Mode'),
                _buildModeToggle(
                  value: isTimeMode,
                  onChanged: (value) => setState(() => isTimeMode = value),
                  trueText: 'Time Limit',
                  falseText: 'Score Limit',
                  trueIcon: Icons.timer,
                  falseIcon: Icons.score,
                ),

                // Limit Selection
                _buildSectionHeader(isTimeMode ? 'Time Limit' : 'Score Target'),
                Wrap(
                  spacing: AppDimensions.spacing(context),
                  runSpacing: AppDimensions.spacing(context),
                  alignment: WrapAlignment.center,
                  children: (isTimeMode ? timeLimits : scoreLimits).map((value) {
                    return _buildLimitButton(
                      text: isTimeMode ? '${value}s' : value.toString(),
                      isSelected: isTimeMode ? timeLimit == value : scoreLimit == value,
                      onTap: () => setState(() {
                        if (isTimeMode) {
                          timeLimit = value;
                        } else {
                          scoreLimit = value;
                        }
                      }),
                    );
                  }).toList(),
                ),

                // Difficulty Selection (Single Player Only)
                if (isSinglePlayer) ...[
                  _buildSectionHeader('Difficulty'),
                  Wrap(
                    spacing: AppDimensions.spacing(context),
                    runSpacing: AppDimensions.spacing(context),
                    alignment: WrapAlignment.center,
                    children: difficulties.map((diff) {
                      return _buildLimitButton(
                        text: diff['name'],
                        isSelected: difficulty == diff['value'],
                        onTap: () => setState(() => difficulty = diff['value']),
                      );
                    }).toList(),
                  ),
                ],

                SizedBox(height: AppDimensions.spacing(context) * 3),
                
                // Start Game Button
                SizedBox(
                  height: AppDimensions.buttonHeight(context),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        '/game',
                        arguments: {
                          'mode': isTimeMode ? 'GameMode.timeLimit' : 'GameMode.scoreLimit',
                          'playerMode': isSinglePlayer ? 'PlayerMode.singlePlayer' : 'PlayerMode.twoPlayer',
                          'timeLimit': timeLimit,
                          'scoreLimit': scoreLimit,
                          'difficulty': difficulty,
                        },
                      );
                    },
                    child: Text(
                      'Start Game',
                      style: AppTextStyles.button(context),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.padding(context),
        AppDimensions.padding(context) * 1.5,
        AppDimensions.padding(context),
        AppDimensions.padding(context) * 0.5,
      ),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.heading(context).copyWith(
          color: AppColors.accent,
          fontSize: AppDimensions.bodyFontSize(context),
        ),
      ),
    );
  }

  Widget _buildModeToggle({
    required bool value,
    required ValueChanged<bool> onChanged,
    required String trueText,
    required String falseText,
    required IconData trueIcon,
    required IconData falseIcon,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildModeButton(
            text: trueText,
            icon: trueIcon,
            isSelected: value,
            onTap: () => onChanged(true),
          ),
        ),
        SizedBox(width: AppDimensions.spacing(context)),
        Expanded(
          child: _buildModeButton(
            text: falseText,
            icon: falseIcon,
            isSelected: !value,
            onTap: () => onChanged(false),
          ),
        ),
      ],
    );
  }

  Widget _buildModeButton({
    required String text,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.accent : Colors.white24,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
        child: Padding(
          padding: EdgeInsets.all(AppDimensions.padding(context)),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: MediaQuery.of(context).size.width * 0.08,
              ),
              SizedBox(height: AppDimensions.spacing(context) * 0.5),
              Text(
                text,
                style: AppTextStyles.body(context),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLimitButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: isSelected ? AppColors.accent : Colors.white24,
      borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadius(context)),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.padding(context) * 1.5,
            vertical: AppDimensions.padding(context) * 0.75,
          ),
          child: Text(
            text,
            style: AppTextStyles.button(context),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
} 