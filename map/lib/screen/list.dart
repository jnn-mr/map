import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteLocationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Places'),
        centerTitle: true,
      ),
      body: FavoriteLocationsList(),
    );
  }
}

class FavoriteLocationsList extends StatefulWidget {
  @override
  _FavoriteLocationsListState createState() => _FavoriteLocationsListState();
}

class _FavoriteLocationsListState extends State<FavoriteLocationsList> {
  List<DocumentSnapshot> favoritePlaces = [];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('favorite_places').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No favorite locations found.'),
          );
        }

        favoritePlaces = snapshot.data!.docs;

        return ListView.builder(
          itemCount: favoritePlaces.length,
          itemBuilder: (BuildContext context, int index) {
            final data = favoritePlaces[index].data() as Map<String, dynamic>;
            final description = data['description'] ?? '';
            final title = data['name'] ?? '';

            return Card(
              child: ListTile(
                title: Text('$title'),
                subtitle: Text(description),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    deleteFavoritePlace(favoritePlaces[index].id);
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> deleteFavoritePlace(String documentId) async {
    try {
      await FirebaseFirestore.instance.collection('favorite_places').doc(documentId).delete();
      setState(() {
        favoritePlaces.removeWhere((doc) => doc.id == documentId);
      });
    } catch (e) {
      print('Error deleting favorite place: $e');
    }
  }
}
