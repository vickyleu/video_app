import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_app/AppHomePage.dart';

import 'flutter_export.dart';

// 底部导航类
class IndexPage extends StatefulWidget {
  int _currentIndex = 0;

  Map<int, StatefulWidget> pageList =
      [AppHomePage(), EmptyPage(), EmptyPage(), EmptyPage()].asMap();

  bool firstDelayed = false;

  @override
  _IndexPageState createState() {
    return _IndexPageState();
  }
}

class EmptyPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _EmptyPage();
  }
}

class _EmptyPage extends State<EmptyPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(),
    );
  }
}

class _IndexPageState extends State<IndexPage> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<_BottomModel> list = List();
    List<_BottomModelTile> lista = List();
    List<_BottomModelTile> listb = List();
    lista.add(_BottomModelTile("首页", "assets/images/icon_home_select.png"));
    lista.add(_BottomModelTile("学习", "assets/images/icon_study_select.png"));
    lista.add(_BottomModelTile("消息", "assets/images/icon_message_select.png"));
    lista.add(_BottomModelTile("我的", "assets/images/icon_mine_select.png"));

    listb.add(_BottomModelTile("首页", "assets/images/icon_home.png"));
    listb.add(_BottomModelTile("学习", "assets/images/icon_study.png"));
    listb.add(_BottomModelTile("消息", "assets/images/icon_message.png"));
    listb.add(_BottomModelTile("我的", "assets/images/icon_mine.png"));

    list.add(_BottomModel(-1, 1));
    list.add(_BottomModel(0, 10));
    list.add(_BottomModel(-1, 1));
    list.add(_BottomModel(1, 10));
    list.add(_BottomModel(-1, 1));
    list.add(_BottomModel(2, 10));
    list.add(_BottomModel(-1, 1));
    list.add(_BottomModel(3, 10));
    list.add(_BottomModel(-1, 1));

    return WillPopScope(
      onWillPop: () {
        return;
      },
      child: Scaffold(
        body:
//        !widget.firstDelayed
//            ? Container()
//            :
            widget.pageList[widget._currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, -4),
                color: Color(0XFFE6E6E6),
                spreadRadius: 0.2,
                blurRadius: 6,
              )
            ],
          ),
          height: kBottomNavigationBarHeight +
              MediaQuery.of(context).padding.bottom,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: list.map((model) {
              var tile = model.idx != -1
                  ? widget._currentIndex == model.idx
                      ? lista[model.idx]
                      : listb[model.idx]
                  : null;

              return model.idx == -1
                  ? (Expanded(
                      flex: model.flex,
                      child: Container(),
                    ))
                  : (Expanded(
                      flex: model.flex,
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).padding.bottom),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Stack(
                            overflow: Overflow.visible,
                            children: <Widget>[
                              Material(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.all(Radius.circular(
                                    kBottomNavigationBarHeight)),
                                shadowColor: Colors.transparent,
                                child: Ink(
                                  decoration: new BoxDecoration(
                                    //不能同时”使用Ink的变量color属性以及decoration属性，两个只能存在一个
                                    color: Colors.white,
                                    //设置圆角
                                    borderRadius: new BorderRadius.all(
                                        new Radius.circular(25.0)),
                                  ),
                                  child: InkWell(
                                    highlightColor: Colors.transparent,
                                    focusColor: Colors.transparent,
                                    hoverColor: Colors.transparent,
                                    borderRadius:
                                        new BorderRadius.circular(25.0),
                                    onTap: () {
                                      if (widget._currentIndex != model.idx) {
                                        _createPageItem(model.idx);
                                        setState(() {
                                          widget._currentIndex = model.idx;
                                        });
                                      }
                                    },
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      child: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            SizedBox(
                                              height: dp_width(24),
                                              width: dp_width(24),
                                              child: AnimatedSize(
                                                duration:
                                                    Duration(milliseconds: 500),
                                                vsync: this,
                                                curve: Curves.easeOutCubic,
                                                child: SizedBox(
                                                  height: dp_width(
                                                      widget._currentIndex ==
                                                              model.idx
                                                          ? 24
                                                          : 18),
                                                  width: dp_width(
                                                      widget._currentIndex ==
                                                              model.idx
                                                          ? 24
                                                          : 18),
                                                  child: Image(
                                                      image: AssetImage(
                                                          tile.image)),
                                                ),
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: dp_width(5)),
                                              child: SizedBox(
                                                height: dp_width(13),
                                                child: AnimatedSize(
                                                  duration: Duration(
                                                      milliseconds: 500),
                                                  vsync: this,
                                                  curve: Curves.easeOutCubic,
                                                  child: SizedBox(
                                                    child: Text(
                                                      tile.title,
                                                      style: TextStyle(
                                                          color: Color(
                                                              widget._currentIndex ==
                                                                      model.idx
                                                                  ? 0XFF17BCE6
                                                                  : 0XFF4A4A4A),
                                                          fontSize: sp2px(
                                                              widget._currentIndex ==
                                                                      model.idx
                                                                  ? 11
                                                                  : 9)),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ));
            }).toList(),
          ),
        ),
      ),
    );
  }

  Future _createPageItem(int idx) async {
//    if (!widget.pageList.containsKey(idx)) {
//      switch (idx) {
//        case 0:
//          widget.pageList[0] = AppHomePage();
//          break;
//        case 1:
//          widget.pageList[1] = StudyPage();
//          break;
//        case 2:
//          widget.pageList[2] = Message();
//          break;
//        case 3:
//          widget.pageList[3] = PersonalPage();
//          break;
//      }
//    }
  }
}

class _BottomModelTile {
  String title;
  String image;

  _BottomModelTile(this.title, this.image);
}

class _BottomModel {
  int idx = 0;
  int flex = 1;

  _BottomModel(this.idx, this.flex);
}
