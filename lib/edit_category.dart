
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'about.dart';

class EditCategory extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  const EditCategory({super.key, required this.docId, required this.data});

  @override
  State<EditCategory> createState() => _EditCategoryState();
}

enum CategoryType { income, expense }

class _EditCategoryState extends State<EditCategory> {
  late CategoryType _selectedType;
  String? selectedIcon;
  late TextEditingController nameController;

  final iconOptions = [
    'food',
    'transport',
    'salary',
    'allowance',
    'bonus',
    'freelance',
    'investment',
    'housing',
    'utilities',
    'health',
    'entertainment',
    'education',
    'shopping'
  ];

  @override
  void initState() {
    super.initState();
    _selectedType =
    widget.data['type'] == 'income' ? CategoryType.income : CategoryType.expense;
    selectedIcon = widget.data['icon_name'];
    nameController = TextEditingController(text: widget.data['category_name']);
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }

  IconData getIconData(String name) {
    switch (name) {
      case 'food':
        return Icons.fastfood;
      case 'transport':
        return Icons.directions_car;
      case 'salary':
        return Icons.payments_outlined;
      case 'allowance':
        return Icons.money;
      case 'bonus':
        return Icons.card_giftcard;
      case 'freelance':
        return Icons.work_outline;
      case 'investment':
        return Icons.show_chart;
      case 'housing':
        return Icons.home;
      case 'utilities':
        return Icons.lightbulb_outline;
      case 'health':
        return Icons.local_hospital;
      case 'entertainment':
        return Icons.movie;
      case 'education':
        return Icons.school;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.category;
    }
  }

  Future<void> _updateCategory() async {
    if (nameController.text.isEmpty || selectedIcon == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.docId)
          .update({
        'category_name': nameController.text.trim(),
        'icon_name': selectedIcon,
        'type': _selectedType == CategoryType.income ? 'income' : 'expense',
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update category: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Category"),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.menu),
            onSelected: (value) {
              if (value == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const About()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.black),
                    SizedBox(width: 5),
                    Text("About"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Select Type", style: TextStyle(fontSize: 16)),
              RadioListTile<CategoryType>(
                title: const Text("Income"),
                value: CategoryType.income,
                groupValue: _selectedType,
                onChanged: (value) => setState(() => _selectedType = value!),
                activeColor: Colors.indigo,
              ),
              RadioListTile<CategoryType>(
                title: const Text("Expense"),
                value: CategoryType.expense,
                groupValue: _selectedType,
                onChanged: (value) => setState(() => _selectedType = value!),
                activeColor: Colors.indigo,
              ),
              const SizedBox(height: 20),
              const Text("Category Name", style: TextStyle(fontSize: 16)),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  hintText: "Enter category name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Select Icon", style: TextStyle(fontSize: 16)),
              DropdownButtonFormField<String>(
                value: selectedIcon,
                hint: const Text("Select Icon"),
                items: iconOptions.map((iconName) {
                  return DropdownMenuItem<String>(
                    value: iconName,
                    child: Icon(getIconData(iconName), color: Colors.indigo),
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedIcon = value),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(250, 60),
                  ),
                  onPressed: _updateCategory,
                  child: const Text(
                    "Update",
                    style: TextStyle(fontSize: 18),
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


