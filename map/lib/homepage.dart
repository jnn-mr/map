import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
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

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key});

  static final initialPosition = LatLng(15.987762855155182, 120.57310242604986);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  Set<Marker> markers = {};
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  String placeName = '';
  String placeDescription = '';

  @override
  void initState() {
    super.initState();
    loadFavoritePlaces();
  }

  void loadFavoritePlaces() async {
    QuerySnapshot snapshot = await firestore.collection('favorite_places').get();
    setState(() {
      markers = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        LatLng position = LatLng(data['latitude'], data['longitude']);
        return Marker(
          markerId: MarkerId(doc.id),
          position: position,
          infoWindow: InfoWindow(title: data['name']),
        );
      }).toSet();
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FavoriteLocationsScreen()),
            ).then((value) {
              loadFavoritePlaces();
            });
          },
            icon: Icon(Icons.delete)
          ),
        ],
        title: Text('Maps'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: GoogleMap(
          mapType: MapType.normal,
          mapToolbarEnabled: true,
          zoomControlsEnabled: true,
          zoomGesturesEnabled: true,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          initialCameraPosition: CameraPosition(
            target: HomeScreen.initialPosition,
            zoom: 10,
          ),
          markers: markers,
          onTap: (position) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Add Favorite Place'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        decoration: InputDecoration(labelText: 'Name'),
                        onChanged: (value) {
                          setState(() {
                            placeName = value;
                          });
                        },
                      ),
                      SizedBox(height: 10),
                      TextField(
                        decoration: InputDecoration(labelText: 'Description'),
                        onChanged: (value) {
                          setState(() {
                            placeDescription = value; 
                          });
                        },
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await firestore.collection('favorite_places').add({
                          'name': placeName,
                          'description': placeDescription,
                          'latitude': position.latitude,
                          'longitude': position.longitude,
                        });
                        loadFavoritePlaces();
                        Navigator.of(context).pop();
                      },
                      child: Text('Add'),
                    ),
                  ],
                );
              },
            );
          },
          onMapCreated: (controller) {
            mapController = controller;
          },
        ),
      ),
    );
  }
}
