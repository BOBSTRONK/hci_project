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
      return GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text('History'),
          ),
          body: buildListOfHistory(),
        ),
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
                    ListOfHistory[index].description != null
                        ? Text(
                            "Description: ${ListOfHistory[index].description}",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )
                        : Text("You didn't add any description on this History",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  setState(() {});
                                } else {
                                  setState(() {});
                                }
                              },
                              controller: textFieldController,
                              textInputAction: TextInputAction.newline,
                              maxLines: null,
                              keyboardType: TextInputType.multiline,
                              decoration: InputDecoration(
                                  labelText: 'Enter Your description',
                                  enabledBorder: UnderlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(90)),
                                    borderSide: MediaQuery.of(context)
                                                .platformBrightness ==
                                            Brightness.light
                                        ? BorderSide.none
                                        : BorderSide(
                                            color:
                                                Colors.grey.withOpacity(0.3)),
                                  ),
                                  filled: true,
                                  focusedBorder: UnderlineInputBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(90)),
                                      borderSide: MediaQuery.of(context)
                                                  .platformBrightness ==
                                              Brightness.light
                                          ? BorderSide.none
                                          : BorderSide(
                                              color: Colors.grey
                                                  .withOpacity(0.3)))),
                            ),
                          ),
                          textFieldController.text.trim().isEmpty
                              ? SizedBox()
                              : Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: SizedBox(
                                    child: RawMaterialButton(
                                      fillColor: Colors.red,
                                      shape: const CircleBorder(),
                                      onPressed: () {
                                        uploadHistory(ListOfHistory[index]);
                                      },
                                      elevation: 5.0,
                                      child: Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ))
                        ],
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

  void uploadHistory(History history) {
    if (textFieldController.text.trim().isEmpty) {
      return;
    }

    History updateHistory = History(
        id: history.id,
        startTime: history.startTime,
        endTime: history.endTime,
        duration: history.duration,
        description: textFieldController.text);

    _beaconRepositoryNotifier!.updateHistoryDesc(updateHistory);
    textFieldController.clear();
  }
}
