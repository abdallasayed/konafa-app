class UserModel {
  String uid;
  String email;
  String name;
  String phone;
  String? profileImage;
  String role;
  int points;
  double totalSpent;
  List<String>? addresses;
  List<String>? favoriteProducts;
  DateTime createdAt;
  DateTime? lastLogin;
  
  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.phone,
    this.profileImage,
    this.role = 'customer',
    this.points = 0,
    this.totalSpent = 0,
    this.addresses,
    this.favoriteProducts,
    DateTime? createdAt,
    this.lastLogin,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'phone': phone,
      'profileImage': profileImage,
      'role': role,
      'points': points,
      'totalSpent': totalSpent,
      'addresses': addresses,
      'favoriteProducts': favoriteProducts,
      'createdAt': createdAt,
      'lastLogin': lastLogin ?? DateTime.now(),
    };
  }

  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      uid: id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'],
      role: data['role'] ?? 'customer',
      points: (data['points'] ?? 0).toInt(),
      totalSpent: (data['totalSpent'] ?? 0).toDouble(),
      addresses: data['addresses'] != null ? List<String>.from(data['addresses']) : [],
      favoriteProducts: data['favoriteProducts'] != null ? List<String>.from(data['favoriteProducts']) : [],
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      lastLogin: data['lastLogin']?.toDate(),
    );
  }
}
