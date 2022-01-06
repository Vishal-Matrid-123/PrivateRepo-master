//import 'dart:html';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:provider/provider.dart';
// import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

// import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/AppPages/HomeScreen/HomeScreen.dart';

// import 'package:untitled2/AppPages/SplashScreen/GuestxxResponsexx/GuestResponsexx.dart';
import 'package:untitled2/AppPages/SplashScreen/TokenResponse/TokenxxResponsexx.dart';
import 'package:untitled2/Constants/ConstantVariables.dart';
import 'package:untitled2/utils/ApiCalls/ApiCalls.dart';
import 'package:untitled2/utils/CartBadgeCounter/CartBadgetLogic.dart';
// import 'package:untitled2/utils/utils/build_config.dart';

// import '../LoginScreen/LoginScreen.dart';
import 'package:notification_permissions/notification_permissions.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String name = "MyAssets/logo.png";
  var _guestCustomerID;
  var _guestGUID;
  var permGranted = "granted";
  var permDenied = "denied";
  var permUnknown = "unknown";
  var permProvisional = "provisional";
  bool shouldScaleDown = true; // c
  final width = 200.0;
  final height = 300.0;
  late AnimationController animationController;
  var animation;

  var isVisible = false;

  Future initilaize() async {
    ConstantsVar.prefs = await SharedPreferences.getInstance();
    if(ConstantsVar.prefs.getStringList('RecentProducts') == null) {
      ConstantsVar.prefs.setStringList('RecentProducts', []);
    }
    // setState(())
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if (!isAllowed) {
    //     // This is just a basic example. For real apps, you must show some
    //     // friendly dialog box before call the request method.
    //     // This is very important to not harm the user experience
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });
    animationController = new AnimationController(
        vsync: this, duration: new Duration(seconds: 5));
    animation =
        new CurvedAnimation(parent: animationController, curve: Curves.easeOut);

    animation.addListener(() => this.setState(() {}));
    animationController.forward();
    getCheckNotificationPermStatus();
    Future.delayed(
      Duration(seconds: 4, milliseconds: 80),
    ).then((value) => setState(() => isVisible = true));
    initilaize().then((value) {
      _guestCustomerID = ConstantsVar.prefs.getString('guestCustomerID');
      print('init');
      print('$_guestCustomerID');
      if (_guestCustomerID == null ||
          _guestCustomerID == '' ||
          _guestCustomerID.toString().isEmpty) {
        print('guestCustomerID is null');
        ApiCalls.getApiTokken(context).then((value) {
          TokenResponse myResponse = TokenResponse.fromJson(value);
          _guestCustomerID = myResponse.cutomer.customerId;
          _guestGUID = myResponse.cutomer.customerGuid;
          ConstantsVar.prefs.setString('guestCustomerID', '$_guestCustomerID');
          ConstantsVar.prefs.setString('guestGUID', _guestGUID);
          ConstantsVar.prefs.setString('sepGuid', _guestGUID!);
          int val = 0;
          ApiCalls.readCounter(
                  customerGuid: ConstantsVar.prefs.getString('guestGUID')!)
              .then((value) {
            setState(() {
              val = value;
            });
            context.read<cartCounter>().changeCounter(val);
            Navigator.pushReplacement(
                context,
                CupertinoPageRoute(
                  builder: (context) => MyApp(),
                ));
          });
        }
            // },
            );
      } else {
        // int val = 0;
        getCartBagdge().then(
          (value) => Future.delayed(
            Duration(seconds: 6),
            () => Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => MyApp(),
              ),
            ),
          ),
        );
      }
    }).then((value) => null);

    // // } else {
    // }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: true,
      child: FlutterSizer(
        builder: (context, orientation, screenType) {
          return Scaffold(
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    width: animation.value * width,
                    height: animation.value * height,
                    child: Hero(
                      tag: 'HomeImage',
                      child: Image.asset(name),
                      transitionOnUserGestures: true,
                      placeholderBuilder: (context,_,widget) {
                        return Container(
                          height: 15.w,
                          width: 15.w,
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                  SpinKitRipple(
                    color: Colors.red,
                    size: 60,
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future getCustomerId() async {
    ConstantsVar.prefs = await SharedPreferences.getInstance();
    if (ConstantsVar.prefs.getString('userId') != null) {
      ConstantsVar.customerID = ConstantsVar.prefs.getString('userId')!;
    }

    return ConstantsVar.customerID;
  }

  Future getCartBagdge() async {
    int val = 0;
    Future.delayed(
        Duration(seconds: 3),
        () => ApiCalls.readCounter(
                    customerGuid: ConstantsVar.prefs.getString('guestGUID')!)
                .then((value) {
              if (mounted)
                setState(() {
                  val = value;
                  context.read<cartCounter>().changeCounter(val);
                });
            }));
  }

  /// Checks the notification permission status
  Future<String> getCheckNotificationPermStatus() async {
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
    return NotificationPermissions.getNotificationPermissionStatus()
        .then((status) {
      switch (status) {
        case PermissionStatus.denied:
          return permDenied;
        case PermissionStatus.granted:
          return permGranted;
        case PermissionStatus.unknown:
          requestPermission();
          return permUnknown;
        case PermissionStatus.provisional:
          return permProvisional;
        default:
          return '';
      }
    });
  }

  requestPermission() async {
    await NotificationPermissions.requestNotificationPermissions();
  }

// Future<void> getSearchSuggestions() async {
//   final uri = Uri.parse("uri");
// }
}
