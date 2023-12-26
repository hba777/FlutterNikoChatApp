import 'package:flutter/material.dart';

class MyDateUtil{
  // Function to check if two DateTime objects are in the same minute
  static bool isSameMinute(String? time1, String? time2) {
    if (time1 == null || time2 == null) {
      return false;
    }
    // Convert string times to DateTime objects
    DateTime dateTime1 = DateTime.parse(time1);
    DateTime dateTime2 = DateTime.parse(time2);

    return dateTime1.year == dateTime2.year &&
        dateTime1.month == dateTime2.month &&
        dateTime1.day == dateTime2.day &&
        dateTime1.hour == dateTime2.hour &&
        dateTime1.minute == dateTime2.minute;
  }

  //From getting formatted time from MilliSecondsSinceEpochs
  static String getFormattedTime({required BuildContext context, required String time}){
    final date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  //Get last message time (used in chat user card)
  static String getLastMessageTime({required BuildContext context,
  required String time, bool showYear =false}){
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if(now.day == sent.day && now.month == sent.month && now.year == sent.year){
      return TimeOfDay.fromDateTime(sent).format(context);
    }
    return showYear ? '${sent.day} ${_getMonth(sent)} ${sent.year}':'${sent.day} $_getMonth';
  }
  
  //For getting formatted time for sent and read
  static String getMessageTime(
      {required BuildContext context, required String time}
      ){
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();
    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);

    if(now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year){
      return formattedTime;
    }

    return now.year == sent.year
        ? '$formattedTime - ${sent.day} ${_getMonth(sent)}'
        : '$formattedTime - ${sent.day} ${_getMonth(sent)} ${sent.year}';
  }

  //Get Last Active Time
  static String getLastActiveTime({required BuildContext context,
    required String lastActive}){
    final int i = int.tryParse(lastActive) ?? -1;
    
    //if time not available return below statement
    if(i == -1) {
      return  'Last Seen Not Available';
    }

    final DateTime time = DateTime.fromMillisecondsSinceEpoch(i);
    final DateTime now = DateTime.now();

    String formattedTime = TimeOfDay.fromDateTime(time).format(context);
    if(now.day == time.day && now.month == time.month && now.year == time.year){
      return 'Last seen today at $formattedTime';
    }

    if((now.difference(time).inHours / 24).round() == 1) {
      return 'Last seen yesterday at $formattedTime';
    }
    String month = _getMonth(time);
    return 'Last seen on ${time.day} $month on $formattedTime';
  }


  //Get Month name fro no or index
  static String _getMonth(DateTime date){
    switch (date.month){
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
    }
    return 'NA';
  }

}
