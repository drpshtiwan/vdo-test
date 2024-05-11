import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:vdocipher_flutter/vdocipher_flutter.dart';

const EmbedInfo SAMPLE_1 = EmbedInfo.streaming(
    otp: '20160313versASE313BlEe9YKEaDuju5J0XcX2Z03Hrvm5rzKScvuyojMSBZBxfZ',
    playbackInfo: 'eyJ2aWRlb0lkIjoiM2YyOWI1NDM0YTVjNjE1Y2RhMThiMTZhNjIzMmZkNzUifQ==',
    embedInfoOptions: EmbedInfoOptions(
        autoplay: true
    )
);

const EmbedInfo SAMPLE_2 = EmbedInfo.streaming(
    otp: '20160313versASE313CBS0f0mkwrNqTswuCYx7Lo41GpQ3r06wbx2WgOUASrQIgH',
    playbackInfo: 'eyJ2aWRlb0lkIjoiYTllYWUwOTZjZDg4NGRiYmEzNTE1M2VlNDJhNTA0YTgifQ=='
);


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VdoCipher Sample Application',
      home: MyHome(),
      navigatorObservers: [VdoPlayerController.navigatorObserver('/player/(.*)')],
      theme: ThemeData(
          primaryColor: Colors.white,
          textTheme: TextTheme(bodyText1: TextStyle(fontSize: 12.0))),
    );
  }
}

class MyHome extends StatefulWidget {
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  String? _nativePlatformLibraryVersion = 'Unknown';

  @override
  void initState() {
    super.initState();
    getNativeLibraryVersion();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> getNativeLibraryVersion() async {
    String? version;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      version = await (Platform.isIOS ? VdocipherMethodChannel.nativeIOSAndroidLibraryVersion : VdocipherMethodChannel.nativeAndroidLibraryVersion);
    } on PlatformException {
      version = 'Failed to get native platform library version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _nativePlatformLibraryVersion = version;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('VdoCipher Sample Application'),
        ),
        body: Center(child: Column(
          children: <Widget>[
            Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: _goToVideoPlayback,
                    child: const Text('Online Playback',
                        style: TextStyle(fontSize: 20)),
                  ),
                  ElevatedButton(
                    onPressed: null,
                    child: const Text('Todo: video selection',
                        style: TextStyle(fontSize: 20)),
                  )
                ])),
            Padding(padding: EdgeInsets.all(16.0),
                child: Text('Native ${Platform.isIOS ? 'iOS' : 'Android'} library version: $_nativePlatformLibraryVersion',
                    style: TextStyle(color: Colors.grey, fontSize: 16.0)))
          ],
        ))
    );
  }

  void _goToVideoPlayback() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        settings: RouteSettings(name: '/player/sample/video'),
        builder: (BuildContext context) {
          return VdoPlaybackView();
        },
      ),
    );
  }
}

class VdoPlaybackView extends StatefulWidget {

  @override
  _VdoPlaybackViewState createState() => _VdoPlaybackViewState();
}

class _VdoPlaybackViewState extends State<VdoPlaybackView> {
  VdoPlayerController? _controller;
  final double aspectRatio = 16/9;
  ValueNotifier<bool> _isFullScreen = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Flexible(child: Container(
                child: VdoPlayer(
                  embedInfo: SAMPLE_1,
                  onPlayerCreated: (controller) => _onPlayerCreated(controller),
                  onFullscreenChange: _onFullscreenChange,
                  onError: _onVdoError,
                  controls: true, //optional, set false to disable player controls
                ),
                width: MediaQuery.of(context).size.width,
                height: _isFullScreen.value ? MediaQuery.of(context).size.height : _getHeightForWidth(MediaQuery.of(context).size.width),
              )),
              ValueListenableBuilder(
                  valueListenable: _isFullScreen,
                  builder: (context, dynamic value, child) {
                    return value ? SizedBox.shrink() : _nonFullScreenContent();
                  }),
            ])
    );
  }

  _onVdoError(VdoError vdoError)  {
    print("Oops, the system encountered a problem: " + vdoError.message);
  }

  _onPlayerCreated(VdoPlayerController? controller) {
    setState(() {
      _controller = controller;
      _onEventChange(_controller);
    });
  }

  _onEventChange(VdoPlayerController? controller) {
    controller!.addListener(() {
      VdoPlayerValue value = controller.value;

      print("VdoControllerListner"
          "\nloading: ${value.isLoading} "
          "\nplaying: ${value.isPlaying} "
          "\nbuffering: ${value.isBuffering} "
          "\nended: ${value.isEnded}"
      );
    });
  }

  _onFullscreenChange(isFullscreen) {
    setState(() {
      _isFullScreen.value = isFullscreen;
    });
  }

  _nonFullScreenContent() {
    return Column(
        children: [
          Text('Sample Playback', style: TextStyle(fontSize: 20.0),)
        ]);
  }

  double _getHeightForWidth(double width) {
    return width / aspectRatio;
  }
}