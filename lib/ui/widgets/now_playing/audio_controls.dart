import 'package:app/main.dart';
import 'package:app/mixins/stream_subscriber.dart';
import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart' show CupertinoIcons;
import 'package:flutter/material.dart';

class AudioControls extends StatelessWidget {
  const AudioControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: () async => await audioHandler.skipToPrevious(),
            icon: const Icon(CupertinoIcons.backward_fill),
            iconSize: 52,
            tooltip: 'Previous',
          ),
          const SizedBox(width: 24),
          const PlayPauseButton(),
          const SizedBox(width: 24),
          IconButton(
            onPressed: audioHandler.skipToNext,
            icon: const Icon(CupertinoIcons.forward_fill),
            iconSize: 52,
            tooltip: 'Next',
          ),
        ],
      ),
    );
  }
}

class PlayPauseButton extends StatefulWidget {
  const PlayPauseButton({Key? key}) : super(key: key);

  @override
  _PlayPauseButtonState createState() => _PlayPauseButtonState();
}

class _PlayPauseButtonState extends State<PlayPauseButton>
    with StreamSubscriber {
  PlaybackState? _state;

  @override
  void initState() {
    super.initState();
    subscribe(audioHandler.playbackState.listen((PlaybackState value) {
      setState(() => _state = value);
    }));
  }

  @override
  void dispose() {
    unsubscribeAll();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    if (state == null) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        onPressed: audioHandler.playOrPause,
        icon: state.playing
            ? const Icon(CupertinoIcons.pause_solid)
            : const Icon(CupertinoIcons.play_fill),
        iconSize: 68,
        padding: const EdgeInsets.all(16),
        tooltip: state.playing ? 'Pause' : 'Play',
      ),
    );
  }
}
