import 'package:flutter/cupertino.dart';
import 'package:test2/models/directions.dart';

class Infoapp extends ChangeNotifier{
  Directions? userPickUpLocation, userDropOffLocation;
  int countTotalTrips = 0;
  List<String> historyTripsKeyList = [];
  // List<TripsHistoryModel> allTripsHistoryInformationList = [];

  void  updatePickUpAddress(Directions userPickUpAddress){
    userDropOffLocation = userPickUpAddress;
    notifyListeners();
  }
  void updateDropOffLocationAddress(Directions dropOffAddress){
    userDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}