import 'package:flutter/material.dart';
import 'package:clickbattle/styles/app_styles.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> with SingleTickerProviderStateMixin {
  bool isSinglePlayer = true;
  bool isTimeMode = true;
  int timeLimit = 10;
  int scoreLimit = 10;
  int difficulty = 1;
  bool _isStartHovered = false;

  final List<int> timeLimits = [10, 30, 60];
  final List<int> scoreLimits = [10, 50, 100];
  final List<Map<String, dynamic>> difficulties = [
    {'name': 'Easy', 'value': 1, 'icon': Icons.star_border_rounded},
    {'name': 'Normal', 'value': 3, 'icon': Icons.star_half_rounded},
    {'name': 'Hard', 'value': 9, 'icon': Icons.star_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppDimensions.padding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Back Button and Title
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    'Game Setup',
                    style: AppTextStyles.heading(context).copyWith(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(width: 48), // Balance for back button
                ],
              ),
              SizedBox(height: AppDimensions.spacing(context) * 3),

              // Player Mode Selection
              Container(
                width: screenSize.width * 0.9,
                padding: EdgeInsets.all(AppDimensions.padding(context)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Choose Players',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing(context)),
                    Row(
                      children: [
                        _buildModeButton(
                          text: 'Single Player',
                          icon: Icons.person_outline_rounded,
                          secondaryIcon: Icons.smart_toy_outlined,
                          isSelected: isSinglePlayer,
                          onTap: () => setState(() => isSinglePlayer = true),
                          color: Colors.blue[400]!,
                        ),
                        SizedBox(width: AppDimensions.spacing(context)),
                        _buildModeButton(
                          text: 'Two Players',
                          icon: Icons.person_outline_rounded,
                          secondaryIcon: Icons.person_outline_rounded,
                          isSelected: !isSinglePlayer,
                          onTap: () => setState(() => isSinglePlayer = false),
                          color: Colors.red[400]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spacing(context) * 2),

              // Game Mode Selection
              Container(
                width: screenSize.width * 0.9,
                padding: EdgeInsets.all(AppDimensions.padding(context)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      'Choose Mode',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing(context)),
                    Row(
                      children: [
                        _buildModeButton(
                          text: 'Time Mode',
                          icon: Icons.timer,
                          isSelected: isTimeMode,
                          onTap: () => setState(() => isTimeMode = true),
                          color: Colors.orange[400]!,
                        ),
                        SizedBox(width: AppDimensions.spacing(context)),
                        _buildModeButton(
                          text: 'Score Mode',
                          icon: Icons.score,
                          isSelected: !isTimeMode,
                          onTap: () => setState(() => isTimeMode = false),
                          color: Colors.green[400]!,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spacing(context) * 2),

              // Limit Selection
              Container(
                width: screenSize.width * 0.9,
                padding: EdgeInsets.all(AppDimensions.padding(context)),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    Text(
                      isTimeMode ? 'Time Limit' : 'Score Target',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppDimensions.spacing(context)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          color: isTimeMode ? Colors.orange[400]! : Colors.green[400]!,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDimensions.spacing(context) * 2),

              // Difficulty Selection (Single Player Only)
              if (isSinglePlayer)
                Container(
                  width: screenSize.width * 0.9,
                  padding: EdgeInsets.all(AppDimensions.padding(context)),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Difficulty',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: AppDimensions.spacing(context)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: difficulties.map((diff) {
                          final Color diffColor = diff['value'] == 1 
                              ? Colors.green[400]! 
                              : diff['value'] == 3 
                                  ? Colors.orange[400]! 
                                  : Colors.red[400]!;
                          return _buildDifficultyButton(
                            text: diff['name'],
                            icon: diff['icon'],
                            isSelected: difficulty == diff['value'],
                            onTap: () => setState(() => difficulty = diff['value']),
                            color: diffColor,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: AppDimensions.spacing(context) * 3),
              
              // Start Game Button
              MouseRegion(
                onEnter: (_) => setState(() => _isStartHovered = true),
                onExit: (_) => setState(() => _isStartHovered = false),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.identity()
                    ..scale(_isStartHovered ? 1.05 : 1.0),
                  child: SizedBox(
                    height: 70,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.resolveWith<Color>(
                          (states) => _isStartHovered ? Colors.blue[500]! : Colors.blue[400]!,
                        ),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        elevation: MaterialStateProperty.all(_isStartHovered ? 12 : 6),
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                          SizedBox(width: 16),
                          Text(
                            'START BATTLE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeButton({
    required String text,
    required IconData icon,
    IconData? secondaryIcon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? color : Colors.white10,
              borderRadius: BorderRadius.circular(15),
              boxShadow: isSelected ? [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ] : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (secondaryIcon != null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        icon,
                        color: Colors.white,
                        size: 24,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 2,
                        height: 20,
                        color: Colors.white38,
                      ),
                      Icon(
                        secondaryIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  )
                else
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 32,
                  ),
                SizedBox(height: 8),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLimitButton({
    required String text,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white10,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.5) : Colors.white24,
              width: 2,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : [],
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyButton({
    required String text,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white10,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? color.withOpacity(0.5) : Colors.white24,
              width: 2,
            ),
            boxShadow: isSelected ? [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ] : [],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.amber : Colors.white70,
                size: 28,
              ),
              SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 