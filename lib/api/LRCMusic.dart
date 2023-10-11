import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:music/dio/initDio.dart';
import 'package:music/dto/SearchList.dart';
import 'package:xpath_selector_html_parser/src/ext.dart';
import 'package:xpath_selector_html_parser/xpath_selector_html_parser.dart';

final dio = initDio();

/// 搜索歌曲
Future<List<SearchList>> search(String text) async {
  print(dio.options.headers);
  print('搜索地址 https://www.musicenc.com/?search=$text');
  Response response = await dio.get('https://www.musicenc.com/?search=$text');
  final htmlXpath = HtmlXPath.html(response.data.toString());
  var query = htmlXpath.queryXPath("//div[@class='list']/li");
  List<SearchList> list = [];
  for (var node in query.nodes) {
    var singer = node.queryXPath("//span/text()");
    var name = node.queryXPath("//a/text()");
    var dates = node.queryXPath("//a/@dates");
    var searchList = SearchList(name: name.attr, singer: singer.attr, dates: dates.attr);
    list.add(searchList);
  }
  return list;
}

/// 选择播放歌曲
Future<String?> actionSong(String? token) async {
  print('1.访问链接 https://www.musicenc.com/searchr/?token=$token');
  // 选择搜索的歌曲
  Response response = await dio.get('https://www.musicenc.com/searchr/?token=$token');
  final htmlXpath = HtmlXPath.html(response.data.toString());
  // 获取歌曲重定向地址
  var href = htmlXpath.queryXPath("//a[@class='downBu secm3']/@href");
  String targetUrl;
  if (href.attr!.indexOf("/") > 0) {
    targetUrl = href.attr!;
  } else {
    targetUrl = 'https://www.musicenc.com${href.attr}';
  }
  print('2.访问链接 $targetUrl');
  Response target = await dio.get(targetUrl);
  // 用正则 取出地址 base64
  var pics = RegExp(r'(?<=\bpics=")[^"]*');
  var picsMatch = pics.stringMatch(target.data.toString());
  List<int> bytes = base64Decode(picsMatch!);
  String decodeStr = String.fromCharCodes(bytes);
  print('3.访问链接 $decodeStr');
  Response realMusicUrl = await dio.get(decodeStr);
  return realMusicUrl.data.toString();
}
