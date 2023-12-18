import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:tflite/tflite.dart';
import 'main.dart';

class SpeechBubbleIcon extends StatelessWidget {
  final String text;

  SpeechBubbleIcon({required this.text});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 150.0,
          height: 100.0,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(0.0),
              bottomRight: Radius.circular(20.0),
            ),
            border: Border.all(color: Colors.black, width: 2.0),
          ),
        ),
        Positioned.fill(
          child: Align(
            alignment: Alignment.center,
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 20.0,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isWorking = false;
  bool filterSelected = false;
  String result = '';
  CameraController? cameraController;
  CameraImage? imgCamera;

  initCamera() {
    cameraController = CameraController(cameras![0], ResolutionPreset.medium);
    cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }

      setState(() {
        cameraController!.startImageStream((imageFromStream) => {
              if (!isWorking)
                {
                  isWorking = true,
                  imgCamera = imageFromStream,
                  runModelOnStreamFrames(),
                }
            });
      });
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: "assets/emotion_model.tflite", labels: "assets/labels.txt");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadModel();
  }

  runModelOnStreamFrames() async {
    if (imgCamera != null) {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: imgCamera!.planes.map((plane) {
          return plane.bytes;
        }).toList(),
        imageHeight: imgCamera!.height,
        imageWidth: imgCamera!.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 1,
        threshold: 0.1,
        asynch: true,
      );
      result = '';

      recognitions!.forEach((response) {
        result += response["label"] +
            "  " +
            (response["confidence"] as double).toStringAsFixed(2) +
            "\n\n";
      });
      setState(() {
        result;
      });
      isWorking = false;
    }
  }

  @override
  void dispose() async {
    // TODO: implement dispose
    super.dispose();
    await Tflite.close();
    cameraController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Animogram"),
          actions: [
            IconButton(
              icon: Icon(Icons.notifications_none),
              onPressed: () {
                // Handle notification button press
              },
            ),
          ],
        ),
        body: Expanded(
          child: Column(
            children: [
              Stack(
                children: [
                  Center(
                    child: TextButton(
                      onPressed: () {
                        initCamera();
                      },
                      child: Container(
                        height: MediaQuery.of(context).size.height - 300,
                        width: MediaQuery.of(context).size.width,
                        child: imgCamera == null
                            ? Container(
                                height: 400.0,
                                width: 480.0,
                                child: const Icon(
                                  Icons.photo_camera_front,
                                  color: Colors.pink,
                                  size: 40.0,
                                ),
                              )
                            : AspectRatio(
                                aspectRatio:
                                    cameraController!.value.aspectRatio,
                                child: CameraPreview(cameraController!),
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 300.0, // Adjust the bottom value as needed
                    child: Container(
                      width:
                          520.0, // Set the width to match the camera preview width
                      color: Colors.transparent,
                      child: Center(
                        child: SingleChildScrollView(
                          child: imgCamera != null
                              ? SpeechBubbleIcon(text: result)
                              : Container(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                  visible: filterSelected,
                  child: Container(
                    width: 400,
                    height: 120,
                    color: Colors.black45,
                    child: Column(children: [
                      SingleChildScrollView(
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 20),
                            InkWell(
                              onTap: () {},
                              child: Text(
                                '내 필터',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 20),
                            InkWell(
                              onTap: () {

                              },
                              child: Text(
                                '추천',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.white),
                              ),
                            ),
                            SizedBox(width: 20),
                            InkWell(
                              onTap: () {},
                              child: Text(
                                'NEW',
                                style: TextStyle(
                                    fontSize: 16.0, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: <Widget>[
                            SizedBox(width: 20),
                            Container(
                              width: 50,
                              height: 50,
                              margin: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors
                                    .white, // You can set a background color if necessary
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Your button 1 logic here
                                },
                                child: Image.asset('assets/trash.png'),
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              width: 50,
                              height: 50,
                              margin: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors
                                    .white, // You can set a background color if necessary
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Your button 1 logic here
                                },
                                child: Image.asset('assets/restriction.png'),
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              width: 50,
                              height: 50,
                              margin: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors
                                    .white, // You can set a background color if necessary
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Your button 1 logic here
                                },
                                child: Image.asset('assets/sadSticker.png'),
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              width: 50,
                              height: 50,
                              margin: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors
                                    .white, // You can set a background color if necessary
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Your button 1 logic here
                                },
                                child: Image.asset('assets/redAngryFilter.png'),
                              ),
                            ),
                            SizedBox(width: 20),
                            Container(
                              width: 50,
                              height: 50,
                              margin: EdgeInsets.all(5.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors
                                    .white, // You can set a background color if necessary
                              ),
                              child: InkWell(
                                onTap: () {
                                  // Your button 1 logic here
                                },
                                child: Image.asset('assets/happyFace.png'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ]),
                  )),
              Positioned(
                bottom: 10.0, // Adjust the bottom value as needed
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(20.0, 20.0),
                      ),
                      child: Icon(Icons.home),
                    ),
                    SizedBox(width: 5.0),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(20.0, 20.0),
                      ),
                      child: Icon(Icons.camera_alt),
                    ),
                    SizedBox(width: 5.0),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(20.0, 20.0),
                      ),
                      child: Icon(Icons.upload),
                    ),
                    SizedBox(width: 5.0),
                    ElevatedButton(
                      onPressed: () {
                        filterSelected = !filterSelected;
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(20.0, 20.0),
                      ),
                      child: Icon(Icons.search),
                    ),
                    SizedBox(width: 5.0),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(20.0, 20.0),
                      ),
                      child: Icon(Icons.person),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
