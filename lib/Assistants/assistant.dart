import 'dart:js_interop';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:test2/Assistants/request_assistant.dart';
import 'package:test2/global/global.dart';
import 'package:test2/global/map_key.dart';
import 'package:test2/infoHandler/infoapp.dart';
import 'package:test2/models/directions.dart';
import 'package:test2/models/user_model.dart';

import '../models/direction_detailinfo.dart';

class AssistantMethods{
  static void readCurrentonlineUserInfo()async{
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef = FirebaseDatabase.instance.ref().child("user").child(currentUser!.uid);
    userRef.once().then((snap){
      if(snap.snapshot.value != null){
        userModelCurrentInfo = UserModel.fromSnapshot(snap.snapshot);
      }
    });

  }

  static Future<String> searchAddress(Position position, context) async{
    String apiurl = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey';
    String ReadableAddress ='';
    var requestResponse = await RequestAssistant.receiveRequest(apiurl);

    if(requestResponse!= "Error Bang"){
      ReadableAddress = requestResponse["results"][0]["formatted Address"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationLatitude = position.latitude;
      userPickUpAddress.locationLongtitude = position.longitude;
      userPickUpAddress.locationName = ReadableAddress;
      Provider.of<Infoapp>(context,listen: false).updateDropOffLocationAddress(userPickUpAddress);
    }

    return ReadableAddress;
  }
  static Future<DirectionDetailinfo> obtainOrigintoDestinationDirectionDetails(LatLng originPositions, LatLng Destinationposition)async{
    String urlDestinationDetails = "https://maps.googleapis.com/maps/api/directions/json?origin=${originPositions.latitude},${originPositions.longitude}&destination=${Destinationposition.latitude},${Destinationposition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.receiveRequest(urlDestinationDetails);
    // if(responseDirectionApi == "Error Bang"){
    //   return null;
    // }
    DirectionDetailinfo directionDetailinfo = DirectionDetailinfo();
    directionDetailinfo.distanceText = responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailinfo.distance_value = responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailinfo.durationText = responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailinfo.durationText = responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
    return directionDetailinfo;

  }
}