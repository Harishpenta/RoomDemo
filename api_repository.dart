import 'package:cia_flutter/utils/constants.dart';
import 'package:cia_flutter/utils/requestManager.dart';
import 'package:cia_flutter/utils/utils.dart';

class ApiRepository {
  Future<dynamic> getAdditionalData(
      String baseUrl, Map<String, String> params) async {
    try {
      dynamic response;
      RequestManager.post(baseUrl, params, (isSuccess, responseJson) {
        if (isSuccess) {
          if (responseJson[STATUS_KEY] == FAIL_KEY) {
            showAlert(appName, responseJson[MESSAGE_KEY]);
          } else {
            response = responseJson;
          }
        }
      });
      return response;
    } catch (error, stacktrace) {
      print("Exception occured: $error stackTrace: $stacktrace");
      return null;
    }
  }

  static dynamic getQuoteDataCommon(String qtId, callback(bool, dyanmic)) async {
    Map<String, String> params = {
      'cmdAction': 'getQuoteData',
      'qtId': qtId,
    };
    RequestManager.post(baseURL, params, (isSuccess, responseJson) {
      callback(true, responseJson);
      return responseJson;
    });
  }

  static dynamic getQuoteDataForHealthCommon(String hqmId, callback(bool, dyanmic)) async {
    Map<String, String> params = {
      'cmdAction': 'getQuoteData',
      'hqmId': hqmId,
    };
    RequestManager.post(healthBaseURL, params, (isSuccess, responseJson) {
      callback(true, responseJson);
      return responseJson;
    });
  }

  static dynamic getClientSearchResultsCommon(Map<String, String> params, callback(bool, dyanmic)) async {
    RequestManager.post(baseURL, params, (isSuccess, responseJson) {
      callback(true, responseJson);
      return responseJson;
    });
  }

  static dynamic getClientSearchFormHealthResultsCommon(Map<String, String> params, callback(bool, dyanmic)) async {
    RequestManager.post(healthBaseURL, params, (isSuccess, responseJson) {
      callback(true, responseJson);
      return responseJson;
    });
  }


static dynamic getQuoteUrlCommon(Map<String, String> params, callback(bool, dyanmic)) async {
    RequestManager.post(baseURL, params, (isSuccess, responseJson) {
      callback(true, responseJson);
      return responseJson;
    });
  }
}
