import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class ItemBarChart extends StatelessWidget {
  final List<int> data;
  final bool animate;

  ItemBarChart(this.data, {this.animate});

  /// Creates a [BarChart] with initial selection behavior.
 /* factory InitialSelection.withSampleData() {
    return new InitialSelection(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }*/


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(flex: 0,child: Text('week day transaction count'),),
        Expanded(
          child: new charts.BarChart(
            _createSampleData(data),
            animate: animate,
            behaviors: [
              new charts.InitialSelection(selectedDataConfig: [
                new charts.SeriesDatumConfig<String>('Sales', '2016')
              ])
            ],
          )
        )
      ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<WeekCount, String>> _createSampleData(List<int> count) {
    final data = [
      new WeekCount('Mon', count[0]),
      new WeekCount('Tue', count[1]),
      new WeekCount('Wed', count[2]),
      new WeekCount('Thu', count[3]),
      new WeekCount('Fri', count[4]),
      new WeekCount('Sat', count[5]),
      new WeekCount('Sun', count[6]),
    ];

    return [
      new charts.Series<WeekCount, String>(
        id: 'Week Count',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (WeekCount count, _) => count.day,
        measureFn: (WeekCount count, _) => count.count,
        data: data,
      )
    ];
  }
}

/// Sample ordinal data type.
class WeekCount {
  final String day;
  final int count;

  WeekCount(this.day, this.count);
}