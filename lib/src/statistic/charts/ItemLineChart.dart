
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:pocketshopping/src/utility/utility.dart';
import 'package:random_string/random_string.dart';

class ItemLineChart extends StatelessWidget {
  final Map<String,dynamic> data;
  final bool animate;

  ItemLineChart(this.data, {this.animate});

  /// Creates a [TimeSeriesChart] with sample data and no transition.
 /* factory ItemLineChart.withSampleData() {
    return new ItemLineChart(
      _createSampleData(),
      // Disable animations for image tests.
      animate: false,
    );
  }*/


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 0,
          child: Center(child: Text('30 days growth chart'),),
        ),
        Expanded(
          child: new charts.TimeSeriesChart(_createSampleData(data),
            animate: animate,
            dateTimeFactory: const charts.LocalDateTimeFactory(),
          )
        )
      ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TimeSeriesSales, DateTime>> _createSampleData(Map<String,dynamic> gData) {
    final data = [
      new TimeSeriesSales(new DateTime(2017, 9, 23), 6),
      new TimeSeriesSales(new DateTime(2017, 9, 24), 6),
      new TimeSeriesSales(new DateTime(2017, 9, 25), 6),
      new TimeSeriesSales(new DateTime(2017, 9, 26), 8),
      new TimeSeriesSales(new DateTime(2017, 9, 27), 6),
      new TimeSeriesSales(new DateTime(2017, 9, 28), 9),
      new TimeSeriesSales(new DateTime(2017, 9, 29), 11),
      new TimeSeriesSales(new DateTime(2017, 9, 30), 15),
      new TimeSeriesSales(new DateTime(2017, 10, 01), 25),
      new TimeSeriesSales(new DateTime(2017, 10, 02), 33),
      new TimeSeriesSales(new DateTime(2017, 10, 03), 27),
      new TimeSeriesSales(new DateTime(2017, 10, 04), 31),
      new TimeSeriesSales(new DateTime(2017, 10, 05), 23),

    ];

    List<TimeSeriesSales> items = [];

    List<String> range = Utility.rangeOf30Days();

    /*Utility.rangeOf30Days().forEach((element) {
      var temp = element.split('-');
      items.add(MyRow(DateTime(int.parse(temp[2]),int.parse(temp[1]),int.parse(temp[0])),randomBetween(1, 10)));
    });*/



    List<DateTime> keys = gData.keys.map((e) {
      var temp = e.toString().split('-');
      return DateTime(int.parse(temp[2]),int.parse(temp[1]),int.parse(temp[0]));
    }).toList();
    keys.sort();
    //print(keys);
    if(keys.length > 10){
      keys.forEach((key) {
        if((key.day%3) == 0){
          String _key = '${key.day}-${key.month}-${key.year}';
          items.add(TimeSeriesSales(key,(gData[_key] as int)));
        }
      });
    }
    else{
      keys.forEach((key) {
          String _key = '${key.day}-${key.month}-${key.year}';
          items.add(TimeSeriesSales(key,(gData[_key] as int)));
      });
    }

    return [
      new charts.Series<TimeSeriesSales, DateTime>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (TimeSeriesSales sales, _) => sales.time,
        measureFn: (TimeSeriesSales sales, _) => sales.sales,
        data: items,
      )
    ];
  }
}

/// Sample time series data type.
class TimeSeriesSales {
  final DateTime time;
  final int sales;

  TimeSeriesSales(this.time, this.sales);
}