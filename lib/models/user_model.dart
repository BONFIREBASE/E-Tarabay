class UserProfile {
  String name;
  String gender;
  DateTime? birthday;
  String parentName;
  String parentContact;
  String lrn;
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
    this.parentName = '',
    this.parentContact = '',
    this.lrn = '',
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
      'parentName': parentName,
      'parentContact': parentContact,
      'lrn': lrn,
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
          json['birthday'] != null ? DateTime.parse(json['birthday']) : null,
      parentName: json['parentName']?.toString() ?? '',
      parentContact: json['parentContact']?.toString() ?? '',
      lrn: json['lrn']?.toString() ?? '',
      stars: json['stars'] ?? 0,
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      achievements: Map<String, int>.from(json['achievements'] ?? {}),
      certificates: List<String>.from(json['certificates'] ?? []),
      claimedBadges: List<String>.from(json['claimedBadges'] ?? []),
    );
  }
}
