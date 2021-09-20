import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sizer/flutter_sizer.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:untitled2/AppPages/CartxxScreen/ConstantVariables.dart';
import 'package:untitled2/AppPages/HomeScreen/HomeScreen.dart';
import 'package:untitled2/AppPages/MyAddresses/MyAddresses.dart';
import 'package:untitled2/AppPages/Registration/RegistrationPage.dart';
import 'package:untitled2/utils/ApiCalls/ApiCalls.dart';
import 'package:untitled2/utils/utils/build_config.dart';
import 'package:untitled2/utils/utils/colors.dart';

class AddressScreen extends StatefulWidget {
  AddressScreen(
      {Key? key,
      required this.uri,
      required this.isShippingAddress,
      required this.isEditAddress,
      required this.firstName,
      required this.lastName,
      required this.email,
      required this.address1,
      required this.countryName,
      required this.city,
      required this.phoneNumber,
      required this.id, required this.myCallBack})
      : super(key: key);
  String uri;
  bool isShippingAddress;
  bool isEditAddress;
  VoidCallback myCallBack;
  //data of address
  String firstName;
  String lastName;
  String email;
  String address1;
  String countryName;
  String city;
  String phoneNumber;
  int id;

  @override
  _AddressScreenState createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen>
    with InputValidationMixin {
  var emailController = TextEditingController();
  var apiToken;
  var firstNameController = TextEditingController(); //for first name
  var numberController = TextEditingController();
  var cityController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool checkBoxVal = false;
  FocusNode myFocusNode = new FocusNode();

  var countryController = TextEditingController();

  var textControllerLast = TextEditingController();

  var controllerAddress = TextEditingController();
  var guestId;
  var buttonText = 'ADD ADDRESS';

  @override
  void initState() {
    super.initState();
    getGuestId();
    firstNameController = TextEditingController();
    textControllerLast = TextEditingController();
    numberController = TextEditingController();
    countryController = TextEditingController();
    controllerAddress = TextEditingController();
    cityController = TextEditingController();
    emailController = TextEditingController();

    //changes for add new address and edit address both 19 sept
    if (widget.isEditAddress == true) {
      setState(() {
        firstNameController.text = widget.firstName;
        textControllerLast.text = widget.lastName;
        emailController.text = widget.email;
        numberController.text = widget.phoneNumber;
        countryController.text = widget.countryName;
        controllerAddress.text = widget.address1;
        cityController.text = widget.city;
        buttonText = 'SAVE';
        String addressId = widget.id.toString();
        print('addressid>> $addressId');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: SafeArea(
        top: true,
        bottom: true,
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: new AppBar(
              toolbarHeight: 18.w,
              centerTitle: true,
              title: InkWell(
                onTap: () => Navigator.pushAndRemoveUntil(
                    context,
                    CupertinoPageRoute(
                        builder: (BuildContext context) => MyHomePage()),
                    (route) => false),
                child: Image.asset(
                  'MyAssets/logo.png',
                  width: 15.w,
                  height: 15.w,
                ),
              )),
          // resizeToAvoidBottomInset: false,
          key: scaffoldKey,
          body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            decoration: BoxDecoration(
              color: Color(0xFFEEEEEE),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Color(0xFFEEEEEE),
                  ),
                  child: Align(
                    alignment: Alignment(0.05, 0),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Billing ADDRESS'.toUpperCase(),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 6.w,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    scrollDirection: Axis.vertical,
                    children: [
                      Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {}),
                            controller: firstNameController,
                            obscureText: false,
                            decoration: editBoxDecoration(
                                'FIRST NAME'.toUpperCase(),
                                Icon(
                                  Icons.person_outline,
                                  color: AppColor.PrimaryAccentColor,
                                ),
                                ''),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18.dp,
                            ),
                            maxLines: 1,
                            validator: (val) {
                              if (isFirstName(firstNameController.text))
                                return null;
                              else
                                return 'Please Enter Your First Name';
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {}),
                            controller: textControllerLast,
                            obscureText: false,
                            decoration: editBoxDecoration(
                              'last Name'.toUpperCase(),
                              Icon(
                                Icons.person_outline,
                                color: Colors.red,
                              ),
                              '',
                            ),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18.dp,
                            ),
                            maxLines: 1,
                            validator: (val) {
                              if (isLastName(val!))
                                return null;
                              else
                                return 'Please Provide Your Last Name';
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              maxLength: 9,
                              onChanged: (_) => setState(() {}),
                              controller: numberController,
                              obscureText: false,
                              decoration: editBoxDecoration(
                                  'number'.toUpperCase(),
                                  Icon(Icons.phone,
                                      color: AppColor.PrimaryAccentColor),
                                  BuildConfig.countryCode),
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18.dp,
                              ),
                              keyboardType: TextInputType.number,
                              validator: (val) {
                                if (val!.isEmpty) {
                                  return 'Please Enter Your Number';
                                }
                                if (val.length < 9) {
                                  return 'Please Enter Your Number Correctly';
                                }
                                if (val.length > 9) {
                                  return 'Please Enter Your Number Correctly';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        elevation: 8.0,
                        child: Container(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              controller: emailController,
                              validator: (val) {
                                if (isEmailValid(val!))
                                  return null;
                                else
                                  return 'Enter Your Email Address';
                              },
                              cursorColor: Colors.black,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              decoration: editBoxDecoration(
                                  'Email Address'.toUpperCase(),
                                  Icon(
                                    Icons.email_outlined,
                                    color: AppColor.PrimaryAccentColor,
                                  ),
                                  ''),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0)),
                        elevation: 8.0,
                        child: Container(
                          padding: EdgeInsets.only(right: 12.0),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: TextFormField(
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.emailAddress,
                              controller: controllerAddress,
                              validator: (val) {
                                if (isAddress(val!)) {
                                  return null;
                                }
                                return 'Please Provide Your Address';
                              },
                              cursorColor: Colors.black,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                              maxLines: 3,
                              decoration: editBoxDecoration(
                                  'Address'.toUpperCase(),
                                  Icon(
                                    Icons.home_outlined,
                                    color: AppColor.PrimaryAccentColor,
                                  ),
                                  ''),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Card(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextFormField(
                            textInputAction: TextInputAction.next,
                            onChanged: (_) => setState(() {}),
                            controller: cityController,
                            obscureText: false,
                            decoration: InputDecoration(
                              prefixIcon: Icon(
                                Icons.location_city_outlined,
                                color: AppColor.PrimaryAccentColor,
                              ),
                              labelText: 'CITY'.toUpperCase(),
                              labelStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18.dp,
                            ),
                            maxLines: 1,
                            validator: (val) {
                              if (val!.isEmpty) {
                                return 'Please Provide Your City';
                              }

                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 40,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                          color: ConstantsVar.appColor,
                        ),
                        child: Align(
                          alignment: Alignment(0, 0),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Text(
                              'CANCEL',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Work Sans',
                                  fontSize: 18.dp,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                        onTap: () {
                          if (formKey.currentState!.validate()) {
                            formKey.currentState!.save();
                            Map<String, dynamic> body = {
                              'FirstName': '${firstNameController.text}',
                              'LastName': textControllerLast.text,
                              'Email': emailController.text,
                              'Company': '',
                              'CountryId': '79',
                              'StateProvinceId': '',
                              'City': '${cityController.text}',
                              'Address1': controllerAddress.text,
                              'Address2': '',
                              'ZipPostalCode': '',
                              'PhoneNumber': '${numberController.text}',
                              'FaxNumber': '',
                              'Country': 'UAE',
                            };
                            if (widget.isEditAddress == false) {
                              //add new address
                              ConstantsVar.prefs.setString(
                                  'addressJsonString', jsonEncode(body));
                              ApiCalls.addBillingORShippingAddress(
                                  context,
                                  widget.uri.toString(),
                                  '${apiToken}',
                                  guestId,
                                  jsonEncode(body));
                            } else {
                              //call api to save address
                              Fluttertoast.showToast(msg: 'Save Address');
                              ApiCalls.editAndSaveAddress(
                                  context,
                                  '${apiToken}',
                                  guestId,
                                  widget.id.toString(),
                                  jsonEncode(body),widget.myCallBack).then((value) =>
                                  Navigator.pushReplacement(context,CupertinoPageRoute(builder: (context)=>MyAddresses())).then((value) => setState((){})));
                            }
                          } else {
                            Fluttertoast.showToast(
                                msg: 'Please Provide correct details');
                          }
                        },
                        child: Row(
                          children: <Widget>[
                            Container(
                              height: 40,
                              width: MediaQuery.of(context).size.width * 0.5,
                              decoration: BoxDecoration(
                                color: ConstantsVar.appColor,
                              ),
                              child: Align(
                                alignment: Alignment(0, 0),
                                child: Padding(
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Text(
                                    buttonText,
                                    style: TextStyle(
                                      fontFamily: 'Work Sans',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.dp,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration editBoxDecoration(String name, Icon icon, String prefixText) {
    return new InputDecoration(
      prefixText: prefixText,
      counterText: '',
      prefixIcon: icon,
      // alignLabelWithHint: true,
      labelStyle: TextStyle(
          fontSize: myFocusNode.hasFocus ? 20 : 16.0,
          //I believe the size difference here is 6.0 to account padding
          color:
              myFocusNode.hasFocus ? AppColor.PrimaryAccentColor : Colors.grey),
      labelText: name,

      border: InputBorder.none,
    );
  }

  void getGuestId() async {
    ConstantsVar.prefs = await SharedPreferences.getInstance();
    guestId = ConstantsVar.prefs.getString('guestCustomerID');
    apiToken = ConstantsVar.prefs.getString('apiTokken');
    print('guest $guestId apiToken $apiToken');
  }
}
