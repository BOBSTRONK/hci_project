import 'package:flutter/material.dart';
import 'package:sound_mode/permission_handler.dart';
import 'screen/chat.dart';
import 'screen/dashboard.dart';
import 'screen/beaconList.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentTab = 0;
  double? _deviceWidth;
  bool? isGranted;
  bool isInitialized = false;
  final List<Widget> screens = [Dashboard(), Chat()];

  final PageStorageBucket bucket = PageStorageBucket();
  Widget currentScreen = Dashboard();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getPermissionStatus_firstTime();
  }

  //get the permission status of the application
  Future<void> _getPermissionStatus_firstTime() async {
    isGranted = await PermissionHandler.permissionsGranted;
    print(isGranted);
    if(!isInitialized){
        if (!isGranted!) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return NoPermissionDialog();
          });
    }
    isInitialized=true;
    }
  }
    // if the application has no permission, we ask the user to try grant permission
  Widget NoPermissionDialog() {
    return AlertDialog(
      title: Text("Asking for permission"),
      content: Text(
          "We detected your device hasn't granted permission to the app for enabling Silent mode. If you'd like, we can open the Do Not Disturb Access settings for you to grant access. So when we detect the beacon you added to the trust list, then the device will automatically turn into silent mode"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Cancel",
              style: TextStyle(color: Colors.red),
            )),
        TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await PermissionHandler.openDoNotDisturbSetting();
            },
            child: Text("OK!")),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    _deviceWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      body: PageStorage(
        child: currentScreen,
        bucket: bucket,
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 10,
        child: Container(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MaterialButton(
                    minWidth: _deviceWidth! / 3,
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
                          color:
                              currentTab == 0 ? Colors.blueAccent : Colors.grey,
                        ),
                        Text(
                          'BLE',
                          style: TextStyle(
                            color: currentTab == 0
                                ? Colors.blueAccent
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: _deviceWidth! / 3,
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
                          color:
                              currentTab == 1 ? Colors.blueAccent : Colors.grey,
                        ),
                        Text(
                          'History',
                          style: TextStyle(
                            color: currentTab == 1
                                ? Colors.blueAccent
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  MaterialButton(
                    minWidth: _deviceWidth! / 3,
                    onPressed: () {
                      setState(() {
                        currentScreen = BeaconList();
                        currentTab = 2;
                      });
                    },
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt,
                          color:
                              currentTab == 2 ? Colors.blueAccent : Colors.grey,
                        ),
                        Text(
                          'Beacon List',
                          style: TextStyle(
                            color: currentTab == 2
                                ? Colors.blueAccent
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
