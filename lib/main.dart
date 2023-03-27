import 'dart:io';

import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/asymmetric/api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp() : super();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScrollController? _scrollController;
  bool lastStatus = true;
  double height = 200;

  void _scrollListener() {
    if (_isShrink != lastStatus) {
      setState(() {
        lastStatus = _isShrink;
      });
    }
  }

  bool get _isShrink {
    return _scrollController != null &&
        _scrollController!.hasClients &&
        _scrollController!.offset > (height - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController?.removeListener(_scrollListener);
    _scrollController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    crypt();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      title: 'Horizons Weather',
      home: SafeArea(
        child: Scaffold(
          body: Container(),
        ),
      ),
    );
  }

  Future writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  crypt() async {
    var pubKey = await rootBundle.load("assets/public.pem");
    var priKey = await rootBundle.load("assets/private.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/public.pem');
    writeToFile(priKey, '$dir/private.pem');

    final publicKey =
    await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);

    final privateKey =
    await parseKeyFromFile<RSAPrivateKey>(File('$dir/private.pem').path);

    final sampleText = 'q+3A3Dyid/2MAYVsS9je+CmvLImKyM73qpLbLvXc5m77Utg9FV5M7z+YH9CVbajHZaT2XFV4qpDKfZhbrFgzDCCcnia3JShCGGIh30JMiL4blzKYWFcMFAImxRecRvv7KOhpObunvI8fw2p4lYLmwVS/3S/JAxvB6DpQTyvz1oIEc3UWbdz5W7SWkf6OK0GrPRn/5nYIF6ZIgUm3TMnpH4rfnxPwzWc34NsIwRwTtskItwHE/qI3IajxhB9uFu50bluKLUSewQdgJzakLKlFnIggUqEcgbb3/2rtyF7l/1i8zH5NEbtvzK2MGbREZw72NcSQlCsf0McOVeVVHs7hFg==';

    final encrypter = Encrypter(RSA(publicKey: publicKey, privateKey: privateKey));

    final decrypted = encrypter.decrypt64(sampleText);

    print(decrypted);
  }
}
