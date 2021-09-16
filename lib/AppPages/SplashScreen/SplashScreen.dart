//import 'dart:html';
import 'package:provider/provider.dart';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:nb_utils/nb_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/AppPages/HomeScreen/HomeScreen.dart';
import 'package:untitled2/AppPages/SplashScreen/GuestxxResponsexx/GuestResponsexx.dart';
import 'package:untitled2/AppPages/SplashScreen/TokenResponse/TokenxxResponsexx.dart';
import 'package:untitled2/Constants/ConstantVariables.dart';
import 'package:untitled2/utils/ApiCalls/ApiCalls.dart';
import 'package:untitled2/utils/CartBadgeCounter/CartBadgetLogic.dart';
import 'package:untitled2/utils/utils/build_config.dart';

import '../LoginScreen/LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String name = "MyAssets/logo.png";
  var _guestCustomerID;
  var _guestGUID;

  Future initilaize() async {
    ConstantsVar.prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
          int val = 0;
          ApiCalls.readCounter(
                  customerGuid: ConstantsVar.prefs.getString('guestGUID')!)
              .then((value) {
            setState(() {
              val = int.parse(value);
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
        getCartBagdge().then((value) => Navigator.pushReplacement(
            context, CupertinoPageRoute(builder: (context) => MyApp())));
      }
    });

    // // } else {
    // }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
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
                    margin: EdgeInsets.all(0.5.h),
                    alignment: Alignment.topCenter,
                    child: Image.asset(name),
                  ),
                  SpinKitCircle(
                    itemBuilder: (context, index) {
                      return DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                      );
                    },
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

  checkCreds() async {
    ConstantsVar.prefs = await SharedPreferences.getInstance();
    var email = ConstantsVar.prefs.getString('email');
    var passWord = ConstantsVar.prefs.getString('passWord');
    print('Email : $email\nPassword :$passWord ');
    email == null && passWord == null
        ? Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return LoginScreen();
              },
            ),
          )
        : Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) {
                return MyApp();
              },
            ),
          );
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
                  val = int.parse(value);
                  context.read<cartCounter>().changeCounter(val);
                });
            }));
  }
}
