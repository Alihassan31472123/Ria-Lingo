// class Chat {
//   final String id;
//   final String name;
//   final List<Member> members;
//   final bool isGroup;
//   final String? lastMessage;

//   Chat({
//     required this.id,
//     required this.name,
//     required this.members,
//     required this.isGroup,
//     this.lastMessage,
//   });

//   factory Chat.fromJson(Map<String, dynamic> json) {
//     return Chat(
//       id: json['_id'],
//       name: json['name'],
//       members: (json['members'] as List)
//           .map((member) => Member.fromJson(member))
//           .toList(),
//       isGroup: json['isGroup'],
//       lastMessage: json['lastMessage'],
//     );
//   }
// }

// class Member {
//   final String id;
//   final String firstName;
//   final String lastName;
//   final String profileUrl;

//   Member({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     required this.profileUrl,
//   });

//   factory Member.fromJson(Map<String, dynamic> json) {
//     return Member(
//       id: json['_id'],
//       firstName: json['firstName'],
//       lastName: json['lastName'],
//       profileUrl: json['profileUrl'],
//     );
//   }
// }
