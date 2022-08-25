
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatScreen extends StatefulWidget {

   ChatScreen() ;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
TextEditingController textEditingController = TextEditingController();

class _ChatScreenState extends State<ChatScreen> {
  final record = FlutterSoundRecorder();
  @override
  void initState()
  {
    initRecorder();
    // TODO: implement initState
  }
  @override
  void dispose() {
    record.closeRecorder();
    // TODO: implement dispose
    super.dispose();
  }
  Future initRecorder() async{
    final status = await Permission.microphone.request();
    if(status != PermissionStatus.granted){
      throw 'Microphone';
    }
    await record.openRecorder();
    record.setSubscriptionDuration(
      const Duration(milliseconds:  500),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('chat').orderBy('time').snapshots()
          ,builder: (context, snapshot)
            {
              List<MessageLine> messageWidgets = [];
              if(!snapshot.hasData){
                return const CircularProgressIndicator();
              }

              final messages = snapshot.data!.docs.reversed;
              for(var message in messages) {
                final messageText = message.get('text');
                if (messageText == null || message.get('name') == null) {

                } else {
                                  messageWidgets.add(MessageLine(messageText: messageText,sender:message.get('name'),isMe: 'amr.atef503092@gmail.com'== message.get('name'),));

                }
              }
              return Expanded(
                child: ListView(
                  reverse: true,
                  padding: EdgeInsets.symmetric(horizontal: 10,vertical: 20),
                  children: messageWidgets,
                ),
              );
            },),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.black,
                    width: 2
                  )
                )
              ),
              child: Row(
                children:
                [
                 Expanded(child: TextFormField(decoration: const InputDecoration(
                   hintText: "Type Text",
                 ),controller: textEditingController  ,)),
                  IconButton(onPressed: (){
                    if(textEditingController.text.isNotEmpty){
                      FirebaseFirestore.instance.collection('chat')
                          .add({
                        'name' :'amr.atef503092@gmail.com',
                        'text' :textEditingController.text,
                        'time' : DateTime.now(),
                      }).then((value) {
                        textEditingController.clear();
                      });
                    }

                  },
                      icon: Icon(
                        Icons.abc
                      )),
                  
                  StreamBuilder<RecordingDisposition>(stream: record.onProgress,
                    builder: (context, snapshot) {
                    final duration = snapshot.hasData ? snapshot.data!.duration :Duration.zero;
                    return Text("${duration.inSeconds} s");
                  },),
                  IconButton(onPressed: () async{
                    if(record.isRecording){
                      await stop();
                    }else{
                      await recorder();
                    }
                    setState(() {

                    });
                  }, icon: Icon(Icons.add))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
  Future recorder() async{
    await record.startRecorder( toFile: 'audio');
  }
  Future stop() async{
  final path =   await record.stopRecorder();
    final audioFile =File(path!);
    print("Recorder  $audioFile");
  }

}
class MessageLine extends StatelessWidget {
  MessageLine({
    this.messageText,
    this.sender,
    this.isMe,
  });

  String? messageText;
  String? sender;
  bool? isMe;

  @override
  Widget build(BuildContext context) {
    return (isMe!)
        ? Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('$sender'),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
                topLeft: Radius.circular(30),
              ),
              color: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(
                  '$messageText',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    )
        : Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$sender'),
            Material(
              elevation: 2,
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                  topRight: Radius.circular(30)),
              color: Color(0xffAAACAE),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(
                  '$messageText',
                  style: TextStyle(
                    color: Color(0xff1A1D21),
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}