import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'IndexPage.dart';

class SplashPage extends StatefulWidget {
  int currentStep = 4;

  @override
  State<StatefulWidget> createState() {
    return _SplashPage();
  }
}

class _SplashPage extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;
  Timer _timer;

  @override
  void initState() {
    //创建动画控制器
    _animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1000));
    _animation = Tween(begin: 0.0, end: 1.0).animate(_animationController);
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //这边的添加动画的监听，当动画3秒后的状态是completed完成状态，
        // 则执行这边的代码，跳转到登录页，或者其他页面
        Future.delayed(Duration(milliseconds: 1000), () {
          setState(() {
            widget.currentStep = 3;
            Future.delayed(Duration(milliseconds: 400)).then((f2) {
              const oneSec = const Duration(seconds: 1);
              var callback = (timer) {
                counter();
              };
              _timer = Timer.periodic(oneSec, callback);
            });
          });
        });
      }
    });
    super.initState();
    _animationController.forward();
  }

  void counter() {
    if (widget.currentStep <= 3) {
      if (widget.currentStep >= 1) {
        if ((widget.currentStep - 1) == 0) {
          setState(() {
            _timer?.cancel();
            routerToNext(context);
//                            widget.currentStep = 0;
          });
        } else {
          setState(() {
            widget.currentStep = widget.currentStep - 1;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    //If you want to set the font size is scaled according to the system's "font size" assist option
    ScreenUtil.instance =
        ScreenUtil(width: 375, height: 667, allowFontScaling: true)
          ..init(context);

    return Scaffold(
      body: FadeTransition(
        opacity: _animation,
        alwaysIncludeSemantics: true,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Image.asset('assets/images/bg.webp',
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                fit: BoxFit.fill),
            FractionallySizedBox(
                widthFactor: null,
                heightFactor: 0.4,
                child: Column(
                  children: <Widget>[
                    SizedBox.fromSize(
                      child: Image.asset('assets/images/logo.webp'),
                      size: Size(124, 141),
                    ),
                    Padding(
                      child: Text(
                        '邦德家长通',
                        style: TextStyle(
                            fontSize: 24,
                            color: Color(0XFF333333),
                            fontFamily: 'STYuanti'),
                      ),
                      padding: EdgeInsets.only(top: 12),
                    ),
                    Text(
                      'Bond Parent Assistan',
                      style: TextStyle(
                        fontSize: 8,
                        color: Color(0XFF9B9B9B),
                      ),
                    )
                  ],
                )),
            buildPositioned(),
          ],
        ),
      ),
    );
  }

  Widget buildPositioned() {
    if (widget.currentStep > 3) {
      return Container();
    }
    FocusScope.of(context).requestFocus(FocusNode());
    final w = MediaQuery.of(context).size.width * 0.1;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return Positioned(
      child: GestureDetector(
        onTap: () {
          _timer?.cancel();
          routerToNext(context);
        },
        child: Container(
          width: w,
          height: w * 0.7,
          decoration: BoxDecoration(
            color: Color(0XFF808080),
            shape: BoxShape.rectangle,
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 3),
                color: Color(0XFFE6E6E6),
                spreadRadius: 0.1,
                blurRadius: 8,
              )
            ],
            borderRadius: BorderRadius.circular(w / 2),
          ),
          child: Center(
            child: Text(
              '${widget.currentStep}',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ),
      ),
      right: 20,
      top: statusBarHeight + 10,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> routerToNext(BuildContext context) async {
    Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: Duration(milliseconds: 500), //动画时间为500毫秒
          pageBuilder: (BuildContext context, Animation animation,
              Animation secondaryAnimation) {
            return new FadeTransition(
                //使用渐隐渐入过渡,
                opacity: animation,
                child: _pageSelector());
          },
        ));
  }

  StatefulWidget _pageSelector() {
    return IndexPage();
  }
}
