import 'package:flutter/material.dart';
import 'package:clickbattle/components/arcade_chrome.dart';

/// Full-screen pause card. Swallows every tap so the match underneath
/// cannot score while it is open.
class PauseOverlay extends StatelessWidget {
  final String title;
  final String resumeLabel;
  final String restartLabel;
  final String quitLabel;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onQuit;

  const PauseOverlay({
    Key? key,
    required this.title,
    required this.resumeLabel,
    required this.restartLabel,
    required this.quitLabel,
    required this.onResume,
    required this.onRestart,
    required this.onQuit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: const Key('pauseOverlay'),
      behavior: HitTestBehavior.opaque,
      onTap: () {},
      child: ColoredBox(
        color: Colors.black.withOpacity(0.72),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: DecoratedBox(
                decoration: ArcadeChrome.panelBox(accent: ArcadeChrome.yellow),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 22, 18, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: ArcadeChrome.display(
                          size: 48,
                          color: ArcadeChrome.yellow,
                          outline: ArcadeChrome.ink,
                          outlineWidth: 3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ComicButton(
                        key: const Key('pauseResume'),
                        onPressed: onResume,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.play_arrow_rounded,
                              size: 26,
                              color: Colors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(resumeLabel.toUpperCase()),
                          ],
                        ),
                      ),
                      ComicButton(
                        key: const Key('pauseRestart'),
                        color: ArcadeChrome.blue,
                        foregroundColor: Colors.white,
                        height: 52,
                        onPressed: onRestart,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.replay_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(restartLabel.toUpperCase()),
                          ],
                        ),
                      ),
                      ComicButton(
                        key: const Key('pauseQuit'),
                        color: ArcadeChrome.panel,
                        foregroundColor: Colors.white,
                        height: 52,
                        onPressed: onQuit,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.logout_rounded,
                              size: 22,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 8),
                            Text(quitLabel.toUpperCase()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small corner control. Only the disc is tappable; the rest of the
/// screen falls through to the arenas.
class PauseMatchButton extends StatelessWidget {
  final VoidCallback onPressed;

  const PauseMatchButton({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 10, top: 6),
          child: GestureDetector(
            key: const Key('pauseButton'),
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ArcadeChrome.yellow,
                border: Border.all(color: ArcadeChrome.ink, width: 3),
                boxShadow: const [
                  BoxShadow(
                    color: ArcadeChrome.ink,
                    offset: Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.pause_rounded,
                color: Colors.black,
                size: 28,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
