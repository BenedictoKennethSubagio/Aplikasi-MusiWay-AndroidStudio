import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test2/Assistants/request_assistant.dart';
import 'package:test2/global/global.dart';
import 'package:test2/global/map_key.dart';
import 'package:test2/infoHandler/infoapp.dart';
import 'package:test2/models/directions.dart';
import 'package:test2/models/predictplace.dart';
import 'package:test2/widgets/progressdialog.dart';

class Placepredictiontitle extends StatefulWidget {

  final Predictplace? predictplace;

  Placepredictiontitle({
    this.predictplace
  });

  @override
  State<Placepredictiontitle> createState() => _PlacepredictiontitleState();
}

class _PlacepredictiontitleState extends State<Placepredictiontitle> {
  getPlaceDirectionDetails(String? placeId, context)async{
    showDialog(
        context: context,
        builder: (BuildContext context) => Progressdialog(
          message: "Setting up Next Bus Stop",
        )
    );
    String placeDirectionDetailsurl = 'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$mapKey';
    var responseApi= await RequestAssistant.receiveRequest(placeDirectionDetailsurl);
    Navigator.pop(context);
    if(responseApi == "Error Bang"){
      return;
    }
    if(responseApi["Status"]==["OK"]){
      Directions directions = Directions();
      directions.locationName = responseApi["Result"]["Name"];
      directions.locationId = placeId;
      directions.locationLongtitude = responseApi["Result"]["Geometry"]["Location"]["lat"];
      directions.locationLatitude = responseApi["Result"]["Geometry"]["Location"]["lat"];

      Provider.of<Infoapp>(context,listen: false).updateDropOffLocationAddress(directions);
      setState(() {
        userDropOffAddress = directions.locationName!;
      });
      Navigator.pop(context,"obtainedDropoff");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
        onPressed: (){
          getPlaceDirectionDetails(widget.predictplace!.place_id, context);

        },
        style: ElevatedButton.styleFrom(
          backgroundColor: darkTheme ? Colors.black : Colors.white,
        ),
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(
                Icons.add_location,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              ),
              SizedBox(width: 10,),
              Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.predictplace!.prim_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                        ),
                      ),
                      Text(
                        widget.predictplace!.sec_text!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                        ),
                      ),
                    ],
                  )
              )
            ],
          ),
        )
    );
  }
}
