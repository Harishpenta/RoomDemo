import 'dart:convert';

import 'package:cia_flutter/common_widget/custom_dialog.dart';
import 'package:cia_flutter/common_widget/material_textfield.dart';
import 'package:cia_flutter/common_widget/radio_list.dart';
import 'package:cia_flutter/models/client_item.dart';
import 'package:cia_flutter/models/famliy_member_item.dart';
import 'package:cia_flutter/models/healthNewQuote.dart';
import 'package:cia_flutter/models/health_client_item.dart';
import 'package:cia_flutter/models/health_insurer_item.dart';
import 'package:cia_flutter/new_quote/select_client.dart';
import 'package:cia_flutter/repository/api_repository.dart';

import 'package:cia_flutter/utils/assetutils.dart';
import 'package:cia_flutter/utils/colors.dart';
import 'package:cia_flutter/utils/constants.dart';
import 'package:cia_flutter/utils/requestManager.dart';
import 'package:cia_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'existing_health_quote.dart';
import 'health_quote_utils.dart';
import 'health_select_client.dart';
import 'new_quote_response.dart';

class HealthQuoteScreen extends StatefulWidget {
  HealthQuoteScreen({
    Key key,
    this.selectedTabIndex = 0,
  });
  final int selectedTabIndex;
  // bool isFromQuoteDetailsScreen;
  @override
  HealthQuoteScreenState createState() => HealthQuoteScreenState();
}

class HealthQuoteScreenState extends State<HealthQuoteScreen>
    with SingleTickerProviderStateMixin, TickerProviderStateMixin {
  static const platform = const MethodChannel('insurance.data');

  // MotorNewQuote healthNewQuote = new MotorNewQuote();

  TabController _tabController;

  int _tabIndex = 0;

  TextEditingController mobileTextController = new TextEditingController();
  TextEditingController emailTextController = new TextEditingController();
  TextEditingController clientNameTextController = new TextEditingController();
  FocusNode clientNameFocusNode;
  FocusNode emailFocusNode;
  FocusNode mobileFocusNode;
  List<String> arrGender = new List();
  List<dynamic> arrCity = new List();
  List<FamilyMemberItem> familyMembersList = new List();
  int selectedGenderIndex = 0;

  int selectedCityIndex = 0;

  String persons;

  String cityName;

  @override
  void initState() {
    super.initState();
    // motorState = this;
    _tabIndex = widget.selectedTabIndex;
    _tabController =
        TabController(length: 2, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);

    clientNameTextController.text = '';
    emailTextController.text = '';
    mobileTextController.text = '';

    clientNameFocusNode = FocusNode();
    emailFocusNode = FocusNode();
    mobileFocusNode = FocusNode();
    arrGender = ["Select Gender", "Male", "Female"];
    getAccess();
    getAgeValuesForMinor();
    getAgeValuesForMajor();
  }

  getCityResponse() async {
    Map<String, String> params = {
      'cmdAction': 'getCity',
    };

    RequestManager.post(healthBaseURL, params, (isSuccess, responseJson) {
      if (isSuccess) {
        if (responseJson != null) {
          if (responseJson['status'] == 'success') {
            arrCity.clear();
            List<dynamic> clientList = responseJson['data']['listBean'];
            Map<dynamic, dynamic> startItem = {
              "cityName": "Select City",
              "cityId": "0"
            };
            arrCity.add(startItem);
            arrCity.addAll(clientList);
            setState(() {});
          }
        }
      } else {}
    });
  }

  getAccess() async {
    Map<String, String> params = {
      'cmdAction': 'getAccess',
    };

    RequestManager.post(healthBaseURL, params, (isSuccess, responseJson) {
      if (isSuccess) {
        if (responseJson != null) {
          if (responseJson['status'] == 'success') {
            String accessResult = responseJson['data']['accessDenied'];
            if (accessResult == "Y") {
              showAlertForAccess(appName, "ACCESS DENIED");
            } else {
              getCityResponse();
            }
          }
        }
      } else {}
    });
  }

  setFamilyCompositionField() {
    healthInsurersList.clear();    
    persons="";
    if (familyMembersList.length > 0) {
      for (var item in familyMembersList) {
        if (item.isSelected) {
          persons = persons +
              item.person.toString() +
              '(' +
              item.age.replaceAll(" Years", "").toString() +
              '),';
          HealthInsurerModel insurer = new HealthInsurerModel(
              person: item.person.toString(), age: item.age.toString());
          healthInsurersList.add(insurer);
        }
      }
    } else {
      persons = "NA";
    }
    persons = persons.substring(0, persons.length - 1);
    setState(() {});
  }

  String getSelectedMemersJsonString() {
    List<Map<String, dynamic>> familyMemberItems = new List();
    for (var item in familyMembersList) {
      if (item.isSelected) {
        Map<String, dynamic> itemObj = new Map();
        itemObj['relation'] = item.person.toString();
        itemObj['age'] = item.age.replaceAll(" Years", "").toString();
        familyMemberItems.add(itemObj);
      }
    }
    return json.encode(familyMemberItems).toString();
  }

  void showAlertForAccess(String title, String bodyValue) {
    showDialog(
      context: contextMain,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(5.0))),
          title: new Text(title),
          content: new Text(
            bodyValue, style: TextStyle(fontSize: 20),
            // maxLines: 4,
          ),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                SystemChannels.platform
                    .invokeMethod<void>('SystemNavigator.pop');
                // platform.invokeMethod("closeHealth", null);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    clientNameFocusNode.dispose();
    mobileFocusNode.dispose();
    emailFocusNode.dispose();
    super.dispose();
  }

  void onPressDismisskeyboard(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  onSelectionGender(index) {
    Navigator.pop(context);
    setState(() {
      selectedGenderIndex = index;
    });
  }

  onSelectionCity(index) {
    Navigator.pop(context);
    setState(() {
      selectedCityIndex = index;

      cityName = arrCity[selectedCityIndex]['cityName'].toString();
    });
  }

  saveFamilyComposition(HealthClientObject co) async {
    Map<String, String> params = {
      'cmdAction': 'saveFamilyComposition',
      'listBean': getSelectedMemersJsonString()
    };
    debugPrint("saveFamilyComposition PARAMS =>" + params.toString());

    RequestManager.post(healthBaseURL, params, (isSuccess, responseJson) {
      debugPrint("saveFamilyComposition RES =>" + responseJson.toString());
      if (isSuccess) {
        if (responseJson['status'] == 'fail') {
          // showAlert(appName, responseJson['message']);
        } else {
          saveQuote(co);
        }
      } else {}
    });
  }

  saveQuote(HealthClientObject co) async {
    Map<String, String> params = {
      'cmdAction': 'saveQuote',
      'clientFullName': co.clientFullName,
      'mobile': co.mobile,
      'email': co.email,
      'gender': co.gender,
      'cityId': arrCity[selectedCityIndex]['cityId'],
      'minSI': "400000",
      'maxSI': "500000",
    };

    RequestManager.post(healthBaseURL, params, (isSuccess, responseJson) {
      if (isSuccess) {
        if (responseJson != null) {
          if (responseJson['status'] == 'success') {
            healthNewQuote = new HealthNewQuote();
            healthNewQuote.hqmId = responseJson['data']['hqmId'];
            getQuoteData(responseJson['data']['hqmId']);
          }
        }
      } else {}
    });
  }

  getQuoteData(String hqmId) async {
    //8452
    ApiRepository.getQuoteDataForHealthCommon(hqmId, (isSuccess, responseJson) {
      if (isSuccess) {
        if (responseJson != null) {
          if (responseJson['status'] == 'success') {
            Map<String, dynamic> quoteData = responseJson['data'];
            debugPrint(quoteData.toString());
            healthNewQuote.hqmId = "8452";
            healthNewQuote.name = quoteData['clientName'];
            healthNewQuote.members = quoteData['members'];
            healthNewQuote.city = quoteData['city'];
            healthNewQuote.minSA = quoteData['minSA'];
            healthNewQuote.maxSA = quoteData['maxSA'];
            healthNewQuote.planType = quoteData['planType'];
            Navigator.of(context).pushNamed('/healthQuotePlanList');
          }
        }
      } else {}
    });
  }

  getDraftQuote(HealthClientObject co, String isRegisterd) async {
    showProgressHudWithContext(context);
    Map<String, String> params = {
      'cmdAction': 'getDraftQuote',
      'clientFullName': co.clientFullName,
      'mobile': co.mobile,
      'email': co.email,
      'clientId': co.clientId,
    };

    RequestManager.post(healthBaseURL, params, (isSuccess, responseJson) {
      hideProgressHud();
      if (isSuccess) {
        if (responseJson != null) {
          if (responseJson['errorCode'] == '002') {
            showDialog(
              barrierDismissible: false,
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(5.0))),
                  title: new Text(appName),
                  content: new Text(
                    responseJson['message'],
                    // maxLines: 4,
                  ),
                  actions: <Widget>[
                    new FlatButton(
                      child: new Text("Continue"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        getQuoteData(responseJson['data']['hqmId']);
                      },
                    ),
                    new FlatButton(
                      child: new Text("Create New"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        saveFamilyComposition(co);
                      },
                    ),
                    new FlatButton(
                      child: new Text("Cancel"),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            saveFamilyComposition(co);
          }
        }
      } else {
        hideProgressHud();
        if (responseJson != internetMessage) {
          showSnackBar(context, errorMessage);
        }
      }
    });
  }

  int getCityIndex() {
    int index = 0;
    for (var item in arrCity) {
      index = arrCity.indexOf(item);
      if (item['cityName'] == cityName) {
        return index;
      }
    }
    return index;
  }

  @override
  Widget build(BuildContext context) {
    size = ui.window.physicalSize;
    devicePixelRatio = ui.window.devicePixelRatio;
    width = size.width;
    height = size.height;
    debugPrint("width" + width.toString());
    screenWidth = width / devicePixelRatio;
    screenHeight = height / devicePixelRatio;

    contextMain = context;
    if (healthNewQuote.name == '') {
      clientNameTextController.text = '';
      emailTextController.text = '';
      mobileTextController.text = '';
    }
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      backgroundColor: Colors.white,
      body: Container(
        child: Stack(
          children: <Widget>[
            Opacity(
              opacity: 0.15,
              child:
                  Image.asset(AssetUtils.health_quote_bg, fit: BoxFit.fitWidth),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomRight,
                child: Opacity(
                  opacity: 0.06,
                  child: Image.asset(AssetUtils.bottom_bg_image,
                      fit: BoxFit.fitWidth),
                ),
              ),
            ),
            Column(
              children: <Widget>[
                Container(
                  height: MediaQuery.of(context).padding.top,
                ),
                Container(
                  height: kToolbarHeight,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      IconButton(
                        icon: const BackButtonIcon(),
                        color: ColorUtils.blackColor,
                        onPressed: () {
                          _tabIndex = 0;
                          _tabController.index = 0;
                          healthNewQuote = new HealthNewQuote();
                          clientNameTextController.text = '';
                          emailTextController.text = '';
                          mobileTextController.text = '';
                          Navigator.maybePop(context);
                          platform.invokeMethod("closeHealth", null);
                        },
                      ),
                      Text(
                        'Health Quote',
                        style: TextStyle(
                            fontSize: 20,
                            color: ColorUtils.blackColor,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                TabBar(
                  unselectedLabelColor: ColorUtils.darkGrey,
                  labelColor: ColorUtils.blueThemeColor,
                  labelStyle: TextStyle(
                    fontSize: 16,
                    color: ColorUtils.blueThemeColor,
                    fontWeight: FontWeight.w500,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 16,
                    color: ColorUtils.darkGrey,
                    fontWeight: FontWeight.w400,
                  ),
                  indicatorColor: ColorUtils.blueThemeColor,
                  indicatorWeight: 3,
                  isScrollable: true,
                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: _tabController,
                  indicatorPadding: EdgeInsets.only(left: 40, right: 40),
                  labelPadding:
                      EdgeInsets.only(left: 10, right: 10, top: 0, bottom: 0),
                  tabs: [
                    Tab(icon: Text("    New Quote   ")),
                    Tab(icon: Text("Existing Quotes")),
                  ],
                ),
                Expanded(
                    child: [
                  newQuoteWidget(),
                  ExistingHealthQuoteScreen()
                ][_tabIndex]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  newQuoteWidget() {
    return Column(
      children: <Widget>[
        Expanded(
          child: GestureDetector(
            onTap: () {
              onPressDismisskeyboard(context);
            },
            child: Container(
              // color: Colors.green,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  // mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    RadioSelection(
                      selectedIndex: healthNewQuote.quoteFor,
                      headingLabel: 'Quote For*',
                      headingLabelfontSize: 14,
                      labels: ['Registered Client', 'Prospective Client'],
                      onSelected: (value) {
                        onPressDismisskeyboard(context);
                        healthNewQuote.clientId = '';
                        healthNewQuote.name = '';
                        selectedCityIndex = 0;
                        selectedGenderIndex = 0;
                        persons = "";
                        clientNameTextController.text = '';
                        emailTextController.text = '';
                        mobileTextController.text = '';
                        clientNameFocusNode.requestFocus();
                        setState(() {
                          healthNewQuote.quoteFor = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    Visibility(
                      visible: healthNewQuote.quoteFor == 0,
                      child: Text(
                        'Name',
                        style:
                            TextStyle(fontSize: 14, color: ColorUtils.darkGrey),
                      ),
                    ),
                    Visibility(
                      visible: healthNewQuote.quoteFor == 0,
                      child: GestureDetector(
                        onTap: () async {
                          HealthClientObject clientDetails =
                              await Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                      builder: (__) =>
                                          new SearchClientForHealthScreen()));

                          if (clientDetails != null) {
                            clientNameTextController.text =
                                clientDetails.clientFullName;
                            mobileTextController.text = clientDetails.mobile;
                            emailTextController.text = clientDetails.email;
                            cityName = clientDetails.city;
                            selectedGenderIndex =
                                clientDetails.gender == "M" ? 0 : 1;
                            selectedCityIndex = getCityIndex();

                            setState(() {
                              healthNewQuote.clientId = clientDetails.clientId;
                              healthNewQuote.name =
                                  clientDetails.clientFullName;
                              healthNewQuote.mobile = clientDetails.mobile;
                              healthNewQuote.email = clientDetails.email;
                              healthNewQuote.city = clientDetails.city;
                              healthNewQuote.gender = clientDetails.gender;
                            });
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text(
                                  healthNewQuote.name == ''
                                      ? 'Select Name'
                                      : healthNewQuote.name,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: healthNewQuote.name == ''
                                          ? ColorUtils.darkGrey
                                          : ColorUtils.blackColor,
                                      fontWeight: FontWeight.w400),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Icon(Icons.arrow_forward_ios,
                                  size: 14, color: ColorUtils.blackColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                      visible: healthNewQuote.quoteFor == 1,
                      child: new MaterialTextField(
                        // focusNodeParam: clientNameFocusNode,
                        isEnabled: true,
                        textLength: 200,
                        inputType: TextInputType.text,
                        hintText: 'Name',
                        labelText: 'Name',
                        textController: clientNameTextController,
                        onChanged: (value) {
                          healthNewQuote.name = value;
                        },
                      ),
                    ),
                    Container(
                      height: 1,
                      color: ColorUtils.lightGrey,
                    ),
                    SizedBox(
                      height: 12,
                    ),

                    RadioSelection(
                      isEnabled: healthNewQuote.quoteFor == 1,
                      selectedIndex: selectedGenderIndex,
                      headingLabel: 'Gender*',
                      headingLabelfontSize: 14,
                      labels: ['Male', 'Female'],
                      onSelected: (value) {
                        if (value == 0) {
                          healthNewQuote.gender = "M";
                        } else {
                          healthNewQuote.gender = "F";
                        }
                      },
                    ),
                    SizedBox(
                      height: 12,
                    ),

                    Container(
                      padding: EdgeInsets.only(),
                      child: GestureDetector(
                        onTap: () {
                          if (healthNewQuote.quoteFor != 0) {
                            CustomDialog.showSingleSelectionDialogWithKey(
                                contextMain,
                                "Select City",
                                arrCity,
                                "cityName",
                                onSelectionCity,
                                selectedCityIndex);
                          }
                        },
                        child: Padding(
                          padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Container(
                            color: Colors.transparent,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  selectedCityIndex == 0
                                      ? "Select City"
                                      : arrCity[selectedCityIndex]['cityName'],
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: healthNewQuote.quoteFor == 0 ||
                                              selectedCityIndex == 0
                                          ? Colors.grey.withOpacity(0.6)
                                          : ColorUtils.lightBlueThemeColor,
                                      fontWeight: selectedCityIndex == 0
                                          ? FontWeight.w400
                                          : FontWeight.w700),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                RotatedBox(
                                  quarterTurns: 1,
                                  child: Icon(Icons.arrow_forward_ios,
                                      size: 14,
                                      color: ColorUtils.lightBlueThemeColor),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 1,
                      color: ColorUtils.lightGrey,
                    ),
                    SizedBox(
                      height: 12,
                    ),
                    MaterialTextField(
                      // focusNodeParam: mobileFocusNode,
                      textLength: 10,
                      inputType: TextInputType.phone,
                      isEnabled: healthNewQuote.quoteFor == 0 ? false : true,
                      hintText: 'Mobile',
                      labelText: 'Mobile',
                      textController: mobileTextController,
                      onChanged: (value) {
                        healthNewQuote.mobile = value;
                      },
                    ),
                    SizedBox(
                      height: 16,
                    ),
                    // Text(
                    //   'E-mail',
                    //   style: TextStyle(fontSize: 14, color: ColorUtils.darkGrey),
                    // ),
                    MaterialTextField(
                      // focusNodeParam: emailFocusNode,
                      textLength: 50,
                      inputType: TextInputType.emailAddress,
                      isEnabled: healthNewQuote.quoteFor == 0 ? false : true,
                      hintText: 'E-mail',
                      labelText: 'E-mail',
                      textController: emailTextController,
                      onChanged: (value) {
                        healthNewQuote.email = value;
                      },
                    ),
                    SizedBox(
                      height: 26,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                            padding: EdgeInsets.only(left: 0, top: 10),
                            child: null != persons
                                ? Text(
                                    persons,
                                    style: TextStyle(
                                        color: healthNewQuote.quoteFor == 0
                                            ? ColorUtils.darkGrey
                                            : Colors.black,letterSpacing: 1.5,
                                        fontSize: 16),
                                  )
                                : Text(
                                    "Select Family Members",
                                    style: TextStyle(
                                        color: healthNewQuote.quoteFor == 0
                                            ? ColorUtils.darkGrey
                                            : Colors.black,
                                        fontSize: 16),
                                  )),
                        Material(
                          child: InkWell(
                            onTap: () async {
                              // if (healthNewQuote.quoteFor != 0) {
                              final result = await Navigator.of(context)
                                  .pushNamed('/family_members');
                              if (result != null || result != "NA") {                                
                                familyMembersList.clear();
                                familyMembersList.addAll(result);
                                setFamilyCompositionField();
                              }
                              // }
                            },
                            child: Icon(
                              Icons.add_circle,
                              color: ColorUtils.blueThemeColor,
                              size: 30,
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      height: 1,
                      color: ColorUtils.lightGrey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          width: screenWidth - 52,
          margin: EdgeInsets.only(top: 0, bottom: 30),
          child: FlatButton(
            color: ColorUtils.blueThemeColor,
            textColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(40.0),
                side: BorderSide(color: ColorUtils.blueThemeColor)),
            padding: EdgeInsets.only(top: 16, bottom: 16),
            onPressed: () {
              // getCityResponse();
              if (healthNewQuote.quoteFor == 0) {
                if (healthNewQuote.name == '') {
                  showAlert(appName, 'Please make selection for \'Name\'.');
                  return;
                }
                if ("" == persons || null == persons) {
                  showAlert(appName, 'Please make selection for \'Members to be covered\'.');
                  return;
                }
                //Please make selection for 'Members to be covered'.

                HealthClientObject clientDetails = new HealthClientObject();
                clientDetails.clientId = healthNewQuote.clientId;
                clientDetails.clientFullName = healthNewQuote.name;
                clientDetails.mobile = healthNewQuote.mobile;
                clientDetails.email = healthNewQuote.email;
                clientDetails.gender = healthNewQuote.gender;
                getDraftQuote(clientDetails, 'Y');
              } else {
                if (clientNameTextController.text == '') {
                  showAlert(appName, 'Please enter value for \'Name\'.');
                  clientNameFocusNode.requestFocus();
                  return;
                } else if (clientNameTextController.text.length < 3) {
                  showAlert(appName, 'Please enter valid value for \'Name\'.');
                  clientNameFocusNode.requestFocus();
                  return;
                } else if (mobileTextController.text == '') {
                  showAlert(appName, 'Please enter value for \'Mobile\'.');
                  mobileFocusNode.requestFocus();
                  return;
                }

                if (mobileTextController.text.length < 10) {
                  showAlert(appName,
                      '\'Mobile\' should not be lesser than 10 digits.');
                  mobileFocusNode.requestFocus();
                  return;
                } else if (mobileTextController.text.length == 10) {
                  String patttern = r'^[0-9]{10}$';
                  RegExp regExp = new RegExp(patttern);
                  if (!regExp.hasMatch(mobileTextController.text)) {
                    showAlert(
                        appName, 'Please enter valid value for \'Mobile\'.');
                    mobileFocusNode.requestFocus();
                    return;
                  }
                }

                if (emailTextController.text == '') {
                  showAlert(appName, 'Please enter value for \'Email\'.');
                  emailFocusNode.requestFocus();
                  return;
                } else if (emailTextController.text.length > 0) {
                  String patttern =
                      r'^(([^<>()[\]\\.,;#$:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                  RegExp regExp = new RegExp(patttern);
                  if (!regExp.hasMatch(emailTextController.text)) {
                    showAlert(
                        appName, 'Please enter valid value for \'Email\'.');
                    emailFocusNode.requestFocus();
                    return;
                  }
                }
                healthNewQuote.clientId = '';
                healthNewQuote.name = clientNameTextController.text;
                healthNewQuote.mobile = mobileTextController.text;
                healthNewQuote.email = emailTextController.text;
                healthNewQuote.city = arrCity[selectedCityIndex];

                HealthClientObject clientDetails = new HealthClientObject();
                clientDetails.clientId = healthNewQuote.clientId;
                clientDetails.clientFullName = healthNewQuote.name;
                clientDetails.mobile = healthNewQuote.mobile;
                clientDetails.email = healthNewQuote.email;
                getDraftQuote(clientDetails, 'N');
              }
            },
            child: Text(
              'Search Plan',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }
}
