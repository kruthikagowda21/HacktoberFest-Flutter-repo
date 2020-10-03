import 'package:ext_video_player/ext_video_player.dart';
import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/animated_list_view.dart';
import 'package:youtube_player_flutter/feature_discovery.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return FeatureDiscovery(
      child: MaterialApp(
        title: 'Youtube Video Player',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(

          primarySwatch: Colors.red,

          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        //home: MyHomePage(title: 'Youtube Video Player'),
        //home: FeatureDiscoveryPage(),
        home: AnimatedListViewPage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);


  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  VideoPlayerController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.network(
      'https://www.youtube.com/watch?v=YFCSODyFxbE',
    );

    _controller.addListener(() {
      setState(() {});
    });
    _controller.setLooping(true);
    _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(padding: const EdgeInsets.only(top: 20.0)),
            const Text('Video from Youtube',style: TextStyle(fontWeight: FontWeight.bold),),
            Container(
              padding: const EdgeInsets.all(20),
              child: AspectRatio(
                //aspectRatio: _controller.value.aspectRatio,
                aspectRatio:16 / 9,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    VideoPlayer(_controller),
                    ClosedCaption(text: _controller.value.caption.text),
                    _PlayPauseOverlay(controller: _controller),
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(playedColor: Colors.redAccent,bufferedColor: Colors.grey,),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class _PlayPauseOverlay extends StatelessWidget {
  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  final VideoPlayerController controller;

  showOverlay(BuildContext context) async {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Container(
        color: Colors.black54,
        child: Stack(
          children: <Widget>[
            Positioned(
              top: MediaQuery.of(context).size.height * 0.32,
              left: 30,
              child: MaterialButton(
                onPressed: () {
                  print('replay');
                  Duration replayDuration =
                      controller.value.position - Duration(seconds: 10);
                  controller.seekTo(replayDuration);
                },
                child: Icon(
                  Icons.replay_10,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.32,
              left: 160,
              child: AnimatedSwitcher(
                duration: Duration(milliseconds: 50),
                reverseDuration: Duration(milliseconds: 200),
                child: controller.value.isPlaying
                    ? MaterialButton(
                  onPressed: () {
                    controller.pause();
                  },
                  child: Center(
                    child: Icon(
                      Icons.pause,
                      color: Colors.white,
                      size: 50.0,
                    ),
                  ),
                )
                    : MaterialButton(
                  onPressed: () {
                    controller.value.isPlaying
                        ? controller.pause()
                        : controller.play();
                  },
                  child: Center(
                    child: Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 50.0,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.32,
              right: 30,
              child: MaterialButton(
                onPressed: () {
                  Duration forwardDuration =
                      controller.value.position + Duration(seconds: 10);
                  controller.seekTo(forwardDuration);
                },
                child: Icon(
                  Icons.forward_10,
                  size: 50,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    await Future.delayed(Duration(seconds: 3));

    overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //controller.value.isPlaying ? controller.pause() : controller.play();
        showOverlay(context);
      },
    );
  }
}