import 'package:flutter/material.dart';
import 'package:BeaconGuard/screen/beacon_scanned_page.dart';
import 'package:BeaconGuard/model/history_model.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';

import '../service/beacon_repository.dart';

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  BeaconRepositoryNotifier? _beaconRepositoryNotifier;
  String userInput = '';
  List<History> ListOfHistory = <History>[];
  bool isTextFieldVisible = false;
  TextEditingController textFieldController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<BeaconRepositoryNotifier>(
            create: (BuildContext context) => BeaconRepositoryNotifier())
      ],
      child: _build(),
    );
  }

  @override
  Widget _build() {
    return Builder(builder: (context) {
      _beaconRepositoryNotifier = context.watch<BeaconRepositoryNotifier>();
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('History'),
        ),
        body: buildListOfHistory(),
      );
    });
  }

  Widget buildListOfHistory() {
    ListOfHistory = _beaconRepositoryNotifier!.savedHisotry;
    if (ListOfHistory.isEmpty) {
      return const Center(
        child: Text("There is no History.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 25,
                fontWeight: FontWeight.w600)),
      );
    }
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(
              color: Colors.grey,
              height: 0.8,
              thickness: 1,
            ),
        itemCount: ListOfHistory.length,
        itemBuilder: (BuildContext context, int index) {
          return Card(
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                  side: BorderSide(width: 2),
                  borderRadius: BorderRadius.circular(20)),
              title: Text(
                "${DateFormat('E, dd/MM').format(ListOfHistory[index].startTime)}",
                style: TextStyle(fontSize: 20),
              ),
              subtitle: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "${DateFormat('HH:MM').format(ListOfHistory[index].startTime)} ----- ${durationInMinutes(ListOfHistory[index].duration)} ----- ${DateFormat('HH:MM').format(ListOfHistory[index].endTime)}  ",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 21),
                  ),
                ),
              ),
              trailing: Icon(Icons.arrow_circle_down),
              children: [
                Column(
                  children: [
                    ListOfHistory[index].description!=null? Text("Description: ${ListOfHistory[index].description}") : Text("You didn't add any description on this History"),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        onChanged: (value){
                          setState(() {
                            userInput=value;
                          });
                        },
                        
                        decoration: InputDecoration(labelText: 'Enter Your description',enabledBorder:UnderlineInputBorder() ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  String durationInMinutes(int duration) {
    int minutes = (duration / 60).truncate();
    int seconds = duration % 60;
    String minuteFormat = "$minutes:${seconds.toString().padLeft(1, "0")}";
    return minuteFormat;
  }
}
