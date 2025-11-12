import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import '../models/service_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../services/booking_service.dart';
import '../services/database_service.dart';
import '../utils/shared_prefs.dart';

class ServiceDetailScreen extends StatefulWidget {
  final ServiceModel service;

  const ServiceDetailScreen({Key? key, required this.service}) : super(key: key);

  @override
  _ServiceDetailScreenState createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  final BookingService _bookingService = BookingService();
  String? _selectedImagePath;
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  final _databaseService = DatabaseService();
  UserModel? _user;
  bool _isLoading = true;
  bool _isBooking = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    try {
      final userId = SharedPrefs.getUserId();
      if (userId.isNotEmpty) {
        final user = await _databaseService.getUser(userId);
        setState(() {
          _user = user;
          _nameController.text = _user?.name ?? '';
          _phoneController.text = _user?.phone ?? '';
          _addressController.text = _user?.city ?? '';
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _selectedImagePath = pickedFile.path);
      }
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showBookingDialog() {
    // Check if user is logged in
    final userId = SharedPrefs.getUserId();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to book a service')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Book ${widget.service.name}'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Your Phone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: 'Your Address',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 12),
                    TextFormField(
                      controller: _issueController,
                      decoration: InputDecoration(
                        labelText: 'Describe your issue',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 16),
                    if (_selectedImagePath != null)
                      Column(
                        children: [
                          Image.file(
                            File(_selectedImagePath!),
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Selected Image',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    ElevatedButton(
                      onPressed: _showImagePickerDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Upload Issue Photo'),
                    ),
                    SizedBox(height: 8),
                    if (_isBooking)
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isBooking ? null : () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isBooking ? null : _confirmBooking,
                  child: Text('Confirm Booking'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmBooking() async {
    // Get current user ID
    final userId = SharedPrefs.getUserId();
    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please login to book a service')),
      );
      return;
    }

    // Validate required fields
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _issueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    // Generate service ID if not provided
    String serviceId = widget.service.id ??
        'service_${DateTime.now().millisecondsSinceEpoch}';

    setState(() {
      _isBooking = true;
    });

    try {
      final booking = BookingModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        serviceId: serviceId,
        serviceName: widget.service.name,
        serviceCategory: widget.service.category,
        serviceImage: widget.service.imageUrl,
        customerName: _nameController.text.trim(),
        customerPhone: _phoneController.text.trim(),
        customerAddress: _addressController.text.trim(),
        bookingDate: DateTime.now().toString(),
        bookingTime: '10:00 AM',
        status: 'pending',
        issueDescription: _issueController.text.trim(),
        uploadedImage: _selectedImagePath,
        totalAmount: _calculateAmount(widget.service.category),
        createdAt: DateTime.now(),
      );

      print('Creating booking for user: $userId');
      print('Service ID: $serviceId');
      print('Service Name: ${widget.service.name}');
      print('Booking details: ${booking.toJson()}');

      await _bookingService.createBooking(booking);

      Navigator.pop(context); // Close dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking confirmed successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form after successful booking
      _issueController.clear();
      setState(() {
        _selectedImagePath = null;
        _isBooking = false;
      });
    } catch (e) {
      setState(() {
        _isBooking = false;
      });

      print('Booking error details: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  double _calculateAmount(String category) {
    switch (category.toLowerCase()) {
      case 'plumbing':
        return 500.0;
      case 'salon':
        return 300.0;
      case 'tuition':
        return 200.0;
      case 'electrician':
        return 400.0;
      default:
        return 350.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.service.name),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(widget.service.imageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),

            // Service Name and Rating
            Text(
              widget.service.name,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 20),
                SizedBox(width: 4),
                Text(widget.service.rating?.toString() ?? '0.0'),
                SizedBox(width: 16),
                Chip(
                  label: Text(widget.service.category),
                  backgroundColor: Colors.blue.withOpacity(0.2),
                ),
              ],
            ),
            SizedBox(height: 16),

            // Description
            Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(widget.service.description),
            SizedBox(height: 16),

            // Contact Information
            Text(
              'Contact Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.blue),
                title: Text(widget.service.phone),
                onTap: () => _makePhoneCall(widget.service.phone),
              ),
            ),
            Card(
              child: ListTile(
                leading: Icon(Icons.location_on, color: Colors.green),
                title: Text(widget.service.address),
              ),
            ),
            SizedBox(height: 16),

            // Selected Image Preview
            if (_selectedImagePath != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Image:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: FileImage(File(_selectedImagePath!)),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                ],
              ),

            // Upload Photo Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showImagePickerDialog,
                icon: Icon(Icons.camera_alt),
                label: Text('Upload Photo'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            SizedBox(height: 16),

            // Call and SMS Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _makePhoneCall(widget.service.phone),
                    icon: Icon(Icons.call),
                    label: Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _sendSMS(widget.service.phone),
                    icon: Icon(Icons.message),
                    label: Text('SMS'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Book Now Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showBookingDialog,
                icon: Icon(Icons.book_online),
                label: Text('Book Now'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'tel',
        path: phoneNumber,
      );
      await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot make call: $e')),
      );
    }
  }

  Future<void> _sendSMS(String phoneNumber) async {
    try {
      final Uri launchUri = Uri(
        scheme: 'sms',
        path: phoneNumber,
      );
      await launchUrl(launchUri);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot send SMS: $e')),
      );
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
}