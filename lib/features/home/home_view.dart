import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../../helper/publisher.dart';

class HomeView extends StatefulWidget {
  const HomeView({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  dynamic publish;
  int _selectedIndex = 0;
  bool _isVisible = false;
  bool _isLoading = false;
  TextEditingController accID = TextEditingController();
  TextEditingController pubTok = TextEditingController();
  TextEditingController streamName = TextEditingController();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();

  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initRenderers();
    super.initState();
  }

  // publishExample handles starting the stream and checking if credentials are valid
  void publishExample() async {
    if (pubTok.text.isEmpty || streamName.text.isEmpty || accID.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.grey,
        content: Text('Make sure Account ID, Stream Name, and Publishing Token all include values.'),
      ));
    } else {
      try {
        _isLoading = !_isLoading;

        _isLoading
            ? showDialog(
                context: context,
                builder: (context) {
                  return const AlertDialog(
                    content: Text('Loading...'),
                  );
                },
              )
            : null;
        publish = await publishConnect(_localRenderer, streamName.text, pubTok.text).then((value) {
          showWidget();
          Navigator.of(context).pop(); // close the dialog
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.grey,
          content: Text(
              'Make sure Account ID, Stream Name, and Publishing Token are all valid or Make sure the permissions are configured from the AndroidManifest.xml File.'),
        ));
      }
    }
  }

  // endPublishExample stops the streaming instance.
  void endPublishExample() async {
    /*  await publish.stop(); */
    _localRenderer.srcObject = null;
    showWidget();
    setState(() {});
  }

  //shareStream handles the functionality for sharing a stream link
  void shareStream() {
    Clipboard.setData(ClipboardData(text: "https://viewer.millicast.com/?streamId=${accID.text}/${streamName.text}"));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      backgroundColor: Colors.grey,
      content: Text('Stream link copied to clipboard.'),
    ));
  }

  //
  void initRenderers() async {
    await _localRenderer.initialize();
  }

  // _onItemTapped handles footer links
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    var links = [
      "https://docs.dolby.io/",
      "https://levelup.gitconnected.com/flutter-hyperlinks-d2eee3fd24f",
      "https://docs.dolby.io/"
    ];
    launchUrlString(links[index]);
  }

  // showWidget handles the visibility of widgets
  void showWidget() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: OrientationBuilder(
          builder: (context, orientation) {
            return Container(
                alignment: Alignment.center,
                child: Column(children: [
                  Visibility(
                      visible: !_isVisible,
                      child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(children: [
                            const SizedBox(height: 20),
                            // Title Widget
                            const Text('Enter Your Dolby.io \n Streaming Credentials:',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: 'Aleo',
                                    fontStyle: FontStyle.normal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25.0,
                                    color: Colors.white)),
                            // Account ID Input
                            Container(
                                width: MediaQuery.of(context).size.width,
                                constraints: const BoxConstraints(minWidth: 100, maxWidth: 400),
                                child: TextFormField(
                                  maxLength: 20,
                                  controller: accID,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Account ID',
                                  ),
                                  onChanged: (v) => accID.text = v,
                                )),
                            // Stream Name Input
                            Container(
                                width: MediaQuery.of(context).size.width,
                                constraints: const BoxConstraints(minWidth: 100, maxWidth: 400),
                                child: TextFormField(
                                  maxLength: 20,
                                  controller: streamName,
                                  onChanged: (v) => streamName.text = v,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Stream Name',
                                  ),
                                )),
                            // Publishing Token Input
                            Container(
                                width: MediaQuery.of(context).size.width,
                                constraints: const BoxConstraints(minWidth: 100, maxWidth: 400),
                                child: TextFormField(
                                  controller: pubTok,
                                  maxLength: 100,
                                  onChanged: (v) => pubTok.text = v,
                                  decoration: const InputDecoration(
                                    labelText: 'Enter Publishing Token',
                                  ),
                                )),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              onPressed: publishExample,
                              child: const Text('Start Stream'),
                            ),
                          ]))),
                  Visibility(
                      visible: _isVisible,
                      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                        Row(
                          children: [
                            const SizedBox(
                              height: 50,
                              width: 20,
                            ),
                            // Share Stream Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              onPressed: shareStream,
                              child: const Text('Share Stream'),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            // End Stream Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                              ),
                              onPressed: endPublishExample,
                              child: const Text('End Stream'),
                            ),
                          ],
                        ),
                        // Viewer Widget Settings
                        Container(
                          margin: const EdgeInsets.all(30),
                          constraints: const BoxConstraints(minWidth: 100, maxWidth: 1000, maxHeight: 500),
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height / 1.7,
                          decoration: const BoxDecoration(color: Colors.black54),
                          child: RTCVideoView(_localRenderer, mirror: true),
                        )
                      ])),
                ]));
          },
        ),
      ),
      // Footer Widget Settings
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Read the Tutorial",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dataset_linked),
            label: "See the Code",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.web),
            label: "Documentation",
          )
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        onTap: _onItemTapped,
      ),
    );
  }
}
