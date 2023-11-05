import 'dart:async';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:tmp/ai_service.dart';
import 'package:tmp/widgets/ai_network_image.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

// ideally i would use some state management approach like Bloc or Cubit
// i tried to create a Stream of current wordpair and its generated url
// and  to use stream from future and somehow make it work, but couldnt handle it, so just left Stream
// also it would be nice to show the user that we are waiting for a response from API
// we could create a var called isLoading (it also could be ValueNotifier<bool> ) and then we should change the stream to be broadcasted

class _MainScreenState extends State<MainScreen> {
  // init AiService
  final aiService = AiService.instance;

  // how many words should be processed
  int count = 5;

  // initialize List of [count] WordPairs elements
  late final List<WordPair> wordPairs;
  late final List<WordPairImgUrl> wordParmImgUrls;
  int currentIndex = 0;

  // for iterating throughout the List
  final streamController = StreamController<WordPairImgUrl>();

  @override
  void initState() {
    super.initState();
    wordPairs = generateWordPairs().take(count).toList();

    // populate
    wordParmImgUrls = List<WordPairImgUrl>.generate(wordPairs.length,
        (index) => WordPairImgUrl(wordPair: wordPairs[index]));
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    final url = await getImageUrlFromAi();
    wordParmImgUrls[currentIndex] =
        wordParmImgUrls[currentIndex].copyWith(url: url);

    streamController.add(wordParmImgUrls[currentIndex]);
  }

  Future<String> getImageUrlFromAi() async {
    final url = await aiService.getAiImageByText(
        imageDescription: wordParmImgUrls[currentIndex].wordPair.toString());

    return url;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 250,
              height: 250,
              child: StreamBuilder<WordPairImgUrl>(
                  stream: streamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          snapshot.error.toString(),
                          style: const TextStyle(
                            color: Colors.red,
                          ),
                        ),
                      );
                    }
                    late Widget child;
                    switch (snapshot.connectionState) {
                      case ConnectionState.none:
                      case ConnectionState.waiting:
                        child = const CircularProgressIndicator();
                      case ConnectionState.active:
                      case ConnectionState.done:
                        child = NetworkImageFromAi(url: snapshot.data!.url!);
                    }
                    return child;
                  }),
            ),
            const Text('image gen promt'),
            const SizedBox(height: 50),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(
                  onPressed: currentIndex == 0
                      ? null
                      : () {
                          setState(() {
                            currentIndex--;
                          });
                          streamController.add(wordParmImgUrls[currentIndex]);
                        },
                  child: const Text('prev'),
                ),
                ElevatedButton(
                  onPressed: count == 1
                      ? null
                      : () async {
                          setState(() {
                            currentIndex++;
                            count--;
                          });

                          if (wordParmImgUrls[currentIndex].url == null) {
                            final url = await getImageUrlFromAi();

                            wordParmImgUrls[currentIndex] =
                                wordParmImgUrls[currentIndex]
                                    .copyWith(url: url);
                          }

                          streamController.add(wordParmImgUrls[currentIndex]);
                        },
                  child: const Text('next'),
                ),
              ],
            ),
            Text('left : ${count - 1}'),
          ],
        ),
      ),
    );
  }
}

// model to keep wordPair and corresponding url
class WordPairImgUrl {
  WordPairImgUrl({required this.wordPair, this.url});

  final WordPair wordPair;
  // if null url has not been added yet
  final String? url;

  @override
  String toString() {
    return '{wordPair: ${wordPair.toString()}; url: ${url.toString()}}';
  }

  WordPairImgUrl copyWith({WordPair? wordPair, String? url}) {
    return WordPairImgUrl(
        wordPair: wordPair ?? this.wordPair, url: url ?? this.url);
  }
}
