import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:quiver/async.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Demo Countdown',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Countdown Live View'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final database = FirebaseDatabase.instance.reference().child('countdown');
  
  int _countdownTime = 1;
  bool _state = false;
  int _secondsSinceEpoch = DateTime.now().toUtc().millisecondsSinceEpoch;
  CountdownTimer countdownTimer;
  String _countdownText = "0:00";
  Color backgroundColour = Colors.white;
  Color textColour = Colors.black;


  void _startCountdown(var length) {
    if (countdownTimer == null) {
      countdownTimer = new CountdownTimer(
        new Duration(milliseconds: length + 1000),
        new Duration(seconds: 1),
      );
      _runCountdown();
    } else if (countdownTimer.isRunning == false) {
      countdownTimer = new CountdownTimer(
        new Duration(milliseconds: length + 1000),
        new Duration(seconds: 1),
      );
      _runCountdown();
    }
  }

  void _runCountdown() {
    var sub = countdownTimer.listen(null);

    sub.onData((duration) {
      setState(() {
        int minutes = duration.remaining.inMinutes;
        String seconds = (duration.remaining.inSeconds % 60).toString().padLeft(2, '0');
        _countdownText = "$minutes:$seconds"; 

        if (duration.remaining.inSeconds < 20 && duration.remaining.inSeconds % 2 == 1) {
          backgroundColour = Colors.red;
          textColour = Colors.white; 
        } else {
          backgroundColour = Colors.white;
          textColour = Colors.black; 
        }
      });

      sub.onDone(() {
        _state = false;
        backgroundColour = Colors.white;
        textColour = Colors.black;
        sub.cancel();
      });
    }); 
  }

  void _stopCountdown() {
    _state = false;
    _countdownText = "0:00";
    if (countdownTimer != null) {
      countdownTimer.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        decoration: new BoxDecoration(color: backgroundColour),
        child: new Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Time Remaining:',
                style: new TextStyle(
                  color: textColour,
                  fontSize: 20
                )
              ),
              StreamBuilder(
                stream: database.onValue,
                builder: (context, snap) {
                  if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {
                    Map data = snap.data.snapshot.value;
                    _state = data['start'];
                    _countdownTime = data['time'];
                    _secondsSinceEpoch = data['timestamp'];
                    if (_state == false) {
                      _stopCountdown();
                      _countdownText = "$_countdownTime:00";
                    } else if (_state == true) {
                      var now = DateTime.now().toUtc().millisecondsSinceEpoch;
                      _secondsSinceEpoch = DateTime.now().toUtc().add(Duration(minutes: _countdownTime)).millisecondsSinceEpoch;
                      var diff =  _secondsSinceEpoch - now;
                      _startCountdown(diff);
                    }
                    return Text("$_countdownText",
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: new TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 150,
                          color: textColour)
                    );
                  }
                  else
                    return Text("Error: No Time");
                },
              ),
            ],
          ),
        ),
      )
    );
  }
}
