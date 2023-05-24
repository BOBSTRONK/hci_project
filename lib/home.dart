import 'package:flutter/material.dart';
import 'screen/chat.dart';
import 'screen/dashboard.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  int currentTab = 0;
  final List<Widget> screens = [
    Dashboard(),
    Chat()
  ];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = Dashboard();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      floatingActionButton: FloatingActionButton( //add button
        child: Icon(Icons.add),
        onPressed: () => _onButtonPressed(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //left bluetooth
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () {
                      setState(() {
                        currentScreen = Dashboard();
                        currentTab = 0;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.bluetooth,
                          color: currentTab == 0 ? Colors.blueAccent : Colors.grey,
                        ),
                        Text(
                          'BLE',
                          style: TextStyle(color: currentTab == 0 ? Colors.blueAccent : Colors.grey),
                        )
                      ],
                    ),
                    )
                ],
              ),
              //right history
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MaterialButton(
                    minWidth: 60,
                    onPressed: () {
                      setState(() {
                        currentScreen = Chat();
                        currentTab = 1;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.history,
                          color: currentTab == 1 ? Colors.blueAccent : Colors.grey,
                        ),
                        Text(
                          'History',
                          style: TextStyle(color: currentTab == 1 ? Colors.blueAccent : Colors.grey),
                        )
                      ],
                    ),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _onButtonPressed() {
    showModalBottomSheet(context: context, builder: (context) {
      return Container(
        color: Color(0xFF737373),
        height: 120,
        child: Container(
          child: _buildBottomNavigationMenu(),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(10),
              topRight: const Radius.circular(10),
            ),
          ),
        ),
      );
    });
  }

  Column _buildBottomNavigationMenu() {
    return Column(children: <Widget>[
        ListTile(
          leading: Icon(Icons.add),
          title: Text('Add Beacon'),
          onTap: (){},
        ),
        ListTile(
          leading: Icon(Icons.bluetooth),
          title: Text('io come Beacon'),
          onTap: (){},
        )
      ],
    );
  }
}