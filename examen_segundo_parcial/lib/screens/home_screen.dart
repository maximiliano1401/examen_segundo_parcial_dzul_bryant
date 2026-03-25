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
  String _statusFilter = 'All';
  int? _ratingFilter;

  static const _statuses = ['All', 'Pending', 'Playing', 'Completed'];

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

  Future<void> _editGame(Game game) async {
    final edited = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddGameScreen(gameToEdit: game)),
    );
    if (edited == true) {
      _loadGames();
    }
  }

  Future<void> _changeStatus(Game game, String newStatus) async {
    if (newStatus == game.status) return;
    await DatabaseHelper.instance.updateGame(game.copyWith(status: newStatus));
    _loadGames();
  }

  List<Game> get _filteredGames {
    return _games.where((game) {
      final statusOk =
          _statusFilter == 'All' ||
          game.status.toLowerCase() == _statusFilter.toLowerCase();
      final ratingOk =
          _ratingFilter == null || game.rating.round() == _ratingFilter;
      return statusOk && ratingOk;
    }).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'playing':
        return const Color(0xFF1D4ED8);
      case 'completed':
        return const Color(0xFF059669);
      case 'pending':
        return const Color(0xFFEA580C);
      default:
        return Colors.grey;
    }
  }

  Color _ratingColor(double rating) {
    final value = rating.round();
    if (value <= 2) return const Color(0xFFDC2626);
    if (value == 3) return const Color(0xFFD97706);
    if (value == 4) return const Color(0xFF2563EB);
    return const Color(0xFF059669);
  }

  @override
  Widget build(BuildContext context) {
    final filteredGames = _filteredGames;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GAME VAULT',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tu biblioteca con estilo arcade',
                            style: TextStyle(color: Color(0xFFCBD5E1)),
                          ),
                        ],
                      ),
                    ),
                    IconButton.filled(
                      onPressed: _loadGames,
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF0EA5E9),
                      ),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ),
              _FiltersPanel(
                statuses: _statuses,
                selectedStatus: _statusFilter,
                selectedRating: _ratingFilter,
                onStatusChanged: (value) =>
                    setState(() => _statusFilter = value),
                onRatingChanged: (value) =>
                    setState(() => _ratingFilter = value),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    : filteredGames.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'No hay resultados con estos filtros.\nIntenta otra combinacion o agrega un juego.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFFE2E8F0),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadGames,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(12, 8, 12, 90),
                          itemCount: filteredGames.length,
                          itemBuilder: (context, index) {
                            final game = filteredGames[index];
                            return _GameCard(
                              game: game,
                              statusColor: _statusColor(game.status),
                              ratingColor: _ratingColor(game.rating),
                              onDelete: () => _deleteGame(game.id!),
                              onEdit: () => _editGame(game),
                              onStatusChange: (value) =>
                                  _changeStatus(game, value),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFF97316),
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
    required this.statusColor,
    required this.ratingColor,
    required this.onDelete,
    required this.onEdit,
    required this.onStatusChange,
  });

  final Game game;
  final Color statusColor;
  final Color ratingColor;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final ValueChanged<String> onStatusChange;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ratingColor.withValues(alpha: 0.24),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: ratingColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      game.rating.toStringAsFixed(0),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        game.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${game.platform} • ${game.genre ?? "Sin genero"}',
                        style: const TextStyle(color: Color(0xFF475569)),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Chip(
                            label: Text(
                              game.status,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            backgroundColor: statusColor,
                            side: BorderSide.none,
                          ),
                          _StarsRow(
                            color: ratingColor,
                            rating: game.rating.round(),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  tooltip: 'Cambiar estado',
                  onSelected: onStatusChange,
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'Pending', child: Text('Pending')),
                    PopupMenuItem(value: 'Playing', child: Text('Playing')),
                    PopupMenuItem(value: 'Completed', child: Text('Completed')),
                  ],
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.sync_alt, size: 16),
                        SizedBox(width: 6),
                        Text('Estado'),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                  ),
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Eliminar'),
                        content: Text('Eliminar "${game.title}"?'),
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
          ],
        ),
      ),
    );
  }
}

class _FiltersPanel extends StatelessWidget {
  const _FiltersPanel({
    required this.statuses,
    required this.selectedStatus,
    required this.selectedRating,
    required this.onStatusChanged,
    required this.onRatingChanged,
  });

  final List<String> statuses;
  final String selectedStatus;
  final int? selectedRating;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<int?> onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filtros',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: statuses.map((status) {
              final isSelected = status == selectedStatus;
              return ChoiceChip(
                label: Text(status),
                selected: isSelected,
                onSelected: (_) => onStatusChanged(status),
                selectedColor: const Color(0xFFF97316),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
                ),
                backgroundColor: const Color(0x1AFFFFFF),
                side: const BorderSide(color: Color(0x40FFFFFF)),
              );
            }).toList(),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                label: const Text('Todas las estrellas'),
                selected: selectedRating == null,
                onSelected: (_) => onRatingChanged(null),
                selectedColor: const Color(0xFF0EA5E9),
                labelStyle: TextStyle(
                  color: selectedRating == null
                      ? Colors.white
                      : const Color(0xFFE2E8F0),
                ),
                backgroundColor: const Color(0x1AFFFFFF),
                side: const BorderSide(color: Color(0x40FFFFFF)),
              ),
              ...List.generate(5, (index) {
                final stars = index + 1;
                final isSelected = selectedRating == stars;
                return FilterChip(
                  label: Text('$stars★'),
                  selected: isSelected,
                  onSelected: (_) => onRatingChanged(stars),
                  selectedColor: const Color(0xFF0EA5E9),
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFFE2E8F0),
                  ),
                  backgroundColor: const Color(0x1AFFFFFF),
                  side: const BorderSide(color: Color(0x40FFFFFF)),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.color, required this.rating});

  final Color color;
  final int rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_border_rounded,
          color: color,
          size: 16,
        );
      }),
    );
  }
}
