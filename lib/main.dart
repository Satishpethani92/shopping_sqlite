import 'package:flutter/material.dart';
import 'package:library_system_sqflite/database_helper.dart';
import 'package:library_system_sqflite/library_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final dbHelper = DatabaseHelper.instance;

  List<ShoppingModel> shopModel = [];
  List<ShoppingModel> shopByNames = [];

  //insert controllers
  TextEditingController shopNameController = TextEditingController();
  TextEditingController itemsController = TextEditingController();

  //update controllers
  TextEditingController shopNameUpdateController = TextEditingController();
  TextEditingController itemsUpdateController = TextEditingController();
  TextEditingController idUpdateController = TextEditingController();

  //delete controllers
  TextEditingController isDeleteController = TextEditingController();

  //query controller
  TextEditingController queryController = TextEditingController();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showMessageInScaffold(String? message) {
    _scaffoldKey.currentState!.showSnackBar(SnackBar(content: Text(message!)));
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(
                text: "Insert",
              ),
              Tab(
                text: "View",
              ),
              Tab(
                text: "Query",
              ),
              Tab(
                text: "Update",
              ),
              Tab(
                text: "Delete",
              ),
            ],
          ),
          title: Text('TutorialKart - Flutter SQLite Tutorial'),
        ),
        body: TabBarView(
          children: [
            Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: shopNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Shop Name',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: itemsController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Shop item',
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text('Insert Shop Details'),
                    onPressed: () {
                      String name = shopNameController.text;
                      String miles = itemsController.text;
                      _insert(name, miles);
                    },
                  ),
                ],
              ),
            ),
            Container(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: shopModel.length + 1,
                itemBuilder: (BuildContext context, int index) {
                  if (index == shopModel.length) {
                    return RaisedButton(
                      child: Text('Refresh'),
                      onPressed: () {
                        setState(() {
                          _queryAll();
                        });
                      },
                    );
                  }
                  return Container(
                    height: 40,
                    child: Center(
                      child: Text(
                        '[${shopModel[index].shopId}] ${shopModel[index].shopName}'
                        ' - '
                        '${shopModel[index].items} items',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  );
                },
              ),
            ),
            Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: queryController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Shop Name',
                      ),
                      onChanged: (text) {
                        if (text.length >= 2) {
                          setState(() {
                            _query(text);
                          });
                        } else {
                          setState(() {
                            shopByNames.clear();
                          });
                        }
                      },
                    ),
                    height: 100,
                  ),
                  Container(
                    height: 300,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: shopByNames.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Container(
                          height: 50,
                          margin: EdgeInsets.all(2),
                          child: Center(
                            child: Text(
                              '[${shopByNames[index].shopId}] '
                              '${shopByNames[index].shopName} - ${shopByNames[index].items} '
                              'items',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: idUpdateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Shop id',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: shopNameUpdateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Shop Name',
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: itemsUpdateController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Shop Miles',
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text('Update Shop Details'),
                    onPressed: () {
                      int id = int.parse(idUpdateController.text);
                      String name = shopNameUpdateController.text;
                      String items = itemsUpdateController.text;
                      _update(id, name, items);
                    },
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(20),
                    child: TextField(
                      controller: isDeleteController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Shop id',
                      ),
                    ),
                  ),
                  RaisedButton(
                    child: Text('Delete'),
                    onPressed: () {
                      int id = int.parse(isDeleteController.text);
                      _delete(id);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _insert(shopName, items) async {
    Map<String, dynamic> row = {
      DatabaseHelper.shopName: shopName,
      DatabaseHelper.items: items,
    };

    ShoppingModel shoppingModel = ShoppingModel.fromMap(row);
    final id = await dbHelper.insert(shoppingModel);
    _showMessageInScaffold('Inserted row id $id');
  }

  void _queryAll() async {
    final allRows = await dbHelper.queryAllRows();
    shopModel.clear();
    allRows.forEach((element) => shopModel.add(ShoppingModel.fromMap(element)));
    _showMessageInScaffold('Query done');
    setState(() {});
  }

  void _query(name) async {
    final allRows = await dbHelper.queryRows(name);
    shopByNames.clear();
    allRows
        .forEach((element) => shopByNames.add(ShoppingModel.fromMap(element)));
  }

  void _update(id, name, items) async {
    ShoppingModel shoppingModel =
        ShoppingModel(shopId: id, items: items, shopName: name);
    final rowsAffected = await dbHelper.update(shoppingModel);
    _showMessageInScaffold('updated $rowsAffected row(s)');
  }

  void _delete(id) async {
    final rowsAffected = await dbHelper.delete(id);
    _showMessageInScaffold('delete $rowsAffected row(s): row $id');
  }
}
