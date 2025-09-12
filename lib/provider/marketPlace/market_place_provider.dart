import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:talknep/UI/bottomBar/bottom_screen.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';
import 'package:talknep/widget/app_snackbar.dart';

class MarketPlaceProvider with ChangeNotifier {
  bool isLoading = false;
  File? selectedPageImage;
  dynamic currencyDataList;
  bool hasLoadedOnce = false;
  dynamic marketPlaceDataList;

  GlobalKey<FormState>? _marketPlaceForm;
  GlobalKey<FormState> get marketPlaceForm {
    _marketPlaceForm ??= GlobalKey<FormState>();
    return _marketPlaceForm!;
  }

  String _selectedCategory = 'All';
  String _selectedCondition = 'New';
  String _selectedStatus = 'In Stock';

  String get selectedStatus => _selectedStatus;
  String get selectedCategory => _selectedCategory;
  String get selectedCondition => _selectedCondition;

  Map<String, dynamic>? _selectedCategoryItem;
  Map<String, dynamic>? get selectedCategoryItem => _selectedCategoryItem;

  List<dynamic> _itemsSelectedCurrency = [];
  List<String> get itemsSelectedCondition => ['New', 'Old'];
  List<dynamic> get itemsSelectedCurrency => _itemsSelectedCurrency;
  List<String> get itemsSelectedStatus => ['In Stock', 'Out of Stock'];

  final TextEditingController minController = TextEditingController();
  final TextEditingController maxController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController brandController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  final TextEditingController buyLinkController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  MarketPlaceProvider() {
    currencyListData();
    getMarketPlace();
  }

  void resetFormKey() {
    _marketPlaceForm = null;
  }

  void setSelectedCategoryType(String newValue) {
    _selectedCategory = newValue;
    notifyListeners();
  }

  void setSelectedStatus(String newValue) {
    _selectedStatus = newValue;
    notifyListeners();
  }

  void setSelectedCondition(String newValue) {
    _selectedCondition = newValue;
    notifyListeners();
  }

  void setSelectedCurrency(Map<String, dynamic> newValue) {
    _selectedCategoryItem = newValue;
    notifyListeners();
  }

  void setSelectedPageImage(File image) {
    selectedPageImage = image;
    notifyListeners();
  }

  void createMarketPlace(context) async {
    if (marketPlaceForm.currentState!.validate()) {
      try {
        isLoading = true;
        notifyListeners();

        if (selectedPageImage != null) {
          final file = await dio.MultipartFile.fromFile(
            selectedPageImage!.path,
            filename: selectedPageImage!.path.split('/').last,
          );

          final response = await ApiService.postMultipart(
            'create_marketplace',
            {
              'title': titleController.text,
              'price': priceController.text,
              'currency': _selectedCategoryItem?['category_id'],
              'location': locationController.text,
              'condition': _selectedCondition,
              'brand': brandController.text.trim(),
              'status': _selectedStatus,
              'description': descriptionController.text.trim(),
            },
            {'multiple_files': file},
          );

          if (response != null &&
              (response.statusCode == 201 || response.statusCode == 200)) {
            showCustomSnackbar(
              context,
              response.data['message'],
              type: SnackbarType.success,
            );

            // Clear form and reset
            titleController.clear();
            priceController.clear();
            locationController.clear();
            quantityController.clear();
            brandController.clear();
            buyLinkController.clear();
            descriptionController.clear();
            selectedPageImage = null;
            resetFormKey(); // Reset form key after successful submission

            getMarketPlace();
            Get.to(
              () => BottomBarScreen(),
              transition: Transition.fadeIn,
              duration: const Duration(milliseconds: 500),
            );
          } else {
            showCustomSnackbar(
              context,
              response!.data['message'],
              type: SnackbarType.error,
            );
          }
        } else {
          showCustomSnackbar(
            context,
            "No image selected for upload",
            type: SnackbarType.error,
          );
        }
      } catch (e) {
        logger.e("Create Market Place Error: $e");
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

  void currencyListData() async {
    notifyListeners();
    try {
      final response = await ApiService.get('currencies');
      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        currencyDataList = response.data;
        _itemsSelectedCurrency.clear();
        for (var item in currencyDataList) {
          if (item['category'] != null) {
            _itemsSelectedCurrency.add(item);
          }
        }
        _itemsSelectedCurrency = _itemsSelectedCurrency.toSet().toList();
        if (_itemsSelectedCurrency.isNotEmpty) {
          if (_itemsSelectedCurrency.isNotEmpty) {
            _selectedCategoryItem = _itemsSelectedCurrency[0];
          }
        }
        notifyListeners();
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';
        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("Currency API Error: $e");
      showCustomSnackbar(
        Get.context!,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    } finally {
      notifyListeners();
    }
  }

  getMarketPlace() async {
    if (!hasLoadedOnce) {
      isLoading = true;
      notifyListeners();
    }

    try {
      final response = await ApiService.get('marketplace');

      if (response != null &&
          (response.statusCode == 200 || response.statusCode == 201)) {
        marketPlaceDataList = response.data['data'];
      } else {
        final message =
            response?.data is Map && response?.data['message'] != null
                ? response?.data['message']
                : 'Unexpected error occurred.';
        showCustomSnackbar(Get.context!, message, type: SnackbarType.error);
      }
    } catch (e) {
      logger.e("Market Place API Error: $e");
      showCustomSnackbar(
        Get.context!,
        "Something went wrong: $e",
        type: SnackbarType.error,
      );
    } finally {
      isLoading = false;
      hasLoadedOnce = true;
      notifyListeners();
    }
  }

  List<dynamic> get filteredMarketPlaceList {
    if (marketPlaceDataList == null) return [];

    double? minPrice = double.tryParse(minController.text);
    double? maxPrice = double.tryParse(maxController.text);
    String searchText = searchController.text.toLowerCase();

    return marketPlaceDataList.where((item) {
      final price = double.tryParse(item['price'].toString()) ?? 0;

      final matchesCategory =
          selectedCategory == 'All' || item['category'] == selectedCategory;
      final matchesMin = minPrice == null || price >= minPrice;
      final matchesMax = maxPrice == null || price <= maxPrice;
      final matchesCondition =
          selectedCondition == 'New' || selectedCondition == 'Old'
              ? item['condition'] == selectedCondition
              : true;

      final matchesSearch =
          item['title'] != null &&
          item['title'].toString().toLowerCase().contains(searchText);

      return matchesCategory &&
          matchesMin &&
          matchesMax &&
          matchesCondition &&
          matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    // Dispose controllers
    minController.dispose();
    maxController.dispose();
    titleController.dispose();
    brandController.dispose();
    priceController.dispose();
    searchController.dispose();
    buyLinkController.dispose();
    locationController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}
