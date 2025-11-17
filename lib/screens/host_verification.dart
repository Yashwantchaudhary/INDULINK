import 'package:flutter/material.dart';

class HostVerification extends StatefulWidget {
  final VoidCallback onBack;
  final VoidCallback onVerified;

  const HostVerification({super.key, required this.onBack, required this.onVerified});

  @override
  State<HostVerification> createState() => _HostVerificationState();
}

class _HostVerificationState extends State<HostVerification> {
  int currentStep = 0;
  final Map<String, dynamic> verificationData = {
    'personalInfo': {
      'fullName': '',
      'phone': '',
      'address': '',
      'completed': false
    },
    'idVerification': {
      'idType': '',
      'idNumber': '',
      'idImage': null,
      'completed': false
    },
    'propertyVerification': {
      'propertyType': '',
      'propertyAddress': '',
      'propertyImages': <String>[],
      'propertyDescription': '',
      'completed': false
    },
    'bankDetails': {
      'accountNumber': '',
      'ifscCode': '',
      'accountHolderName': '',
      'completed': false
    }
  };

  List<Map<String, dynamic>> get verificationSteps => [
    {
      'id': 'personal',
      'title': 'Personal Information',
      'icon': Icons.person,
      'description': 'Verify your identity with basic information',
      'status': verificationData['personalInfo']['completed'] ? 'completed' : 'pending'
    },
    {
      'id': 'id',
      'title': 'ID Verification',
      'icon': Icons.credit_card,
      'description': 'Upload government-issued ID for verification',
      'status': verificationData['idVerification']['completed'] ? 'completed' : 'pending'
    },
    {
      'id': 'property',
      'title': 'Property Details',
      'icon': Icons.home,
      'description': 'Provide information about your property',
      'status': verificationData['propertyVerification']['completed'] ? 'completed' : 'pending'
    },
    {
      'id': 'bank',
      'title': 'Bank Details',
      'icon': Icons.description,
      'description': 'Add banking information for payments',
      'status': verificationData['bankDetails']['completed'] ? 'completed' : 'pending'
    }
  ];

  int get completedSteps => verificationSteps.where((step) => step['status'] == 'completed').length;
  double get progressPercentage => (completedSteps / verificationSteps.length) * 100;

  void handlePersonalInfoSubmit() {
    setState(() {
      verificationData['personalInfo']['completed'] = true;
      currentStep = 1;
    });
  }

  void handleIdVerificationSubmit() {
    setState(() {
      verificationData['idVerification']['completed'] = true;
      currentStep = 2;
    });
  }

  void handlePropertySubmit() {
    setState(() {
      verificationData['propertyVerification']['completed'] = true;
      currentStep = 3;
    });
  }

  void handleBankSubmit() {
    setState(() {
      verificationData['bankDetails']['completed'] = true;
    });

    if (completedSteps == 4) {
      widget.onVerified();
    }
  }

  void handleFileUpload(String fileName, String type) {
    setState(() {
      if (type == 'id') {
        verificationData['idVerification']['idImage'] = fileName;
      } else {
        if (verificationData['propertyVerification']['propertyImages'].length < 5) {
          verificationData['propertyVerification']['propertyImages'].add(fileName);
        }
      }
    });
  }

  Widget renderStepContent() {
    switch (currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Personal Information',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please provide your personal details for verification',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              onChanged: (value) => verificationData['personalInfo']['fullName'] = value,
              decoration: const InputDecoration(
                labelText: 'Full Name *',
                hintText: 'Enter your full name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => verificationData['personalInfo']['phone'] = value,
              decoration: const InputDecoration(
                labelText: 'Phone Number *',
                hintText: 'Enter your phone number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => verificationData['personalInfo']['address'] = value,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Address *',
                hintText: 'Enter your complete address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (verificationData['personalInfo']['fullName'].isNotEmpty &&
                           verificationData['personalInfo']['phone'].isNotEmpty &&
                           verificationData['personalInfo']['address'].isNotEmpty)
                    ? handlePersonalInfoSubmit
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Continue'),
              ),
            ),
          ],
        );

      case 1:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ID Verification',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Upload a government-issued ID for verification',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: verificationData['idVerification']['idType'].isEmpty
                  ? null
                  : verificationData['idVerification']['idType'],
              onChanged: (value) => setState(() => verificationData['idVerification']['idType'] = value ?? ''),
              decoration: const InputDecoration(
                labelText: 'ID Type *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'aadhaar', child: Text('Aadhaar Card')),
                DropdownMenuItem(value: 'pan', child: Text('PAN Card')),
                DropdownMenuItem(value: 'passport', child: Text('Passport')),
                DropdownMenuItem(value: 'driving_license', child: Text('Driving License')),
                DropdownMenuItem(value: 'voter_id', child: Text('Voter ID')),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => verificationData['idVerification']['idNumber'] = value,
              decoration: const InputDecoration(
                labelText: 'ID Number *',
                hintText: 'Enter ID number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Upload ID Image *'),
            const SizedBox(height: 8),
            if (verificationData['idVerification']['idImage'] != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(verificationData['idVerification']['idImage']),
                    ),
                    const Icon(Icons.check_circle, color: Colors.green),
                  ],
                ),
              )
            else
              GestureDetector(
                onTap: () => handleFileUpload('id_image.jpg', 'id'),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.camera_alt, size: 32, color: Colors.grey),
                      SizedBox(height: 8),
                      Text('Click to upload ID image'),
                      Text('PNG, JPG up to 5MB', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => currentStep = 0),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (verificationData['idVerification']['idType'].isNotEmpty &&
                               verificationData['idVerification']['idNumber'].isNotEmpty &&
                               verificationData['idVerification']['idImage'] != null)
                        ? handleIdVerificationSubmit
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        );

      case 2:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Property Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Provide information about your property',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: verificationData['propertyVerification']['propertyType'].isEmpty
                  ? null
                  : verificationData['propertyVerification']['propertyType'],
              onChanged: (value) => setState(() => verificationData['propertyVerification']['propertyType'] = value ?? ''),
              decoration: const InputDecoration(
                labelText: 'Property Type *',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'hostel', child: Text('Hostel')),
                DropdownMenuItem(value: 'pg', child: Text('PG Accommodation')),
                DropdownMenuItem(value: 'apartment', child: Text('Apartment')),
                DropdownMenuItem(value: 'house', child: Text('House')),
                DropdownMenuItem(value: 'room', child: Text('Single Room')),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => verificationData['propertyVerification']['propertyAddress'] = value,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Property Address *',
                hintText: 'Enter complete property address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => verificationData['propertyVerification']['propertyDescription'] = value,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Property Description *',
                hintText: 'Describe your property, amenities, and facilities',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Property Images (max 5) *'),
            const SizedBox(height: 8),
            if (verificationData['propertyVerification']['propertyImages'].isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: verificationData['propertyVerification']['propertyImages']
                    .map<Widget>((image) => Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(image),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            if (verificationData['propertyVerification']['propertyImages'].length < 5)
              GestureDetector(
                onTap: () => handleFileUpload('property_image.jpg', 'property'),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.camera_alt, size: 32, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text('Upload property images'),
                      Text(
                        '${verificationData['propertyVerification']['propertyImages'].length}/5 images uploaded',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => currentStep = 1),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (verificationData['propertyVerification']['propertyType'].isNotEmpty &&
                               verificationData['propertyVerification']['propertyAddress'].isNotEmpty &&
                               verificationData['propertyVerification']['propertyDescription'].isNotEmpty &&
                               verificationData['propertyVerification']['propertyImages'].isNotEmpty)
                        ? handlePropertySubmit
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ],
        );

      case 3:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bank Details',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add your banking information to receive payments',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            TextField(
              onChanged: (value) => verificationData['bankDetails']['accountHolderName'] = value,
              decoration: const InputDecoration(
                labelText: 'Account Holder Name *',
                hintText: 'Enter account holder name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => verificationData['bankDetails']['accountNumber'] = value,
              decoration: const InputDecoration(
                labelText: 'Account Number *',
                hintText: 'Enter account number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) => verificationData['bankDetails']['ifscCode'] = value,
              decoration: const InputDecoration(
                labelText: 'IFSC Code *',
                hintText: 'Enter IFSC code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                border: Border.all(color: Colors.yellow.shade200),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning, color: Colors.yellow),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Security Notice',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.yellow),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Your banking information is encrypted and secure. We use this only for payment processing.',
                          style: TextStyle(fontSize: 12, color: Colors.yellow),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(() => currentStep = 2),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: (verificationData['bankDetails']['accountHolderName'].isNotEmpty &&
                               verificationData['bankDetails']['accountNumber'].isNotEmpty &&
                               verificationData['bankDetails']['ifscCode'].isNotEmpty)
                        ? handleBankSubmit
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Complete Verification'),
                  ),
                ),
              ],
            ),
          ],
        );

      default:
        return const SizedBox();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                const Text(
                  'Host Verification',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 48),
              ],
            ),
          ),

          // Progress
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Verification Progress', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text('$completedSteps/4 completed'),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progressPercentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                ),
              ],
            ),
          ),

          // Steps Overview
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey, width: 0.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: verificationSteps.map((step) {
                final index = verificationSteps.indexOf(step);
                final isCompleted = step['status'] == 'completed';
                final isCurrent = index == currentStep;

                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCurrent ? Colors.blue.shade50 : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isCompleted
                                ? Colors.green
                                : isCurrent
                                    ? const Color(0xFF1976D2)
                                    : Colors.grey.shade300,
                          ),
                          child: Icon(
                            isCompleted ? Icons.check : step['icon'] as IconData,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          step['title'] as String,
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: renderStepContent(),
            ),
          ),
        ],
      ),
    );
  }
}