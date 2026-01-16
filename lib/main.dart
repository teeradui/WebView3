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
      title: 'My Cart',
      theme: ThemeData(colorScheme: .fromSeed(seedColor: const Color.fromARGB(255, 208, 180, 255))),
      home: const MyHomePage(title: 'Webview JS'),
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
        backgroundColor: const Color.fromARGB(255, 245, 191, 255),
        centerTitle: true,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(child: WebViewWidget(controller: _controller)),

          Container(
            width: double.infinity,
            color: Colors.grey[200],
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Received from JS: $totalFromJs',
                  style: const TextStyle(fontSize: 20),
                ),

                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () {
                    if (totalFromJs.isEmpty) return;

                    final numberOnly = totalFromJs.replaceAll(
                      RegExp(r'[^0-9]'),
                      '',
                    );

                    final total = int.parse(numberOnly);

                    final newTotal = total + 100;

                    _controller.runJavaScript(
                      'updateTotalFromFlutter($newTotal);',
                    );
                  },
                  child: const Text('Add 100 from Flutter'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const String htmlContent = '''<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>My Cart</title>
  <style>
    body {
      font-family: Arial, sans-serif;
      padding: 16px;
    }
    h1 {
      margin-top: 2px;
    }
    .item {
      display: flex;
      justify-content: space-between;
      margin-bottom: 8px;
      border: 1px solid #ddd;
      padding: 8px;
      border-radius: 6px;
      font-size: 16px;
    }
    button {
      background-color: #dcdcdc;
      color: #2196F3;
      border: none;
      padding: 4px 12px;
      border-radius: 4px;
      font-size: 14px;
      cursor: pointer;
      font-weight:bold;
    }
    .cart {
      margin-top: 20px;
    }
  </style>
</head>

<body>

<h1>My Cart</h1>

<div class="item">
  <span>Apple - \$30</span>
  <button onclick="addItem(30)">Add</button>
</div>

<div class="item">
  <span>Banana - \$20</span>
  <button onclick="addItem(20)">Add</button>
</div>

<div class="item">
  <span>Orange - \$25</span>
  <button onclick="addItem(25)">Add</button>
</div>

<div class="item">
  <span>Milk - \$45</span>
  <button onclick="addItem(45)">Add</button>
</div>

<div class="item">
  <span>Bread - \$35</span>
  <button onclick="addItem(35)">Add</button>
</div>

<div class="cart">
  <h2>Cart</h2>
  <p id="total">Total: \$0</p>
</div>

<script>
  var total = 0;

  function addItem(price) {
    total += price;
    updateUI();
    sendTotalToFlutter();
  }

  function updateUI() {
    document.getElementById('total').innerText = "Total: \$" + total;
  }

  function sendTotalToFlutter() {
    FlutterChannel.postMessage(total.toString());
  }

  function updateTotalFromFlutter(newTotal) {
    total = newTotal;
    updateUI();
    sendTotalToFlutter();
  }

  function sendTotalToFlutter() {
  FlutterChannel.postMessage(total.toString());
}

window.onload = function () {
  sendTotalToFlutter();
};

  </script>
</body>
</html> ''';
