import 'package:flutter/material.dart';
import 'package:get/get.dart';

var purple = const Color(0xffB453D4).obs;
var textHeadingColor = const Color(0xff4C4C4C).obs;
var contentGrey = const Color(0xffA7A6B4).obs;
var BoxGrey = const Color(0xFFC8C8C8).obs;
var tileBlack = const Color(0xFF626262).obs;
var Colorgreen = const Color(0xFF28A314).obs;
var circleGrey = const Color(0xFFDADADA).obs;
var background = const Color(0xFFFFFFFF).obs;
var borderaroundColor = const Color(0xff8F8F8F).obs;
var darkcontentgrey = const Color(0xff626262).obs;

var primaryBackgroundColor = const Color(0xFFf49600).obs;
var primaryColorDull = const Color(0xFF0C9D7D).obs;
var dividerColor = const Color(0xFFF2F2F2).obs;
Color nonActiveInputColor = const Color(0xFFEDEDED);
Color activeInputColor = const Color(0xFFFCFCFC);
Color activeInputBorderColor = const Color(0xFF03314B);
Color nonActiveInputBorderColor = Colors.transparent;
Color filledInputColor = const Color(0xFFEDEDED);
var headingColor = const Color(0xFF030319).obs;
var labelColor = const Color(0xFF8F92A1).obs;
var dashLabelColor = const Color(0xFFB4B6DB).obs;
var dashBtnColor = const Color(0xFF292E9A).obs;
Color placeholderColor = const Color(0xff8F92A1);
var inputFieldTextColor = const Color(0xFF0F001C).obs;
var inputFieldBackgroundColor = const Color(0xFFFAFAFA).obs;
var listCardColor = const Color(0xFFFAFAFA).obs;

var appBarColor = const Color(0xff462D81).obs;
var chatBoxBg = const Color(0xffF8F8F8).obs;

Color btnTxtColor = const Color(0xFFFCFCFC);
Color errorTxtColor = const Color(0xFFFF0E41);
Color lightColor = const Color(0xFFFCFCFC);
var cardColor = const Color(0xFFFFFFFF).obs;
var greenCardColor = const Color(0xFF39B171).obs;
var redCardColor = const Color(0xFFF16464).obs;
var chipChoiceColor = const Color(0xFF27C19F).withOpacity(0.1);
var bSheetbtnColor = const Color(0x0D27C19F).withOpacity(0.10);

///////////history screen colors//////////////
var bgCintainerColor = const Color(0xff27C19F);
var bg2CintainerColor = const Color(0xffFED5D5);
var iconUpColor = const Color(0xffE34446);

var iconDownColor = const Color(0xff0C9D7D);

//////////////history/////////

var appShadow = [
  BoxShadow(
    color: const Color.fromRGBO(155, 155, 155, 15).withOpacity(0.15),
    spreadRadius: 5,
    blurRadius: 7,
    offset: const Offset(0, 3), // changes position of shadow
  ),
].obs;

var homeCardBgShadow = [
  const BoxShadow(
    color: Color(0x00000000),
    offset: Offset(0.0, 4.0),
    blurRadius: 20.0,
  ),
].obs;
