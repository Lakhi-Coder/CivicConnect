import 'package:flutter/material.dart';

const int mobileScreenSize = 600;
const int tabletScreenSize = 1000;

var mobileSize = 'desktop';


deviceData(context) {
  var data = MediaQuery.of(context); 
  return data;
}


getScreenSize(context) {
  var windowSize = deviceData(context).size;
  if (windowSize.width <= mobileScreenSize) { 
    mobileSize = 'mobile'; 
  } else if (windowSize.width <= tabletScreenSize) { 
    mobileSize = 'tablet';
  } else {
    mobileSize = 'desktop';
  }

  return mobileSize;
}
