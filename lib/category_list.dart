import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_category.dart';
import 'edit_category.dart';

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  IconData getIconFromName(String name) {
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

  Widget categoryList(List<QueryDocumentSnapshot<Map<String, dynamic>>> docs) {
    if (docs.isEmpty) return Center(child: Text("No data"));

    return ListView.separated(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: docs.length,
      separatorBuilder: (_, __) => SizedBox(height: 8),
      itemBuilder: (context, index) {
        final doc = docs[index];
        final data = doc.data();
        final name = data['category_name'] ?? 'No name';
        final iconName = data['icon_name'] ?? '';

        return Card(
          child: ListTile(
            leading: Icon(getIconFromName(iconName)),
            title: Text(name),
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'delete') {
                  try {
                    await FirebaseFirestore.instance
                        .collection('categories')
                        .doc(doc.id)
                        .delete();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Category deleted'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                } else if (value == 'edit') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditCategory(docId: doc.id, data: data),
                    ),
                  );
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildCategorySection(String type) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('categories')
          .where('type', isEqualTo: type)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData) {
          return Center(child: Text("No data"));
        }

        final docs = snapshot.data!.docs;
        print("Fetched ${docs.length} $type categories"); // Debug

        return docs.isEmpty
            ? Center(child: Text("No data"))
            : categoryList(docs);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Income",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 10),
              buildCategorySection('income'),
              SizedBox(height: 30),
              Text("Expense",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              SizedBox(height: 10),
              buildCategorySection('expense'),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddCategory()),
          );
        },
        shape: CircleBorder(),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
      ),
    );
  }
}
