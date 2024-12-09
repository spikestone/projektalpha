import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'global.dart' as global;
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              // Action for Profile button
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'Navigation',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                // Action for Profile button
              },
            ),
            ListTile(
              leading: Icon(Icons.chat),
              title: Text('Chats'),
              onTap: () {
                // Action for Chats button
              },
            ),
            ListTile(
              leading: Icon(Icons.search),
              title: Text('Search Users'),
              onTap: () {
                // Action for Search Users button
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Action for Settings button
              },
            ),
            ListTile(
              leading: Icon(Icons.calendar_today),
              title: Text('Calendar'),
              onTap: () {
                // Action for Calendar button
              },
            ),
            ListTile(
              leading: Icon(Icons.forum),
              title: Text('Forum'),
              onTap: () {
                // Action for Forum button
              },
            ),
            ListTile(
              leading: Icon(Icons.calculate),
              title: Text('Calculator'),
              onTap: () {
                // Action for Calculator button
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                // Action for Logout button
              },
            ),
          ],
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(16.0),
        color: Colors.grey[900],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: Colors.deepPurple,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Welcome Home!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                children: [
                  _buildAnimatedCard('Profile', Icons.person, Colors.deepPurpleAccent, () {
                    // Action for Profile button
                    Navigator.pushNamed(context, '/upload');
                  }),
                  _buildAnimatedCard('Chats', Icons.chat, Colors.deepPurpleAccent, () {
                    // Action for Chats button
                    Navigator.pushNamed(context, '/blank');
                  }),
                  _buildAnimatedCard('Search Users', Icons.search, Colors.deepPurpleAccent, () {
                    // Action for Search Users button
                    Navigator.pushNamed(context, '/blank');
                  }),
                  _buildAnimatedCard('Settings', Icons.settings, Colors.deepPurpleAccent, () {
                    // Action for Settings button
                    Navigator.pushNamed(context, '/blank');
                  }),
                  _buildAnimatedCard('Calendar', Icons.calendar_today, Colors.deepPurpleAccent, () {
                    // Action for Calendar button
                    Navigator.pushNamed(context, '/blank');
                  }),
                  _buildAnimatedCard('Forum', Icons.forum, Colors.deepPurpleAccent, () async {
                   
                    // Action for Forum button
                   final authData = await global.pb.collection('users').authRefresh();
                   print(authData);
                    Navigator.pushNamed(context, '/forum');
                  }),
                  _buildAnimatedCard('Calculator', Icons.calculate, Colors.deepPurpleAccent, () {
                    // Action for Calculator button
                    Navigator.pushNamed(context, '/blank');
                  }),
                  _buildAnimatedCard('Logout', Icons.logout, Colors.deepPurpleAccent, () {
                    // Action for Logout button
                    Navigator.pushNamed(context, '/blank');
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedCard(String title, IconData icon, Color color, Function onTap) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        bool _isTapped = false;

        return GestureDetector(
          onTapDown: (_) => setState(() {
            _isTapped = true;
          }),
          onTapUp: (_) => setState(() {
            _isTapped = false;
            onTap();
          }),
          onTapCancel: () => setState(() {
            _isTapped = false;
          }),
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            padding: _isTapped ? EdgeInsets.all(12.0) : EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isTapped
                  ? []
                  : [BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 1)],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 48, color: color),
                  SizedBox(height: 10),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
