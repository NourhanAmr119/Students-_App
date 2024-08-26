class UserData {
  final int? id;
  final String name;
  final String gender;
  final String email;
  final String studentId;
  final String level;
  final String password;
  final String? imagePath;  

  UserData({
    this.id,
    required this.name,
    required this.gender,
    required this.email,
    required this.studentId,
    required this.level,
    required this.password,
    this.imagePath,  
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'email': email,
      'studentId': studentId,
      'level': level,
      'password': password,
      'imagePath': imagePath,  
    };
  }

  factory UserData.fromMap(Map<String, dynamic> map) {
    return UserData(
      id: map['id'],
      name: map['name'],
      gender: map['gender'] ?? '',
      email: map['email'],
      studentId: map['studentId'],
      level: map['level'] ?? '',
      password: map['password'],
      imagePath: map['imagePath'],  
    );
  }
}