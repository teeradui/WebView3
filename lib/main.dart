import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const MyHomePage(title: 'Webview 3'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late WebViewController _controller;
  String totalFromJs = "";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            totalFromJs = message.message;
          });
        },
      )
      ..loadHtmlString(htmlContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _controller)),
          Container(
            width: double.infinity,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16),
            child: Text(
              'Total from JS: $totalFromJs',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}

const String htmlContent = '''<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Shopping Cart</title>
</head>
<body>
    <h1>My Crat <p id="total">Total: \$120</p></h1>
    <button style="padding: 16px 32px; font-size: 20px; width: 100%;" onclick="sendTotalFlutter()">Send Total to Flutter</button>

    <script>
        function sendTotalFlutter() {
            var totalPrice = document.getElementById('total').innerText;
            FlutterChannel.postMessage(totalPrice);
        }
    </script>
</body>
</html> ''';
