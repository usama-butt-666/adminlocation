import 'dart:async';

import 'package:adminlocation/user_data.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

import 'main.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    Key? key,
    // required this.title,
    // required this.email,
    required this.user,
  }) : super(key: key);

  // final String title, email;
  final User? user;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Location location = Location();
  // bool? _serviceEnabled;
  // PermissionStatus? _permissionGranted;
  // LocationData? _locationData;
  // double? lat, lng;

  // final databaseReference = FirebaseDatabase.instance.ref("users/123");
  DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
  List<UserData> userData = [];
  // create this variable

  _getPlace(lat, lng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(52.2165157, 6.9437819);

    print(placemarks[0]);
    // this is all you need
    Placemark placeMark = placemarks[0];

    String name = placeMark.name ?? '';
    String subLocality = placeMark.subLocality ?? '';
    String locality = placeMark.locality ?? '';
    String administrativeArea = placeMark.administrativeArea ?? '';
    String postalCode = placeMark.postalCode ?? '';
    String country = placeMark.country ?? '';
    String address =
        "${name}, ${subLocality}, ${locality}, ${administrativeArea} ${postalCode}, ${country}";

    // print(address);
    return address;
  }

  // Future<void> askLocation() async {
  //   _serviceEnabled = await location.serviceEnabled();
  //   if (!_serviceEnabled!) {
  //     _serviceEnabled = await location.requestService();
  //     if (!_serviceEnabled!) {
  //       return;
  //     }
  //   }

  //   _permissionGranted = await location.hasPermission();
  //   if (_permissionGranted == PermissionStatus.denied) {
  //     _permissionGranted = await location.requestPermission();
  //     if (_permissionGranted != PermissionStatus.granted) {
  //       return;
  //     }
  //   }

  //   _locationData = await location.getLocation();
  //   location.onLocationChanged.listen(
  //     (LocationData locationData) {
  //       setState(() {
  //         lat = _locationData!.latitude;
  //         lng = _locationData!.longitude;
  //       });
  //       print(lat);
  //       print(lng);
  //       createData(widget.user!.displayName, widget.user!.email,
  //           _locationData!.latitude, _locationData!.longitude);
  //     },
  //   );
  // }

  @override
  void initState() {
    readData();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    // askLocation();
    super.dispose();
  }

  String? name, email, type, lat, lng, address;
  void readData() {
    UserData user;
    databaseReference.once().then((DatabaseEvent snapshot) {
      for (var element in snapshot.snapshot.children) {
        element.children.forEach((val) async {
          name = val.children.elementAt(0).value.toString().split("|")[0];
          type = val.children.elementAt(0).value.toString().split("|")[1];
          email = val.children.elementAt(1).value.toString();
          lat = val.children.elementAt(2).value.toString();
          lng = val.children.elementAt(3).value.toString();
          address = await _getPlace(
              double.parse(lat.toString()), double.parse(lng.toString()));
          user = UserData(
              name: name!,
              email: email!,
              type: type!,
              lat: lat!,
              long: lng!,
              address: address!);
          setState(() {
            userData.add(user);
          });
        });
      }
    });
  }

  void createData(name, email, lat, long) async {
    await databaseReference
        .child("Users/${widget.user!.uid}")
        .set({"name": name, "email": email, "lat": lat, "long": long});
    print("written");
    // await ref.set({
    //   "name": "John",
    //   "lat": 18,
    //   "long": 18,
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user!.displayName!),
      ),
      body: ListView.builder(
          itemCount: userData.length,
          scrollDirection: Axis.vertical,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              leading: Text(userData[index].type),
              trailing: Text(userData[index].name),
              title: Text(userData[index].email),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Text(
                  //   "lat = ${userData[index].lat} ",
                  //   style: TextStyle(color: Colors.green, fontSize: 15),
                  // ),
                  // Text(
                  //   "lng = ${userData[index].long} ",
                  //   style: TextStyle(color: Colors.green, fontSize: 15),
                  // ),
                  Text(
                    "address = ${userData[index].address} ",
                    style: TextStyle(color: Colors.green, fontSize: 15),
                  ),
                ],
              ),
            );
          }),

      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Text("Name : "),
      //     Text(widget.user!.displayName!),
      //   ],
      // ),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Text("Email : "),
      //     Text(widget.user!.email!),
      //   ],
      // ),
      // Row(
      //   mainAxisAlignment: MainAxisAlignment.center,
      //   children: <Widget>[
      //     Text("Location : "),
      //     Text("${lat} ${lng}"),
      //   ],
      // ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Sign out Successfully"),
            backgroundColor: Colors.blueAccent,
          ));
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false);
        },
        tooltip: 'Sign out',
        child: const Icon(Icons.logout),
      ),
    );
  }
}
