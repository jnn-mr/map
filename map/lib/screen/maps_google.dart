import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:map/screen/list.dart';

class FavoritePlace {
  final String id;
  final String description;
  final LatLng position;

  FavoritePlace({
    required this.id,
    required this.description,
    required this.position,
  });
}

class MapsScreen extends StatefulWidget {
  MapsScreen({super.key});

  static final initialPosition = LatLng(15.987762855155182, 120.57310242604986);

  @override
  State<MapsScreen> createState() => _MapsScreenState();
}

class _MapsScreenState extends State<MapsScreen> {
  late GoogleMapController mapController;
  late TextEditingController descController;
  late CollectionReference favPlaces;

  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    descController = TextEditingController();
    favPlaces = FirebaseFirestore.instance.collection('favorite_places');
    getCurrentLocation();
    fetchFavoritePlaces();
  }

  @override
  void dispose() {
    descController.dispose();
    super.dispose();
  }

  void fetchFavoritePlaces() async {
    final querySnapshot = await favPlaces.get();
    setState(() {
      markers = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(data['position']['latitude'], data['position']['longitude']),
          infoWindow: InfoWindow(
            title: doc.id,
            snippet: data['description'],
          ),
        );
      }).toSet();
    });
  }

  Future<void> saveFavoritePlace(LatLng position) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Favorite Place'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: descController,
                  decoration: InputDecoration(labelText: 'Description'),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final description = descController.text;
                favPlaces.add({
                  'description': description,
                  'position': {
                    'latitude': position.latitude,
                    'longitude': position.longitude,
                  },
                });
                saveToLocation(position, description);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void saveToLocation(LatLng position, String description) {
    markers.add(
      Marker(
        markerId: MarkerId('${position.latitude}_${position.longitude}'),
        position: position,
        infoWindow: InfoWindow(
          title: description,
        ),
      ),
    );
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 15,
        ),
      ),
    );
    setState(() {});
  }

  Future<bool> checkServicePermission() async {
    bool isEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location services is disabled. Please enable it in the settings.'),
        ),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'Location permission is denied. Please accept the location permission of the app to continue.'),
          ),
        );
      }
      return false;
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Location permission is permanently denied. Please change in the settings to continue.'),
        ),
      );
      return false;
    }
    return true;
  }

  void getCurrentLocation() async {
    if (!await checkServicePermission()) {
      return;
    }
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 10,
      ),
    ).listen((position) {
      saveToLocation(LatLng(position.latitude, position.longitude), 'My Location');
    });
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          mapToolbarEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: MapsScreen.initialPosition,
            zoom: 10,
          ),
          markers: markers,
          onTap: (position) {
            saveFavoritePlace(position);
          },
          onMapCreated: (controller) {
            mapController = controller;
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FavoriteLocationsScreen()),
          );
        },
        child: Icon(Icons.favorite),
      ),
    );
  }
}