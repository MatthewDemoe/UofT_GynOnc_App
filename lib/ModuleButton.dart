import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'HelperFunctions.dart';
import 'package:uoft_gynonc_app/ComponentDirector.dart';

class ModuleButton extends StatelessWidget {
  ModuleButton({this.doc});

  //The document for this module
  //Contains all the module information
  final QueryDocumentSnapshot doc;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerLeft,
      height: 120,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.all(10),
      //The actual button
      child: RaisedButton(
        elevation: 10.0,
        color: Colors.cyan[700],
        padding: EdgeInsets.all(5),
        //The contents of the button, text and icon
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 5),
              width: MediaQuery.of(context).size.width * 0.66,
              //Get the name of this module
              child: Text(
                doc.id,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
            //This is the icon on the right of the button
            //The expanded type will let the icon fill up the correct amount of space
            Expanded(
              //We need to asynchronosly build the icon because it is in firebase storage
              child: FutureBuilder(
                  builder: (context, snapshot) {
                    //When we have the data
                    if (snapshot.connectionState == ConnectionState.done)
                      return Container(
                          alignment: Alignment.center,
                          height: 110.0,
                          //Create the white circle, as well as the cyan and pink accents
                          child: Stack(
                            fit: StackFit.loose,
                            //Overflow allows us to see the pink/cyan highlights
                            //Otherwise they would be cut off
                            overflow: Overflow.visible,
                            alignment: Alignment.center,
                            children: [
                              Positioned(
                                top: 5.0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.pink[400],
                                  radius: 50.0,
                                ),
                              ),
                              Positioned(
                                bottom: 5.0,
                                child: CircleAvatar(
                                  backgroundColor: Colors.cyan[300],
                                  radius: 50.0,
                                ),
                              ),
                              CircleAvatar(
                                backgroundColor: Colors.white,
                                radius: 50.0,
                                child: snapshot.hasData
                                    ? snapshot.data
                                    : CircularProgressIndicator(),
                              ),
                            ],
                          ));

                    //Display progress indicators while we are waiting for the icon
                    if (snapshot.connectionState == ConnectionState.waiting)
                      return Container(
                        height: 110.0,
                        width: 110.0,
                        child: CircularProgressIndicator(),
                      );

                    return Container(
                      height: 110.0,
                      width: 110.0,
                      child: CircularProgressIndicator(),
                    );
                  },

                  //The image we are waiting to receive
                  future: getImage(
                    doc.data()['Icon'],
                  )),
            ),
          ],
        ),

        //When we click the module button, we want to start exploring the contents
        //ComponentDirector handles moving between different module components
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ComponentDirector(
                        title: 'First',
                        doc: doc,
                        pageNum: 0,
                      )));
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
