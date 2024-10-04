class Profile {
  //id,username,first_name,last_name,updated_at,email,avatar_url,website,bio
  final String id;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime? updatedAt;
  final String email;
  final String? avatarUrl;
  final String? website;
  final String? bio;

  Profile(
      {required this.id,
      required this.username,
      required this.firstName,
      required this.lastName,
      required this.updatedAt,
      required this.email,
      required this.avatarUrl,
      required this.website,
      required this.bio});
  
  // Convert a Supabase Record to a profile object
factory Profile.fromMap(Map<String, dynamic> data) {
  return Profile(
    id: data['id'] as String,
    username: data['username'] as String,
    firstName: data['first_name'] as String,
    lastName: data['last_name'] as String,
    updatedAt: data['updated_at'] != null ? DateTime.parse(data['updated_at']) : null, // Handle nullable DateTime
    email: data['email'] as String,
    avatarUrl: data['avatar_url'] as String?, // Nullable field
    website: data['website'] as String?, // Nullable field
    bio: data['bio'] as String?, // Nullable field
  );
}


  // Convert a Profile object to Supabase Record
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'updated_at': updatedAt?.toIso8601String(),
      'email': email,
      'avatar_url': avatarUrl,
      'website': website,
      'bio': bio,
    };
  }

}