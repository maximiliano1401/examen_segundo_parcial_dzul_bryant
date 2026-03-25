import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/game.dart';

class AddGameScreen extends StatefulWidget {
  const AddGameScreen({super.key});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _genreController = TextEditingController();
  final _imageUrlController = TextEditingController();

  String _platform = 'PC';
  String _status = 'Pending';
  int _rating = 3;

  static const _platforms = [
    'PC',
    'PlayStation',
    'Xbox',
    'Switch',
    'Mobile',
    'Other',
  ];
  static const _statuses = ['Pending', 'Playing', 'Completed'];

  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _genreController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    final game = Game(
      title: _titleController.text.trim(),
      platform: _platform,
      status: _status,
      rating: _rating.toDouble(),
      genre: _genreController.text.trim().isEmpty
          ? null
          : _genreController.text.trim(),
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
    );

    await DatabaseHelper.instance.insertGame(game);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('¡"${game.title}" agregado correctamente!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Videojuego'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Titulo
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Titulo *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.videogame_asset),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'El titulo es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),

              // Plataforma
              DropdownButtonFormField<String>(
                initialValue: _platform,
                decoration: const InputDecoration(
                  labelText: 'Plataforma',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.devices),
                ),
                items: _platforms
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _platform = v!),
              ),
              const SizedBox(height: 16),

              // Estado
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                  labelText: 'Estado',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.flag_outlined),
                ),
                items: _statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => setState(() => _status = v!),
              ),
              const SizedBox(height: 16),

              // Rating con estrellas
              const Text('Calificacion', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: List.generate(5, (index) {
                  final star = index + 1;
                  return IconButton(
                    icon: Icon(
                      star <= _rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 36,
                    ),
                    onPressed: () => setState(() => _rating = star),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Genero (opcional)
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(
                  labelText: 'Genero (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // URL imagen (opcional)
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL de imagen (opcional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.image_outlined),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 24),

              // Boton guardar
              ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('Guardar'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
