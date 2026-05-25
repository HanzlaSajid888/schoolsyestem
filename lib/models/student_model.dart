class Student {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String rollNumber;
  final String grade;
  final String section;
  final String parentName;
  final String phone;
  final String parentEmail;
  final String avatarColor; // hex string

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.rollNumber,
    required this.grade,
    required this.section,
    required this.parentName,
    required this.phone,
    required this.parentEmail,
    required this.avatarColor,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id']?.toString() ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      rollNumber: json['rollNumber'] ?? '',
      grade: json['grade'] ?? '',
      section: json['section'] ?? '',
      parentName: json['parentName'] ?? '',
      phone: json['phone'] ?? '',
      parentEmail: json['parentEmail'] ?? '',
      avatarColor: json['avatarColor'] ?? '0xFFE3F2FD',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id.isNotEmpty) 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'rollNumber': rollNumber,
      'grade': grade,
      'section': section,
      'parentName': parentName,
      'phone': phone,
      'parentEmail': parentEmail,
      'avatarColor': avatarColor,
    };
  }

  String get fullName => '$firstName $lastName';
  String get initials => '${firstName[0]}${lastName[0]}';
}

// Dummy Data
final List<Student> dummyStudents = [
  Student(
    id: '1',
    firstName: 'Ahmad',
    lastName: 'Khan',
    email: 'ahmad@example.com',
    rollNumber: '2024-001',
    grade: 'Grade 10',
    section: 'Section A',
    parentName: 'Imran Khan',
    phone: '0300-1234567',
    parentEmail: 'ahmad@example.com',
    avatarColor: '0xFFE3F2FD', // Light Blue
  ),
  Student(
    id: '2',
    firstName: 'Sara',
    lastName: 'Ahmed',
    email: 'sara@example.com',
    rollNumber: '2024-002',
    grade: 'Grade 10',
    section: 'Section B',
    parentName: 'Ahmed Malik',
    phone: '0311-7654321',
    parentEmail: 'sara@example.com',
    avatarColor: '0xFFE1F5FE', // Lighter Blue
  ),
  Student(
    id: '3',
    firstName: 'Zainab',
    lastName: 'Fatima',
    email: 'zainab@example.com',
    rollNumber: '2024-003',
    grade: 'Grade 9',
    section: 'Section A',
    parentName: 'Ali Raza',
    phone: '0322-9988776',
    parentEmail: 'zainab@example.com',
    avatarColor: '0xFFE0F7FA', // Cyan tint
  ),
];

final List<String> dummyClasses = [
  'Grade 9',
  'Grade 10',
];

final List<String> dummySections = [
  'Section A',
  'Section B',
];
