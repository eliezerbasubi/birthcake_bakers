import 'package:birthcake_bakers/chat/chat_activity.dart';
import 'package:birthcake_bakers/models/users_model.dart';
import 'package:flutter/material.dart';

class ChatWindow extends StatefulWidget {
  @override
  _ChatWindowState createState() => _ChatWindowState();
}

class _ChatWindowState extends State<ChatWindow> with TickerProviderStateMixin{
  List<Messages> messages = new List<Messages>();
  TextEditingController _textEditingController = new TextEditingController();
  bool _isWriting = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MainScreen(currentUserId:  "2XbtXuv8d8efiHVKbqKGSRPmFxk1",),
      
    );
  }

@override
  void dispose() {
    for (Messages _messages in messages) {
      _messages.animationController.dispose();
    }
    super.dispose();
  }
  void _submitMsg(String msg){
    _textEditingController.clear();
    setState(() {
     _isWriting = false; 
    });

    Messages _msg = Messages(
      msg: msg,
      animationController: new AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 800),
      ),
    );

    setState(() {
     messages.insert(0, _msg); 
    });

    _msg.animationController.forward();
  }

  buildBuildComposer() => IconTheme(
    data:  IconThemeData(color: Theme.of(context).accentColor),
    child: Container(
      margin: EdgeInsets.symmetric(horizontal: 9.0),
      child: Row(
        children: <Widget>[
          Flexible(
            child: TextField(
              controller: _textEditingController,
              onChanged: (msg){
                setState(() {
                 this._isWriting = msg.length > 0;  
                });
              },
              onSubmitted: (d){},
              decoration: InputDecoration.collapsed(hintText: "Type your message here"),
            ),
          ),

          Container(
            margin: EdgeInsets.all(3.0),
            child: IconButton(
              icon: Icon(Icons.send),
              onPressed: _isWriting ? ()=>_submitMsg(_textEditingController.text) : null,
            ),
          )
        ],
      ),
    ),
  );

}

class Messages extends StatelessWidget {
  final String msg;
  final AnimationController animationController;
  Messages({this.msg, this.animationController});
  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut
      ),
      axisAlignment: 0.0,
      child: Container(
        margin: EdgeInsets.all(8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 18.0),
              child: CircleAvatar(
                backgroundImage: AssetImage(users[0].profileURL),
              ),
            ),

            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(users[0].name, style: Theme.of(context).textTheme.subhead,),
                  Container(
                    margin: EdgeInsets.only(top: 6.0),
                    child: Text(msg))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}