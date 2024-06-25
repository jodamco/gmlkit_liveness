import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AnglesChart extends StatelessWidget {
  final List<List<double>> anglesData;
  const AnglesChart({super.key, required this.anglesData});

  LineChartData get data => LineChartData(
        titlesData: const FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(
          verticalInterval: 4,
          horizontalInterval: 4,
        ),
        lineBarsData: lineBarsData1,
      );

  List<LineChartBarData> get lineBarsData1 => [
        lineChartBarData1_1,
        lineChartBarData1_2,
        lineChartBarData1_3,
      ];

  LineChartBarData get lineChartBarData1_1 => LineChartBarData(
        isCurved: true,
        barWidth: 2,
        color: Colors.blue,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: anglesData
            .asMap()
            .map((i, el) => MapEntry(i, FlSpot(i / 1, el[0])))
            .values
            .toList(),
      );

  LineChartBarData get lineChartBarData1_2 => LineChartBarData(
        isCurved: true,
        color: Colors.green,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: anglesData
            .asMap()
            .map((i, el) => MapEntry(i, FlSpot(i / 1, el[1])))
            .values
            .toList(),
      );

  LineChartBarData get lineChartBarData1_3 => LineChartBarData(
        isCurved: true,
        color: Colors.amber,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: anglesData
            .asMap()
            .map((i, el) => MapEntry(i, FlSpot(i / 1, el[2])))
            .values
            .toList(),
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      width: 300,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                "x angle",
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 16),
              Text(
                "y angle",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 16),
              Text(
                "z angle",
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
          Expanded(
            child: LineChart(data),
          )
        ],
      ),
    );
  }
}
