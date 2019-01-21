import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import './watson.dart';

final ThemeData iOSTheme = new ThemeData(
    primarySwatch: Colors.red,
    primaryColor: Colors.grey[400],
    primaryColorBrightness: Brightness.dark);

final ThemeData androidTheme =
    new ThemeData(primarySwatch: Colors.blue, primaryColor: Colors.green);

const String defaultUserName = "Eu";

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: 'Chat Application',
        theme: defaultTargetPlatform == TargetPlatform.iOS
            ? iOSTheme
            : androidTheme,
        home: new Chat());
  }
}

class Chat extends StatefulWidget {
  @override
  State createState() => new ChatWindow();
}

class ChatWindow extends State<Chat> with TickerProviderStateMixin {
  final List<Msg> _messages = <Msg>[];
  final TextEditingController _textController = new TextEditingController();
  bool _isWriting = false;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Chat Application'),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 0.0 : 6.0,
      ),
      body: new Column(
        children: <Widget>[
          new Flexible(
            child: new ListView.builder(
              itemBuilder: (_, int index) => _messages[index],
              itemCount: _messages.length,
              reverse: true,
              padding: new EdgeInsets.all(6.0),
            ),
          ),
          new Divider(height: 1.0),
          new Container(
            child: _buildComposer(),
            decoration: new BoxDecoration(color: Theme.of(context).cardColor),
          )
        ],
      ),
    );
  }

  Widget _buildComposer() {
    return new IconTheme(
      data: new IconThemeData(color: Theme.of(context).accentColor),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 9.0),
        child: new Row(
          children: <Widget>[
            new Flexible(
              child: new TextField(
                controller: _textController,
                onChanged: (String txt) {
                  setState(() {
                    _isWriting = txt.length > 0;
                  });
                },
                onSubmitted: _submitMsg,
                decoration: new InputDecoration.collapsed(
                    hintText: "Enter some text to send a message"),
              ),
            ),
            new Container(
                margin: new EdgeInsets.symmetric(horizontal: 3.0),
                child: Theme.of(context).platform == TargetPlatform.iOS
                    ? new CupertinoButton(
                        child: new Text("Submit"),
                        onPressed: _isWriting
                            ? () => _submitMsg(_textController.text)
                            : null)
                    : new IconButton(
                        icon: new Icon(Icons.message),
                        onPressed: _isWriting
                            ? () => _submitMsg(_textController.text)
                            : null))
          ],
        ),
        decoration: Theme.of(context).platform == TargetPlatform.iOS
            ? new BoxDecoration(
                border:
                    new Border(top: new BorderSide(color: Colors.brown[200])))
            : null,
      ),
    );
  }

  void _submitMsg(String txt) async {
    _textController.clear();

    setState(() {
      _isWriting = false;
    });

    Msg msg = new Msg(
      txt: txt,
      animationController: new AnimationController(
          vsync: this, duration: new Duration(milliseconds: 800)),
      userMsg: true,
    );

    setState(() {
      _messages.insert(0, msg);
    });

    msg.animationController.forward();

    // watson response
    final watsonMsg = await Watson.call(txt);

    Msg _watsonText = new Msg(
        txt: watsonMsg,
        animationController: new AnimationController(
            vsync: this, duration: new Duration(milliseconds: 800)),
        userMsg: false);

    setState(() {
      _messages.insert(0, _watsonText);
    });

    _watsonText.animationController.forward();
  }

  @override
  void dispose() {
    for (Msg msg in _messages) {
      msg.animationController.dispose();
    }

    super.dispose();
  }
}

class Msg extends StatelessWidget {
  Msg({this.txt, this.animationController, this.userMsg});
  final String txt;
  final AnimationController animationController;
  final bool userMsg;

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
      sizeFactor: new CurvedAnimation(
          parent: animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: new Container(
        margin: const EdgeInsets.symmetric(vertical: 15.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Container(
                margin: this.userMsg == true
                    ? const EdgeInsets.only(right: 10)
                    : const EdgeInsets.only(left: 160.0),
                child: this.userMsg == true
                    ? new CircleAvatar(
                        child: new Text(defaultUserName[0]),
                        backgroundColor: Colors.blue)
                    : new CircleAvatar(
                        child: new Text('W'), backgroundColor: Colors.green)),
            new Expanded(
              child: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(this.userMsg == true ? defaultUserName : 'Watson',
                      style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 6.0),
                    child: new Text(txt),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
