import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';

// import 'package:untitled2/AppPages/CartxxScreen/ConstantVariables.dart';
import 'package:untitled2/AppPages/HomeScreen/HomeScreen.dart';
import 'package:untitled2/AppPages/MyOrders/MyOrders.dart';
import 'package:untitled2/Constants/ConstantVariables.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TopicPage extends StatefulWidget {
  TopicPage({Key? key, required this.paymentUrl}) : super(key: key);
  String paymentUrl;

  @override
  _TopicPageState createState() => _TopicPageState();
}

class _TopicPageState extends State<TopicPage> {
  final Completer<WebViewController> _controller =
  Completer<WebViewController>();
  var progressCount;
  bool isLoading = true;
  bool _willGo = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isAndroid) {
      WebView.platform = SurfaceAndroidWebView();
      context.loaderOverlay.show(
          widget: SpinKitRipple(
            color: Colors.red,
            size: 90,
          ));
    } else {
      context.loaderOverlay.show(widget: CupertinoActivityIndicator());
    }
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _willGoBack() async {
      Navigator.pushAndRemoveUntil(
          context,
          CupertinoPageRoute(
              builder: (context) => MyOrders(
                isFromWeb: true,
              )),
              (route) => false);
      setState((){
        _willGo = true;
      });
      return _willGo;
    }

    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (currentFocus.hasFocus) {
          setState(() {
            currentFocus.unfocus();
          });
        }
      },
      child: SafeArea(
        top: true,
        child: Scaffold(
          appBar: new AppBar(

            backgroundColor: ConstantsVar.appColor,
            toolbarHeight: 18.w,
            centerTitle: true,
            title: GestureDetector(
              onTap: () {
                context.loaderOverlay.hide();
                Navigator.pushAndRemoveUntil(context,
                    CupertinoPageRoute(builder: (context) {
                      return MyApp();
                    }), (route) => false);
              },
              child: Image.asset(
                'MyAssets/logo.png',
                width: 15.w,
                height: 15.w,
              ),
            ),
          ),
          body: Stack(
            children: <Widget>[
              WebView(
                initialUrl: widget.paymentUrl,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
                onProgress: (int progress) {
                  context.loaderOverlay.show(widget: Text('$progress'));

                  setState(() {
                    isLoading = false;
                    progressCount = progress;
                  });
                },
                javascriptChannels: <JavascriptChannel>{
                  _toasterJavascriptChannel(context),
                },
                navigationDelegate: (NavigationRequest request) {
                  if (request.url.startsWith('https://www.youtube.com/')) {
                    print('blocking navigation to $request}');
                    return NavigationDecision.prevent;
                  }
                  print('allowing navigation to $request');
                  return NavigationDecision.navigate;
                },
                onPageStarted: (String url) {
                  setState(() {
                    _willGo = false;
                    isLoading = true;
                  });
                  context.loaderOverlay.show(
                    widget: CupertinoActivityIndicator(),
                  );
                  print('Page started loading: $url');
                },
                onPageFinished: (String url) {
                  print('Page finished loading: $url');
                  setState(() {
                    context.loaderOverlay.hide();
                    _willGo = true;
                    isLoading = false;
                  });
                },
                gestureNavigationEnabled: true,
              ),
              isLoading
                  ? Center(
                  child: SpinKitRipple(
                    color: Colors.red,
                    size: 90,
                  ))
                  : Stack()
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _willPopUp() async {
    context.loaderOverlay.hide();

    Navigator.pushAndRemoveUntil(
        context,
        CupertinoPageRoute(
            builder: (context) => MyHomePage(
              pageIndex: 0,
            )),
            (route) => false);
    return true;
  }

  JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
    return JavascriptChannel(
        name: 'Toaster',
        onMessageReceived: (JavascriptMessage message) {
          // ignore: deprecated_member_use
          Scaffold.of(context).showSnackBar(
            SnackBar(content: Text(message.message)),
          );
        });
  }
}