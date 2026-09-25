import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/styles/app_styles.dart';
import 'package:clickbattle/services/app_manager.dart';
import 'package:clickbattle/components/custom_scrollbar.dart';
import 'package:clickbattle/components/arcade_chrome.dart';

class ModeSelectionScreen extends StatefulWidget {
  const ModeSelectionScreen({Key? key}) : super(key: key);

  @override
  State<ModeSelectionScreen> createState() => _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends State<ModeSelectionScreen> {
  bool isSinglePlayer = true;
  bool isTimeMode = true;
  int timeLimit = 10;
  int scoreLimit = 10;
  int difficulty = 5;
  final ScrollController _scrollController = ScrollController();
  late AppManager _appManager;

  final List<int> timeLimits = [10, 30, 60];
  final List<int> scoreLimits = [10, 50, 100];

  String get _difficultyLabel {
    if (difficulty <= 2) return _appManager.getText('easy');
    if (difficulty <= 5) return _appManager.getText('normal');
    if (difficulty <= 7) return _appManager.getText('hard');
    return 'INSANE';
  }

  @override
  void initState() {
    super.initState();
    _appManager = Provider.of<AppManager>(context, listen: false);
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            ArcadeBackHeader(
              title: _appManager.getText('gameSetup'),
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: CustomScrollbar(
                controller: _scrollController,
                child: ListView(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingMedium,
                  ),
                  children: [
                    _section(
                      title: _appManager.getText('selectMode'),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ChunkTile(
                              selected: isSinglePlayer,
                              color: ArcadeChrome.blue,
                              icon: Icons.smart_toy,
                              label: _appManager.getText('singlePlayer'),
                              onTap: () =>
                                  setState(() => isSinglePlayer = true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ChunkTile(
                              selected: !isSinglePlayer,
                              color: ArcadeChrome.red,
                              icon: Icons.people_alt,
                              label: _appManager.getText('twoPlayers'),
                              onTap: () =>
                                  setState(() => isSinglePlayer = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _section(
                      title: _appManager.getText('chooseMode'),
                      child: Row(
                        children: [
                          Expanded(
                            child: _ChunkTile(
                              selected: isTimeMode,
                              color: ArcadeChrome.yellow,
                              icon: Icons.timer,
                              label: _appManager.getText('timeAttack'),
                              darkLabel: true,
                              onTap: () => setState(() => isTimeMode = true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ChunkTile(
                              selected: !isTimeMode,
                              color: const Color(0xFF39FF14),
                              icon: Icons.flag,
                              label: _appManager.getText('survival'),
                              onTap: () => setState(() => isTimeMode = false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    _section(
                      title: isTimeMode
                          ? _appManager.getText('timeLimit')
                          : _appManager.getText('targetScore'),
                      child: Row(
                        children: (isTimeMode ? timeLimits : scoreLimits)
                            .map(
                              (v) => Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: _ChunkTile(
                                    selected: isTimeMode
                                        ? timeLimit == v
                                        : scoreLimit == v,
                                    color: isTimeMode
                                        ? ArcadeChrome.yellow
                                        : const Color(0xFF39FF14),
                                    topText: '$v',
                                    label: isTimeMode
                                        ? _appManager.getText('seconds')
                                        : _appManager.getText('points'),
                                    darkLabel: isTimeMode,
                                    onTap: () => setState(() {
                                      if (isTimeMode) {
                                        timeLimit = v;
                                      } else {
                                        scoreLimit = v;
                                      }
                                    }),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    if (isSinglePlayer)
                      _section(
                        title: _appManager.getText('difficulty'),
                        child: ArcadeDifficultyRail(
                          value: difficulty,
                          label: _difficultyLabel,
                          onChanged: (v) => setState(() => difficulty = v),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: _start,
                  style: ArcadeChrome.yellowButton().copyWith(
                    shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: Colors.black, width: 3),
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle, size: 26),
                  label: Text(
                    _appManager.getText('startBattle').toUpperCase(),
                    style: ArcadeChrome.ui(
                      size: 16,
                      color: Colors.black,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _start() {
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
  }

  Widget _section({required String title, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: ArcadeChrome.panelBox(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: ArcadeChrome.sectionLabel()),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _ChunkTile extends StatelessWidget {
  final bool selected;
  final Color color;
  final IconData? icon;
  final String label;
  final String? topText;
  final bool darkLabel;
  final VoidCallback onTap;

  const _ChunkTile({
    required this.selected,
    required this.color,
    this.icon,
    required this.label,
    this.topText,
    this.darkLabel = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? color : const Color(0xFF1A1A1A);
    final fg = selected
        ? (darkLabel ? Colors.black : Colors.white)
        : Colors.white70;

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? Colors.black : Colors.white12,
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (topText != null)
                Text(
                  topText!,
                  style: TextStyle(
                    color: fg,
                    fontWeight: FontWeight.w900,
                    fontSize: 22,
                  ),
                )
              else if (icon != null)
                Icon(icon, color: fg, size: 26),
              const SizedBox(height: 6),
              Text(
                label.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ArcadeChrome.ui(
                  color: fg,
                  size: 11,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
