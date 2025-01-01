import 'package:social_network_lite/featured/auth/domain/entities/app_user.dart';

class ProfileUser extends AppUser {
  final String bio;
  final String profileImageUrl;
  final String? emailPrivacy;
  final List<String> followers;
  final List<String> following;
  final List<String>? friendlist;
  final List<String>? friendRequest;
  final List<String>? blockList;

  ProfileUser({
    required super.uid,
    required super.email,
    required super.name,
    required this.bio,
     this.emailPrivacy,
    required this.profileImageUrl,
    required this.followers,
    required this.following,
     this.friendlist,
     this.friendRequest,
     this.blockList,
  });

  //method to update profile user
  ProfileUser copyWith({String? newBio,
    String? newprofileImageUrl,
    String? newemailPrivacy,
    List<String>? newFollowers,
    List<String>? newFollowing,
    List<String>? newfriendlist,
    List<String>? newfriendRequest,
    List<String>? newblockList,
  }) {
    return ProfileUser(
        uid: uid,
        email: email,
        name: name,
        bio: newBio ?? bio,
        emailPrivacy: newemailPrivacy ?? emailPrivacy,
        profileImageUrl: newprofileImageUrl ?? profileImageUrl,
        followers: newFollowers ?? followers,
        following: newFollowing ?? following,
        friendlist: newfriendlist ?? friendlist,
        friendRequest: newfriendRequest ?? friendRequest,
        blockList: newblockList ?? blockList,
    );
  }

  //chuyển profile sang json
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'bio': bio,
      'emailPrivacy': emailPrivacy,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following,
      'friendlist': friendlist,
      'friendRequest': friendRequest,
      'blockList': blockList,
    };
  }

  //convert json sang profile
  factory ProfileUser.fromJson(Map<String, dynamic> json) {
    return ProfileUser(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      bio: json['bio'] ?? '',
      emailPrivacy: json['emailPrivacy'] ?? '',
      profileImageUrl: json['profileImageUrl'] ?? '',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      friendlist: List<String>.from(json['friendlist'] ?? []),
      friendRequest: List<String>.from(json['friendRequest'] ?? []),
      blockList: List<String>.from(json['blockList'] ?? []),
    );
  }
}
