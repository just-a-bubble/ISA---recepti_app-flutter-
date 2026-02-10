import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';


class ApiService {

  // --------------------
  // LOGIN
  // --------------------
  Future<bool> login(String username, String password) async {
    final response = await ApiClient.dio.post(
      '/login',
      data: FormData.fromMap({
        'username': username,
        'password': password,
      }),
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }

  // --------------------
  // REGISTER
  // --------------------
  Future<String> register(String username, String password) async {
    final response = await ApiClient.dio.post(
      '/register',
      data: FormData.fromMap({
        'username': username,
        'password': password,
      }),
      options: Options(
        contentType: Headers.formUrlEncodedContentType,
      ),
    );

    if (response.data is Map && response.data['message'] != null) {
      return response.data['message'];
    }

    return 'Napaka pri registraciji';
  }

  // --------------------
  // ME
  // --------------------
  Future<Map<String, dynamic>> me() async {
    final response = await ApiClient.dio.get('/me');

    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }

    throw Exception('Neavtoriziran');
  }

  // --------------------
  // SEARCH
  // --------------------
  Future<List<dynamic>> search(String query) async {
    final response = await ApiClient.dio.post(
      '/search',
      data: {'query': query},
    );

    if (response.statusCode == 200 && response.data is List) {
      return response.data;
    }

    return [];
  }

  // --------------------
  // FAVOURITES
  // --------------------
  Future<void> addFavourite(int id) async {
    await ApiClient.dio.post(
      '/add_favourite',
      data: {'recipe_id': id},
    );
  }

  Future<void> removeFavourite(int id) async {
    await ApiClient.dio.post(
      '/remove_favourite',
      data: {'recipe_id': id},
    );
  }

  // --------------------
  // SHARE
  // --------------------
  Future<void> share(int id, String receiver) async {
    await ApiClient.dio.post(
      '/share_recipe',
      data: {
        'recipe_id': id,
        'receiver': receiver,
      },
    );
  }

  // --------------------
  // LOGOUT
  // --------------------
  Future<void> logout() async {
    await ApiClient.dio.post('/logout');

    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
  }
  
  // --------------------
  // GET SINGLE RECIPE (kot /api/get_recipe v index.html)
  // --------------------
  Future<Map<String, dynamic>> getRecipe(int id) async {
    final response = await ApiClient.dio.post(
      '/get_recipe',
      data: {'recipe_id': id},
    );

    if (response.statusCode == 200 && response.data is Map) {
      return Map<String, dynamic>.from(response.data);
    }

    throw Exception('Recept ni najden');
  }
}