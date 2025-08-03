import 'package:flutter/material.dart';

// Plan Configuration Class
class PlanConfig {
  final List<Color> avatarGradient;
  final Color borderColor;
  final Color accentColor;
  final String planName;

  PlanConfig({
    required this.avatarGradient,
    required this.borderColor,
    required this.accentColor,
    required this.planName,
  });

  static PlanConfig getPlanConfig(String planType) {
    switch (planType.toUpperCase()) {
      case 'GOLD':
        return PlanConfig(
          avatarGradient: [
            const Color(0xFFFFD700), // Gold
            const Color(0xFFB8860B), // Dark gold
          ],
          borderColor: const Color(0xFFFFD700),
          accentColor: const Color(0xFFFFD700),
          planName: 'Gold',
        );
      case 'SILVER':
        return PlanConfig(
          avatarGradient: [
            const Color(0xFFC0C0C0), // Silver
            const Color(0xFF808080), // Dark silver
          ],
          borderColor: const Color(0xFFC0C0C0),
          accentColor: const Color(0xFFC0C0C0),
          planName: 'Silver',
        );
      case 'PLATINUM':
        return PlanConfig(
          avatarGradient: [
            const Color(0xFFE5E4E2), // Platinum
            const Color(0xFF9C9C9C), // Dark platinum
          ],
          borderColor: const Color(0xFFE5E4E2),
          accentColor: const Color(0xFFE5E4E2),
          planName: 'Platinum',
        );
      case 'BRONZE':
        return PlanConfig(
          avatarGradient: [
            const Color(0xFFCD7F32), // Bronze
            const Color(0xFF8B4513), // Dark bronze
          ],
          borderColor: const Color(0xFFCD7F32),
          accentColor: const Color(0xFFCD7F32),
          planName: 'Bronze',
        );
      case 'DIAMOND':
        return PlanConfig(
          avatarGradient: [
            const Color(0xFFB9F2FF), // Diamond blue
            const Color(0xFF4FC3F7), // Darker diamond blue
          ],
          borderColor: const Color(0xFFB9F2FF),
          accentColor: const Color(0xFFB9F2FF),
          planName: 'Diamond',
        );
      default:
        return PlanConfig(
          avatarGradient: [
            const Color(0xFFD4A574), // Default brown/tan
            const Color(0xFFA67C52),
          ],
          borderColor: const Color(0xFF666666),
          accentColor: const Color(0xFF666666),
          planName: 'Basic',
        );
    }
  }
}

class ProfileCard extends StatelessWidget {
  final String name;
  final String location;
  final String experience;
  final List<String> languages;
  final List<String> categories;
  final bool isKycApproved;
  final String? profileImageUrl;
  final String planType;

  const ProfileCard({
    Key? key,
    required this.name,
    required this.location,
    required this.experience,
    required this.languages,
    required this.categories,
    this.isKycApproved = false,
    this.profileImageUrl,
    this.planType = 'BASIC',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final planConfig = PlanConfig.getPlanConfig(planType);

    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2D2D2D),
            const Color(0xFF1A1A1A),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: planConfig.borderColor.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: planConfig.accentColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with name, location and avatar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            location,
                            style: const TextStyle(
                              color: Color(0xFFB0B0B0),
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Layered Avatar Design
                    _buildLayeredAvatar(planConfig),
                  ],
                ),

                const SizedBox(height: 24),

                // Experience and Languages
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      experience,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      languages.join(', '),
                      style: const TextStyle(
                        color: Color(0xFFB0B0B0),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Categories and KYC section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Categories
                    Expanded(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        children: categories
                            .map((category) => Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF404040),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ))
                            .toList(),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // KYC Status
                    if (isKycApproved)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'KYC',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'approved',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Edit Icon
          Positioned(
            top: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.edit,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),

          // Plan Badge (Optional)
          if (planType.toUpperCase() != 'BASIC')
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: planConfig.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: planConfig.accentColor.withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: Text(
                  planConfig.planName.toUpperCase(),
                  style: TextStyle(
                    color: planConfig.accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLayeredAvatar(PlanConfig planConfig) {
    return Container(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer layer
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFF3A3A3A),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          // Middle layer
          Container(
            width: 85,
            height: 85,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A2A),
              borderRadius: BorderRadius.circular(17),
            ),
          ),
          // Inner gradient layer
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: planConfig.avatarGradient,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: profileImageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      profileImageUrl!,
                      fit: BoxFit.cover,
                    ),
                  )
                : Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            planConfig.avatarGradient[0].withOpacity(0.8),
                            planConfig.avatarGradient[1].withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

// Example usage with subscription data
class ProfileCardExample extends StatelessWidget {
  // Sample subscription data
  final Map<String, dynamic> subscriptionData = {
    "message": "Subscription successful",
    "subscription": {
      "userId": "688e69d3dd8240d79b17c3d8",
      "planType": "SILVER",
      "price": 999,
      "durationDays": 365,
      "isActive": true,
      "_id": "688f64765b9263c9da4ab38a",
      "startDate": "2025-08-03T13:30:30.320Z",
      "endDate": "2026-08-03T13:30:30.320Z",
      "__v": 0
    }
  };

  ProfileCardExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final subscription = subscriptionData['subscription'];
    final planType = subscription['planType'] ?? 'BASIC';

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF121212),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.business,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'kk,',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search Bar
            Container(
              margin: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Search...',
                          hintStyle: TextStyle(color: Color(0xFF808080)),
                          border: InputBorder.none,
                          icon: Icon(
                            Icons.search,
                            color: Color(0xFF808080),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Filters',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Profile Card with dynamic plan type
            ProfileCard(
              name: 'Ayush Kumar.',
              location: 'Delhi NCR',
              experience: '4+ years',
              languages: ['Hindi', 'English'],
              categories: ['Commercial', 'Plots', 'Rental'],
              isKycApproved: true,
              planType: planType, // Dynamic plan type from subscription
            ),

            // View Profile Button
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.qr_code, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'View my Profile QR',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Plan Details Card (Based on subscription data)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: PlanConfig.getPlanConfig(planType)
                      .borderColor
                      .withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Subscription',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Plan:',
                        style: TextStyle(color: Color(0xFFB0B0B0)),
                      ),
                      Text(
                        planType,
                        style: TextStyle(
                          color: PlanConfig.getPlanConfig(planType).accentColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Price:',
                        style: TextStyle(color: Color(0xFFB0B0B0)),
                      ),
                      Text(
                        '₹${subscription['price']}',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duration:',
                        style: TextStyle(color: Color(0xFFB0B0B0)),
                      ),
                      Text(
                        '${subscription['durationDays']} days',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Status:',
                        style: TextStyle(color: Color(0xFFB0B0B0)),
                      ),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: subscription['isActive']
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          subscription['isActive'] ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: subscription['isActive']
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 100), // Space for bottom navigation
          ],
        ),
      ),
    );
  }
}
