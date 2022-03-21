import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gpspro/Config.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:gpspro/commons/traccar_mod/lib/traccar_gennissi.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  late SharedPreferences prefs;

  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final TextEditingController _serverFilter = new TextEditingController();

  String _email = "";
  String _password = "";
  bool isBusy = true;
  bool isLoggedIn = false;
  String _notificationToken = "";
  FormType _form = FormType
      .login; // our default setting is to login, and we should switch to creating an account when the user chooses to

  AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    //_serverFilter.addListener(_urlListen);
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);

    checkPreference();
    initFirebase();
    super.initState();
  }

  Future<void> initFirebase() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    /// Note: permissions aren't requested here just to demonstrate that can be
    /// done later
    final IOSInitializationSettings initializationSettingsIOS =
        IOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
            onDidReceiveLocalNotification: (id, title, body, payload) async {});
    const MacOSInitializationSettings initializationSettingsMacOS =
        MacOSInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false);

    final InitializationSettings initializationSettings =
        InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
            macOS: initializationSettingsMacOS);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
    });

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    await messaging.getToken().then((value) => {_notificationToken = value!});
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      // print(message.notification.title);
      // AndroidNotificationDetails androidPlatformChannelSpecifics =
      //     AndroidNotificationDetails(
      //         "0", message.notification.title, message.notification.body,
      //         channelShowBadge: false,
      //         importance: Importance.max,
      //         priority: Priority.high,
      //         onlyAlertOnce: true);
      // NotificationDetails platformChannelSpecifics =
      //     NotificationDetails(android: androidPlatformChannelSpecifics);
      // await flutterLocalNotificationsPlugin.show(0, message.notification.title,
      //     message.notification.body, platformChannelSpecifics,
      //     payload: 'item x');
    });

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  void checkPreference() async {
    prefs = await SharedPreferences.getInstance();

    if (prefs.get('url') != null) {
      _serverFilter.text = prefs.getString('url')!;
    } else {
      _serverFilter.text = "http://demo.traccar.org";
    }

    if (prefs.get('email') != null) {
      _emailFilter.text = prefs.getString('email')!;
      _passwordFilter.text = prefs.getString('password')!;
      _serverFilter.text = prefs.getString('url')!;
      _loginPressed();
    } else {
      isBusy = false;
      setState(() {});
    }
  }
  //
  // void _urlListen() {
  //   if (_serverFilter.text.isEmpty) {
  //     _url = "";
  //   } else {
  //     _url = _serverFilter.text;
  //   }
  // }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  // Swap in between our two forms, registering and logging in
  void _formChange() async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(AppLocalizations.of(context)!.translate('loginTitle'),
            style: TextStyle(color: CustomColor.secondaryColor)),
        centerTitle: true,
      ),
      body: new Container(
          padding: EdgeInsets.all(16.0),
          child: ListView(
              shrinkWrap: true,
              padding: EdgeInsets.all(15.0),
              children: <Widget>[
                isBusy
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : isLoggedIn
                        ? Center(child: CircularProgressIndicator())
                        : new Column(
                            children: <Widget>[_buildTextFields()],
                          )
              ])),
    );
  }

  Widget _buildTextFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: Card(
              elevation: 10,
              child: Image.asset(
                'images/logo.png',
                width: 200,
                height: 200,
              ),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _emailFilter,
              decoration: new InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.translate('username')),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.translate('userPassword')),
              obscureText: true,
            ),
          ),
          _buildButtons(),
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (_form == FormType.login) {
      return new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              child: ElevatedButton(
                onPressed: () {
                  _loginPressed();
                },
                child: Text(
                    AppLocalizations.of(context)!.translate('loginTitle'),
                    style: TextStyle(fontSize: 18)),
              ),
            ),
//            new FlatButton(
//              child: new Text('Register'),
//              onPressed: _formChange,
//            ),
          ],
        ),
      );
    } else {
      return new Container(
        child: new Column(
          children: <Widget>[
            new Container(
              child: ElevatedButton(
                onPressed: () {
                  _createAccountPressed();
                },
                child: Text("Submit", style: TextStyle(fontSize: 18)),
              ),
            ),
            new TextButton(
              child: new Text('Have an account? Click here to login.'),
              onPressed: _formChange,
            )
          ],
        ),
      );
    }
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password

  void _loginPressed() async {
    try {
      await prefs.setString('url', SERVER_URL);
      prefs.setString("code", PURCHASE_CODE);
      // prefs.setString("domain", _url);
      _showProgress(true);
      Traccar.login(PURCHASE_CODE, _email, _password).then((response) {
        if (response != null) {
          if (response.statusCode == 200) {
            if (json.decode(response.body)["success"] == "Failed") {
              isBusy = false;
              isLoggedIn = true;
              _showProgress(false);
              Fluttertoast.showToast(
                  msg: "Contact Developer for support",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.black54,
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              print(response);
              prefs.setBool("popup_notify", true);
              prefs.setString("user", response.body);
              isBusy = false;
              isLoggedIn = true;
              _showProgress(false);
              final user = User.fromJson(jsonDecode(response.body));
              prefs.setString("userId", user.id.toString());
              prefs.setString("userJson", response.body);
              updateUserInfo(user, user.id.toString());
              Navigator.pushReplacementNamed(context, '/home');
            }
          } else if (response.statusCode == 401) {
            isBusy = false;
            isLoggedIn = false;
            _showProgress(false);
            Fluttertoast.showToast(
                msg: AppLocalizations.of(context)!.translate("loginFailed"),
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0);
            setState(() {});
          } else if (response.statusCode == 400) {
            isBusy = false;
            isLoggedIn = false;
            if (response.body ==
                "Account has expired - SecurityException (PermissionsManager:259 < *:441 < SessionResource:104 < ...)") {
              setState(() {});
              showDialog(
                context: context,
                builder: (context) => new AlertDialog(
                  title:
                      Text(AppLocalizations.of(context)!.translate("failed")),
                  content: Text(
                      AppLocalizations.of(context)!.translate("loginFailed")),
                  actions: <Widget>[
                    new FlatButton(
                      onPressed: () {
                        _showProgress(false);
                        Navigator.of(context, rootNavigator: true)
                            .pop(); // dismisses only the dialog and returns nothing
                      },
                      child: new Text(
                          AppLocalizations.of(context)!.translate("ok")),
                    ),
                  ],
                ),
              );
            }
          } else {
            isBusy = false;
            isLoggedIn = false;
            _showProgress(false);
            Fluttertoast.showToast(
                msg: response.body,
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.black54,
                textColor: Colors.white,
                fontSize: 16.0);
            setState(() {});
          }
        } else {
          isLoggedIn = false;
          isBusy = false;
          setState(() {});
          _showProgress(false);
          Fluttertoast.showToast(
              msg: AppLocalizations.of(context)!.translate("errorMsg"),
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              backgroundColor: Colors.black54,
              textColor: Colors.white,
              fontSize: 16.0);
        }
      });
    } catch (e) {
      isBusy = false;
      isLoggedIn = false;
      _showProgress(false);
      setState(() {});
    }
  }

  void _createAccountPressed() {
    print('The user wants to create an account with $_email and $_password');
  }

  void updateUserInfo(User user, String id) {
    var oldToken = user.attributes!["notificationTokens"].toString().split(",");
    var tokens = user.attributes!["notificationTokens"];

    if (user.attributes!.containsKey("notificationTokens")) {
      if (!oldToken.contains(_notificationToken)) {
        user.attributes!["notificationTokens"] =
            _notificationToken + "," + tokens;
      }
    } else {
      user.attributes!["notificationTokens"] = _notificationToken;
    }

    String userReq = json.encode(user.toJson());

    Traccar.updateUser(userReq, id).then((value) => {});
  }

  Future<void> _showProgress(bool status) async {
    if (status) {
      return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
            content: new Row(
              children: [
                CircularProgressIndicator(),
                Container(
                    margin: EdgeInsets.only(left: 5),
                    child: Text(AppLocalizations.of(context)!
                        .translate('sharedLoading'))),
              ],
            ),
          );
        },
      );
    } else {
      Navigator.pop(context);
    }
  }
}
