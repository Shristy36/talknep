import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/app_snackbar.dart';

class EventProvider with ChangeNotifier {
  bool isLoading = false;
  File? selectedGroupImage;

  final formKey = GlobalKey<FormState>();

  List myEvents = [];
  List allEvents = [];

  dynamic eventDataList;
  bool showMyEventsOnly = false;
  String _selectedPrivacy = 'Public';
  String get selectedPrivacy => _selectedPrivacy;

  List<String> get itemsSelectedPrivacy => ['Public', 'Private'];
  List get selectedEventList => showMyEventsOnly ? myEvents : allEvents;

  TextEditingController descController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  TextEditingController eventNameController = TextEditingController();
  TextEditingController eventDateController = TextEditingController();
  TextEditingController eventTimeController = TextEditingController();

  EventProvider() {
    getEventsList();
  }

  void setSelectedGroupImage(File image) {
    selectedGroupImage = image;
    notifyListeners();
  }

  void setSelectedPrivacy(String newValue) {
    _selectedPrivacy = newValue;
    notifyListeners();
  }

  getEventsList() async {
    isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('events');
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        eventDataList = response.data;
        allEvents =
            eventDataList
                .where((e) => e['my_event'] == 'not_my_event')
                .toList();
        myEvents =
            eventDataList.where((e) => e['my_event'] == 'my_event').toList();
      }
    } catch (e) {
      logger.e("Login Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void postInterestedAPI(id) async {
    try {
      isLoading = true;
      final response = await ApiService.post('event_interested/$id', {});

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        getEventsList();
      }
    } catch (e) {
      logger.e("Interested Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void postGoingAPI(id) async {
    try {
      isLoading = true;
      final response = await ApiService.post('event_going/$id', {});

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        getEventsList();
      }
    } catch (e) {
      logger.e("Interested Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void postNotGoingAPI(id) async {
    try {
      isLoading = true;
      final response = await ApiService.post('event_notgoing/$id', {});

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        getEventsList();
      }
    } catch (e) {
      logger.e("Interested Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void postNotInterAPI(id) async {
    try {
      isLoading = true;
      final response = await ApiService.post('event_notinterested/$id', {});

      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        getEventsList();
      }
    } catch (e) {
      logger.e("Interested Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void createEvent(context) async {
    if (formKey.currentState!.validate()) {
      if (selectedGroupImage == null) {
        showCustomSnackbar(
          context,
          "Please select an event image",
          type: SnackbarType.error,
        );
        return;
      }
      try {
        isLoading = true;
        notifyListeners();

        final file = await dio.MultipartFile.fromFile(
          selectedGroupImage!.path,
          filename: selectedGroupImage!.path.split('/').last,
        );

        final response = await ApiService.postMultipart(
          '/create_event',
          {
            'eventname': eventNameController.text,
            'description': descController.text.trim(),
            'eventdate': eventDateController.text.trim(),
            'eventtime': eventTimeController.text.trim(),
            'eventlocation': locationController.text,
            'privacy': _selectedPrivacy,
          },
          {'coverphoto': file},
        );

        if (response != null &&
            (response.statusCode == 201 || response.statusCode == 200)) {
          showCustomSnackbar(
            context,
            response.data['message'],
            type: SnackbarType.success,
          );
          eventNameController.clear();
          descController.clear();
          locationController.clear();
          selectedGroupImage = null;
          eventDateController.clear();
          eventTimeController.clear();
          getEventsList();
          Get.back();
        } else {
          showCustomSnackbar(
            context,
            response!.data['message'],
            type: SnackbarType.error,
          );
        }
      } catch (e) {
        logger.e("Create Event Error: $e");
        showCustomSnackbar(
          context,
          "Something went wrong: $e",
          type: SnackbarType.error,
        );
      } finally {
        isLoading = false;
        notifyListeners();
      }
    }
  }
}
