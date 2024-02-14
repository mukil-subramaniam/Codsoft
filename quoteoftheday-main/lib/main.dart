// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Your Quote',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: 'Your Quote'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _quote = "";
  String _author = "";
  bool _loading = false;
  List<String> _favoriteQuotes = [];

  Future<http.Response> fetchQuote() async {
    return http.get(Uri.parse('https://zenquotes.io/api/random/'));
  }

  void newQuote() async {
    setState(() => _loading = true);
    var res = await fetchQuote();
    if (res.statusCode == 200) {
      var body = jsonDecode(res.body);
      var item = body[0];
      setState(() {
        _quote = item['q'];
        _author = item['a'];
      });
    }
    setState(() => _loading = false);
  }

  void shareQuote() {
    Share.share('$_quote - $_author');
  }

  void addToFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _favoriteQuotes.add('$_quote - $_author');
    prefs.setStringList('favorite_quotes', _favoriteQuotes);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Quote added to favorites'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void loadFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _favoriteQuotes = prefs.getStringList('favorite_quotes') ?? [];
    });
  }

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    if (_quote == "") {
      newQuote();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("QUOTES OF THE DAY"),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_loading) const Text('Loading...'),
            Container(
              margin: const EdgeInsets.all(22.0),
              child: Text(
                _quote,
                style:
                    const TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
              ),
            ),
            Container(
              margin: const EdgeInsets.all(10.0),
              child: Text(
                _author,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          FloatingActionButton(
            onPressed: newQuote,
            tooltip: 'New Quote',
            child: const Icon(Icons.autorenew),
          ),
          FloatingActionButton(
            onPressed: addToFavorites,
            tooltip: 'Add to Favorites',
            child: const Icon(Icons.favorite),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      persistentFooterButtons: [
        ElevatedButton(
          onPressed: shareQuote,
          child: const Text('Share'),
        ),
      ],
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          FavoriteQuotesPage(favoriteQuotes: _favoriteQuotes)),
                );
              },
              child: const Text('View Favorites'),
            ),
          ],
        ),
      ),
    );
  }
}

class FavoriteQuotesPage extends StatelessWidget {
  final List<String> favoriteQuotes;

  const FavoriteQuotesPage({Key? key, required this.favoriteQuotes})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Quotes'),
        backgroundColor: Colors.blue,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: favoriteQuotes.length,
        itemBuilder: (context, index) {
          return SizedBox(
            child: ListTile(
              title: Text(favoriteQuotes[index]),
            ),
          );
        },
      ),
    );
  }
}
