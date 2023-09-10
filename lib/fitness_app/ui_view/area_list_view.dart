import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../fitness_app_theme.dart';
import 'package:jinsei/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class AreaListView extends StatefulWidget {
  const AreaListView(
      {Key? key, this.mainScreenAnimationController, this.mainScreenAnimation})
      : super(key: key);

  final AnimationController? mainScreenAnimationController;
  final Animation<double>? mainScreenAnimation;
  @override
  State<AreaListView> createState() => _AreaListViewState();
}

class _AreaListViewState extends State<AreaListView>
    with TickerProviderStateMixin {
  AnimationController? animationController;
  final areaListData = [
    Icon(
      Icons.monitor_weight_rounded,
      size: 60,
    ),
    Icon(
      Icons.thermostat,
      size: 60,
    ),
    ImageIcon(
      AssetImage("assets/icon/cardiogram.png"),
      size: 60,
    ),
    ImageIcon(
      AssetImage("assets/icon/blood-pressure.png"),
      size: 60,
    ),
    ImageIcon(
      AssetImage("assets/icon/oxygen.png"),
      size: 60,
    ),
  ];
  List<String> texts = <String>[
    "Weight",
    "Temperature",
    "Pulse Rate",
    "Blood Pressure",
    "Oxygen Level",
  ];

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.mainScreenAnimationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: widget.mainScreenAnimation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 30 * (1.0 - widget.mainScreenAnimation!.value), 0.0),
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: Padding(
                padding: const EdgeInsets.only(left: 8.0, right: 8),
                child: GridView(
                  padding: const EdgeInsets.only(
                      left: 16, right: 16, top: 16, bottom: 16),
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 24.0,
                    crossAxisSpacing: 24.0,
                    childAspectRatio: 1.0,
                  ),
                  children: List.generate(
                    areaListData.length,
                    (int index) {
                      final int count = areaListData.length;
                      final Animation<double> animation =
                          Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: animationController!,
                          curve: Interval((1 / count) * index, 1.0,
                              curve: Curves.fastOutSlowIn),
                        ),
                      );
                      animationController?.forward();
                      return AreaView(
                        icon: areaListData[index],
                        animation: animation,
                        animationController: animationController!,
                        text: texts[index],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AreaView extends StatelessWidget {
  const AreaView({
    Key? key,
    this.icon,
    this.animationController,
    this.animation,
    required this.text,
  }) : super(key: key);

  final dynamic icon;
  final AnimationController? animationController;
  final Animation<double>? animation;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: Container(
              decoration: BoxDecoration(
                color: FitnessAppTheme.white,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8.0),
                    bottomLeft: Radius.circular(8.0),
                    bottomRight: Radius.circular(8.0),
                    topRight: Radius.circular(8.0)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: FitnessAppTheme.grey.withOpacity(0.4),
                      offset: const Offset(1.1, 1.1),
                      blurRadius: 10.0),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  focusColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  splashColor: FitnessAppTheme.nearlyDarkBlue.withOpacity(0.2),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Chart(heading: text),
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Container(
                        padding:
                            const EdgeInsets.only(top: 16, left: 16, right: 16),
                        child: Center(
                          child: icon,
                        ),
                      ),
                      Text(text),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class Chart extends StatefulWidget {
  const Chart({super.key, required this.heading});
  final String heading;

  @override
  State<Chart> createState() => _ChartState();
}

class _ChartState extends State<Chart> {
  late List<dynamic> dataList;
  late DateTime maxdate;
  late DateTime mindate;
  late double maxvalue;
  late Widget bottomTitle;
  bool displayText = false;
  late double max1;
  late double max2;
  late double avg1;
  late double avg2;
  late double min1;
  late double min2;

  Map<String, dynamic> cookie = {};

  @override
  void initState() {
    getCookie().then((value) {
      setState(() {
        cookie = value;
      });
      setData().then((value) {
        setState(() {
          displayText = true;
        });
      });
    });
    super.initState();
  }

  void setText() {
    dynamic buffer = dataList.map((e) {
      return e[widget.heading.toLowerCase()];
    }).toList();
    if (widget.heading == "Blood Pressure") {
      var upperbps = buffer.map((e) => double.parse(e[0]));
      var lowerbps = buffer.map((e) => double.parse(e[1]));
      max1 = upperbps.reduce((a, b) {
        return a > b ? a : b;
      });
      max2 = lowerbps.reduce((a, b) {
        return a > b ? a : b;
      });
      min1 = upperbps.reduce((a, b) {
        return a < b ? a : b;
      });
      min2 = lowerbps.reduce((a, b) {
        return a < b ? a : b;
      });
      avg1 = upperbps.reduce((a, b) {
            return a + b;
          }) /
          buffer.length;
      avg2 = lowerbps.reduce((a, b) {
            return a + b;
          }) /
          buffer.length;
    } else if (widget.heading == "Pulse Rate") {
      buffer = buffer.map((e) => e.toDouble()).toList();
      max1 = buffer.reduce((a, b) {
        return a > b ? a : b;
      });
      min1 = buffer.reduce((a, b) {
        return a < b ? a : b;
      });
      avg1 = buffer.reduce((a, b) {
            return a + b;
          }) /
          buffer.length;
    } else {
      buffer = buffer.map((e) => double.parse(e)).toList();
      max1 = buffer.reduce((a, b) {
        return a > b ? a : b;
      });
      min1 = buffer.reduce((a, b) {
        return a > b ? b : a;
      });
      avg1 = buffer.reduce((a, b) {
            return a + b;
          }) /
          buffer.length;
    }
  }

  Future<List<dynamic>> setData() async {
    Dio dio = Dio();
    final response =
        await dio.get("$url/${widget.heading.toLowerCase()}", queryParameters: {
      "id": cookie['userdata']['id'],
      'isdoctor': cookie['userdata']['isdoctor'],
    });
    dataList = response.data['${widget.heading.toLowerCase()}list'];
    setDates();
    setMax();
    setText();
    return dataList;
  }

  void setMax() {
    if (widget.heading == "Blood Pressure") {
      maxvalue = 300;
    } else if (widget.heading == "Pulse Rate") {
      maxvalue = 250;
    } else {
      final buffer = dataList;
      buffer.sort(((a, b) {
        return a[widget.heading.toLowerCase()]
            .compareTo(b[widget.heading.toLowerCase()]);
      }));
      maxvalue = double.parse(buffer.last[widget.heading.toLowerCase()]);
    }
  }

  void setDates() {
    final buffer = dataList;
    buffer.sort(((a, b) {
      return DateTime.parse(a['date']).compareTo(DateTime.parse(b['date']));
    }));
    maxdate = DateTime.parse(buffer.last['date']);
    mindate = DateTime.parse(buffer.first['date']);
  }

  List<FlSpot> getUpperSpots() {
    List<FlSpot> spots = <FlSpot>[];
    for (int i = 0; i < dataList.length; i++) {
      DateTime date = DateTime.parse(dataList[i]['date']);
      double x = date.millisecondsSinceEpoch.toDouble();
      double y = double.parse(dataList[i]['blood pressure'][0]);
      spots.add(
        FlSpot(
          x,
          y,
        ),
      );
    }
    return spots;
  }

  List<FlSpot> getLowerSpots() {
    List<FlSpot> spots = <FlSpot>[];
    for (int i = 0; i < dataList.length; i++) {
      DateTime date = DateTime.parse(dataList[i]['date']);
      double x = date.millisecondsSinceEpoch.toDouble();
      double y = double.parse(dataList[i]['blood pressure'][1]);
      spots.add(
        FlSpot(
          x,
          y,
        ),
      );
    }
    return spots;
  }

  List<FlSpot> getSpots() {
    List<FlSpot> spots = <FlSpot>[];
    for (int i = 0; i < dataList.length; i++) {
      DateTime date = DateTime.parse(dataList[i]['date']);
      double x = date.millisecondsSinceEpoch.toDouble();
      double? y;
      if (widget.heading == "Pulse Rate") {
        y = dataList[i][widget.heading.toLowerCase()].toDouble();
      } else if (widget.heading == "Blood Pressure") {
      } else {
        y = double.parse(
          dataList[i][widget.heading.toLowerCase()],
        );
      }
      spots.add(
        FlSpot(
          x,
          y!,
        ),
      );
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    if (cookie.isEmpty) {
      return const CircularProgressIndicator();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.heading),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false,
      ),
      body: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            FutureBuilder(
              future: setData(),
              builder: (BuildContext context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    width: double.infinity,
                    height: 500,
                    margin: EdgeInsets.only(
                      bottom: 20,
                    ),
                    child: LineChart(
                      LineChartData(
                        backgroundColor: Colors.white,
                        minX: mindate
                            .subtract(
                              const Duration(
                                days: 7,
                              ),
                            )
                            .millisecondsSinceEpoch
                            .toDouble(),
                        maxX: maxdate
                            .add(
                              Duration(
                                days: 7,
                              ),
                            )
                            .millisecondsSinceEpoch
                            .toDouble(),
                        minY: 0,
                        maxY: (maxvalue + 5),
                        lineBarsData: [
                          if (widget.heading != "Blood Pressure")
                            LineChartBarData(
                              spots: getSpots(),
                            ),
                          if (widget.heading == "Blood Pressure")
                            LineChartBarData(
                              spots: getUpperSpots(),
                            ),
                          if (widget.heading == "Blood Pressure")
                            LineChartBarData(
                              spots: getLowerSpots(),
                            ),
                        ],
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: AxisTitles(
                            axisNameWidget: Text(""),
                          ),
                          leftTitles: AxisTitles(
                            axisNameSize: 30,
                            axisNameWidget: Text(widget.heading),
                          ),
                          bottomTitles: AxisTitles(
                            // axisNameWidget: Container(
                            //   margin: EdgeInsets.all(5),
                            //   child: Text("Date"),
                            // ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                DateTime date =
                                    DateTime.fromMillisecondsSinceEpoch(
                                        value.toInt());
                                String dateString =
                                    DateFormat("yyyy-MM-d").format(date);
                                return Container(
                                  margin: EdgeInsets.only(
                                    top: 0,
                                  ),
                                  child: Transform.rotate(
                                    angle: -0.785398,
                                    child: Text(dateString),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            if (displayText)
              Expanded(
                child: Container(
                  padding: EdgeInsets.only(left: 30, bottom: 20),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: (widget.heading != "Blood Pressure")
                        ? [
                            Text("Max ${widget.heading} : $max1"),
                            Text("Avg ${widget.heading} : $avg1"),
                            Text("Min ${widget.heading} : $min1"),
                          ]
                        : [
                            Text("Max Upper ${widget.heading} : $max1"),
                            Text("Avg Upper ${widget.heading} : $avg1"),
                            Text("Min Upper ${widget.heading} : $min1"),
                            Text("Max Lower ${widget.heading} : $max2"),
                            Text("Avg Lower ${widget.heading} : $avg2"),
                            Text("Min Lower ${widget.heading} : $min2"),
                          ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
