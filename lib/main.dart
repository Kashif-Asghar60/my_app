import 'dart:async';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:my_app/record_repo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final RecordRepo _recorder = RecordRepo();
  late AssetsAudioPlayer _music;
  late Timer _musicTimer;

  bool isRecording = false;
  bool isRecorded = false;
  bool isPlaying = false;

  @override
  void initState() {
    _recorder.openSession();
    _music = AssetsAudioPlayer.newPlayer();
    _playMusic();
    super.initState();
  }

  void _playMusic() async {
    await _music.open(Audio('assets/music/music.mp3'));
    _musicTimer = Timer(const Duration(seconds: 214), _playMusic);
    _music.setVolume(0.5);
  }

  void _record() {
    if (!isPlaying) {
      if (!isRecording) {
        isRecording = true;
        _recorder.record('audio');
      } else {
        isRecording = false;
        isRecorded = true;
        _recorder.stopRecord();
      }
    } else {
      _playAudio();
      _record();
    }
    setState(() {});
  }

  void _playAudio() {
    if (!isRecording) {
      if (!isPlaying) {
        isPlaying = true;
        _recorder.play(
          'audio',
          () {
            setState(() {
              isPlaying = false;
            });
          },
        );
      } else {
        isPlaying = false;
        _recorder.stopPlay();
      }
    } else {
      _record();
      _playAudio();
    }
    setState(() {});
  }

  @override
  void dispose() {
    _recorder.close();
    _music.dispose();
    _musicTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 75.0,
              height: 75.0,
              decoration: BoxDecoration(
                color: isRecording
                    ? const Color.fromRGBO(14, 74, 68, 1.0)
                    : const Color.fromRGBO(41, 150, 137, 1.0),
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(75.0),
                  onTap: _record,
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 50.0,
            ),
            Container(
              width: 75.0,
              height: 75.0,
              decoration: BoxDecoration(
                color: isPlaying
                    ? Colors.red
                    : isRecorded
                        ? const Color.fromRGBO(45, 160, 146, 1.0)
                        : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(75.0),
                  onTap: _playAudio,
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
