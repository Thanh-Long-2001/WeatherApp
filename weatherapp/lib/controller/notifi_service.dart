import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:weatherapp_starter_project/utils/download_utils.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    AndroidInitializationSettings initializationSettingsAndroid =
        const AndroidInitializationSettings('flutter_logo');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification:
            (int id, String? title, String? body, String? payload) async {});

    var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
    await notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) async {});
  }

  void showNotificationsAfterSecond() async {
    await notificationAfterSec();
  }

  Future<NotificationDetails> notificationDetails(String image, String iconDay, String iconNight, String tempDay, String tempNight) async {
    ScreenshotController screenshotController = ScreenshotController();

    final Completer<NotificationDetails> completer = Completer();
    screenshotController
      .captureFromWidget(Container(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.white, width: 5.0),
            color: const Color.fromARGB(255, 223, 225, 228),
            borderRadius: BorderRadius.circular(5.0),

          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Container cho thời tiết sáng
              Container(
                padding: const EdgeInsets.all(70),
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.white, width: 5.0),
                  color: const Color.fromARGB(255, 50, 155, 241),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Day', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Container(
                      margin: const EdgeInsets.all(5),
                      child: Image.network(
                        iconDay, // Show image only if there is network
                        height: 30,
                        width: 30,
                      ),
                    ),
                    Text(tempDay, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                ]),
              ),
              // Container cho thời tiết tối
              Container(
              padding: const EdgeInsets.all(65),
                decoration: BoxDecoration(
                  // border: Border.all(color: Colors.white, width: 5.0),
                  color: const Color.fromARGB(255, 50, 155, 241),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Night', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                    Container(
                        margin: const EdgeInsets.all(5),
                        child: Image.network(
                          iconNight, // Show image only if there is network
                          height: 30,
                          width: 30,
                        ),
                    ),
                    Text(tempNight, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),

                ]),
              ),
            ],
          ),
        ))
        .then((capturedImage) async {
          final directory = await getApplicationDocumentsDirectory();
          final imagePath = await File('${directory.path}/image.png').create();
          await imagePath.writeAsBytes(capturedImage);

          final bigPicture =
              await DownloadUtil.downloadAndSaveFile(image, "iconweather");

          AndroidNotificationDetails androidPlatformChannelSpecifics =
              AndroidNotificationDetails(
            'channel id',
            'channel name',
            channelDescription: 'channel description',
            importance: Importance.max,
            priority: Priority.max,
            playSound: true,
            ticker: 'ticker',
            largeIcon: FilePathAndroidBitmap(bigPicture),
            styleInformation: BigPictureStyleInformation(
              FilePathAndroidBitmap(imagePath.path),
              hideExpandedLargeIcon: false,
            ),
            color: const Color(0xff2196f3),
          );

          NotificationDetails platformChannelSpecifics =
              NotificationDetails(android: androidPlatformChannelSpecifics);
          completer.complete(platformChannelSpecifics);
        });

    return completer.future;
  }

  Future<void> showLocalNotification(
    String? image,
    String? maxtempC,
    String? humidity,
    String? iconDay,
    String? iconNight,
    String? tempDay,
    String? tempNight,
    String? mintempC,
     {
    int id = 0,
    String? title,
    String? body,
    String? payload,
    
  }) async {
    final platformChannelSpecifics = await notificationDetails(image!, iconDay!, iconNight!, tempDay!, tempNight!);
    await notificationsPlugin.periodicallyShow(
      id,
      "Dự báo thời tiết hôm nay",
      "Nhiệt độ: $maxtempC - $mintempC   Độ ẩm: $humidity %",
      RepeatInterval.everyMinute,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  Future<void> notificationAfterSec(
    
  ) async {
    // var timeDelayed = DateTime.now().add(Duration(seconds: 5));
    AndroidNotificationDetails androidNotificationDetails =
        const AndroidNotificationDetails(
            'second channel ID', 'second Channel title',
            priority: Priority.high,
            importance: Importance.max,
            ticker: 'test');

    // IOSNotificationDetails iosNotificationDetails = IOSNotificationDetails();

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await notificationsPlugin.periodicallyShow(
        1,
        'Hello there',
        'please subscribe my channel',
        RepeatInterval.everyMinute,
        notificationDetails);
  }
}
