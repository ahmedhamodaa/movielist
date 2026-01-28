// ==================== create_list_screen.dart ====================
import 'package:flutter/material.dart';
import 'package:movielist/data/models/models.dart';
import 'package:movielist/services/tmdb_service.dart';

class CreateListScreen extends StatefulWidget {
  final MovieList? existingList;

  CreateListScreen({this.existingList});

  @override
  _CreateListScreenState createState() => _CreateListScreenState();
}

class _CreateListScreenState extends State<CreateListScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final TmdbService _tmdbService = TmdbService();
  bool _isLoading = false;
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    if (widget.existingList != null) {
      _nameController.text = widget.existingList!.name;
      _descriptionController.text = widget.existingList!.description ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveList() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (widget.existingList != null) {
      // Update existing list
      final success = await _tmdbService.updateList(
        widget.existingList!.id,
        _nameController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        _selectedLanguage,
      );

      setState(() => _isLoading = false);

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('List updated'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update list'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      // Create new list
      final list = await _tmdbService.createList(
        _nameController.text.trim(),
        _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        _selectedLanguage,
      );

      setState(() => _isLoading = false);

      if (list != null) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('List created'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create list'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingList != null ? 'Edit List' : 'Create List'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'List Name',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a list name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description (optional)',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 4,
              ),
              // SizedBox(height: 16),
              // DropdownButtonFormField<String>(
              //   value: _selectedLanguage,
              //   decoration: InputDecoration(
              //     labelText: 'Language',
              //     prefixIcon: Icon(Icons.language),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(12),
              //     ),
              //     filled: true,
              //     fillColor: Colors.white,
              //   ),
              //   items: [
              //     DropdownMenuItem(value: 'en', child: Text('English')),
              //     DropdownMenuItem(value: 'es', child: Text('Spanish')),
              //     DropdownMenuItem(value: 'fr', child: Text('French')),
              //     DropdownMenuItem(value: 'de', child: Text('German')),
              //     DropdownMenuItem(value: 'it', child: Text('Italian')),
              //     DropdownMenuItem(value: 'pt', child: Text('Portuguese')),
              //     DropdownMenuItem(value: 'ja', child: Text('Japanese')),
              //     DropdownMenuItem(value: 'ko', child: Text('Korean')),
              //     DropdownMenuItem(value: 'zh', child: Text('Chinese')),
              //   ],
              //   onChanged: (value) {
              //     if (value != null) {
              //       setState(() => _selectedLanguage = value);
              //     }
              //   },
              // ),
              SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: _isLoading ? null : _saveList,
                  style: FilledButton.styleFrom(),
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.existingList != null
                              ? 'Update List'
                              : 'Create List',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
