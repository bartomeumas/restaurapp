import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_restaurapp/models/product_model.dart';
import 'package:flutter_restaurapp/services/product_service.dart';

class _BarChart extends StatelessWidget {
  final List<Product> products;

  const _BarChart({required this.products});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue[50], // Light blue background color
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Inner padding
          child: BarChart(
            BarChartData(
              barTouchData: barTouchData,
              titlesData: titlesData,
              borderData: borderData,
              barGroups: barGroups,
              gridData: const FlGridData(show: false),
              alignment:
                  BarChartAlignment.spaceBetween, // Align bars to the left
              maxY: products.isNotEmpty
                  ? products
                          .map((p) => p.quantity)
                          .reduce((a, b) => a > b ? a : b) +
                      10
                  : 20,
            ),
          ),
        ),
      ),
    );
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: false,
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (group) => Colors.transparent,
          tooltipPadding: EdgeInsets.zero,
          tooltipMargin: 8,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Colors.blue,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text = products.isNotEmpty ? products[value.toInt()].name : '';
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 4,
      child: Text(text, style: style),
    );
  }

  FlTitlesData get titlesData => FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            getTitlesWidget: getTitles,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
      );

  FlBorderData get borderData => FlBorderData(
        show: false,
      );

  LinearGradient get _barsGradient => const LinearGradient(
        colors: [
          Colors.blueGrey,
          Colors.deepPurple,
        ],
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
      );

  List<BarChartGroupData> get barGroups =>
      products.asMap().entries.map((entry) {
        int index = entry.key;
        Product product = entry.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: product.quantity,
              gradient: _barsGradient,
              width: 30,
            )
          ],
          showingTooltipIndicators: [0],
        );
      }).toList();
}

class _PieChart extends StatelessWidget {
  final double scarcePercentage;
  final double sufficientPercentage;
  final double excellentPercentage;

  const _PieChart({
    required this.scarcePercentage,
    required this.sufficientPercentage,
    required this.excellentPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlue[50], // Light blue background color
          borderRadius: BorderRadius.circular(16), // Rounded corners
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0), // Inner padding
          child: PieChart(
            PieChartData(
              sections: [
                PieChartSectionData(
                  color: Colors.red,
                  value: scarcePercentage,
                  title: '${scarcePercentage.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.yellow,
                  value: sufficientPercentage,
                  title: '${sufficientPercentage.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.green,
                  value: excellentPercentage,
                  title: '${excellentPercentage.toStringAsFixed(1)}%',
                  radius: 50,
                  titleStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
      ),
    );
  }
}

class GraphicsPage extends StatefulWidget {
  const GraphicsPage({super.key});

  @override
  State<StatefulWidget> createState() => GraphicsPageState();
}

class GraphicsPageState extends State<GraphicsPage> {
  late Future<Map<String, double>> _productPercentagesFuture;
  late Future<List<Product>> _quesoProductsFuture;
  late Future<List<Product>> _jamonProductsFuture;

  @override
  void initState() {
    super.initState();
    _productPercentagesFuture = Future.delayed(Duration.zero, () => {});
    _quesoProductsFuture = Future.delayed(Duration.zero, () => []);
    _jamonProductsFuture = Future.delayed(Duration.zero, () => []);
    _loadProductPercentages();
    _loadProductsContaining('Queso');
    _loadProductsContaining('Jamón');
  }

  Future<void> _loadProductPercentages() async {
    try {
      Map<String, double> productPercentages =
          await ProductService().getProductPercentages();
      setState(() {
        _productPercentagesFuture = Future.value(productPercentages);
      });
    } catch (e) {
      setState(() {
        _productPercentagesFuture = Future.error(e);
      });
    }
  }

  Future<void> _loadProductsContaining(String substring) async {
    try {
      List<Product> products =
          await ProductService().getProductsContaining(substring);
      if (substring == 'Queso') {
        setState(() {
          _quesoProductsFuture = Future.value(products);
        });
      } else if (substring == 'Jamón') {
        setState(() {
          _jamonProductsFuture = Future.value(products);
        });
      }
    } catch (e) {
      if (substring == 'Queso') {
        setState(() {
          _quesoProductsFuture = Future.error(e);
        });
      } else if (substring == 'Jamón') {
        setState(() {
          _jamonProductsFuture = Future.error(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Text(
              "Estado de los productos",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 4,
              child: FutureBuilder<Map<String, double>>(
                future: _productPercentagesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No se encontraron datos.'));
                  } else {
                    return _PieChart(
                      scarcePercentage: snapshot.data!['scarce'] ?? 0,
                      sufficientPercentage: snapshot.data!['sufficient'] ?? 0,
                      excellentPercentage: snapshot.data!['excellent'] ?? 0,
                    );
                  }
                },
              ),
            ),
            const Text(
              "Quesos (gramos)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: FutureBuilder<List<Product>>(
                future: _quesoProductsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No hay productos con "Queso"'));
                  } else {
                    return _BarChart(products: snapshot.data!);
                  }
                },
              ),
            ),
            const Text(
              "Jamones (gramos)",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: FutureBuilder<List<Product>>(
                future: _jamonProductsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text('No hay productos con "Jamón"'));
                  } else {
                    return _BarChart(products: snapshot.data!);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
