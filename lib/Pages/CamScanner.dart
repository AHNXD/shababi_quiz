import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';

class CamScanner extends StatefulWidget {
  const CamScanner({super.key});
  static String id = "/CamScanner";
  @override
  State<CamScanner> createState() => _CamScannerState();
}

class _CamScannerState extends State<CamScanner> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  Barcode? result;
  QRViewController? controller;
  String audioasset = "audio/beep.mp3";

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    } else if (Platform.isIOS) {
      controller!.resumeCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: const Text(
          "QR Scan",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                    color: Colors.amber,
                    borderRadius:
                        BorderRadius.only(bottomLeft: Radius.circular(20))),
                child: IconButton(
                  onPressed: () async {
                    await controller?.toggleFlash();
                    setState(() {});
                  },
                  icon: FutureBuilder<bool?>(
                    future: controller?.getFlashStatus(),
                    builder: (BuildContext context, AsyncSnapshot snapshot) {
                      if (snapshot.data != null) {
                        return snapshot.data!
                            ? const Icon(
                                Icons.flash_on,
                                color: Colors.green,
                              )
                            : const Icon(
                                Icons.flash_off,
                                color: Colors.red,
                              );
                      } else {
                        return const Icon(
                          Icons.flash_off,
                          color: Colors.red,
                        );
                      }
                    },
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                    color: Colors.amber,
                    borderRadius:
                        BorderRadius.only(bottomRight: Radius.circular(20))),
                child: IconButton(
                    onPressed: () async {
                      await controller?.flipCamera();
                      setState(() {});
                    },
                    icon: const Icon(
                      Icons.switch_camera,
                      color: Colors.white,
                    )),
              )
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            height: MediaQuery.of(context).size.height / 2,
            width: double.infinity,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                  borderWidth: 10,
                  borderColor: Colors.amber,
                  borderLength: 30,
                  borderRadius: 10,
                  cutOutSize: MediaQuery.of(context).size.width * 0.8),
            ),
          ),
          const Divider(
            thickness: 5,
            color: Colors.amber,
          ),
          Center(
            child: (result != null)
                ? Text(
                    'Ip : ${result!.code}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )
                : const Text('Scan a code',
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          const Divider(
            thickness: 5,
            color: Colors.amber,
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                if (result != null) {
                  Navigator.pop(context, result?.code);
                }
              },
              child: const Icon(Icons.check))
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    Barcode? aux;
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
        if (result != null && aux?.code != result?.code) {
          final player = AudioPlayer();
          player.play(AssetSource(audioasset));
          aux = result;
        }
      });
    });
  }
}
