class UserGroupDto {
  const UserGroupDto({required this.users, required this.groups});

  final List<UserDto> users;
  final List<String> groups;

  factory UserGroupDto.fromJson(Map<String, dynamic> json) {
    return UserGroupDto(
      users:
          (json['users'] as List<dynamic>?)
              ?.map((e) => UserDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      groups:
          (json['groups'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class UserDto {
  const UserDto({required this.username, required this.group});

  final String username;
  final String group;

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      username: json['username'] as String? ?? '',
      group: json['group'] as String? ?? '',
    );
  }
}
