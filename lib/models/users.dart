class BaseUser {
  final String email;
  final String lastname;
  final String name;
  final String password;
  final String phone;
  final String biography;
  final String image;

  BaseUser({
    required this.email,
    required this.lastname,
    required this.name,
    required this.password,
    required this.phone,
    required this.biography,
    required this.image,
  });

  factory BaseUser.fromJson(Map<String, dynamic> json) => BaseUser(
    email: json["email"] ?? '',
    lastname: json["lastname"] ?? '',
    name: json["name"] ?? '',
    password: json["password"] ?? '',
    phone: json["phone"] ?? '',
    biography: json["biography"] ?? '',
    image: json["image"] ?? '',
  );

  Map<String, dynamic> toJson() => {
    "email": email,
    "lastname": lastname,
    "name": name,
    "password": password,
    "phone": phone,
    "biography": biography,
    "image": image,
  };
}