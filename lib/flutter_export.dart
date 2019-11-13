import 'package:flutter_screenutil/flutter_screenutil.dart';

double dp_width(double size) {
  return ScreenUtil.instance.setWidth(size);
}

double dp_height(double size) {
  return ScreenUtil.instance.setHeight(size);
}

double sp2px(double size) {
  return ScreenUtil.instance.setSp(size);
}
