import 'package:flutter/material.dart';
import 'package:flutter_restaurapp/models/product_model.dart';
import 'package:flutter_restaurapp/pages/employees_page.dart';
import 'package:flutter_restaurapp/pages/graphics_page.dart';
import 'package:flutter_restaurapp/pages/login_page.dart';
import 'package:flutter_restaurapp/pages/product_detail_page.dart';
import 'package:flutter_restaurapp/pages/products_page.dart';
import 'package:flutter_restaurapp/pages/time_records_page.dart';

class HomeTabPage extends StatefulWidget {
  const HomeTabPage({super.key});

  @override
  State<HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<HomeTabPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Builder(builder: (context) {
                  return IconButton(
                    onPressed: () {
                      Scaffold.of(context).openDrawer();
                    },
                    icon: const Icon(Icons.menu),
                  );
                }),
                const Expanded(
                  child: TabBar(tabs: [
                    Tab(
                      icon: Icon(Icons.food_bank),
                      child: Text(
                        "Inventario",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.person),
                      child: Text(
                        "Personal",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.bar_chart_rounded),
                      child: Text(
                        "Gráficos",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                    Tab(
                      icon: Icon(Icons.calendar_today),
                      child: Text(
                        "Horas",
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(color: Colors.blue),
                child: Column(
                  children: <Widget>[
                    Text(
                      "RestaurApp",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    )
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text("Cerrar sesión"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ProductsPage(),
            EmployeesPage(),
            const GraphicsPage(),
            const TimeRecordsPage()
          ],
        ),
        floatingActionButton: Builder(
          builder: (context) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(
                      product: Product(
                        id: "",
                        name: '',
                        quantity: 0.0,
                        measure: '',
                        scarseState: 0.0,
                        sufficientState: 0.0,
                        thumbnailImage: '',
                        details: '',
                      ),
                    ),
                  ),
                );
              },
              tooltip: 'Add Product',
              child: const Icon(Icons.add),
            );
          },
        ),
      ),
    );
  }
}
