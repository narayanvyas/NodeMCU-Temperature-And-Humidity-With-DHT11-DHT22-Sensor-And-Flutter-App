import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String c = '';
String f = '';
String h = '';

BuildContext scaffoldContext;

displaySnackBar(BuildContext context, String msg) {
  final snackBar = SnackBar(
    content: Text(msg),
    action: SnackBarAction(
      label: 'Ok',
      onPressed: () {},
    ),
  );
  Scaffold.of(scaffoldContext).showSnackBar(snackBar);
}

void main() {
  runApp(MaterialApp(
    title: "LED Blink",
    debugShowCheckedModeBanner: false,
    home: Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    getSensorData(); // Getting initial state of LED, which is by default on
  }

  String _status = '';
  String url =
      'http://192.168.1.200:80/'; //IP Address which is configured in NodeMCU Sketch
  var response;
  bool progressIndicator = true;

  getSensorData() async {
    try {
      response = await http.get(url + 'dht', headers: {"Accept": "plain/text"});
      if (response.body == 'sensorError') {
        setState(() {
          _status = 'Sensor Not Connected';
          c = '';
          f = '';
          h = '';
          progressIndicator = false;
          displaySnackBar(context, 'Check Sensor Connections!');
        });
      } else {
        setState(() {
          _status = 'Sensor Connected';
          progressIndicator = false;
        });
        c = response.body.substring(0, 4) + '°C';
        print('Celcius: ' + c);
        f = response.body.substring(6, 10) + '°F';
        print('Fahrenheit: ' + f);
        h = response.body.substring(12, 16) + '%';
        print('Humidity: ' + h);
      }
    } catch (e) {
      // If NodeMCU is not connected, it will throw error
      print(e);
      if (this.mounted) {
        setState(() {
          _status = 'NodeMCU Not Connected';
          c = '';
          f = '';
          h = '';
          progressIndicator = false;
          displaySnackBar(context, 'Problem in WiFi Connection');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: Text("Temperature And Humidity"), centerTitle: true),
      body: Builder(builder: (BuildContext context) {
        scaffoldContext = context;
        return Center(
          child: ListView(
            padding: const EdgeInsets.only(top: 30.0),
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text('Celsius'),
                        ),
                        Image(
                          image: AssetImage('assets/celsius.png'),
                          width: 70.0,
                          height: 70.0,
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 15.0),
                            child: Text(c)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text('Fahrenheit'),
                        ),
                        Image(
                          image: AssetImage('assets/fahrenheit.png'),
                          width: 70.0,
                          height: 70.0,
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 15.0),
                            child: Text(f)),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(bottom: 15.0),
                          child: Text('Humidity'),
                        ),
                        Image(
                          image: AssetImage('assets/humidity.png'),
                          width: 70.0,
                          height: 70.0,
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 15.0),
                            child: Text(h))
                      ],
                    ),
                  ),
                ],
              ),
              progressIndicator
                  ? Container(
                      margin: const EdgeInsets.only(bottom: 15.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : Container(),
              Container(
                padding: const EdgeInsets.only(bottom: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: () {
                        setState(() {
                          progressIndicator = true;
                        });
                        getSensorData();
                      },
                      child: Text('Refresh'),
                    ),
                  ],
                ),
              ),
              Text(
                _status,
                textAlign: TextAlign.center,
              )
            ],
          ),
        );
      }),
    );
  }
}
