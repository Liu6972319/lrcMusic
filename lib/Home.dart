import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:music/api/LRCMusic.dart';
import 'package:music/util/DateUtil.dart';

import 'dto/SearchList.dart';

// 初始化
var player = AudioPlayer();

List<String> source = ["lrc"];

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: const HomePage(title: 'Music'),
      builder: EasyLoading.init(),
      // builder: TransitionBuilder,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController searchInput = TextEditingController();

  late List<SearchList> searchResult = [];

  Duration songDuration = const Duration(milliseconds: 1);
  Duration stepDuration = const Duration(milliseconds: 0);

  int playerStatus = 0;

  int selectIndex = -1;

  @override
  void initState() {
    super.initState();
    // 歌曲时长
    player.onDurationChanged.listen((Duration d) {
      setState(() => songDuration = d);
    });
    // 设置进度
    player.onPositionChanged.listen((Duration p) {
      setState(() => stepDuration = p);
    });
    // 当前状态
    player.onPlayerStateChanged.listen((PlayerState s) {
      setState(() => playerStatus = s.index);
    });
  }

  /// 搜索方法
  void searchMusic() {
    // 执行搜索
    var searchStr = searchInput.text;
    if (searchStr.isNotEmpty) {
      search(searchStr).then((list) {
        setState(() {
          if (list.isNotEmpty) {
            // 保存结果
            searchResult = list;
          }
        });
      });
    }
  }

  downLoad(index) async {
    SearchList searchList = searchResult.elementAt(index);
    var url = searchList.realUrl ?? await actionSong(searchList.dates);
    // var url = await actionSong(searchList.dates);
    // 设置当前选中歌曲地址
    print('即将下载的歌曲 ${url}');
    EasyLoading.showToast("status");
  }

  void playerMusic(index) async {
    setState(() {
      // 设置选中颜色
      selectIndex = index;
    });
    SearchList searchList = searchResult.elementAt(index);
    print("歌名: ${searchList.name} 歌手:${searchList.singer}");

    String? url = searchList.realUrl ?? await actionSong(searchList.dates);
    // 设置当前选中歌曲地址
    if (url != null) {
      print('得到 ${url}');
      searchList.realUrl = url;
      // 停止播放
      player.stop();
      // 播放
      player.play(UrlSource(url));
    }
  }

  /// 构建 listView
  ListView buildMusicList() {
    return ListView.builder(
        itemCount: searchResult.length,
        itemExtent: 50.0,
        itemBuilder: (BuildContext context, int index) {
          var elementAt = searchResult.elementAt(index);
          var singer = elementAt.singer;
          var name = elementAt.name;
          return ListTile(
            title: Text("$name"),
            subtitle: Text("$singer"),
            trailing: IconButton(onPressed: () => downLoad(index), icon: const Icon(Icons.cloud_download)),
            selectedColor: Colors.red,
            selected: index == selectIndex,
            onTap: () => playerMusic(index),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Row(children: [
          Text(widget.title, style: const TextStyle(color: Colors.white)),
          Flexible(
            flex: 1,
            child: TextField(
              autofocus: true,
              controller: searchInput,
              onSubmitted: (value) => searchMusic(),
              textInputAction: TextInputAction.search,
              maxLines: 1,
            ),
          ),
          IconButton(onPressed: searchMusic, icon: const Icon(Icons.search))
        ]),
      ),
      drawer: Drawer(
        child: ListView.builder(
          itemCount: 1,
          itemBuilder: (context, index) {
            return ListTile(title: Text("111"), onTap: () => Navigator.pop(context));
          },
        ),
      ),
      body: Container(
        child: Column(children: [
          Expanded(child: buildMusicList()), // body
          // TabBar(tabs: tabs)
          Container(
              color: Colors.red,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateUtil.durationTransform(stepDuration)),
                      Text(DateUtil.durationTransform(songDuration)),
                    ],
                  ),
                  Slider(
                    value: (stepDuration.inMilliseconds / songDuration.inMilliseconds),
                    onChanged: (value) {
                      int location = (songDuration.inMilliseconds * value).round();
                      player.seek(Duration(milliseconds: location));
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(onPressed: () => print('前一首'), icon: const Icon(Icons.skip_previous)),
                      IconButton(
                          onPressed: () => playerStatus == 1 ? player.pause() : player.resume(),
                          icon: playerStatus == 1 ? const Icon(Icons.pause) : const Icon(Icons.play_arrow)),
                      IconButton(onPressed: () => player.stop(), icon: const Icon(Icons.stop)),
                      IconButton(onPressed: () => print('后一首'), icon: const Icon(Icons.skip_next)),
                    ],
                  )
                ],
              ))
        ]),
      ),
    );
  }
}
