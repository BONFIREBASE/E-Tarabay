class UserProfile {
  String name;
  String gender;
  DateTime? birthday;
  DateTime? createdAt;
  String parentName;
  String parentContact;
  String lrn;
  String avatar;
  int stars;
  int lessonsCompleted;
  Map<String, int> achievements;
  List<String> certificates;
  List<String> claimedBadges;

  // Computed property for age based on birthday
  int get age {
    if (birthday == null) return 2; // Default age if no birthday
    final now = DateTime.now();
    int age = now.year - birthday!.year;
    if (now.month < birthday!.month ||
        (now.month == birthday!.month && now.day < birthday!.day)) {
      age--;
    }
    return age;
  }

  UserProfile({
    required this.name,
    required this.gender,
    this.birthday,
    this.createdAt,
    this.parentName = '',
    this.parentContact = '',
    this.lrn = '',
    this.avatar = '',
    this.stars = 0,
    this.lessonsCompleted = 0,
    Map<String, int>? achievements,
    List<String>? certificates,
    List<String>? claimedBadges,
  })  : achievements = achievements ?? {},
        certificates = certificates ?? [],
        claimedBadges = claimedBadges ?? [];

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'birthday': birthday?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'parentName': parentName,
      'parentContact': parentContact,
      'lrn': lrn,
      'avatar': avatar,
      'stars': stars,
      'lessonsCompleted': lessonsCompleted,
      'achievements': achievements,
      'certificates': certificates,
      'claimedBadges': claimedBadges,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name']?.toString() ?? '',
      gender: json['gender']?.toString() ?? '',
      birthday:
          json['birthday'] != null ? DateTime.tryParse(json['birthday'].toString()) : null,
      createdAt:
          json['createdAt'] != null ? DateTime.tryParse(json['createdAt'].toString()) : null,
      parentName: json['parentName']?.toString() ?? '',
      parentContact: json['parentContact']?.toString() ?? '',
      lrn: json['lrn']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
      stars: json['stars'] ?? 0,
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      achievements: Map<String, int>.from(json['achievements'] ?? {}),
      certificates: List<String>.from(json['certificates'] ?? []),
      claimedBadges: List<String>.from(json['claimedBadges'] ?? []),
    );
  }
}
