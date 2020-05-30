import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cia_flutter/utils/constants.dart';
import 'package:cia_flutter/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

class RequestManager {
  static const platform = const MethodChannel('insurance.data');
  final client = new HttpClient();
  // static Map<String, String> headers = {};
  static Map<String, String> cookies = {};

  static void updateCookie(http.Response response) {
    String allSetCookie = response.headers['set-cookie'];

    if (allSetCookie != null) {
      var setCookies = allSetCookie.split(',');

      for (var setCookie in setCookies) {
        var cookies = setCookie.split(';');

        for (var cookie in cookies) {
          storeCookie(cookie);
        }
      }
      headers['cookie'] = generateCookieHeader();
    }
  }

  static void storeCookie(String rawCookie) {
    if (rawCookie.length > 0) {
      var keyValue = rawCookie.split('=');
      if (keyValue.length == 2) {
        var key = keyValue[0].trim();
        var value = keyValue[1];

        // ignore keys that aren't cookies
        if (key == 'path' || key == 'expires') return;

        cookies[key] = value;
      }
    }
  }

  static String generateCookieHeader() {
    String cookie = "";

    for (var key in cookies.keys) {
      if (cookie.length > 0) cookie += ";";
      cookie += key + "=" + cookies[key];
    }
    return cookie;
  }

  static Future<bool> checkInternetConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  static callAutologinStatus(
      String url, dynamic body, callback(bool, dyanmic)) async {
    String autoLoginStatus = await getStringValue('loginStatus');

    if (autoLoginStatus == 'true') {
      var empName = await getStringValue('empName');
      var logidata = await getStringValue('loginData');
      dynamic loginDetails = json.decode(logidata);

      userId = await getStringValue('loginId');

      Map<String, String> deviceDetails = await getDeviceDetails();
      Map<String, String> autoLoginParams = {
        'cmdAction': 'checkAutoLogin',
        'userId': loginDetails['loginData']['empCode'],
        'sessionId': loginDetails['loginData']['sessionId'],
        'serRegId': '',
        'empName': empName,
      };
      autoLoginParams.addAll(deviceDetails);

      post(baseURL, autoLoginParams, (isSuccess, responseJson) {
        hideProgressHud();
        if (isSuccess) {
          if (responseJson['status'] == 'fail') {
            storeStringValue('loginStatus', 'false');
          } else {
            setLoginData(responseJson);
            post(url, body, callback);
          }
        }
      });
    }
  }

  static void setLoginData(dynamic responseJson) async {
    String loginData = json.encode(responseJson['data']);
    storeStringValue('loginStatus', 'true');

    storeStringValue('loginData', loginData);
    storeStringValue(
        'empName', responseJson['data']['logivalidatenData']['empName']);
    empCode = responseJson['data']['loginData']['empCode'];
    storeStringValue('empCode', empCode);
  }

  static void checkSSLData() async {
    // if (await checkInternetConnectivity()) {
    var platform = MethodChannel(
        Platform.isIOS ? 'flutter.native/helper' : 'test_activity');
    try {
      String isSecure =
          await platform.invokeMethod('checkSSLData', {'url': baseURL});
      // isSecure = "2";
      if (isSecure == "1") {
        isSecureNetwork = true;
      } else if (isSecure == "2") {
        hideProgressHud();
        isSecureNetwork = false;
        showAlert(appName, unsecuredNetwork);
      } else {
        hideProgressHud();
        isSecureNetwork = true;
        showAlert(appName, connectivityIssue);
      }
    } on PlatformException catch (e) {
      hideProgressHud();
      isSecureNetwork = false;
      showAlert(appName, technicalProblem);
    }
    // } else {
    //   isSecureNetwork = false;
    //   showSnackBar(contextMain, noInternetConnection);
    //   // showAlert(appName, noInternetConnection);
    // }
  }

  static void get(String url, onSuccess(dynamic), onFail(dynamic)) async {
    dynamic responseJson;
    try {
      final response = await http.get(url);

      responseJson = _returnResponse(response);
      if (responseJson != null) {
        onSuccess(responseJson);
      } else {
        onFail(responseJson);
      }
    } on SocketException {
      showSnackBar(contextMain, noInternetConnection);
      // showAlert(appName, noInternetConnection);
    }
  }

  static dynamic post(String url, dynamic body, callback(bool, dyanmic)) async {
    if (await checkInternetConnectivity()) {
      // checkSSLData();
      if (isSecureNetwork) {
        dynamic responseJson;
        debugPrint("Url :" + url + "parameteres : " + body.toString());
        debugPrint("headers :" + headers.toString());
        try {
          return http
              .post(url, body: body, headers: headers)
              .timeout(Duration(seconds: 30))
              .catchError((onError) {
            // index++;

            callback(false, "");

            // responseString = new http.Response(
            //     '{"status":"fail","errorCode":"504","message":"TimeoutError","ccode":"${itemId['ccode']}"}',
            //     504);
            // // responseItem['index'] = index;
            // callback(true, responseString);
            return "onValue";
          }).then((response) {
            updateCookie(response);
            debugPrint("response :" + response.body.toString());
            // showAlert('title', response.body.toString());
            responseJson = _returnResponse(response);
//          debugPrint(" " + responseJson.toString());
            if (responseJson != null) {
              if (responseJson == 'SesExp') {
                platform.invokeMethod("closeMotor", null);
                platform.invokeMethod("sessionExpired", null);
              } else {
                callback(true, responseJson);
                return responseJson;
              }
            } else {
              callback(false, "");
              return null;
              // showAlert(appName, technicalProblem);
            }
            return response;
          });

//          final response = await http
//               .post(url, body: body, headers: headers)
//               .timeout(const Duration(seconds: 30));
//           updateCookie(response) ;
//           debugPrint("response :" + response.body.toString());
//           // showAlert('title', response.body.toString());
//           responseJson = _returnResponse(response);
// //          debugPrint(" " + responseJson.toString());
//           if (responseJson != null) {
//             if (responseJson == 'SesExp') {
//               platform.invokeMethod("closeMotor", null);
//               platform.invokeMethod("sessionExpired", null);
//             } else {
//               callback(true, responseJson);
//               return responseJson;
//             }
//           } else {
//             callback(false, "");
//             return null;
//             // showAlert(appName, technicalProblem);
//           }
        } on TimeoutException catch (te) {
          errorMessage = serverProblem;
          callback(false, errorMessage);
        } on HandshakeException catch (he) {
          errorMessage = serverProblem;
          callback(false, serverProblem);
          showSnackBar(contextMain, serverProblem);
        } on SocketException catch (e) {
          if (e.osError.errorCode == 61) {
            errorMessage = technicalProblem;
            callback(false, "");
            // showSnackBar(contextMain, technicalProblem);
            // showAlert(appName, technicalProblem);
          } else {
            callback(false, internetMessage);
            showSnackBar(contextMain, noInternetConnection);
            // showAlert(appName, noInternetConnection);
          }

          return null;
        }
      } else {
        callback(false, "");
        errorMessage = unsecuredNetwork;
        // showAlert(appName, unsecuredNetwork);
        return null;
      }
    } else {
      callback(false, internetMessage);
      showSnackBar(contextMain, noInternetConnection);
    }
  }

  static Map<String, dynamic> getParamsCompanyWise(itemId, body) {
    Map<String, dynamic> param = {'ccode': itemId['ccode']};
    param.addAll(body);
    debugPrint(param.toString());
    return param;
  }

  static Map<String, dynamic> getParamsCompanyWiseForHealth(itemId, body) {
    Map<String, dynamic> param = {
      'ccode': itemId['ccode'],
      'hqmId': healthNewQuote.hqmId,
      'hpmId': itemId['hpmId'],
      'siForWS': itemId['siForWS'],
      'hpdId': itemId['hpdId']
    };
    param.addAll(body);
    debugPrint(param.toString());
    return param;
  }

  static Future<dynamic> getAllQuotesCompanyWise(String url, dynamic body,
      List<Map<String, dynamic>> companyList, callback(bool, dyanmic)) async {
    List<Response> responseList = new List();
    Map<String, dynamic> responseItem = new Map();
    // int index = 0;
    if (await checkInternetConnectivity()) {
      if (isSecureNetwork) {
        responseList = await Future.wait(companyList.map((itemId) {
          return http
              .post(url,
                  body: getParamsCompanyWise(itemId, body), headers: headers)
              .timeout(Duration(minutes: 1))
              .catchError((onError) {
            // index++;
            responseItem['res'] = new http.Response(
                '{"status":"fail","errorCode":"504","message":"TimeoutError","ccode":"${itemId['ccode']}"}',
                504);
            // responseItem['index'] = index;
            callback(true, responseItem);
            return "onValue";
          }).then((onValue) {
            responseItem['res'] = onValue;
            callback(true, responseItem);
            return onValue;
          });
        }));
      } else {
        callback(false, "");
        errorMessage = unsecuredNetwork;
        return null;
      }
    } else {
      callback(false, internetMessage);
      showSnackBar(contextMain, noInternetConnection);
    }
  }

  static Future<dynamic> getAllQuotesCompanyWiseForHealth(
      String url,
      dynamic body,
      List<Map<String, dynamic>> companyList,
      callback(bool, dyanmic)) async {
    List<Response> responseList = new List();
    Map<String, dynamic> responseItem = new Map();
    // int index = 0;
    if (await checkInternetConnectivity()) {
      if (isSecureNetwork) {
        responseList = await Future.wait(companyList.map((itemId) {
          return http
              .post(url,
                  body: getParamsCompanyWiseForHealth(itemId, body), headers: headers)
              .timeout(Duration(minutes: 1))
              .catchError((onError) {
            // index++;
            responseItem['res'] = new http.Response(
                '{"status":"fail","errorCode":"504","message":"TimeoutError","ccode":"${itemId['ccode']}"}',
                504);
            // responseItem['index'] = index;
            callback(true, responseItem);
            return "onValue";
          }).then((onValue) {
            responseItem['res'] = onValue;
            callback(true, responseItem);
            return onValue;
          });
        }));
      } else {
        callback(false, "");
        errorMessage = unsecuredNetwork;
        return null;
      }
    } else {
      callback(false, internetMessage);
      showSnackBar(contextMain, noInternetConnection);
    }
  }

  // static void uploadFile(String filePath, callback(bool, dyanmic)) async {
  //   if (isSecureNetwork == true) {
  //     try {
  //       File uploadfile = File.fromUri(Uri.parse(filePath));
  //       var filename = "testing.pdf"; //basename(uploadfile.path);
  //       var stream =
  //       new http.ByteStream(DelegatingStream.typed(uploadfile.openRead()));
  //       var length = await uploadfile.length();

  //       var uri = Uri.parse(uploadURL);

  //       var request = new http.MultipartRequest("POST", uri);
  //       var multipartFile =
  //       new http.MultipartFile('file', stream, length, filename: filename);
  //       request.files.add(multipartFile);
  //       var response = await request.send();

  //       print(response.statusCode);
  //       callback(true, "");

  //       // response.stream.transform(utf8.decoder).listen((value) {
  //       //   print(value);
  //       // });
  //     } on SocketException {
  //       callback(false, "");
  //       showAlert(appName, noInternetConnection);
  //     }
  //   } else {
  //     callback(false, "");
  //     showAlert(appName, unsecuredNetwork);
  //   }
  // }

  static dynamic _returnResponse(
    http.Response response,
  ) {
    switch (response.statusCode) {
      case 200:
        {
          var responseString = response.body.toString();
          if (responseString == "ERROR") {
            hideProgressHud();
            errorMessage = technicalProblem;
            // showSnackBar(contextMain,technicalProblem);
            // showAlert(appName, technicalProblem);
            return null;
          } else if (responseString.contains("OFF@---")) {
            hideProgressHud();
            errorMessage = responseString.split("---")[1];
            showAlert(appName, responseString.split("---")[1]);
            // return null;
          } else if (responseString
              .contains("<head><title>Blocked</title></head>")) {
            hideProgressHud();
            // showAlert(appName, responseString.split("---")[1]);
          } else if (responseString == "300") {
            hideProgressHud();
            errorMessage = connectivityIssue;
            // showAlert(appName, connectivityIssue);
            return null;
          } else if (responseString == "") {
            hideProgressHud();
            errorMessage = connectivityIssue;
            // showAlert(appName, connectivityIssue);
            return null;
          } else if (responseString ==
              "Please check your Internet connection.") {
            hideProgressHud();
            errorMessage = noInternetConnection;
            // showAlert(appName, noInternetConnection);
            return null;
          } else if (responseString.startsWith("<html>")) {
            hideProgressHud();
            errorMessage = connectivityIssue;
            // showAlert(appName, connectivityIssue);
            return null;
          } else if (responseString.startsWith("<!DOCTYPE html PUBLIC")) {
            hideProgressHud();
            errorMessage = connectivityIssue;
            // showAlert(appName, connectivityIssue);
            return null;
          } else if (responseString.startsWith("SesExp")) {
            hideProgressHud();
            // showSnackBar(contextMain,technicalProblem);
            // showAlert(appName, technicalProblem);

            errorMessage = technicalProblem;
            // callAutologinStatus();
            return "SesExp";
          } else {
            if (responseString.contains("----NA----true")) {
              responseString = responseString.replaceAll('----NA----true', '');
            }

            try {
              var responseJson = jsonDecode(responseString);
              return responseJson;
            } catch (exc) {
              showAlert(appName, technicalProblem);
              return null;
            }
          }
        }
        break;
      case 400:
      // throw BadRequestException(response.body.toString());
      case 401:
      case 403:
      // throw UnauthorisedException(response.body.toString());
      case 500:
      default:
      // throw FetchDataException(
      // 'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
