import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:ueo_app/HomePage.dart';
import 'package:ueo_app/Loginscreen.dart';
import 'Memories.dart';
import 'Map.dart';
import 'Profile.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}
class _MainPageState extends State<MainPage> {
List pages=[
  HomePage(),
  Memories(),
  Map(),
  Profile(),
  Loginscreen(),
];
var currentindex=0;
  void ontap(int index){
    setState(() {
      currentindex=index;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
child: ListView(
  children: [
    DrawerHeader(decoration: BoxDecoration(color: Colors.deepPurple),
    child: CircleAvatar(),
    ),
    ListTile(
      leading: Icon(Icons.home),
      title: Text("Home"),
      onTap:(){
        Navigator.pushNamed(context,"/MainPage");
      },
    ),
// ListTile(
//   leading: Icon(Icons.search),
//   title: Text("Search"),
// ),
//     ListTile(
//       leading: Icon(Icons.favorite),
//       title: Text("Favorite"),
//     ),
    ListTile(
      leading: Icon(Icons.person),
      title: Text("Profile"),
      onTap: (){
        Navigator.pushNamed(context,"/Profile");
      },
    ),
    ListTile(
      leading: Icon(Icons.settings),
      title: Text("Settings"),
      onTap: (){
        Navigator.pushNamed(context,'/settings');
      },
    ),
    ListTile(
      leading: Icon(Icons.logout),
      title: Text("Logout"),
      onTap: (){
        Navigator.pushNamed(context,"/");
      },
    ),
  ],
  ),
),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
      ),
      body: pages[currentindex],
      bottomNavigationBar: Container(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 15.0),
          child: GNav(
            backgroundColor: Colors.white,
            color: Colors.black,
            activeColor: Colors.white,
            tabBackgroundColor: Colors.deepPurple,
            padding: EdgeInsets.all(16),
            gap: 8,
            tabs:
           const [
              GButton(icon: Icons.calendar_month,
                text: "Schedule",
              ),
              GButton(icon: Icons.image,
              text: "memories",
              ),
              GButton(icon: Icons.location_on,
              text: "location",
              ),
              GButton(icon: Icons.person,
              text: "Profile",
              ),
            ],
            selectedIndex: currentindex,
            onTabChange: (index){
              setState(() {
                currentindex = index;
              });
            },
          ),
        ),
      ),
    );
  }
}
