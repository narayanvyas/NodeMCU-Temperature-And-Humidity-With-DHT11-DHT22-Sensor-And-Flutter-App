import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

String c, f, h;

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

  getSensorData() async {
    try {
      response =
      await http.get(url + 'celcius', headers: {"Accept": "plain/text"});
      c = response.body + '°C';
      print('Celcius: ' + response.body);
      response =
      await http.get(url + 'fahrenheit', headers: {"Accept": "plain/text"});
      f = response.body + '°F';
      print('Fahrenheit: ' + response.body);
      response =
      await http.get(url + 'humidity', headers: {"Accept": "plain/text"});
      h = response.body + '%';
      print('Humidity: ');
      setState(() {
        _status = 'Sensor Connected';
      });
      if (c == '200' || f == '200' || h == '200') {
        setState(() {
          _status = 'Sensor Not Connected';
          displaySnackBar(context, 'Check Sensor Connections!');
        });
      }
    } catch (e) {
      // If NodeMCU is not connected, it will throw error
      print(e);
      if (this.mounted) {
        setState(() {
          _status = 'NodeMCU Not Connected';
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
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/celsius.png'),
                          width: 70.0,
                          height: 70.0,
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 20.0),
                            child: _status=='Sensor Connected'?Text(c):Container(
                              child: CircularProgressIndicator(),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/fahrenheit.png'),
                          width: 70.0,
                          height: 70.0,
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 20.0),
                            child: _status=='Sensor Connected'?Text(f):Container(
                              child: CircularProgressIndicator(),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: <Widget>[
                        Image(
                          image: AssetImage('assets/humidity.png'),
                          width: 70.0,
                          height: 70.0,
                        ),
                        Container(
                            margin: const EdgeInsets.only(top: 20.0),
                            child: _status=='Sensor Connected'?Text(h):Container(
                              child: CircularProgressIndicator(),
                            )),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    RaisedButton(
                      onPressed: getSensorData,
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
