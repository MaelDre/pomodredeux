import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pomodredeux/show_notification.dart';

void main() {
  // just added on the 6/04/23 by Mael
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pomodedeux',
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Pomodre',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 50,
                ),
              ),
              SizedBox(
                height: 80,
              ),
              CounterScreen(),
            ]),
      )),
    );
  } // build()
}

class CounterScreen extends StatefulWidget {
  /// C'est le widget principal de l'application
  const CounterScreen({Key? key}) : super(key: key);

  @override
  _CounterScreenState createState() => _CounterScreenState();
}

class _CounterScreenState extends State<CounterScreen> {
  /// On déclare les variables nécessaires pour utiliser stopWatch
  static const countdownDuration = Duration(minutes: 5);
  Duration duration = Duration();
  Timer? timer2;

  bool countDown = true;

  NotificationService _notificationService = NotificationService();
  @override
  void initState() {
    super.initState();
    reset();
  }

  /// on définit la méthode reset()
  void reset() {
    if (countDown) {
      setState(
        () => duration = countdownDuration,
      );
    } else {
      setState(() => duration = Duration());
    } // else
  } // reset

  void startTimer() {
    timer2 = Timer.periodic(Duration(seconds: 1), (timer2) => addTime());
  }

  void addTime() {
    /// Selon si on décrémente ou incrémente, on ajoutera, ou retirera 1seconde
    final addSeconds = countDown ? -1 : 1;

    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds < 0) {
        timer2?.cancel();
        _notificationService.showNotification();
      } else {
        duration = Duration(seconds: seconds);
      } // else
    });
  } // addTime

  void stopTimer({bool resets = true}) {
    if (resets) {
      reset();
    }
    setState(() => timer2?.cancel());
  } // stopTimer

  /// Constructeur de la classe _CounterScreenState
  @override
  Widget build(BuildContext context) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildTime(),
            SizedBox(
              height: 80,
            ),
            buildButtons()
          ],
        ),
      );

  // buildTime Widget
  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        buildTimeCard(time: hours, header: 'HEURES'),
        SizedBox(
          width: 8,
        ),
        buildTimeCard(time: minutes, header: 'MINUTES'),
        SizedBox(
          width: 8,
        ),
        buildTimeCard(time: seconds, header: 'SECONDES'),
      ],
    );
  } // buildTime()

  @override
  Widget buildTimeCard({required String time, required String header}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Text(
              time,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 50),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Text(
            header,
            style: TextStyle(color: Colors.white54),
          ),
        ],
      );
  // buildTimeCard

  Widget buildButtons() {
    final isRunning = timer2 == null ? false : timer2!.isActive;
    final isCompleted = duration.inSeconds == 0;
    return isRunning || isCompleted
        ? Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ButtonWidget(
                  text: 'STOP',
                  color: Colors.black,
                  onClicked: () {
                    if (isRunning) {
                      stopTimer(resets: false);
                    }
                  }),
              SizedBox(
                width: 12,
              ),
              ButtonWidget(
                  text: 'ANNULER', color: Colors.black, onClicked: stopTimer),
            ],
          )
        : ButtonWidget(
            text: "Lancer le timer",
            color: Colors.black,
            backgroundColor: Colors.white,
            onClicked: () async {
              startTimer();
              await _notificationService.showNotification();
            });
  } // buildButtons

} // class _counterScreenState

class ButtonWidget extends StatelessWidget {
  final String text;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onClicked;

  const ButtonWidget(
      {Key? key,
      required this.text,
      required this.onClicked,
      this.color = Colors.white,
      this.backgroundColor = Colors.black})
      : super(key: key);

  @override
  Widget build(BuildContext context) => ElevatedButton(
      style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
      onPressed: onClicked,
      child: Text(
        text,
        style: TextStyle(fontSize: 20, color: color),
      ));
}
