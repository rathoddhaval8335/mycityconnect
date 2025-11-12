import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@mycityconnect.com',
      queryParameters: {
        'subject': 'MyCityConnect App Support',
        'body': 'Hello MyCityConnect Team,',
      },
    );
    await _launchURL(emailLaunchUri.toString());
  }

  Future<void> _makePhoneCall() async {
    final Uri phoneLaunchUri = Uri(
      scheme: 'tel',
      path: '+18005551234',
    );
    await _launchURL(phoneLaunchUri.toString());
  }

  Future<void> _openWebsite() async {
    await _launchURL('https://www.mycityconnect.com');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contact Us'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get in Touch',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We\'re here to help you with any questions or concerns.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30),

            // Contact Options
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.phone, color: Colors.blue),
                      title: Text('Call Us'),
                      subtitle: Text('+1 (800) 555-1234'),
                      onTap: _makePhoneCall,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.email, color: Colors.blue),
                      title: Text('Email Us'),
                      subtitle: Text('support@mycityconnect.com'),
                      onTap: _sendEmail,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.language, color: Colors.blue),
                      title: Text('Visit Website'),
                      subtitle: Text('www.mycityconnect.com'),
                      onTap: _openWebsite,
                    ),
                    Divider(),
                    ListTile(
                      leading: Icon(Icons.location_on, color: Colors.blue),
                      title: Text('Office Address'),
                      subtitle: Text('123 Business Street, City, State 12345'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Support Hours
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Support Hours',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text('Monday - Friday: 9:00 AM - 6:00 PM'),
                    Text('Saturday: 10:00 AM - 4:00 PM'),
                    Text('Sunday: Closed'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}