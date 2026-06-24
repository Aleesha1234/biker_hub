class UserModel {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String role; // "user" or "admin"
  final bool isBlocked;
  final String profileImage;
  final DateTime? createdAt;
  final int rides;
  final int listings;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.phone = '',
    this.role = 'user',
    this.isBlocked = false,
    this.profileImage = '',
    this.createdAt,
    this.rides = 0,
    this.listings = 0,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'user',
      isBlocked: map['isBlocked'] ?? false,
      profileImage: map['profileImage'] ?? '',
      rides: map['rides'] ?? 0,
      listings: map['listings'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'isBlocked': isBlocked,
        'profileImage': profileImage,
        'rides': rides,
        'listings': listings,
      };
}
