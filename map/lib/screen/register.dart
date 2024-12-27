//register.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final api= 'psgc.gitlab.io';
  Map<String, String> regions = {};
  bool isRegionLoaded = false;
  Map<String, String> provinces = {};
  bool isProvincesLoaded = false;
  var provinceController = TextEditingController();
  Map<String, String> cities = {};
  bool isCitiesLoaded = false;
  var citiesController = TextEditingController();


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    loadRegions();
  }

  void callAPI() async{
    var url = Uri.https(api, 'api/island-groups/');
    var response = await http.get(url);
    print(response.statusCode);
    print(response.body);
    if(response.statusCode == 200){
      List data = jsonDecode(response.body);
    }
  }

  Future <void> loadRegions() async{
    var url = Uri.https(api, 'api/regions/');
    var response = await http.get(url);
    if(response.statusCode == 200){
      List data = jsonDecode(response.body);
      data.forEach((element) {
        var map = element as Map;
        print(map['regionName']);
        regions.addAll({
          map['code'] : map['regionName']
        });
      });
    }
    setState(() {
      isRegionLoaded = true;
    });
  }

  Future <void> loadProvinces(String regionCode) async{
    provinces.clear();
    var url = Uri.https(api, 'api/regions/$regionCode/provinces');
    var response = await http.get(url);
    if(response.statusCode == 200){
      List data = jsonDecode(response.body);
      data.forEach((element) {
        var map = element as Map;
        print(map['regionName']);
        provinces.addAll({
          map['code'] : map['name']
        });
      });
    }
    setState(() {
      isProvincesLoaded = true;
    });
  }

  Future<void> loadCities(String provinceCode) async {
    cities.clear();
    var url = Uri.https(api, 'api/provinces/$provinceCode/cities-municipalities/');
    var response = await http.get(url);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      data.forEach((element) {
        var map = element as Map;
        cities.addAll({
          map['code']: map['name']
        });
      });
    }
    setState(() {
      isCitiesLoaded = true;
    });
  }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const screenPadding = 12.0;
    return Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: Padding(
          padding: EdgeInsets.all(screenPadding),
          child: Column(
            children: [
              if(isRegionLoaded)
                DropdownMenu(
                  width: width - screenPadding * 2,
                  dropdownMenuEntries: regions.entries.map((entry){
                    return DropdownMenuEntry(value: entry.key, label: entry.value);
                  }).toList(),
                  onSelected: (value) {
                    provinceController.clear();
                    loadProvinces(value ?? '');
                  },
                ),
              const SizedBox(height: 10,),
              if(isProvincesLoaded)
                DropdownMenu(
                  controller: provinceController,
                  width: width - screenPadding * 2,
                  dropdownMenuEntries: provinces.entries.map((entry){
                    return DropdownMenuEntry(value: entry.key, label: entry.value);
                  }).toList(),
                  onSelected: (value) {
                    citiesController.clear();
                    loadCities(value ?? '');
                  },
                ),
              const SizedBox(height: 10,),
              if(isCitiesLoaded)
                DropdownMenu(
                  controller: citiesController,
                  width: width - screenPadding * 2,
                  dropdownMenuEntries: cities.entries.map((entry){
                    return DropdownMenuEntry(value: entry.key, label: entry.value);
                  }).toList(),
                ),
            ],
          ),
        )
      );
  }
}
