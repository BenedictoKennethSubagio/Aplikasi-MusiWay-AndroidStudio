import 'package:flutter/material.dart';
import 'package:test2/Assistants/request_assistant.dart';
import 'package:test2/global/map_key.dart';
import 'package:test2/models/predictplace.dart';
import 'package:test2/widgets/placepredictiontitle.dart';

class SearchLocation extends StatefulWidget {
  const SearchLocation({super.key});

  @override
  State<SearchLocation> createState() => _SearchLocationState();
}

class _SearchLocationState extends State<SearchLocation> {
  List<Predictplace> placePredictedList = [];
  AutoCompleteSearch(String InputText) async{
    if(InputText.length>1){
      String urlAutoCompleteSearch= "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$InputText&key=$mapKey&components=country:IDN";
      var responseAutoCompleteSearch = await RequestAssistant.receiveRequest(urlAutoCompleteSearch);

      if(responseAutoCompleteSearch == "Error Bang"){
        return;
      }
      if(responseAutoCompleteSearch["Status"]=="OK"){
        var placePredictions = responseAutoCompleteSearch["predictions"];
        var placePredictionsList = (placePredictions as List).map((jsonData)=> Predictplace.fromJson(jsonData)).toList();
        setState(() {
          placePredictionsList = placePredictionsList;
        });
      }
    }

  }
  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
          leading: GestureDetector(
            onTap: (){
              Navigator.pop(context);
            },
            child: Icon(Icons.arrow_back, color: darkTheme? Colors.black : Colors.white),
          ),
          title: Text(
            "Search and Set Next Bus Stop",
            style: TextStyle(color: darkTheme ? Colors.black : Colors.white),
          ),
          elevation: 0.0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white54,
                    blurRadius: 8,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7
                    )
                  )
                ]
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.adjust_sharp,
                          color: darkTheme ? Colors.black45 : Colors.white,
                        ),
                        SizedBox(height: 18,),
                        Expanded(
                            child:Padding(
                              padding: EdgeInsets.all(8),
                              child: TextField(
                                onChanged: (value){
                                  AutoCompleteSearch(value);

                                },
                                decoration: InputDecoration(
                                  hintText: "Search Location...",
                                  fillColor: darkTheme ? Colors.black : Colors.white54,
                                  filled: true,
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(
                                    left: 11,
                                    top: 8,
                                    bottom: 8,
                                  )
                                ),
                              ),
                            )
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            (placePredictedList.length>0)
            ? Expanded(
              child: ListView.separated(
                itemCount: placePredictedList.length,
                physics: ClampingScrollPhysics(),
                itemBuilder: (context, index){
                  return Placepredictiontitle(
                    predictplace: placePredictedList[index],
                  );
                },
                separatorBuilder:(BuildContext context, int index){
                  return Divider(
                    height: 0,
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                    thickness: 0,
                  );
                },

              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }
}
