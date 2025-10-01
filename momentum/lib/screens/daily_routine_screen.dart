
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_alarm_clock/flutter_alarm_clock.dart';

class DailyRoutineScreen extends StatefulWidget {
  const DailyRoutineScreen({Key? key}) : super(key: key);

  @override
  _DailyRoutineScreenState createState() => _DailyRoutineScreenState();
}

class _DailyRoutineScreenState extends State<DailyRoutineScreen> {
  List<FlSpot> _spots = [];
  List<DateTime> _markedTimes = [];

  void _markProgress() {
    setState(() {
      final now = DateTime.now();
      _markedTimes.add(now);
      _spots = _markedTimes.map((time) {
        return FlSpot(time.hour.toDouble(), _markedTimes.where((t) => t.hour == time.hour).length.toDouble());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Routine'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: const Color(0xff37434d), width: 1),
                  ),
                  minX: 0,
                  maxX: 23,
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: _spots,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 5,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FlutterAlarmClock.createAlarm(hour: 8, title: 'Daily Routine');
              },
              child: const Text('Set Reminder'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _markProgress,
              child: const Text('Mark Progress'),
            ),
          ],
        ),
      ),
    );
  }
}
