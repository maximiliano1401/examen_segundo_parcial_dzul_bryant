import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/game.dart';
import 'add_game_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Game> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    final games = await DatabaseHelper.instance.getAllGames();
    setState(() {
      _games = games;
      _isLoading = false;
    });
  }

  Future<void> _deleteGame(int id) async {
    await DatabaseHelper.instance.deleteGame(id);
    _loadGames();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Videojuegos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _games.isEmpty
          ? const Center(
              child: Text(
                'No hay videojuegos.\nPresiona + para agregar uno.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadGames,
              child: ListView.builder(
                itemCount: _games.length,
                itemBuilder: (context, index) {
                  final game = _games[index];
                  return _GameCard(
                    game: game,
                    onDelete: () => _deleteGame(game.id!),
                    onRefresh: _loadGames,
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const AddGameScreen()),
          );
          if (added == true) _loadGames();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.game,
    required this.onDelete,
    required this.onRefresh,
  });

  final Game game;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'playing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _statusColor(game.status),
          child: Text(
            game.rating.toStringAsFixed(0),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          game.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${game.platform}  •  ${game.genre ?? "Sin género"}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(
                game.status,
                style: const TextStyle(fontSize: 11, color: Colors.white),
              ),
              backgroundColor: _statusColor(game.status),
              padding: EdgeInsets.zero,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Eliminar'),
                    content: Text('¿Eliminar "${game.title}"?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
                if (confirm == true) onDelete();
              },
            ),
          ],
        ),
      ),
    );
  }
}
