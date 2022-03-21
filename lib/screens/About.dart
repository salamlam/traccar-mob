import 'package:flutter/material.dart';
import 'package:gpspro/arguments/AboutPageArguments.dart';
import 'package:gpspro/theme/CustomColor.dart';
import 'package:gpspro/commons/traccar_mod/lib/traccar_gennissi.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  List<AboutModel> aboutList = [
    AboutModel('Terms and Conditions', 'https://gennissi.com/terms.html'),
    AboutModel('Privacy Policy', 'https://gennissi.com/privacy.html'),
    AboutModel('Contact Us', 'https://gennissi.com/contact.html'),
    AboutModel('WhatsApp', 'https://wa.me/917010022101')
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          new Container(
            color: CustomColor.primaryColor,
            padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
            child: new Column(children: <Widget>[
              Card(
                  color: CustomColor.primaryColor,
                  elevation: 30,
                  child: new Image.asset(
                    'images/logo_old.png',
                    height: 120.0,
                    fit: BoxFit.contain,
                  )),
              Text("Gennissi",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
              Text("gennissi2018@gmail.com",
                  style: TextStyle(color: Colors.white, fontSize: 13)),
              InkWell(
                onTap: () {
                  launch("tel://+917010022101");
                },
                child: RichText(
                  text: TextSpan(
                    children: [
                      WidgetSpan(
                        child: Icon(Icons.call, color: Colors.white, size: 14),
                      ),
                      TextSpan(
                        text: "+917010022101",
                      ),
                    ],
                  ),
                ),
              )
            ]),
          ),
          Container(
              color: Colors.white,
              child: new Column(
                children: <Widget>[loadList()],
              ))
        ],
      ),
    );
  }

  Widget loadList() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: aboutList.length,
      itemBuilder: (context, index) {
        final urlItem = aboutList[index];
        return new Container(
            padding: const EdgeInsets.all(1.0), child: itemCardList(urlItem));
      },
    );
  }

  Widget itemCardList(AboutModel aboutItem) {
    return new Card(
        elevation: 1.0,
        child: InkWell(
          onTap: () async {
            if (aboutItem.title == "WhatsApp") {
              if (await canLaunch(aboutItem.url!)) {
                await launch(aboutItem.url!);
              } else {
                Navigator.pushNamed(context, "/webView",
                    arguments:
                        AboutPageArguments(aboutItem.title!, aboutItem.url!));
              }
            } else {
              Navigator.pushNamed(context, "/webView",
                  arguments:
                      AboutPageArguments(aboutItem.title!, aboutItem.url!));
            }
          },
          child: Row(
            children: <Widget>[
              new Container(
                padding: EdgeInsets.only(left: 10.0, top: 5, bottom: 5),
                child: Text(aboutItem.title!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.0,
                    )),
              )
            ],
          ),
        ));
  }
}
