class UserProfile {
  String name;
  String gender;
  DateTime? birthday;
  String parentName;
  String parentContact;
  int stars;
  int lessonsCompleted;
  Map<String, int> achievements;

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
    this.stars = 0,
    this.lessonsCompleted = 0,
    Map<String, int>? achievements,
  }) : achievements = achievements ?? {};

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'birthday': birthday?.toIso8601String(),
      'parentName': parentName,
      'parentContact': parentContact,
      'stars': stars,
      'lessonsCompleted': lessonsCompleted,
      'achievements': achievements,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      birthday: json['birthday'] != null 
          ? DateTime.parse(json['birthday']) 
          : null,
      parentName: json['parentName'] ?? '',
      parentContact: json['parentContact'] ?? '',
      stars: json['stars'] ?? 0,
      lessonsCompleted: json['lessonsCompleted'] ?? 0,
      achievements: Map<String, int>.from(json['achievements'] ?? {}),
    );
  }
}