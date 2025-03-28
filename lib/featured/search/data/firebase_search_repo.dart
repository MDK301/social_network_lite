import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_network_lite/featured/profile/domain/entities/profile_user.dart';
import 'package:social_network_lite/featured/search/domain/search_repo.dart';

class FirebaseSearchRepo implements SearchRepo {
  @override
  Future<List<ProfileUser?>> searchUsers(String query) async {
    try {

      final lowercaseQuery = query.toLowerCase(); // hoa thường bình đẳng =)))

      final result = await FirebaseFirestore.instance
          .collection("users")
          .get(); // lụm tất cả users

      // lọc user
      final filteredUsers = result.docs.where((doc) {
        final lowercaseName = doc.data()['name'].toString().toLowerCase(); // chuyen thanh thường từ data
        final lowercaseEmail = doc.data()['email'].toString().toLowerCase(); // chuyen thanh thường từ data

        return lowercaseName.startsWith(lowercaseQuery)||lowercaseEmail.startsWith(lowercaseQuery) ; //be nao trung ten len buc nhan thuong
      }).toList();

      return filteredUsers
          .map((doc) => ProfileUser.fromJson(doc.data()))
          .toList();




      // final result = await FirebaseFirestore.instance
      //     .collection("users")
      //     .where('name', isGreaterThanOrEqualTo: query)
      //     .where('name', isLessThanOrEqualTo: '$query\uf8ff')
      //     .get();
      //
      // return result.docs
      //     .map((doc) => ProfileUser.fromJson(doc.data()))
      //     .toList();
    } catch (e) {
      throw Exception('Error searching users: $e');
    }
  }
}