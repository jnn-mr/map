//current_location.dart
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' as geocoding;

class CurrentLocation extends StatefulWidget {
  const CurrentLocation({super.key});

  @override
  State<CurrentLocation> createState() => _CurrentLocationState();
}

class _CurrentLocationState extends State<CurrentLocation> {
  Position? position;
  TextEditingController address = TextEditingController();
  geocoding.Location? location;

  Future<bool> checkServicePermission()async{
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location services disabled'),
      ),);
    return false;
    }
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location Permission is denied')));
      }
      return false;
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location Permission is permanently denied')));
      return false;
    }
    return true;
  }

  void getCurrentLocation() async{
    if (!await checkServicePermission()) {
      return;
    }
    position = await Geolocator.getCurrentPosition();
    setState(() {
      
    });
  }

  //geocoding
  void getGeoCoding() async{
    List<geocoding.Location> locations = await geocoding.locationFromAddress(address.text);
    print(locations);
    if (locations.isNotEmpty) {
      setState(() {
        location = locations.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Location'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: getCurrentLocation, 
            child: const Text('Get Location'),
          ),
          Text('Lat: ${position?.latitude ?? '' }'),
          Text('Long: ${position?.longitude ?? ''}'),
          TextField(
            controller: address,
          ),
          ElevatedButton(onPressed: getGeoCoding, child: Text('Geocoding')),
          Text('GPS: ${location?.latitude ?? ''} ${location?.longitude ?? ''}')
        ],
      ),
    );
  }
}