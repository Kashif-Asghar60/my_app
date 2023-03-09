import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordRepo {
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;

  String? _path;

  Future<void> openSession() async {
    Directory directory = await getApplicationDocumentsDirectory();
    _path = directory.path;

    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    _recorder!.openRecorder();
    _player!.openPlayer();

    await Permission.microphone.request();
    await Permission.storage.request();
    await Permission.manageExternalStorage.request();

    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
      AVAudioSessionCategoryOptions.allowBluetooth |
      AVAudioSessionCategoryOptions.defaultToSpeaker,
      avAudioSessionMode: AVAudioSessionMode.spokenAudio,
      avAudioSessionRouteSharingPolicy:
      AVAudioSessionRouteSharingPolicy.defaultPolicy,
      avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
      androidAudioAttributes: const AndroidAudioAttributes(
        contentType: AndroidAudioContentType.speech,
        flags: AndroidAudioFlags.none,
        usage: AndroidAudioUsage.voiceCommunication,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      androidWillPauseWhenDucked: true,
    ));

    await _recorder!.setSubscriptionDuration(
      const Duration(milliseconds: 20),
    );
    await _player!.setSubscriptionDuration(
      const Duration(milliseconds: 50),
    );
  }

  Future<void> close() async {
    _recorder!.closeRecorder();
    _recorder = null;
    _player!.closePlayer();
    _player = null;
  }

  void record(String name) async {
    String filepath = '$_path/$name.wav';

    _recorder!.startRecorder(
      toFile: filepath,
      codec: Codec.pcm16WAV,
    );
  }

  Future<void> stopRecord() async {
    await _recorder!.stopRecorder();
  }

  Future<void> play(String name, void Function() set) async {
    await _player!
        .startPlayer(fromURI: '$_path/$name.wav', whenFinished: set)
        .then((value) => set);
  }

  Future<void> stopPlay() async {
    await _player!.stopPlayer();
  }

}