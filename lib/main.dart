import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:html/parser.dart' show parse;
import 'student.dart';





void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Trombinoscope',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Trombinoscope'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool loading = false;

  var kStudents = <Student>[];
  final TextEditingController _controller = new TextEditingController();

  _getStudents() async {

    setState(() {
      kStudents.clear();
      loading = true;
    });

    var httpClient = createHttpClient();

    var url = 'http://trombi.it-sudparis.eu/etudiants.php';

    var response = await httpClient.post(url, body:{'user':'${_controller.text}'.replaceAll("é", "e")});
    var document = parse(response.body);

    var photoUrls = <String>[];
    for (var x in document.getElementsByClassName("ldapPhoto")){
      RegExp exp = new RegExp(r'(["])(?:(?=(\\?))\2.)*?\1');
      String str = x.innerHtml;
      Iterable<Match> matches = exp.allMatches(str);

      for (Match m in matches) {
        String match = m.group(0);
        photoUrls.add("http://trombi.it-sudparis.eu/" + match.substring(1, match.length - 1));
        break;
      }
    }

    var emails = <String>[];
    for (var x in document.getElementsByClassName("ldapInfo")){
      RegExp exp = new RegExp(r'Email :</span> (.*)</p>');
      String str = x.innerHtml;
      Iterable<Match> matches = exp.allMatches(str);

      for (Match m in matches) {
        String match = m.group(0);
        emails.add(match.substring(15, match.length - 4).replaceFirst("[AT]", "@"));
        break;
      }
    }

    int i = 0;
    for (var x in document.getElementsByClassName("ldapNom")){
      kStudents.add(new Student(
        fullName: x.innerHtml,
        email:emails[i],
        photoUrl: photoUrls[i],
      ));
      i++;
    }
    httpClient.close();

    setState((){
      loading = false;
    });

  }

  @override
  Widget build(BuildContext context) {

    Widget chidlWidget;
    if (loading){
      chidlWidget = new Center( child: new CircularProgressIndicator());
    }
    else {
      chidlWidget = new StudentList(kStudents);
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            new TextField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.person),
                hintText: 'Nom',
                labelText: 'Qui voulez vous chercher ?',
              ),
              controller: _controller,
            ),
            new Expanded(
              child: chidlWidget,
            ),
          ],
        ),
      floatingActionButton: new FloatingActionButton(
        onPressed: _getStudents,
        tooltip: 'Increment',
        child: new Icon(Icons.search),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


