import 'dart:math';

import 'package:birthcake_bakers/tools/my_strings.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocalMethods {
  //initDist is the distance before the driver starts to ride
  static double dist, initDist, hours, minutes, seconds;
  static var speed = 53;
  static var initialDistance;

  static capitalize(String word) {
    List<String> input = word.split(" ");
    StringBuffer sb = StringBuffer();
    String result = "", output= "";
    try {
      for (var res in input) {
        result = res.substring(0, 1).toUpperCase() + res.substring(1);
        sb.write(result + " ");
      }

       output = sb.toString();
    } catch (e) {}

    return output;
  }

   static double deg2rad(double deg) {
      return (deg * pi / 180.0);
  }

  static double rad2deg(double rad) {
      return (rad * 180.0 / pi);
    }
  
  //Pass two parameters to distanceInkm method, customer current position and 
  //Driver current position
  static distanceInKm(clientLat, driverLat, clientLong, driverLong){
      // var R = 6371; // km
      var lat1 = clientLat, lat2 = driverLat;
      var lon1 = clientLong, lon2 = driverLong;
     double theta = lon1 - lon2;
     dist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) 
                    * cos(deg2rad(lat2)) * cos(deg2rad(theta));
      dist = acos(dist);
      dist = rad2deg(dist);
      dist = dist * 60 * 1.1515;
      // if (unit == 'K') {
        dist = dist * 1.609344;
      // } else if (unit == 'N') {
        // dist = dist * 0.8684;
        // } formula of time = distance / speed
      return (dist.toStringAsFixed(2));
  }

  static estimatedTime(){
    var time = dist / speed;
    var estimated ;

    hours = time / 3600;
    minutes = time * 3600 / 60;

    seconds = minutes.remainder(3);

    seconds = seconds * 60;

    //Check if seconds is greater than 60, then convert it back to 60
    if(seconds > 60){
      seconds = seconds / 60;
      seconds =  seconds.remainder(3);
    }

    // print("${hours.round()} : ${minutes.round()} : $seconds");
    
    if (hours.round() == 0) {
      estimated = "${minutes.round()}min ${seconds.round()}s";
    } else {
      estimated = "${hours.round()}h ${minutes.round()}min";
    }
    return estimated;
  }

  static getInitialDistance(cLat, dLat, cLong, dLong){
    var lat1 = 0.2846263, lat2 = 0.2846263;
      var lon1 = 32.6065395, lon2 = 32.6565395;
     double theta = lon1 - lon2;
     initDist = sin(deg2rad(lat1)) * sin(deg2rad(lat2)) + cos(deg2rad(lat1)) 
                    * cos(deg2rad(lat2)) * cos(deg2rad(theta));
      initDist = acos(initDist);
      initDist = rad2deg(initDist);
      initDist = initDist * 60 * 1.1515;
      // if (unit == 'K') {
      initDist = initDist * 1.609344;

      initialDistance = initDist.toStringAsFixed(2);
      return (initDist.toStringAsFixed(2));
  }

  static arrivalStatus(){
    var status = "";
    var distance = double.parse(dist.toStringAsFixed(2));
    //the real or initial distance between driver and customer
    if (distance >= 50.0) {
      status = Strings.onMyWay;
    } else if(dist <= (dist / 2)) {
      status = Strings.almostThere;
    }else if(dist <= 1.500){
      status = Strings.closeToYou;
    }else {
      status = Strings.alreadyThere;
    }
    // print("The get initial distance is $initialDistance and distance $distance");

    return status;
  }

  static hasDriverArrived(LatLng clientLocation, LatLng driverLocation){
    // double cLat = clientLocation.latitude;
    // double dLat =  driverLocation.latitude;
    // double cLong =  clientLocation.longitude;
    // double dLong =  driverLocation.longitude;


  }
}
