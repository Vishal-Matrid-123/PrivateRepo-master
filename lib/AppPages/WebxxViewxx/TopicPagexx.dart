import 'dart:async';
import 'dart:io' show Platform;
import 'package:nb_utils/nb_utils.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:untitled2/AppPages/Categories/ProductList/SubCatProducts.dart';

// import 'package:untitled2/AppPages/CartxxScreen/ConstantVariables.dart';
import 'package:untitled2/AppPages/HomeScreen/HomeScreen.dart';
import 'package:untitled2/AppPages/MyOrders/MyOrders.dart';
import 'package:untitled2/AppPages/NewSubCategoryPage/NewSCategoryPage.dart';
import 'package:untitled2/AppPages/StreamClass/NewPeoductPage/NewProductScreen.dart';
import 'package:untitled2/Constants/ConstantVariables.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'WebController.dart';

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

  Future<WebViewController>? _webViewControllerFuture;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _webViewControllerFuture = _controller.future;
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
      setState(() {
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
        bottom: true,
        child: Scaffold(
          appBar: new AppBar(
            backgroundColor: ConstantsVar.appColor,
            toolbarHeight: 18.w,
            centerTitle: true,
            leading: NavigationControls(_controller.future),
            actions: [
              FutureBuilder<WebViewController>(
                future: _webViewControllerFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<WebViewController> snapshot) {
                  final bool webViewReady =
                      snapshot.connectionState == ConnectionState.done;
                  final WebViewController? controller = snapshot.data;
                  var controllerGlobal = controller;

                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 32,
                          child: IconButton(
                            icon: const Icon(Icons.replay, color: Colors.white),
                            onPressed: !webViewReady
                                ? null
                                : () {
                                    controller!.reload();
                                  },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              )
            ],
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
          body: FutureBuilder<WebViewController>(
            future: _webViewControllerFuture,
            builder: (BuildContext context,
                AsyncSnapshot<WebViewController> snapshot) {
              final bool webViewReady =
                  snapshot.connectionState == ConnectionState.done;
              final WebViewController? controller = snapshot.data;
              var controllerGlobal = controller;

              return WillPopScope(
                onWillPop: !webViewReady
                    ? null
                    : () async {
                  if (await controller!.canGoBack()) {
                    controller.goBack();
                    return false;
                  } else {
                    Navigator.pop(context);
                    // Scaffold.of(context).showSnackBar(
                    //   const SnackBar(
                    //       content: Text("No back history item")),
                    // );
                    return true;
                  }
                },
                child: Stack(
                  children: <Widget>[
                    WebView(
                      initialUrl: widget.paymentUrl,
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController webViewController) {
                        _controller.complete(webViewController);
                      },
                      onProgress: (int progress) {

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

                        if (request.url.contains('GetProductModelById')) {
                          var url = request.url;
                          Navigator.push(context,
                              CupertinoPageRoute(builder: (context) {
                                return NewProductDetails(
                                    productId: url.splitAfter('id='),
                                    screenName: 'Home Screen');
                              }));
                          return NavigationDecision.prevent;
                        }

                        if (request.url.contains('GetCategoryPage')) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              CupertinoPageRoute(
                                  builder: (context) => MyHomePage(pageIndex: 1)),
                                  (route) => false);
                          return NavigationDecision.prevent;
                        }

                        if (request.url.contains('http://theone.createsend.com/')) {
                          return NavigationDecision.navigate;
                        }
                        // if (request.url.contains('www.theone.com/')) {
                        //   return NavigationDecision.navigate;
                        // }
                        print('allowing navigation to $request');
                        return NavigationDecision.navigate;
                      },
                      onPageStarted: (String url) {
                        setState(() {
                          _willGo = false;
                          isLoading = true;
                        });

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
                  ],
                ),
              );
            },
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
