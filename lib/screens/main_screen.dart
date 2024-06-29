import 'dart:async';
import 'dart:convert';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' as loc;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:test2/Assistants/assistant.dart';
import 'package:test2/global/global.dart';
import 'package:test2/global/map_key.dart';
import 'package:test2/infoHandler/infoapp.dart';
import 'package:test2/models/user_model.dart';
import 'package:test2/screens/search_location.dart';
import 'package:test2/widgets/progressdialog.dart';

import '../models/directions.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  LatLng? pickLocation;
  loc.Location location = loc.Location();
  String? _address;

  final Completer<GoogleMapController> _controllerGoogleMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  GlobalKey<ScaffoldState> _scaffoldsState = GlobalKey<ScaffoldState>();
  double SearchLocationContainerHeight = 220;
  double waitingResponsefromDriverContainerHeight = 0;
  double assignDriverInfoContainerHeight = 0;

  Position? userCurrentPosition;

  var geolocation = Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingofMap = 0;
  List<LatLng>plineCoordinates = [];
  Set<Polyline> polylineSet = {};
  Set<Marker> marketSet = {};
  Set<Circle> circleSet = {};

  String userName = '';
  String userEmail = '';

  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;



  locateUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;

    LatLng latLngPosition = LatLng(
        userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition = CameraPosition(
        target: latLngPosition, zoom: 15);
    newGoogleMapController!.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition));

    String ReadableAddress = await AssistantMethods.searchAddress(
        userCurrentPosition!, context);
    print("This is our address = " + ReadableAddress);

    userName = userModelCurrentInfo!.name!;
    userEmail = userModelCurrentInfo!.email!;
    // initializeGeoFireListener();
    // AssistantMethods.readTripsKeysForOnlineUser(context);
  }
  Future<void>drawPolyLinetoDestination(bool darkTheme) async{
    var originPosition = Provider.of<Infoapp>(context,listen: false).userPickUpLocation;
    var DestinationPosition = Provider.of<Infoapp>(context,listen: false).userDropOffLocation;
    var originLatlng = LatLng(originPosition!.locationLatitude!, originPosition!.locationLongtitude!);
    var DestinationLatlng = LatLng(DestinationPosition!.locationLatitude!, DestinationPosition!.locationLongtitude!);

    showDialog(
        context: context,
        builder: (BuildContext context) => Progressdialog(message: "Please wait...",),
    );
    var directionDetailsInfo = await AssistantMethods.obtainOrigintoDestinationDirectionDetails(originLatlng, DestinationLatlng);
    setState(() {
      tripDirectionDetailsInfo = directionDetailsInfo;
    });
    Navigator.pop(context);
    PolylinePoints pPoints = PolylinePoints();
    List<PointLatLng> decodePolyLinePointsResultList = pPoints.decodePolyline(directionDetailsInfo.e_points!);
    plineCoordinates.clear();
    if(decodePolyLinePointsResultList.isNotEmpty){
      decodePolyLinePointsResultList.forEach((PointLatLng pointLatLn){
        plineCoordinates.add(LatLng(pointLatLn.latitude, pointLatLn.longitude));
      });
    }
    polylineSet.clear();

    setState(() {
      Polyline polyline = Polyline(
        color: darkTheme ? Colors.amberAccent : Colors.blue,
        polylineId: PolylineId("PolylineID"),
        jointType: JointType.round,
        points: plineCoordinates,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );
      polylineSet.add(polyline);
    });
    LatLngBounds boundslatLng;
    if(originLatlng.latitude > DestinationLatlng.latitude && originLatlng.longitude > DestinationLatlng.longitude){
      boundslatLng = LatLngBounds(southwest: DestinationLatlng, northeast: originLatlng);
    }else if(originLatlng.longitude > DestinationLatlng.longitude){
      boundslatLng = LatLngBounds(
          southwest: LatLng(originLatlng.latitude,DestinationLatlng.longitude),
          northeast: LatLng(DestinationLatlng.latitude,originLatlng.longitude,)
      );
    }
    else if(originLatlng.latitude > DestinationLatlng.latitude){
      boundslatLng = LatLngBounds(
          southwest: LatLng(DestinationLatlng.latitude,originLatlng.longitude),
          northeast: LatLng(originLatlng.latitude,DestinationLatlng.longitude,)
      );
    }else{
      boundslatLng = LatLngBounds(southwest: originLatlng, northeast: DestinationLatlng);
    }
    newGoogleMapController!.animateCamera(CameraUpdate.newLatLngBounds(boundslatLng, 65));
    Marker originMarker = Marker(
        markerId: MarkerId("OriginID"),
      infoWindow: InfoWindow(title: originPosition.locationName,snippet: "Origin"),
      position: originLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: MarkerId("DestionationID"),
      infoWindow: InfoWindow(title: originPosition.locationName,snippet: "Destination"),
      position: originLatlng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      marketSet.add(originMarker);
      marketSet.add(destinationMarker);
    });

  }


    getAddressFromLatLng() async {
      try {
        GeoData data = await Geocoder2.getDataFromCoordinates(
            latitude: pickLocation!.latitude,
            longitude: pickLocation!.longitude,
            googleMapApiKey: mapKey
        );
        setState(() {
          Directions userPickUpAddress = Directions();
          userPickUpAddress.locationLatitude = pickLocation!.latitude;
          userPickUpAddress.locationLongtitude = pickLocation!.longitude;
          userPickUpAddress.locationName = data.address;
          Provider.of<Infoapp>(context,listen: false).updatePickUpAddress(userPickUpAddress);

        });
      } catch (e) {
        print(e);
      }
    }

    checkIfLocationPermissionisAllowed() async {
      _locationPermission = await Geolocator.requestPermission();

      if (_locationPermission == LocationPermission.denied) {
        _locationPermission = await Geolocator.requestPermission();
      }
    }

    @override
    void initState() {
      // TODO: implement initState
      super.initState();

      checkIfLocationPermissionisAllowed();
    }

    @override
    Widget build(BuildContext context) {

      bool darkTheme = MediaQuery.of(context).platformBrightness == Brightness.dark;
      return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                mapType: MapType.normal,
                myLocationEnabled: true,
                zoomControlsEnabled: true,
                zoomGesturesEnabled: true,
                polylines: polylineSet,
                markers: marketSet,
                circles: circleSet,
                initialCameraPosition: _kGooglePlex,
                onMapCreated: (GoogleMapController controller) {
                  _controllerGoogleMap.complete(controller);
                  newGoogleMapController = controller;

                  setState(() {

                  });
                  locateUserPosition();
                },
                onCameraMove: (CameraPosition? position) {
                  if (pickLocation != position!.target) {
                    setState(() {
                      pickLocation = position.target;
                    });
                  }
                },
                onCameraIdle: () {
                  // getAddressFromLatLng();
                },
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 35.0),
                  child: Image.asset(
                    "location_blacak.png", height: 45, width: 45,),
                ),

              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: darkTheme ? Colors.black:Colors.white,
                          borderRadius: BorderRadius.circular(10)
                        ),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: darkTheme ? Colors.grey.shade400 : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(10)
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(10),
                                    child:Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, color: darkTheme ? Colors.amber.shade400 : Colors.blue,),
                                        SizedBox(width: 10,),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("From",
                                              style: TextStyle(
                                                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                                  fontSize:12,
                                                  fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text( Provider.of<Infoapp>(context).userPickUpLocation!=null ? (Provider.of<Infoapp>(context).userPickUpLocation!.locationName!).substring(0,24)+
                                                ". . ." : "Not Getting Address",
                                              style: TextStyle(color: Colors.grey, fontSize: 14),
                                            )
                                          ],
                                        )
                                      ],
                                    ) ,
                                  ),
                                  SizedBox(height: 5,),
                                  Divider(
                                    height: 1,
                                    thickness: 2,
                                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                  ),
                                  SizedBox(height: 5,),
                                  Padding(
                                    padding: EdgeInsets.all(5),
                                    child: GestureDetector(
                                      onTap: () async{
                                        var responsseFromSearch = await Navigator.push(context, MaterialPageRoute(builder: (c)=> SearchLocation()));
                                        if(responsseFromSearch == "ObtainedBusStop"){
                                          setState(() {
                                            openNavigationDrawer = false;
                                          });
                                        }
                                        await drawPolyLinetoDestination(darkTheme);

                                      },
                                      child: Row(
                                        children: [
                                          Icon(Icons.location_on_outlined, color: darkTheme ? Colors.amber.shade400 : Colors.blue,),
                                          SizedBox(width: 10,),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("From",
                                                style: TextStyle(
                                                  color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                                                  fontSize:12,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text( Provider.of<Infoapp>(context).userDropOffLocation !=null ? (Provider.of<Infoapp>(context).userDropOffLocation!.locationName!).substring(0,24)+
                                                  ". . ." : "",
                                                style: TextStyle(color: Colors.grey, fontSize: 14),
                                              )
                                            ],
                                          )
                                        ],
                                      ) ,
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),

              ),
              Positioned(
                top: 40,
                right: 20,
                left: 20,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(20),
                  child: Text(
                    Provider.of<Infoapp>(context).userPickUpLocation!=null ? (Provider.of<Infoapp>(context).userPickUpLocation!.locationName!).substring(0,24)+
                        ". . ." : "Not Getting Address",
                    overflow: TextOverflow.visible, softWrap: true,

                  ),
                ),
              )
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }


