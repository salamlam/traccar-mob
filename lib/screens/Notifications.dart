import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gpspro/Config.dart';
import 'package:gpspro/localization/app_localizations.dart';
import 'package:gpspro/theme/CustomColor.dart';

import 'package:gpspro/commons/traccar_mod/lib/traccar_gennissi.dart';

class NotificationTypePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _NotificationTypeState();
}

class _NotificationTypeState extends State<NotificationTypePage> {
  late StreamController<NotificationTypeModel> _postsController;
  List<NotificationTypeModel> notificationTypeList = [];
  bool isLoading = true;

  @override
  void initState() {
    _postsController = new StreamController();
    getNotificationList();
    super.initState();
  }

  void getNotificationList() {
    Traccar.getNotificationTypes().then((value) => {
          notificationTypeList.addAll(value!),
          value.forEach((element) {
            _postsController.add(element);
          })
        });
    notificationTypeList.sort((a, b) {
      return a.type!.toLowerCase().compareTo(b.type!.toLowerCase());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.translate('notification'),
              style: TextStyle(color: CustomColor.secondaryColor)),
        ),
        body: loadNotificationType());
  }

  Widget loadNotificationType() {
    return StreamBuilder<NotificationTypeModel>(
        stream: _postsController.stream,
        builder: (BuildContext context,
            AsyncSnapshot<NotificationTypeModel> snapshot) {
          if (snapshot.hasData) {
            return loadNotifyTypes();
          } else if (isLoading) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return Center(
              child: Text(AppLocalizations.of(context)!.translate('noData')),
            );
          }
        });
  }

  Widget loadNotifyTypes() {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: notificationTypeList.length,
        itemBuilder: (context, index) {
          final notificationType = notificationTypeList[index];
          return new Card(
            elevation: 3.0,
            child: Column(
              children: <Widget>[
                new ListTile(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(notificationType.type!,
                          style: TextStyle(
                              fontSize: 13.0, fontWeight: FontWeight.bold)),
                    ],
                  ),
                )
              ],
            ),
          );
        });
  }
}
