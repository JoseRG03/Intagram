import 'package:flutter/material.dart';
import 'package:intec_social_app/const.dart';
import 'package:intec_social_app/controllers/user-controller.dart';

import '../../../../models/users.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  BaseUser? currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getInitialData();
  }

  void getInitialData() async {
    UserController userController = UserController();

    final userData = await userController.getUserData();

    BaseUser? user = userData != null ? BaseUser.fromJson(userData) : null;

    setState(() {
      currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        decoration: BoxDecoration(color: Colors.grey),
        height: 300,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Image.network(
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                  currentUser?.image ?? baseImage),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${currentUser?.name ?? ''} ${currentUser?.lastname ?? ''}",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('${currentUser?.phone ?? ''}'),
                      SizedBox(
                        height: 5,
                      ),
                      Text('${currentUser?.email ?? ''}'),
                      SizedBox(
                        height: 5,
                      ),
                      Text('${currentUser?.biography ?? ''}'),
                      SizedBox(
                        height: 5,
                      ),
                      MaterialButton(
                        onPressed: () async {
                          await Navigator.of(context).pushNamed('/edit-profile');

                          getInitialData();
                        },
                        child: Text('Edit profile'),
                        color: Colors.white,
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    ]);
  }
}
