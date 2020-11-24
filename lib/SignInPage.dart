import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  String emailAddress = '';
  String password = '';
  String confirmPassword = '';
  String firstName = '';
  String lastName = '';

  bool obscurePassword = true;
  bool signIn = true;
  bool forgotPassword = false;
  User theUser;

  bool usernameMistake = false;
  bool passwordMistake = false;

  double messageSize = 14.0;

  @override
  void initState() {
    super.initState();

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
                        (!forgotPassword
                            ? (signIn
                                ? buildSignIn(context)
                                : buildCreateAccount(context))
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
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          decoration: InputDecoration(
              labelStyle:
                  TextStyle(color: usernameMistake ? Colors.red : Colors.black),
              labelText: usernameMistake ? 'Email Address *' : 'Email Address'),
          onFieldSubmitted: (inEmail) {
            setState(() {
              emailAddress = inEmail;
            });
            print(emailAddress);
          },
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          obscureText: obscurePassword,
          decoration: InputDecoration(
              labelStyle:
                  TextStyle(color: passwordMistake ? Colors.red : Colors.black),
              suffixIcon: IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              labelText: passwordMistake ? 'Password *' : 'Password'),
          onFieldSubmitted: (inPassword) {
            setState(() {
              password = inPassword;
            });
            print(password);
          },
        ),
      ),
      Container(
        padding: EdgeInsets.all(10),
        alignment: Alignment.center,
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: 'Don\'t have an account? ',
                style: TextStyle(color: Colors.black, fontSize: messageSize)),
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
                    });
                    print(emailAddress);
                  }),
          ]),
        ),
      ),
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
      Container(
          alignment: Alignment.center,
          width: 100,
          padding: EdgeInsets.symmetric(vertical: 25),
          child: RaisedButton(
            child: Text(
              'Next',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            color: Colors.cyan[700],
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
          decoration: InputDecoration(
              labelStyle:
                  TextStyle(color: usernameMistake ? Colors.red : Colors.black),
              labelText: usernameMistake ? 'Email Address *' : 'Email Address'),
          onFieldSubmitted: (inEmail) {
            usernameMistake = false;

            setState(() {
              emailAddress = inEmail;
            });
          },
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          obscureText: obscurePassword,
          decoration: InputDecoration(
              labelStyle:
                  TextStyle(color: passwordMistake ? Colors.red : Colors.black),
              suffixIcon: IconButton(
                icon: Icon(Icons.visibility),
                onPressed: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
              ),
              labelText: passwordMistake ? 'Password *' : 'Password'),
          onFieldSubmitted: (inPassword) {
            setState(() {
              password = inPassword;
            });
            print(password);
          },
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          obscureText: obscurePassword,
          decoration: InputDecoration(
              labelStyle:
                  TextStyle(color: passwordMistake ? Colors.red : Colors.black),
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
          onFieldSubmitted: (inPassword) {
            setState(() {
              confirmPassword = inPassword;
            });
          },
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.black),
              labelText: 'First Name'),
          onFieldSubmitted: (inName) {
            setState(() {
              firstName = inName;
            });
          },
        ),
      ),
      Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(10),
        child: TextFormField(
          decoration: InputDecoration(
              labelStyle: TextStyle(color: Colors.black),
              labelText: 'Last Name'),
          onFieldSubmitted: (inName) {
            setState(() {
              lastName = inName;
            });
          },
        ),
      ),
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
      Container(
          alignment: Alignment.center,
          width: 100,
          padding: EdgeInsets.symmetric(vertical: 25),
          child: RaisedButton(
            child: Text(
              'Next',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            color: Colors.cyan[700],
            onPressed: () async {
              if (password == confirmPassword) {
                setState(() {
                  passwordMistake = false;
                });
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
                  TextStyle(color: usernameMistake ? Colors.red : Colors.black),
              labelText: usernameMistake
                  ? 'University Email Address *'
                  : 'University Email Address'),
          onFieldSubmitted: (inEmail) {
            setState(() {
              emailAddress = inEmail;
            });
            print(emailAddress);
          },
        ),
      ),
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
                      //emailAddress = '';
                      //password = '';
                    });
                    print(emailAddress);
                  }),
          ]),
        ),
      ),
      Container(
          alignment: Alignment.center,
          width: 100,
          padding: EdgeInsets.symmetric(vertical: 25),
          child: RaisedButton(
            child: Text(
              'Next',
              style: TextStyle(fontSize: 14, color: Colors.white),
            ),
            color: Colors.cyan[700],
            onPressed: () {
              FirebaseAuth mAuth = FirebaseAuth.instance;
              mAuth.sendPasswordResetEmail(email: emailAddress);
              showErrorSnackbar(context, 'Password reset link sent.');
            },
          )),
    ];
  }

  void showErrorSnackbar(BuildContext context, String message) {
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Icon(Icons.warning)),
        Text(message),
      ]),
      action: SnackBarAction(
          label: 'Okay',
          onPressed: () {
            //Dismiss
          }),
    ));
  }

  void initializeUser() {
    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .set({});

    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .update({'First Name': firstName});

    FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser.email)
        .update({'Last Name': lastName});

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
        .collection('Module Categories ')
        .snapshots()
        .forEach((element) {
      element.docs.forEach((category) {
        category.reference.collection('Modules').snapshots().forEach((module) {
          module.docs.forEach((doc) {
            print(doc.id);
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
