import 'package:flutter/material.dart';

class ProfileStats extends StatelessWidget {
  final int postCount;
  final int followerCount;
  final int followingCount;

  const ProfileStats({
    super.key,
    required this.postCount,
    required this.followerCount,
    required this.followingCount,
  });

  // BUILD UI
  @override
  Widget build(BuildContext context) {

    // text style for count
    var textStyleForCount = TextStyle(
        fontSize: 20, color: Theme.of(context).colorScheme.inversePrimary
    );

    // text style for text
    var textStyleForText = TextStyle(
        color: Theme.of(context).colorScheme.primary
    );


    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // posts
          Column(
            children: [
              Text(postCount.toString(),style: textStyleForCount,),
              Text("Posts",style: textStyleForText,),
            ],
          ),
          SizedBox(width: 15,),
          // followers
          Column(
            children: [
              Text(followerCount.toString(),style: textStyleForCount,),
              Text("Followers",style: textStyleForText,),
            ],
          ),
          SizedBox(width: 10,),
          // following
          Column(
            children: [
              Text(followingCount.toString(),style: textStyleForCount,),
              Text("Following",style: textStyleForText,),
            ],
          ),
    ]);
  }
}
