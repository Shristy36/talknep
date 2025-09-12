import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class LocationProvider with ChangeNotifier {
  final String _apiKey = 'AIzaSyDne_xczXvTGwHJpg9aUDQ9G4WLpIbu0Wg';

  String _locationName = 'New Delhi';

  LatLng _position = LatLng(28.6139, 77.2090);

  List<dynamic> _suggestions = [];

  LatLng get position => _position;

  String get locationName => _locationName;

  List<dynamic> get suggestions => _suggestions;

  GoogleMapController? mapController;
  final TextEditingController searchController = TextEditingController();

  void setPosition(LatLng newPosition) {
    _position = newPosition;
    updateAddressFromLatLng();
    notifyListeners();
  }

  Future<void> searchLocation(
    String query,
    GoogleMapController? mapController,
  ) async {
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final latLng = LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
        _position = latLng;
        mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
        await updateAddressFromLatLng();
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Search error: $e");
    }
  }

  Future<void> fetchSuggestions(String input) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&key=$_apiKey&types=geocode&language=en';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      _suggestions = data['predictions'];
      notifyListeners();
    } catch (e) {
      debugPrint("Autocomplete error: $e");
    }
  }

  Future<void> selectSuggestion(
    String placeId,
    GoogleMapController? mapController,
  ) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      final lat = data['result']['geometry']['location']['lat'];
      final lng = data['result']['geometry']['location']['lng'];
      final latLng = LatLng(lat, lng);

      _position = latLng;
      mapController?.animateCamera(CameraUpdate.newLatLng(latLng));
      await updateAddressFromLatLng();
      _suggestions.clear();
      notifyListeners();
    } catch (e) {
      debugPrint("Place details error: $e");
    }
  }

  Future<void> updateAddressFromLatLng() async {
    try {
      List<Placemark> placemark = await placemarkFromCoordinates(
        _position.latitude,
        _position.longitude,
      );
      if (placemark.isNotEmpty) {
        final place = placemark.first;
        _locationName = '${place.name}, ${place.locality} ${place.country}';
      }
    } catch (e) {
      debugPrint("Reverse geocoding error: $e");
    }
  }
}
