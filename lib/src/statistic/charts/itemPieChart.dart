/// Donut chart with labels example. This is a simple pie chart with a hole in
/// the middle.
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

class ItemPieChart extends StatelessWidget {
  final List<List<dynamic>> chartData;
  final bool animate;
  final title;
  ItemPieChart(this.chartData, {this.animate,this.title});

  /// Creates a [PieChart] with sample data and no transition.
 /* factory ItemPieChart.withSampleData() {
    return new ItemPieChart(
       _createSampleData(chartData),
      // Disable animations for image tests.
      animate: false,
    );
  }*/


  @override
  Widget build(BuildContext context) {
    var topFive=makeList(chartData);

    return Column(
      children: [
        Expanded(flex: 0,child:
        Center(child: Text('$title'),)
          ,),
        Expanded(
          child: new charts.PieChart(
              _createSampleData(chartData,topFive),
              animate: animate,
              defaultRenderer: new charts.ArcRendererConfig(arcRendererDecorators: [
                new charts.ArcLabelDecorator(
                    labelPosition: charts.ArcLabelPosition.auto)
              ])

          )
        )
      ],
    );
  }

  /// Create one series with sample hard coded data.
  static List<charts.Series<TopFive, int>> _createSampleData(List<List<dynamic>> chartData,List<String>tf) {
    final data = [];


    int count=1;
    chartData.forEach((element) {
      data.add(TopFive(count,(element[1] as int)));
          count +=1;
    });


    return [
      new charts.Series<TopFive, int>(
        id: 'TopFive',
        domainFn: (TopFive _count, _) => _count.index,
        measureFn: (TopFive _count, _) => _count.count,
        data: List.castFrom(data),
        displayName: 'Top Five Items',
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (TopFive row, _) => '${tf[(row.index-1)]}',
        insideLabelStyleAccessorFn: (TopFive row, _){return charts.TextStyleSpec(color: charts.Color(r: 0,g: 0,b: 0));},


      )
    ];
  }

  List<String> makeList(List<List<dynamic>> chartData){
    List<String> data = [];


    chartData.forEach((element) {
      data.add(element[0]);

    });
    return data;
  }
}

/// Sample linear data type.
class TopFive {
  final int index;
  final int count;

  TopFive(this.index, this.count);
}