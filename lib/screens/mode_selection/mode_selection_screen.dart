import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:clickbattle/components/custom_scrollbar.dart';
import 'package:clickbattle/components/screen_head.dart';
import 'package:clickbattle/components/mode_option.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool isSinglePlayer = true; // default choice when app is opened
  bool isTimeMode = true;
  int timeLimit = 10;
  int scoreLimit = 10;
  int difficulty = 1;
  bool _isStartHovered = false;
  final ScrollController _scrollController = ScrollController();
  late AppManager _appManager;

  final List<int> timeLimits = [10, 30, 60];
  final List<int> scoreLimits = [10, 50, 100];
  final List<Map<String, dynamic>> difficulties = [
    {'name': 'Easy', 'value': 1, 'stars': 1},
    {'name': 'Normal', 'value': 6, 'stars': 2},
    {'name': 'Hard', 'value': 12, 'stars': 3},
  ];

  @override
  void initState() {
    super.initState();
    _appManager = Provider.of<AppManager>(context, listen: false);
  }

  Color _getDifficultyColor(int value) {
    switch (value) {
      case 1:
        return _appManager.scoreModeColor;
      case 6:
        return _appManager.timeModeColor;
      case 12:
        return _appManager.hardModeColor;
      default:
        return _appManager.primaryBlue;
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _appManager = Provider.of<AppManager>(context);

    return Scaffold(
      backgroundColor: _appManager.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            ScreenHead(
              title: _appManager.getText('gameSetup'),
              onBackPressed: () => Navigator.pop(context),
            ),

            // Content
            Expanded(
              child: CustomScrollbar(
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.paddingMedium),
                  children: [
                    _buildSection(
                      title: _appManager.getText('selectMode'),
                      subtitle: _appManager.getText('selectModeSubtitle'),
                      child: _buildOptionRow([
                        ModeOption(
                          text: _appManager.getText('singlePlayer'),
                          icon: Icons.smart_toy_outlined,
                          secondaryIcon: Icons.person_outline_rounded,
                          isSelected: isSinglePlayer,
                          onTap: () => setState(() => isSinglePlayer = true),
                          color: _appManager.player1Color,
                        ),
                        ModeOption(
                          text: _appManager.getText('twoPlayers'),
                          icon: Icons.person_outline_rounded,
                          secondaryIcon: Icons.person_outline_rounded,
                          isSelected: !isSinglePlayer,
                          onTap: () => setState(() => isSinglePlayer = false),
                          color: _appManager.player2Color,
                        ),
                      ]),
                    ),
                    _buildSection(
                      title: _appManager.getText('chooseMode'),
                      subtitle: _appManager.getText('chooseModeSubtitle'),
                      child: _buildOptionRow([
                        ModeOption(
                          text: _appManager.getText('timeAttack'),
                          icon: Icons.timer_outlined,
                          isSelected: isTimeMode,
                          onTap: () => setState(() => isTimeMode = true),
                          color: _appManager.timeModeColor,
                        ),
                        ModeOption(
                          text: _appManager.getText('survival'),
                          icon: Icons.flag_outlined,
                          isSelected: !isTimeMode,
                          onTap: () => setState(() => isTimeMode = false),
                          color: _appManager.scoreModeColor,
                        ),
                      ]),
                    ),
                    _buildSection(
                      title: isTimeMode
                          ? _appManager.getText('timeLimit')
                          : _appManager.getText('targetScore'),
                      subtitle: isTimeMode
                          ? _appManager.getText('timeLimitSubtitle')
                          : _appManager.getText('targetScoreSubtitle'),
                      child: _buildOptionRow(
                        (isTimeMode ? timeLimits : scoreLimits)
                            .map(
                              (value) => ModeOption(
                                text: isTimeMode
                                    ? _appManager.getText('seconds')
                                    : _appManager.getText('points'),
                                topText: value.toString(),
                                isSelected: isTimeMode
                                    ? timeLimit == value
                                    : scoreLimit == value,
                                onTap: () => setState(() {
                                  if (isTimeMode) {
                                    timeLimit = value;
                                  } else {
                                    scoreLimit = value;
                                  }
                                }),
                                color: isTimeMode
                                    ? _appManager.timeModeColor
                                    : _appManager.scoreModeColor,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    if (isSinglePlayer)
                      _buildSection(
                        title: _appManager.getText('difficulty'),
                        subtitle: _appManager.getText('difficultySubtitle'),
                        child: _buildOptionRow(
                          difficulties
                              .map(
                                (diff) => ModeOption(
                                  text: _appManager
                                      .getText(diff['name'].toLowerCase()),
                                  isSelected: difficulty == diff['value'],
                                  onTap: () => setState(
                                      () => difficulty = diff['value']),
                                  color: _getDifficultyColor(diff['value']),
                                  stars: diff['stars'],
                                ),
                              )
                              .toList(),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Start Button
            Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              child: _buildStartButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.paddingMedium / 1.5),
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: _appManager.cardBackgroundColor,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: _appManager.white,
              fontSize: AppDimensions.fontSizeMedium * 1.05,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: _appManager.white70,
              fontSize: AppDimensions.fontSizeSmall,
            ),
          ),
          SizedBox(height: AppDimensions.spacing(context) * 0.8),
          child,
        ],
      ),
    );
  }

  Widget _buildOptionRow(List<Widget> options) {
    return Row(
      children: List.generate(options.length * 2 - 1, (index) {
        if (index.isOdd) {
          return SizedBox(width: AppDimensions.spacing(context) * 0.5);
        }
        return Expanded(child: options[index ~/ 2]);
      }),
    );
  }

  Widget _buildStartButton() {
    Color buttonColor = _appManager.primaryBlue;

    return GestureDetector(
      onTap: () {
        final gameArgs = {
          'mode': isTimeMode ? 'GameMode.timeLimit' : 'GameMode.scoreLimit',
          'playerMode': isSinglePlayer
              ? 'PlayerMode.singlePlayer'
              : 'PlayerMode.twoPlayer',
          'timeLimit': timeLimit,
          'scoreLimit': scoreLimit,
          'difficulty': difficulty,
        };

        Navigator.pushNamed(
          context,
          '/game',
          arguments: gameArgs,
        );
      },
      onTapDown: (_) => setState(() => _isStartHovered = true),
      onTapUp: (_) => setState(() => _isStartHovered = false),
      onTapCancel: () => setState(() => _isStartHovered = false),
      child: Container(
        width: double.infinity,
        height: AppDimensions.buttonHeightLarge,
        decoration: BoxDecoration(
          color: buttonColor,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
          boxShadow: _isStartHovered
              ? []
              : [
                  BoxShadow(
                    color: buttonColor.withOpacity(0.4),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
          gradient: LinearGradient(
            colors: [
              buttonColor,
              buttonColor.withOpacity(0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: AnimatedScale(
          scale: _isStartHovered ? 0.98 : 1.0,
          duration: Duration(milliseconds: 150),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow_rounded,
                color: _appManager.white,
                size: AppDimensions.iconSizeLarge,
              ),
              SizedBox(width: AppDimensions.spacing(context) * 0.5),
              Text(
                _appManager.getText('startBattle').toUpperCase(),
                style: TextStyle(
                  color: _appManager.white,
                  fontSize: AppDimensions.fontSizeSmall,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
