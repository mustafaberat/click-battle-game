import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:clickbattle/constants/app_colors.dart';
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
    return _appManager.getText('insane');
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
      backgroundColor: AppColors.comicNavy,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const HalftoneBackground(),
          SafeArea(
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
                        ComicPanel(
                          label: _appManager.getText('selectMode'),
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
                        ComicPanel(
                          label: _appManager.getText('chooseMode'),
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
                                  color: ArcadeChrome.red,
                                  icon: Icons.flag,
                                  label: _appManager.getText('survival'),
                                  onTap: () =>
                                      setState(() => isTimeMode = false),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ComicPanel(
                          label: isTimeMode
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
                                            : ArcadeChrome.red,
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
                          ComicPanel(
                            label: _appManager.getText('difficulty'),
                            child: ArcadeDifficultyRail(
                              value: difficulty,
                              label: _difficultyLabel,
                              easyLabel: _appManager.getText('easy'),
                              hardLabel: _appManager.getText('hard'),
                              onChanged: (v) => setState(() => difficulty = v),
                            ),
                          ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: ComicButton(
                    height: 58,
                    onPressed: _start,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LightningBolt(width: 18, height: 26),
                        const SizedBox(width: 10),
                        Text(
                          _appManager.getText('startBattle').toUpperCase(),
                          style: ArcadeChrome.ui(
                            size: 16,
                            color: Colors.black,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
}

class _ChunkTile extends StatefulWidget {
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
  State<_ChunkTile> createState() => _ChunkTileState();
}

class _ChunkTileState extends State<_ChunkTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop;

  @override
  void initState() {
    super.initState();
    _pop = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
  }

  @override
  void didUpdateWidget(covariant _ChunkTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      _pop.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bg = widget.selected ? widget.color : const Color(0xFF0A142E);
    final fg = widget.selected
        ? (widget.darkLabel ? Colors.black : Colors.white)
        : Colors.white70;

    final scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.92), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.06), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.06, end: 1.0), weight: 30),
    ]).animate(_pop);

    return ScaleTransition(
      scale: scale,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        child: Container(
          constraints: const BoxConstraints(minHeight: 78),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.selected ? ArcadeChrome.ink : Colors.white24,
              width: widget.selected ? 3 : 2,
            ),
            boxShadow: widget.selected
                ? const [
                    BoxShadow(
                      color: ArcadeChrome.ink,
                      offset: Offset(3, 3),
                      blurRadius: 0,
                    ),
                  ]
                : null,
          ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (widget.topText != null)
                  Text(
                    widget.topText!,
                    style: ArcadeChrome.display(size: 26, color: fg),
                  )
                else if (widget.icon != null)
                  Icon(widget.icon, color: fg, size: 26),
                const SizedBox(height: 6),
                Text(
                  widget.label.toUpperCase(),
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
