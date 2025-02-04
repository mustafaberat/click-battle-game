import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/localization_service.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  _ModeSelectionScreenState createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool isSinglePlayer = false;
  bool isTimeMode = true;
  int timeLimit = 10;
  int scoreLimit = 10;
  int difficulty = 1;
  bool _isStartHovered = false;

  final List<int> timeLimits = [10, 30, 60];
  final List<int> scoreLimits = [10, 50, 100];
  final List<Map<String, dynamic>> difficulties = [
    {'name': 'Easy', 'value': 1, 'icon': Icons.star_border_rounded},
    {'name': 'Normal', 'value': 6, 'icon': Icons.star_half_rounded},
    {'name': 'Hard', 'value': 12, 'icon': Icons.star_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new, color: AppColors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  Text(
                    localizationService.getText('gameSetup'),
                    style: AppTextStyles.heading(context),
                  ),
                  const Spacer(),
                  SizedBox(width: 48),
                ],
              ),
            ),

            // Content
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium),
                children: [
                  _buildSection(
                    title: localizationService.getText('selectMode'),
                    subtitle: localizationService.getText('selectModeSubtitle'),
                    child: _buildOptionRow([
                      _buildOption(
                        text: localizationService.getText('twoPlayers'),
                        icon: Icons.person_outline_rounded,
                        secondaryIcon: Icons.person_outline_rounded,
                        isSelected: !isSinglePlayer,
                        onTap: () => setState(() => isSinglePlayer = false),
                        color: AppColors.player2,
                      ),
                      _buildOption(
                        text: localizationService.getText('singlePlayer'),
                        icon: Icons.smart_toy_outlined,
                        secondaryIcon: Icons.person_outline_rounded,
                        isSelected: isSinglePlayer,
                        onTap: () => setState(() => isSinglePlayer = true),
                        color: AppColors.player1,
                      ),
                    ]),
                  ),
                  _buildSection(
                    title: localizationService.getText('chooseMode'),
                    subtitle: localizationService.getText('chooseModeSubtitle'),
                    child: _buildOptionRow([
                      _buildOption(
                        text: localizationService.getText('timeAttack'),
                        icon: Icons.timer_outlined,
                        isSelected: isTimeMode,
                        onTap: () => setState(() => isTimeMode = true),
                        color: AppColors.timeMode,
                      ),
                      _buildOption(
                        text: localizationService.getText('survival'),
                        icon: Icons.flag_outlined,
                        isSelected: !isTimeMode,
                        onTap: () => setState(() => isTimeMode = false),
                        color: AppColors.scoreMode,
                      ),
                    ]),
                  ),
                  _buildSection(
                    title: isTimeMode ? localizationService.getText('timeLimit') : localizationService.getText('targetScore'),
                    subtitle: isTimeMode
                        ? localizationService.getText('timeLimitSubtitle')
                        : localizationService.getText('targetScoreSubtitle'),
                    child: _buildOptionRow(
                      (isTimeMode ? timeLimits : scoreLimits)
                          .map(
                            (value) => _buildSmallOption(
                              text: isTimeMode 
                                ? '$value ${localizationService.getText('seconds')}' 
                                : '$value ${localizationService.getText('points')}',
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
                                  ? AppColors.timeMode
                                  : AppColors.scoreMode,
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  if (isSinglePlayer)
                    _buildSection(
                      title: localizationService.getText('difficulty'),
                      subtitle: localizationService.getText('difficultySubtitle'),
                      child: _buildOptionRow(
                        difficulties
                            .map(
                              (diff) => _buildSmallOption(
                                text: localizationService.getText(diff['name'].toLowerCase()),
                                icon: diff['icon'],
                                isSelected: difficulty == diff['value'],
                                onTap: () =>
                                    setState(() => difficulty = diff['value']),
                                color: diff['value'] == 1
                                    ? AppColors.accentGreen
                                    : diff['value'] == 3
                                        ? AppColors.timeMode
                                        : AppColors.player2,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),

            // Start Button
            Padding(
              padding: EdgeInsets.all(AppDimensions.paddingMedium),
              child: _buildStartButton(localizationService),
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
      margin: EdgeInsets.only(bottom: AppDimensions.paddingMedium),
      padding: EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.title(context)),
          SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.caption(context)),
          SizedBox(height: AppDimensions.paddingMedium),
          child,
        ],
      ),
    );
  }

  Widget _buildOptionRow(List<Widget> children) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: children,
    );
  }

  Widget _buildOption({
    required String text,
    required IconData icon,
    IconData? secondaryIcon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.38,
        height: 80,
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.white10,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.white24,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (secondaryIcon != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.white, size: 24),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 6),
                    height: 16,
                    width: 1,
                    color: AppColors.white38,
                  ),
                  Icon(secondaryIcon, color: AppColors.white, size: 24),
                ],
              )
            else
              Icon(icon, color: AppColors.white, size: 28),
            SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmallOption({
    required String text,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.22,
        height: 52,
        decoration: BoxDecoration(
          color: isSelected ? color : AppColors.white10,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.white24,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.white, size: 20),
              SizedBox(height: 6),
            ],
            Text(
              text,
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(LocalizationService localizationService) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/game',
          arguments: {
            'mode': isTimeMode ? 'GameMode.timeLimit' : 'GameMode.scoreLimit',
            'playerMode': isSinglePlayer
                ? 'PlayerMode.singlePlayer'
                : 'PlayerMode.twoPlayer',
            'timeLimit': timeLimit,
            'scoreLimit': scoreLimit,
            'difficulty': difficulty,
          },
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _isStartHovered = true),
        onExit: (_) => setState(() => _isStartHovered = false),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color:
                _isStartHovered ? AppColors.hoveredBlue : AppColors.primaryBlue,
            borderRadius:
                BorderRadius.circular(AppDimensions.borderRadiusLarge),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.play_arrow_rounded, color: AppColors.white, size: 26),
              SizedBox(width: 8),
              Text(
                localizationService.getText('startBattle'),
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
