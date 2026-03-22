import 'package:flutter/material.dart';
import 'package:movieshub/persentation/home/trailer_page.dart';
import '../../core/constants/api_constants.dart';
import '../../service/movie_model.dart';
import '../../service/movie_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final MovieService _movieService = MovieService();
  Future<List<Movie>>? _moviesFuture;

  @override
  void initState() {
    super.initState();
    _moviesFuture = _movieService.fetchPopularMovies();
  }

  void searchMovie(String query) {
    setState(() {
      if (query.isEmpty) {
        _moviesFuture = _movieService.fetchPopularMovies();
      } else {
        _moviesFuture = _movieService.searchMovies(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "MovieHub",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: TextField(
              onChanged: searchMovie,
              decoration: InputDecoration(
                hintText: "Search movies...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Movie>>(
        future: _moviesFuture,
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final movies = snapshot.data!;

          return GridView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: movies.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (context, index) {
              final movie = movies[index];

              return GestureDetector(
                onTap: () async {

                  final trailerKey =
                  await _movieService.fetchTrailer(movie.id);

                  if (trailerKey != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TrailerPage(videoKey: trailerKey),
                      ),
                    );
                  }
                },
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        "${ApiConstants.imageBaseUrl}${movie.posterPath}",
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      movie.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

