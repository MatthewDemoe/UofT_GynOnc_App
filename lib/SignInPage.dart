import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:uoft_gynonc_app/HelperFunctions.dart';
import 'package:uoft_gynonc_app/VerificationPage.dart';
import 'HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInPage extends StatefulWidget {
  SignInPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  //Strings containing user input
  String emailAddress = '';
  String password = '';
  String confirmPassword = '';
  String firstName = '';
  String lastName = '';

  //Whether or not to hide the input password
  bool obscurePassword = true;

  //Is the user signing in or creating an account - display different widgets
  bool signIn = true;

  //Change display if the user forgot their password
  bool forgotPassword = false;

  //The current user
  User theUser;

  //Has the user made any input mistakes
  bool usernameMistake = false;
  bool passwordMistake = false;
  bool nameMistake = false;

  //Test Size
  double messageSize = 14.0;

  @override
  void initState() {
    super.initState();

    //We go to this page initially, if the user is signed in, go to the home page instead
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
      } else if (!user.isAnonymous) {
        theUser = user;
        if (user.emailVerified) {
          print('Email is Verified' + user.email);
          Navigator.pop(context);
          Navigator.push(
              context,
              //The button will return us to the previous page in the list
              MaterialPageRoute(
                  builder: (context) => HomePage(
                        key: widget.key,
                        title: 'Home Page',
                      )));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Builder(
            builder: (context) => Container(
                alignment: Alignment.center,
                height: size.height,
                width: size.width,
                child: ListView(
                    shrinkWrap: true,
                    children: <Widget>[
                          Container(
                            alignment: Alignment.topCenter,
                            padding: EdgeInsets.symmetric(vertical: 25),
                            height: 150,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    fit: BoxFit.fitHeight,
                                    image:
                                        AssetImage('assets/GynOnc_Logo.png'))),
                          )
                        ] +
                        //If the user is not on the forgot password page
                        (!forgotPassword
                            //If the user is on the sign in page, build the sign in page
                            ? (signIn
                                ? buildSignIn(context)
                                //They are not on the sign in or forgot password page, so go to create account page
                                : buildCreateAccount(context))
                            //They are on the reset password page, build it
                            : buildReset(context))))));
  }

  List<Widget> buildSignIn(BuildContext context) {
    return [
      Container(
        child: Text(
          'Sign In',
          style: TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
      ),
      /////////////////////////////////EMAIL////////////////////////////////////
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          //We need to add the key to the object so that the list knows they are unique objects
          //Otherwise the input would not be cleared when we went to a different "screen"
          key: ObjectKey('Email Input'),
          initialValue: '',
          decoration: InputDecoration(
              labelStyle:
                  TextStyle(color: usernameMistake ? Colors.red : Colors.black),
              labelText: usernameMistake ? 'Email Address *' : 'Email Address'),
          //Set string when the user inputs anything
          onChanged: (inEmail) {
            setState(() {
              emailAddress = inEmail;
            });
          },
          onFieldSubmitted: (inEmail) {
            setState(() {
              emailAddress = inEmail;
            });
          },
        ),
      ),
      ////////////////PASSWORD////////////////////////
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          key: ObjectKey('Password Input'),
          obscureText: obscurePassword,
          decoration: InputDecoration(
              labelStyle:
                  TextStyle(color: passwordMistake ? Colors.red : Colors.black),
              suffixIcon: IconButton(
                //button to toggle whether to hide the password
                icon: Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              labelText: passwordMistake ? 'Password *' : 'Password'),
          //Set string when the user inputs anything
          onChanged: (inPassword) {
            setState(() {
              password = inPassword;
            });
          },
          onFieldSubmitted: (inPassword) {
            setState(() {
              password = inPassword;
            });
          },
        ),
      ),
      //////////////////////////////////BOTTOM TEXT/////////////////////////////////
      Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: 'Don\'t have an account? ',
                style: TextStyle(color: Colors.black, fontSize: messageSize)),
            //Sends us to create account page
            TextSpan(
                text: 'Create one.',
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: messageSize),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      signIn = false;
                      usernameMistake = false;
                      passwordMistake = false;
                      password = '';
                      emailAddress = '';
                      lastName = '';
                      firstName = '';
                    });
                    print(emailAddress);
                  }),
          ]),
        ),
      ),
      //Sends us to forgot password page
      Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: 'Forgot your password? ',
                style: TextStyle(color: Colors.black, fontSize: messageSize)),
            TextSpan(
                text: 'Reset it.',
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: messageSize),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      forgotPassword = true;
                    });
                    print(emailAddress);
                  }),
          ]),
        ),
      ),
      //////////////////CONFIRM BUTTON///////////////////////////////
      Container(
          alignment: Alignment.center,
          width: 100,
          padding: EdgeInsets.symmetric(vertical: 25),
          child: RaisedButton(
            child: Text(
              'Next',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            color: getAppColor(),
            //Try to sign in, send appropriate error messages
            onPressed: () async {
              try {
                UserCredential userCredential = await FirebaseAuth.instance
                    .signInWithEmailAndPassword(
                        email: emailAddress, password: password);
              } on FirebaseAuthException catch (e) {
                if (e.code == 'user-not-found') {
                  showErrorSnackbar(
                      context, 'No account found with that email.');

                  setState(() {
                    usernameMistake = true;
                  });
                } else if (e.code == 'wrong-password') {
                  showErrorSnackbar(context, 'Email or password is incorrect.');

                  setState(() {
                    passwordMistake = true;
                  });
                } else {
                  setState(() {
                    usernameMistake = false;
                    passwordMistake = false;
                  });

                  theUser.reload();
                }
              } catch (e) {
                print(e);
              }
            },
          )),
    ];
  }

  ////////////////////////////////ACCOUNT CREATION PAGE////////////////////////////////////
  List<Widget> buildCreateAccount(BuildContext context) {
    return <Widget>[
      Container(
        child: Text(
          'Create Account',
          style: TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
      ),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          //We need to add the key to the object so that the list knows they are unique objects
          //Otherwise the input would not be cleared when we went to a different "screen"
          key: ObjectKey('First Name Input'),
          initialValue: '',
          //Change colour etc. when there is an error
          decoration: InputDecoration(
              labelStyle:
                  TextStyle(color: nameMistake ? Colors.red : Colors.black),
              labelText: nameMistake ? 'First Name *' : 'First Name'),
          //update stored name whenever user inputs
          onChanged: (inName) {
            setState(() {
              firstName = inName;
            });
          },
          onFieldSubmitted: (inName) {
            setState(() {
              firstName = inName;
            });
          },
        ),
      ),
      /////////////////////////LAST NAME////////////////////////////////////////
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          key: ObjectKey('Last Name Input'),
          decoration: InputDecoration(
              //Change style if there's an error
              labelStyle:
                  TextStyle(color: nameMistake ? Colors.red : Colors.black),
              labelText: nameMistake ? 'Last Name *' : 'Last Name'),
          //Save input
          onChanged: (inName) {
            setState(() {
              lastName = inName;
            });
          },
          onFieldSubmitted: (inName) {
            setState(() {
              lastName = inName;
            });
          },
        ),
      ),
      ////////////////////////////EMAIL///////////////////////////////
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          key: ObjectKey('Email Input'),
          decoration: InputDecoration(
              //Change style if there's an error
              labelStyle:
                  TextStyle(color: usernameMistake ? Colors.red : Colors.black),
              labelText: usernameMistake ? 'Email Address *' : 'Email Address'),
          //Save input
          onChanged: (inEmail) {
            setState(() {
              emailAddress = inEmail;
            });
          },
          onFieldSubmitted: (inEmail) {
            setState(() {
              usernameMistake = false;

              emailAddress = inEmail;
            });
          },
        ),
      ),
      ////////////////////////////////Password///////////////////////////////////
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          key: ObjectKey('Password Input'),
          obscureText: obscurePassword,
          decoration: InputDecoration(
              //Change style if there's an error
              labelStyle:
                  TextStyle(color: passwordMistake ? Colors.red : Colors.black),
              //Toggle password visibility
              suffixIcon: IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              //Change style if there's an error

              labelText: passwordMistake ? 'Password *' : 'Password'),
          //Save input
          onChanged: (inPassword) {
            setState(() {
              password = inPassword;
            });
          },
          onFieldSubmitted: (inPassword) {
            setState(() {
              password = inPassword;
            });
          },
        ),
      ),
      /////////////////////////////CONFIRM PASSWORD//////////////////////////////////////
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          key: ObjectKey('Confirm Password Input'),
          obscureText: obscurePassword,
          decoration: InputDecoration(
              //Change style if there's a mistake
              labelStyle:
                  TextStyle(color: passwordMistake ? Colors.red : Colors.black),
              //toggle password visibility
              suffixIcon: IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              labelText:
                  passwordMistake ? 'Confirm Password *' : 'Confirm Password'),
          //Save input
          onChanged: (inPassword) {
            setState(() {
              confirmPassword = inPassword;
            });
          },
          onFieldSubmitted: (inPassword) {
            setState(() {
              confirmPassword = inPassword;
            });
          },
        ),
      ),
      ////////////////////////////////////BOTTOM TEXT//////////////////////////////
      Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: 'Already have an account? ',
                style: TextStyle(color: Colors.black, fontSize: messageSize)),
            TextSpan(
                text: 'Sign in.',
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: messageSize),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      signIn = true;
                      emailAddress = '';
                      password = '';
                    });
                  }),
          ]),
        ),
      ),
      ///////////////////////////////////CONFIRM BUTTON/////////////////////////////////////
      Container(
          alignment: Alignment.center,
          width: 100,
          padding: EdgeInsets.symmetric(vertical: 25),
          child: RaisedButton(
            child: Text(
              'Next',
              style: getButtonTextStyle(),
            ),
            color: getAppColor(),
            onPressed: () async {
              if ((firstName == '') || (lastName == '')) {
                setState(() {
                  nameMistake = true;
                });

                showErrorSnackbar(
                    context, 'Please enter a first and last name.');
              } else if (password == confirmPassword) {
                setState(() {
                  nameMistake = false;

                  passwordMistake = false;
                });

                //Try to create an account. Display any necessary error messages
                try {
                  UserCredential userCredential = await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: emailAddress, password: password);
                  userCredential.user.sendEmailVerification();
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Email verification sent.'),
                    action: SnackBarAction(
                        label: 'Okay',
                        onPressed: () {
                          //Dismiss
                        }),
                  ));

                  initializeUser();

                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      //The button will return us to the previous page in the list
                      MaterialPageRoute(
                          builder: (context) => VerificationPage(
                                key: widget.key,
                                title: 'Verification Page',
                              )));
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'weak-password') {
                    showErrorSnackbar(context, 'Password is too weak.');

                    setState(() {
                      passwordMistake = true;
                    });
                  } else if (e.code == 'email-already-in-use') {
                    showErrorSnackbar(context, 'Email already in use.');

                    setState(() {
                      usernameMistake = true;
                    });
                  }
                } catch (e) {
                  print(e);
                }
              } else {
                showErrorSnackbar(context, 'Passwords do not match.');

                setState(() {
                  passwordMistake = true;
                });
              }
            },
          )),
    ];
  }

  ////////////////////////RESET PASSWORD//////////////////////////////
  List<Widget> buildReset(BuildContext context) {
    return [
      Container(
        child: Text(
          'Reset Your Password',
          style: TextStyle(fontSize: 32),
          textAlign: TextAlign.center,
        ),
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
      ),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          decoration: InputDecoration(
              labelStyle:
                  //Change style if there is an error
                  TextStyle(color: usernameMistake ? Colors.red : Colors.black),
              labelText: usernameMistake ? 'Email Address *' : 'Email Address'),
          //Save input
          onFieldSubmitted: (inEmail) {
            setState(() {
              emailAddress = inEmail;
            });
            print(emailAddress);
          },
        ),
      ),
      //////////////////////////////BOTTOM TEXT////////////////////////////////////////
      Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: 'Don\'t need to reset your password? ',
                style: TextStyle(color: Colors.black, fontSize: messageSize)),
            TextSpan(
                text: 'Return to sign in page.',
                style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                    fontSize: messageSize),
                recognizer: TapGestureRecognizer()
                  ..onTap = () {
                    setState(() {
                      forgotPassword = false;
                    });
                    print(emailAddress);
                  }),
          ]),
        ),
      ),
      /////////////////////////////////////CONFIRM BUTTON////////////////////////////////////////
      Container(
          alignment: Alignment.center,
          width: 100,
          padding: EdgeInsets.symmetric(vertical: 25),
          child: RaisedButton(
            child: Text(
              'Next',
              style: getButtonTextStyle(),
            ),
            color: getAppColor(),
            onPressed: () {
              FirebaseAuth mAuth = FirebaseAuth.instance;
              mAuth.sendPasswordResetEmail(email: emailAddress);
              showErrorSnackbar(context, 'Password reset link sent.');
            },
          )),
    ];
  }

  void initializeUser() {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .set({});

    setNewName(firstName: firstName, lastName: lastName);

    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .collection('Evaluations')
        .doc('Marks')
        .set({});

    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .collection('Evaluations')
        .doc('Marks')
        .update({'Overall Evaluation': 'Not Attempted'});

    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .collection('Evaluations')
        .doc('Marks')
        .collection('Modules')
        .doc('Overall')
        .set({'Attempts': 0});

    FirebaseFirestore.instance
        .collection('Module Categories ')
        .snapshots()
        .forEach((element) {
      element.docs.forEach((category) {
        category.reference.collection('Modules').snapshots().forEach((module) {
          module.docs.forEach((doc) {
            //print(doc.id);

            FirebaseFirestore.instance
                .collection('Users')
                .doc(FirebaseAuth.instance.currentUser.email)
                .collection('Evaluations')
                .doc('Marks')
                .collection('Modules')
                .doc(doc.id)
                .set({'Attempts': 0});

            FirebaseFirestore.instance
                .collection('Users')
                .doc(FirebaseAuth.instance.currentUser.email)
                .collection('Evaluations')
                .doc('Marks')
                .update({doc.id + ' Evaluation': 'Not Attempted'});
          });
        });
      });
    });
  }
}
