class User {
  static String? id;
  static String? nom;
  static String? prenom;
  static String? email;
  static String? profilePicture;
  static String? role;
  static String? token;

  static void setUserData(Map<String, dynamic> userData) {
    print('Setting user data: $userData'); // Debug print
    id = userData['id']?.toString();
    nom = userData['nom'];
    prenom = userData['prenom'];
    email = userData['email'];
    profilePicture = userData['profilePicture']; // Changed from photo_profil to profilePicture
    role = userData['role'];
    token = userData['token'];

    // Debug prints to verify data is set correctly
    print('User data set:');
    print('ID: $id');
    print('Name: $nom');
    print('First Name: $prenom');
    print('Email: $email');
    print('Profile Picture: $profilePicture');
    print('Role: $role');
    print('Token: $token');
  }

  static String? userId;

  static void setUserId(String id) {
    User.id = id;
  }

  static String? getUserId() {
    return id;
  }

  static bool isLoggedIn() {
    return id != null;
  }

  static String getPicture() {
    return profilePicture ?? '';
  }
} 