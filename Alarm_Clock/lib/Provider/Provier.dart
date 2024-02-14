// ignore_for_file: file_names

import 'dart:convert';

import 'package:alaram/Model/Model.dart';
import 'package:alaram/main.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:shared_preferences/shared_preferences.dart';
// ignore: depend_on_referenced_packages
import 'package:flutter_local_notifications/flutter_local_notifications.dart';


// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';

// ignore: depend_on_referenced_packages
import 'package:timezone/timezone.dart' as tz;
// ignore: camel_case_types
class alarmprovider extends ChangeNotifier{

late SharedPreferences preferences;

List<Model> modelist=[];

List<String> listofstring=[];

FlutterLocalNotificationsPlugin? flutterLocalNotificationsPlugin;

late BuildContext context;


// ignore: non_constant_identifier_names
SetAlaram(String label,String dateTime,bool check,String repeat,int id,int milliseconds){

modelist.add(Model(label: label, dateTime: dateTime, check: check, when: repeat,id: id,milliseconds: milliseconds));
notifyListeners();


}



// ignore: non_constant_identifier_names
EditSwitch(int index,bool check){

modelist[index].check=check;
notifyListeners();

}



// ignore: non_constant_identifier_names
GetData()async{

preferences=await SharedPreferences.getInstance();

    List<String>? cominglist = preferences.getStringList("data");

if(cominglist == null){


}else{

   modelist = cominglist.map((e) => Model.fromJson(json.decode(e))).toList();
notifyListeners();
}


 

}





// ignore: non_constant_identifier_names
SetData(){


listofstring = modelist.map((e) => json.encode(e.toJson())).toList();
preferences.setStringList("data", listofstring);

notifyListeners();

}




  // ignore: non_constant_identifier_names
  Inituilize(con) async {
  context=con;
    var androidInitilize =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOSinitilize = const DarwinInitializationSettings();
    var initilizationsSettings =
        InitializationSettings(android: androidInitilize, iOS: iOSinitilize);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin!.initialize(initilizationsSettings,
        onDidReceiveNotificationResponse:onDidReceiveNotificationResponse);
  }

  void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (notificationResponse.payload != null) {
      debugPrint('notification payload: $payload');
    }
    await Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (context) => const MyApp())
    );
  }




  // ignore: non_constant_identifier_names
  ShowNotification() async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('your channel id', 'your channel name',
            channelDescription: 'your channel description',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
        );
          
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin!.show(
        0, 'plain title', 'plain body', notificationDetails,
        payload: 'item x');
  }






  // ignore: non_constant_identifier_names
  SecduleNotification(DateTime datetim,int Randomnumber) async {

    int newtime= datetim.millisecondsSinceEpoch - DateTime.now().millisecondsSinceEpoch;
    await flutterLocalNotificationsPlugin!.zonedSchedule(
        Randomnumber,
        'Alarm Clock',
        DateFormat().format(DateTime.now()),
        tz.TZDateTime.now(tz.local).add( Duration(milliseconds: newtime)),


        const NotificationDetails(
            android: AndroidNotificationDetails(
                'your channel id', 'your channel name',
                channelDescription: 'your channel description',
                
                sound: RawResourceAndroidNotificationSound("alarm"),
                autoCancel: false,
                playSound: true,
                priority: Priority.max
                
                
                )),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);
  }




// ignore: non_constant_identifier_names
CancelNotification(int notificationid)async{

await flutterLocalNotificationsPlugin!.cancel(notificationid);


}




}

