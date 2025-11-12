import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../utils/shared_prefs.dart';
import 'login_screen.dart';
import 'service_list_screen.dart';
import 'profile_screen.dart';
import 'bookings_screen.dart';
import 'contact_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  final _databaseService = DatabaseService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userId = SharedPrefs.getUserId();
    if (userId.isNotEmpty) {
      final user = await _databaseService.getUser(userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  void _logout(BuildContext context) async {
    await _authService.signOut();
    await SharedPrefs.setLoggedIn(false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyCityConnect'),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Handle loading and null user states
            if (_isLoading)
              UserAccountsDrawerHeader(
                accountName: Text('Loading...'),
                accountEmail: Text(''),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_user == null)
              UserAccountsDrawerHeader(
                accountName: Text('Guest'),
                accountEmail: Text('Not logged in'),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person),
                ),
              )
            else
              UserAccountsDrawerHeader(
                accountName: Text(_user!.name),
                accountEmail: Text(_user!.email),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                      _user!.name.isNotEmpty
                          ? _user!.name[0].toUpperCase()
                          : 'U',
                      style: TextStyle(fontSize: 20)
                  ),
                ),
              ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.book_online),
              title: Text('My Bookings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingsScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfileScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.contact_phone),
              title: Text('Contact Us'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ContactScreen()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                _logout(context);
              },
            ),
          ],
        ),
      ),
      body: ServiceListScreen(),
    );
  }
}