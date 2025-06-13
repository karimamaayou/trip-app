class User {
  static int? id;
  static String? nom;
  static String? prenom;
  static String? email;
  static String? profilePicture;
  static String? role;
  static String? token;

  static Future<void> setUserData(Map<String, dynamic> data) async {
    try {
      print('Setting user data: $data');
      
      // Vérifier que les données requises sont présentes
      if (data['id'] == null) {
        throw Exception('ID utilisateur manquant');
      }

      // Stocker les données
      id = data['id'];
      nom = data['nom'];
      prenom = data['prenom'];
      email = data['email'];
      profilePicture = data['profilePicture'];
      role = data['role'];
      token = data['token']; // Le token est optionnel

      // Vérifier que les données ont été correctement stockées
      print('User data set:');
      print('ID: $id');
      print('Name: $nom');
      print('First Name: $prenom');
      print('Email: $email');
      print('Profile Picture: $profilePicture');
      print('Role: $role');
      print('Token: $token');

      // Vérifier uniquement l'ID qui est requis
      if (id == null) {
        throw Exception('Erreur lors du stockage des données utilisateur');
      }
    } catch (e) {
      print('Error setting user data: $e');
      // En cas d'erreur, nettoyer les données
      clearUserData();
      rethrow;
    }
  }

  static void clearUserData() {
    id = null;
    nom = null;
    prenom = null;
    email = null;
    profilePicture = null;
    role = null;
    token = null;
  }

  static String? userId;

  static void setUserId(String id) {
    User.id = int.parse(id);
  }

  static String? getUserId() {
    return id?.toString();
  }

  static bool isLoggedIn() {
    return id != null;
  }

  static String getPicture() {
    return profilePicture ?? '';
  }
} 