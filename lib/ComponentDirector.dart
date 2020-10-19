import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'VideoPage.dart';

class ComponentDirector extends StatefulWidget {
  ComponentDirector({Key key, this.title, this.doc}) : super(key: key){
  
  }

  final String title;
  final QueryDocumentSnapshot doc;
  List<Widget> pages; 
  int currentPage = 0;
  int numPages;

  @override
  _ComponentDirectorState createState() => _ComponentDirectorState();
}

class _ComponentDirectorState extends State<ComponentDirector>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  print('PREVIOUS PAGE: ' + widget.currentPage.toString());

                  if(widget.currentPage < (widget.numPages - 1)){
                    setState(() {widget.currentPage++;});
                    //build(context);
                  }                    
                  print('CURRENT PAGE: ' + widget.currentPage.toString());

                },
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 26.0,
        ),
      )
    ),],
        ),
        body: StreamBuilder(
          stream: FirebaseFirestore.instance.collection(widget.doc.reference.collection('Components').path).snapshots(),
           builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if(!snapshot.hasData) return new Text('No module components found');            
            widget.pages = parseComponents(snapshot);
            widget.numPages = widget.pages.length;
            return widget.pages[widget.currentPage];
      },)

    );
  }

  List<Widget> parseComponents(AsyncSnapshot<QuerySnapshot> snapshot){
    return snapshot.data.docs.map((doc) {
      if(doc.id.contains('Video')){
        print(doc.id);
        return new VideoPage(id: doc.data()['Video ID'], title: 'Video');
      }
    }).toList();
  }
}
