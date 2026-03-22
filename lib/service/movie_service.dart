import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import 'movie_model.dart';

class MovieService {

  Future<List<Movie>> fetchPopularMovies() async {
    final url = Uri.parse(
      "${ApiConstants.baseUrl}/discover/movie?api_key=${ApiConstants.apiKey}&with_origin_country=IN",
    );


    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List results = data['results'];

      return results
          .map((movie) => Movie.fromJson(movie))
          .toList();
    } else {
      throw Exception("Failed to load movies");
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.parse(
      "${ApiConstants.baseUrl}/search/movie?api_key=${ApiConstants.apiKey}&query=$query",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List results = data['results'];

      return results
          .map((movie) => Movie.fromJson(movie))
          .toList();
    } else {
      throw Exception("Failed to search movies");
    }
  }

  Future<String?> fetchTrailer(int movieId) async {

    final url = Uri.parse(
      "${ApiConstants.baseUrl}/movie/$movieId/videos?api_key=${ApiConstants.apiKey}",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      List results = data['results'];

      for (var video in results) {
        if (video['site'] == "YouTube" && video['type'] == "Trailer") {
          return video['key'];
        }
      }
    }

    return null;
  }

}
