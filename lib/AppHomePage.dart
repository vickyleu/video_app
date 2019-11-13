import 'dart:io';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyrefresh/easy_refresh.dart';
import 'package:flutter_easyrefresh/material_footer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

import 'AnimatedButton.dart';
import 'MyCupertinoControls.dart';
import 'SpaceHeader.dart';
import 'flutter_export.dart';

class AppHomePage extends StatefulWidget {
  Widget childWidget;
  VideoPlayerController controller =
      VideoPlayerController.network("http://www.bond520.com/js/bond.mp4")
        ..setVolume(1.0);

  ChewieController chewieController;
  bool isFirst = true;
  double currentSeek = 0;
  TextEditingController _nameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();

  @override
  State<StatefulWidget> createState() {
    requestPermission();
    if (chewieController == null) {
      chewieController = ChewieController(
          videoPlayerController: controller,
//        aspectRatio: 3 / 2,
          autoPlay: false,
          looping: false,
          autoInitialize: true,
          startAt: Duration(milliseconds: currentSeek.toInt()),
          deviceOrientationsAfterFullScreen: () sync* {
            yield DeviceOrientation.portraitDown;
            if (Platform.isAndroid) {
              yield DeviceOrientation.landscapeLeft;
            } else {
              yield DeviceOrientation.landscapeRight;
            }
          }()
              .toList(),
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
    return HomeState();
  }

  Future requestPermission() async {
    if (Platform.isAndroid) {
      PermissionStatus permission = await PermissionHandler()
          .checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        Map<PermissionGroup, PermissionStatus> permissions =
            await PermissionHandler()
                .requestPermissions([PermissionGroup.storage]);
        permissions.forEach((g, s) {
          if (s != PermissionStatus.granted) {
            return;
          }
        });
      }
    }
  }
}

class HomeState extends State<AppHomePage> {
  double _scrollOffset = 0;
  VoidCallback _listen;

  bool scrollingInterrupt = false;

  @override
  void initState() {
    if (!widget.controller.hasListeners) {
      widget.controller.addListener(() {
        try {
          widget.controller.position.then((f) {
            widget.currentSeek = f.inMilliseconds.toDouble();
          });
        } catch (e) {}
      });
    }
    _scrollController.addListener(() {
      if (_listen == null && _scrollController.position != null) {
        _listen = () {
          final idle = !_scrollController.position.isScrollingNotifier.value;
          if (scrollingInterrupt) {
            if (idle) {
              if (!(widget.controller?.value?.isPlaying ?? false)) {
                setState(() {
                  widget.chewieController?.play();
                });
                scrollingInterrupt = false;
              }
            }
          } else {
            if (idle) {
            } else {
              if (widget.controller?.value?.isPlaying ?? false) {
                setState(() {
                  widget.chewieController?.pause();
                });
                scrollingInterrupt = true;
              }
            }
          }
        };
        _scrollController.position.isScrollingNotifier.addListener(_listen);
      }
      var of = _scrollController.offset;
      if (of < 0) of = 0;
      setState(() {
        _scrollOffset = of;
      });
    });
    refreshData();
    super.initState();

//    player.setDataSource("https://media.w3.org/2010/05/sintel/trailer.mp4",
//        autoPlay: true);
  }

  void refreshData() {}

  @override
  void dispose() {
    widget.chewieController?.pause();
    widget.controller?.pause();
    try {
      _scrollController?.position?.isScrollingNotifier?.dispose();
    } catch (e) {}
    _scrollController?.dispose();
    super.dispose();
  }

  ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    // 还可以添加autoplay参数,这样会在资源准备完成后自动播放
    final titleBarHeight =
        kToolbarHeight + (MediaQuery.of(context).padding.top);
    return Scaffold(
        body: Stack(
      children: <Widget>[
        buildRefreshController(context, () {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [0, 1, 2]
                .map((index) => new Container(
                      child: _buildItem(index),
                    ))
                .toList(),
          );
        }),
        Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Opacity(
                opacity: buildColorOrTransparent(),
                child: Container(
                  width: double.infinity,
                  color: Colors.transparent,
                  height: titleBarHeight,
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: kToolbarHeight,
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Container(),
                              ),
                              CupertinoButton(
                                  minSize: 0,
                                  padding: EdgeInsets.only(right: dp_width(10)),
                                  child: Text(
                                    '到邦德，更优秀',
                                    style: TextStyle(
                                      fontSize: sp2px(16),
                                      fontWeight: FontWeight.bold,
                                      color: Color(0XFF17BCE6),
                                    ),
                                  ),
                                  onPressed: () {
                                    ///没用的按钮
                                  })
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )))
      ],
    ));
  }

  Widget buildRefreshController(
      BuildContext context, Widget Function() childFunc) {
    final courseCellHeight = dp_width(128);
    return EasyRefresh.custom(
        firstRefresh: false,
        scrollController: _scrollController,
        header: SpaceHeader(),
        footer: MaterialFooter(enableInfiniteLoad: false),
        onLoad: () {
          return;
        },
        onRefresh: () {
          return;
        },
        slivers: <Widget>[
          buildSliverTopBox(context),
          buildSliverCenterBox(context, childFunc),
          SliverPadding(
            padding: EdgeInsets.only(top: dp_width(16)),
            sliver: SliverFixedExtentList(
              itemExtent: courseCellHeight + dp_width(15),
              delegate: SliverChildBuilderDelegate((itemContext, index) {
                var title = "123";
                return LayoutBuilder(builder: (c, cc) {
                  return Column(
                    children: <Widget>[
                      Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: dp_width(0), vertical: dp_width(7.5)),
                          child: ConstrainedBox(
                              constraints:
                                  BoxConstraints(minHeight: courseCellHeight),
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(dp_width(5)),
                                        boxShadow: [
                                          BoxShadow(
                                            offset: Offset(0, dp_width(4)),
                                            color: Color(0X26005580),
                                            spreadRadius: 0.1,
                                            blurRadius: dp_width(10),
                                          )
                                        ]),
                                    child: Padding(
                                      padding: EdgeInsets.all(dp_width(15)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Container(
                                            child: Text(
                                              title,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: sp2px(16),
                                                  color: Color(0XFF333333)),
                                            ),
                                          ),
                                          Flex(
                                            direction: Axis.horizontal,
                                            children: <Widget>[
                                              SizedBox(
                                                child: ImageIcon(AssetImage(
                                                    'assets/images/icon_location.png')),
                                                width: dp_width(15),
                                                height: dp_width(18),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                      left: dp_width(5)),
                                                  child: Text(
                                                    "456",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                        fontSize: sp2px(14),
                                                        color:
                                                            Color(0XFF666666)),
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                          Container(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: <Widget>[
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          dp_width(40)),
                                                  child: Container(
                                                    width: dp_width(40),
                                                    height: dp_width(40),
                                                    child: CachedNetworkImage(
                                                      imageUrl: "",
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      fit: BoxFit.contain,
                                                      placeholder: (c, s) =>
                                                          Image(
                                                        image: AssetImage(
                                                            'assets/images/img_avatar_default.png'),
                                                        width: double.infinity,
                                                        height: double.infinity,
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: Colors.white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    dp_width(
                                                                        40))),
                                                  ),
                                                ),
                                                Container(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: dp_width(10)),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: <Widget>[
                                                        Text(
                                                          "123",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  sp2px(14),
                                                              color: Color(
                                                                  0XFF666666)),
                                                        ),
                                                        Text(
                                                          "授课老师",
                                                          style: TextStyle(
                                                              fontSize:
                                                                  sp2px(12),
                                                              color: Color(
                                                                  0XFF999999)),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                Expanded(
                                                    child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: <Widget>[
                                                    Container(
                                                      alignment:
                                                          Alignment.centerRight,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: <Widget>[
                                                          Text(
                                                            '需参加入学测试',
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0XFFFF6666),
                                                                fontSize:
                                                                    sp2px(12)),
                                                          ),
                                                          Text(
                                                            "¥${4.56}",
                                                            style: TextStyle(
                                                                color: Color(
                                                                    0XFFFF6666),
                                                                fontSize:
                                                                    sp2px(24)),
                                                          )
                                                        ],
                                                      ),
                                                    )
                                                  ],
                                                ))
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              )))
                    ],
                  );
                });
              }, childCount: 6),
            ),
          )
        ]);
  }

  SliverToBoxAdapter buildSliverCenterBox(
      BuildContext context, Widget childFunc()) {
    if (centerBox == null) {
      centerBox = SliverToBoxAdapter(
        child: LayoutBuilder(
          builder: (c, cc) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                  minHeight: (MediaQuery.of(context).size.height)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Container(
                        width: MediaQuery.of(context).size.width,
                        child: Stack(
                          overflow: Overflow.clip,
                          children: <Widget>[
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  color: Colors.white,
                                  width: double.infinity,
                                  height: dp_width(256),
                                ),
                                Container(
                                  color: Colors.transparent,
                                  width: double.infinity,
                                  height: dp_width(5),
                                ),
                              ],
                            ),
                            Stack(
                              overflow: Overflow.visible,
                              children: <Widget>[
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      width: double.infinity,
                                      child: Padding(
                                        child: childFunc(),
                                        padding: EdgeInsets.only(
                                            top: dp_width(10),
                                            left: 0,
                                            right: 0),
                                      ),
                                    ),
                                    Stack(
                                      overflow: Overflow.visible,
                                      children: <Widget>[
                                        Container(
                                            height: dp_width(210),
                                            width: double.infinity,
                                            color: Colors.white,
                                            child: ListView.separated(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder:
                                                    (itemContext, index) {
                                                  return Padding(
                                                      padding: EdgeInsets.only(
                                                          left: index == 0
                                                              ? dp_width(10)
                                                              : dp_width(5),
                                                          right: index == 3 - 1
                                                              ? dp_width(10)
                                                              : dp_width(5)),
                                                      child: Container(
                                                        width: dp_width(180),
                                                        height: dp_width(170),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  bottom:
                                                                      dp_width(
                                                                          35),
                                                                  top: dp_width(
                                                                      20)),
                                                          child: Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              dp_width(5)),
                                                                  boxShadow: [
                                                                    BoxShadow(
                                                                      offset: Offset(
                                                                          0,
                                                                          dp_width(
                                                                              5)),
                                                                      color: Color(
                                                                              0X26005580)
                                                                          .withAlpha(
                                                                              30),
                                                                      spreadRadius:
                                                                          dp_width(
                                                                              8),
                                                                      blurRadius:
                                                                          dp_width(
                                                                              13.5),
                                                                    )
                                                                  ]),
                                                              child: ClipRRect(
                                                                child:
                                                                    CupertinoButton(
                                                                        minSize:
                                                                            0,
                                                                        padding:
                                                                            EdgeInsets
                                                                                .zero,
                                                                        child:
                                                                            Container(
                                                                          child:
                                                                              Image(
                                                                            width:
                                                                                double.infinity,
                                                                            height:
                                                                                double.infinity,
                                                                            image:
                                                                                AssetImage("assets/images/icon_cell_${index}.png"),
                                                                            fit:
                                                                                BoxFit.fill,
                                                                          ),
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          return;
                                                                        }),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            dp_width(5)),
                                                              )),
                                                        ),
                                                      ));
                                                },
                                                separatorBuilder:
                                                    (context, index) =>
                                                        Divider(),
                                                itemCount: 3)),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                          top: dp_width(10), left: 0, right: 0),
                                      child: Container(
                                        color: Colors.transparent,
                                        width: double.infinity,
                                        child: Container(
                                          width: double.infinity,
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: _bottomChildren(),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              ],
                            )
                          ],
                        )),
                    onTap: () {
                      FocusScope.of(context).requestFocus(FocusNode());
                    },
                  )
                ],
              ),
            );
          },
        ),
      );
    }
    return centerBox;
  }

  SliverToBoxAdapter topBox;
  SliverToBoxAdapter centerBox;

  SliverToBoxAdapter buildSliverTopBox(BuildContext context) {
    if (topBox == null) {
      topBox = SliverToBoxAdapter(
        child: Column(
          children: <Widget>[
            Container(
              height:
                  dp_width(238.0 + 17.0) + (MediaQuery.of(context).padding.top),
              child: Stack(
                children: <Widget>[
                  Container(
                    color: Colors.white,
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      children: <Widget>[
                        Container(
                          alignment: Alignment.topCenter,
                          height: dp_width(128) +
                              (MediaQuery.of(context).padding.top),
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [Color(0XFFF0FBFF), Color(0XFFDCEDF5)]),
                          ),
                        ),
                        Positioned(
                          child: Center(
                              widthFactor: 1,
                              child: Container(
                                height: dp_width(193),
                                width: dp_width(345),
                                decoration: BoxDecoration(
                                  color: Colors.black,
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 8),
                                      color: Colors.black.withOpacity(0.4),
                                      spreadRadius: 0.2,
                                      blurRadius: 15,
                                    )
                                  ],
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(dp_width(5))),
                                ),
                                child: ClipRRect(
                                  child: buildPlayer(),
                                  borderRadius:
                                      BorderRadius.circular(dp_width(5)),
                                ),
                              )),
                          bottom: dp_width(17),
                          left: 0,
                          right: 0,
                        )
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      );
    }
    return topBox;
  }

  double buildColorOrTransparent() {
    final offset = _scrollOffset;
    if (offset < dp_width(20)) {
      return 1 - offset / dp_width(20);
    }
    return 0;
  }

  List<Widget> _bottomChildren() {
    return <Widget>[
      Container(
        width: double.infinity,
        color: Colors.white,
        child: Padding(
            padding: EdgeInsets.only(
                left: dp_width(15),
                bottom: dp_width(15),
                top: dp_width(15),
                right: dp_width(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  height: dp_width(161),
                  child: Stack(
                    children: <Widget>[
                      Positioned(
                        child: Container(
                          height: dp_width(161),
                          width: double.infinity,
                          child: Stack(
                            alignment: Alignment.bottomCenter,
                            children: <Widget>[
                              CachedNetworkImage(
                                imageUrl: "",
                                placeholder: (c, s) => Image(
                                  image:
                                      AssetImage('assets/images/speak_bg.png'),
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                alignment: Alignment.bottomCenter,
                              )
                            ],
                          ),
                        ),
                        top: 0,
                        left: 0,
                        right: 0,
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: dp_width(10),
                          decoration: BoxDecoration(
                            color: Color(0XFFFFF7E6),
                          ),
                        ),
                      ),
                      Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Row(
                            children: <Widget>[
                              Container(
                                height: dp_width(12),
                                width: dp_width(4),
                                decoration: BoxDecoration(
                                    color: Color(0XFF17BCE6),
                                    borderRadius:
                                        BorderRadius.circular(dp_width(2))),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: dp_width(5)),
                                child: Text(
                                  '邦德更懂深圳学子',
                                  style: TextStyle(
                                      fontSize: sp2px(18),
                                      fontWeight: FontWeight.bold,
                                      color: Color(0XFF333333)),
                                ),
                              )
                            ],
                          ))
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                      color: Color(0XFFFFF7E6),
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(dp_width(5)),
                          bottomRight: Radius.circular(dp_width(5)))),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: dp_width(15), right: dp_width(15), top: 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                              top: dp_width(7.5), bottom: dp_width(7.5)),
                          child: Container(
                              height: dp_width(40),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: dp_width(0.5),
                                      color: Color(0XFF17BCE6)),
                                  borderRadius:
                                      BorderRadius.circular(dp_width(20))),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: dp_width(15)),
                                    child: RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: '*',
                                              style: TextStyle(
                                                color: Color(0XFFFF6666),
                                                fontSize: sp2px(15),
                                              )),
                                          TextSpan(
                                              text: '家长手机：',
                                              style: TextStyle(
                                                  fontSize: sp2px(15),
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0XFF666666))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Padding(
                                    padding:
                                        EdgeInsets.only(right: dp_width(12)),
                                    child: CupertinoTextField(
                                      controller: widget._phoneController,
                                      padding: EdgeInsets.zero,
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                      ),
                                      placeholder: "请输入手机号码",
                                      placeholderStyle: TextStyle(
                                        color: Color(0xFF999999),
                                        fontSize: sp2px(14),
                                        fontFamily: 'Brutal',
                                      ),
                                      maxLength: 11,
                                      maxLengthEnforced: true,
                                      maxLines: 1,
                                      keyboardAppearance: Brightness.light,
                                      keyboardType: TextInputType.phone,
                                      style: TextStyle(fontSize: sp2px(15)),
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ))
                                ],
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: dp_width(7.5), bottom: dp_width(7.5)),
                          child: Container(
                            height: dp_width(40),
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                    width: dp_width(0.5),
                                    color: Color(0XFF17BCE6)),
                                borderRadius:
                                    BorderRadius.circular(dp_width(20))),
                            child: Row(
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: dp_width(15)),
                                  child: RichText(
                                    text: TextSpan(
                                      children: <TextSpan>[
                                        TextSpan(
                                            text: '*',
                                            style: TextStyle(
                                              color: Color(0XFFFF6666),
                                              fontSize: sp2px(15),
                                            )),
                                        TextSpan(
                                            text: '学生姓名：',
                                            style: TextStyle(
                                                fontSize: sp2px(15),
                                                fontWeight: FontWeight.w500,
                                                color: Color(0XFF666666))),
                                      ],
                                    ),
                                  ),
                                ),
                                Expanded(
                                    child: Padding(
                                  padding: EdgeInsets.only(right: dp_width(12)),
                                  child: CupertinoTextField(
                                    controller: widget._nameController,
                                    maxLength: 5,
                                    maxLengthEnforced: true,
                                    keyboardAppearance: Brightness.light,
                                    maxLines: 1,
                                    padding: EdgeInsets.zero,
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                    ),
                                    placeholder: "请输入姓名",
                                    placeholderStyle: TextStyle(
                                      color: Color(0xFF999999),
                                      fontSize: sp2px(14),
                                      fontFamily: 'Brutal',
                                    ),
                                    style: TextStyle(fontSize: sp2px(15)),
                                    keyboardType: TextInputType.text,
                                    textInputAction: TextInputAction.done,
                                  ),
                                ))
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: dp_width(7.5), bottom: dp_width(7.5)),
                          child: Container(
                              height: dp_width(40),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                      width: dp_width(0.5),
                                      color: Color(0XFF17BCE6)),
                                  borderRadius:
                                      BorderRadius.circular(dp_width(20))),
                              child: Row(
                                children: <Widget>[
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: dp_width(12)),
                                    child: RichText(
                                      text: TextSpan(
                                        children: <TextSpan>[
                                          TextSpan(
                                              text: '*',
                                              style: TextStyle(
                                                color: Color(0XFFFF6666),
                                                fontSize: sp2px(15),
                                              )),
                                          TextSpan(
                                              text: '学生年级：',
                                              style: TextStyle(
                                                  fontSize: sp2px(15),
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0XFF666666))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                      child: Padding(
                                    padding:
                                        EdgeInsets.only(right: dp_width(12)),
                                    child: Stack(
                                      children: <Widget>[
                                        Positioned(
                                          bottom: 0,
                                          top: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: dp_width(40),
                                            child: GestureDetector(
                                              onTapDown: (f) {
                                                FocusScope.of(context)
                                                    .requestFocus(FocusNode());
                                              },
                                              child: Center(
                                                child: Container(),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ))
                                ],
                              )),
                        ),
                        Padding(
                          padding: EdgeInsets.only(
                              top: dp_width(7.5), bottom: dp_width(20)),
                          child: AnimatedButton(ClipRRect(
                            borderRadius: BorderRadius.circular(dp_width(23)),
                            child: CupertinoButton(
                              onPressed: () {
                                final phone =
                                    widget._phoneController.text.toString();
                                final name =
                                    widget._nameController.text.toString();
                                return;
                              },
                              child: Container(
                                  height: dp_width(45),
                                  width: double.infinity,
                                  child: Center(
                                      child: Text(
                                    '立即报名',
                                    style: TextStyle(
                                        fontSize: sp2px(16),
                                        color: Color(0XFFFFFFFF)),
                                  )),
                                  decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [
                                        Color(0XFF17D8E6),
                                        Color(0XFF17BCE6)
                                      ]),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(dp_width(22.5))),
                                      border: Border.all(
                                          width: dp_width(0.5),
                                          color: Color(0XFF17BCE6)))),
                            ),
                          )),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
      Container(
        width: double.infinity,
        color: Colors.transparent,
        height: dp_width(10),
      ),
      Container(
        width: double.infinity,
        color: Colors.white,
        child: Padding(
            padding: EdgeInsets.only(
                left: dp_width(15),
                bottom: dp_width(15),
                top: dp_width(15),
                right: dp_width(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          height: dp_width(12),
                          width: dp_width(4),
                          decoration: BoxDecoration(
                              color: Color(0XFF17BCE6),
                              borderRadius: BorderRadius.circular(dp_width(2))),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: dp_width(5)),
                          child: Text(
                            '邦德精选课程',
                            style: TextStyle(
                                fontSize: sp2px(18),
                                fontWeight: FontWeight.bold,
                                color: Color(0XFF333333)),
                          ),
                        ),
                        Expanded(
                            child: Container(
                          alignment: Alignment.centerRight,
                          child: Padding(
                              padding: EdgeInsets.only(right: 0),
                              child: CupertinoButton(
                                minSize: 0,
                                padding: EdgeInsets.zero,
                                onPressed: () {
                                  return;
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(
                                      "查看全部",
                                      style: TextStyle(
                                          fontSize: sp2px(12),
                                          color: Color(0XFF999999)),
                                    ),
                                    Icon(
                                      Icons.arrow_forward_ios,
                                      size: dp_width(10),
                                      color: Color(0XFF999999),
                                    )
                                  ],
                                ),
                              )),
                        ))
                      ],
                    )
                  ],
                ),
              ],
            )),
      )
    ];
  }

  Widget buildPlayer() {
    if (widget.currentSeek > 0) {
      widget.chewieController
          ?.seekTo(Duration(milliseconds: widget.currentSeek.toInt()));
    }
    return GestureDetector(
      onTap: () {
        setState(() {
          if (widget
                  .chewieController?.videoPlayerController?.value?.isPlaying ??
              false) {
            widget.chewieController?.pause();
          } else {
            widget.chewieController?.play();
          }
        });
      },
      child:
//            VideoPlayer(widget.controller)
          Chewie(
        controller: widget.chewieController,
      ),
    );
  }

  void play() {
    widget.chewieController?.play();
  }

  void stop() {
    widget.chewieController?.pause();
  }

  Widget _buildItem(int index) {
    switch (index) {
      case 0:
        break;
      case 1:
        break;
      case 2:
        break;
    }
    final ints = [18, 300, 55];
    final str = ["专注教育", "培养孩子", "遍布分校"];
    final str2 = ["载", "万", "所"];

    return Column(children: <Widget>[
      Row(
        children: <Widget>[
          Text(
            '${ints[index]}',
            style: TextStyle(fontSize: sp2px(40), color: Color(0XFFFF6666)),
          ),
          Padding(
            padding: EdgeInsets.only(left: dp_width(4)),
            child: Text(str2[index],
                style:
                    TextStyle(fontSize: sp2px(12), color: Color(0XFF333333))),
          ),
        ],
      ),
      Text(
        str[index],
        style: TextStyle(fontSize: sp2px(16), color: Color(0XFF666666)),
      )
    ]);
  }

  final gradeArray = [
    "__",
    "一年级",
    "二年级",
    "三年级",
    "四年级",
    "五年级",
    "六年级",
    "初一",
    "初二",
    "初三",
    "高一",
    "高二",
    "高三",
    "学龄前",
    "__",
    "高中毕业"
  ];
}

class VideoScaffold extends StatefulWidget {
  const VideoScaffold({Key key, this.child}) : super(key: key);

  final Widget child;

  @override
  State<StatefulWidget> createState() => _VideoScaffoldState();
}

class _VideoScaffoldState extends State<VideoScaffold> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    AutoOrientation.landscapeAutoMode();
    super.initState();
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    AutoOrientation.portraitDownMode();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
