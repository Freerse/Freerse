import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Utils{

  static String formatTimestampYYYY(int timestamp) {
    final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    final DateFormat formatter = DateFormat('yyyy/M/d H:mm');
    return formatter.format(dateTime);
  }

  static String getTimeDiffForString(int timestamp){
    if (timestamp <= 0) {
      return '';
    }
    var _time = timestamp * 1000;

    String msg = '';
    var dt = DateTime.fromMillisecondsSinceEpoch(_time).toLocal();

    if (DateTime.now().toLocal().isBefore(dt)) {
      return DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(_time).toLocal()).toString();
    }

    var dur = DateTime.now().toLocal().difference(dt);
    var kk = DateTime.now().toLocal().day;
    if (dur.inDays > 365) {
      msg = DateFormat.yMMMd().format(dt);
      return msg;
    } else if (dur.inDays > 30) {
      msg = DateFormat.yMMMd().format(dt);
      return msg;
    } else if (dur.inDays > 0) {
      msg = '${dur.inDays}' + 'TIAN'.tr;
      return msg;
    } else if (dur.inHours > 0) {
      msg = '${dur.inHours}' + 'XIAO_SHI'.tr;
      return msg;
    } else if (dur.inMinutes > 0) {
      msg = '${dur.inMinutes}' + 'FEN_ZHONG'.tr;
      return msg;
    } else if (dur.inSeconds > 0) {
      msg = '${dur.inSeconds}' + 'MIAO'.tr;
      return msg;
    } else {
      msg = 'now';
    }
    return msg;
  }


  static getDateFromTimeStamp(int time){
    int timestamp = time * 1000;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    String formattedDate = "${date.year}-${date.month}-${date.day} ${date.hour}:${date.minute}:${date.second}";

    String msg = '';
    var dt = DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal();
    if (DateTime.now().toLocal().isBefore(dt)) {
      return DateFormat.jm().format(DateTime.fromMillisecondsSinceEpoch(timestamp).toLocal()).toString();
    }
    var dur = DateTime.now().toLocal().difference(dt);
    if(dur.inDays >= 1){

    }else{
      msg = "${date.hour}:${date.minute}";
    }
    return msg;
  }

  static String handlerMsgTime(int timestamp) {
    DateTime timeValue =  DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    int timeNew = DateTime.now().millisecondsSinceEpoch;
    int timeDiffer = timeNew - timeValue.millisecondsSinceEpoch;
    String returnTime = "";
    print(timestamp);
    print(timeDiffer);
    print(isYestday(timeValue));
    if (timeDiffer < 86400000 && isYestday(timeValue) == false) {
      returnTime = DateFormat('HH:mm').format(timeValue);
    } else if (timeDiffer > 3600000 && isYestday(timeValue) == true) {
      returnTime = "ZUO_TIAN".tr + DateFormat('HH:mm').format(timeValue);
    } else if (timeDiffer > 86400000 && timeDiffer <= 518400000) {
      returnTime = getWeeken(timeValue) + " " + DateFormat('HH:mm').format(timeValue);
    } else if (timeDiffer > 86400000 && isYestday(timeValue) == false && isYear(timeValue) == true) {
      returnTime = DateFormat('MM-dd HH:mm').format(timeValue);
    } else if (timeDiffer > 86400000 && isYestday(timeValue) == false && isYear(timeValue) == false) {
      returnTime = DateFormat('yyyy-MM-dd HH:mm').format(timeValue);
    }
    print(returnTime);
    return returnTime;
  }

  static bool isYear(DateTime timeValue) {
    int dateYear = timeValue.year;
    int toYear = DateTime.now().year;
    return dateYear == toYear;
  }

  static String getWeeken(DateTime date) {
    List<String> weekArray = ["XING_Q_TIAN".tr, "XING_Q_YI".tr, "XING_Q_ER".tr, "XING_Q_SAN".tr, "XING_Q_SI".tr, "XING_Q_WU".tr, "XING_Q_LIU".tr];
    int weekIndex = date.weekday % 7;
    return weekArray[weekIndex];
  }

  static bool isYestday(DateTime timeValue) {
    DateTime date = timeValue;
    DateTime today = DateTime.now();
    if (date.year == today.year && date.month == today.month) {
      if (today.day - date.day == 1) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }



}
