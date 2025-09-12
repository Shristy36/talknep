import 'dart:math';
import 'package:flutter/material.dart';
import 'package:talknep/main.dart';
import 'package:talknep/service/api_service.dart';

class SearchAllFriendProvider with ChangeNotifier {
  bool isLoading = false;
  dynamic allFriendListData;
  List<dynamic> filteredFriendList = [];
  List<dynamic> randomTenList = [];

  SearchAllFriendProvider() {
    getAllFriendListData(true);
  }

  List<dynamic> get getRandomTenList => randomTenList;

  generateRandomTen() {
    if (filteredFriendList.length <= 10) {
      randomTenList = List.from(filteredFriendList);
    } else {
      final random = Random();
      final copyList = List<dynamic>.from(filteredFriendList);
      copyList.shuffle(random);
      randomTenList = copyList.take(10).toList();
    }
    notifyListeners();
  }

  getAllFriendListData(bool isLoad) async {
    try {
      if (isLoad) {
        isLoading = true;
      }
      final response = await ApiService.get('all_user');
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        final allFriends = response.data;
        allFriendListData = allFriends['data'];
        filteredFriendList = List.from(
          allFriendListData.where(
            (friend) => friend['friend_request_status'] != 'friends',
          ),
        );
        generateRandomTen();
      }
    } catch (e) {
      logger.e("Friend Data Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  addFriend(id) async {
    try {
      isLoading = true;
      final response = await ApiService.post('add_friend/$id', {});
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        // getAllFriendListData(false);
      }
    } catch (e) {
      logger.e("Add Friend Data Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  cancelFriend(id) async {
    try {
      isLoading = true;
      final response = await ApiService.post('cancel_friend_request', {
        'user_id': id,
      });
      print("cancelFriend:- $response");
      if (response != null &&
          (response.statusCode == 201 || response.statusCode == 200)) {
        // getAllFriendListData(false);
        print("Cancel Friend:- $allFriendListData");
      }
    } catch (e) {
      logger.e("Cancel Friend Data Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void filterFriendList(String query) {
    if (query.isEmpty) {
      filteredFriendList = List.from(allFriendListData);
    } else {
      filteredFriendList =
          allFriendListData.where((friend) {
            final name = friend['name']?.toString().toLowerCase() ?? '';
            final status =
                friend['friend_request_status']?.toString().toLowerCase() ?? '';
            return name.contains(query.toLowerCase()) && status != 'friends';
          }).toList();
    }
    generateRandomTen();
  }
}
