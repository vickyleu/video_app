import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'AppHomePage.dart';
import 'MyCupertinoControls.dart';

class AppHomePage2 extends StatefulWidget {
  VideoPlayerController controller =
      VideoPlayerController.network("http://www.bond520.com/js/bond.mp4")
        ..setVolume(1.0);
  ChewieController chewieController;
  int currentSeek = 0;
  @override
  State<StatefulWidget> createState() {
    if (chewieController == null) {
      chewieController = ChewieController(
          videoPlayerController: controller,
          autoPlay: false,
          looping: false,
          autoInitialize: true,
          startAt: Duration(milliseconds: currentSeek.toInt()),
          customControls: MyCupertinoControls(
            backgroundColor: Colors.transparent,
            iconColor: Colors.white,
            fullScreenFunction: () {
              chewieController?.enterFullScreen();
            },
          ),
          routePageBuilder: (BuildContext context, Animation<double> animation,
              Animation<double> secondAnimation, provider) {
            return AnimatedBuilder(
              animation: animation,
              builder: (BuildContext context, Widget child) {
                return VideoScaffold(
                  child: Scaffold(
                    resizeToAvoidBottomPadding: false,
                    body: Container(
                      alignment: Alignment.center,
                      color: Colors.black,
                      child: provider,
                    ),
                  ),
                );
              },
            );
          });
    }
    return _State();
  }
}

class _State extends State<AppHomePage2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: SafeArea(
                child: Container(
              child: Chewie(
                controller: widget.chewieController,
              ),
            )),
          )
        ],
      ),
    );
  }
}
