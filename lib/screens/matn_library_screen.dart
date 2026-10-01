import 'package:flutter/material.dart';
import '../models/matn_model.dart';
import '../services/matn_service.dart';
import 'matn_detail_screen.dart';

class MatnLibraryScreen extends StatefulWidget {
  const MatnLibraryScreen({super.key});

  @override
  State createState() => _MatnLibraryScreenState();
}

class _MatnLibraryScreenState extends State {
  // للتحكم في نص البحث ومسحه
  final TextEditingController _searchController = TextEditingController();

  // القائمة الكاملة والقائمة بعد التصفية
  List _allMutoon = [];
  List _filteredMutoon = [];

  // مؤشر حالة التحميل المبدئي
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchMutoon();
  }

  // تحميل المتون مرة واحدة عند فتح الشاشة
  Future _fetchMutoon() async {
    try {
      final data = await MatnService.loadMutoon();
      setState(() {
        _allMutoon = data;
        _filteredMutoon = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // دالة الفلترة والبحث اللحظي بالاسم أو اسم المؤلف
  void _filterMutoon(String query) {
    final cleanQuery = query.trim().toLowerCase();

    setState(() {
      if (cleanQuery.isEmpty) {
        _filteredMutoon = _allMutoon;
      } else {
        _filteredMutoon = _allMutoon.where((matn) {
          final titleMatch = matn.title.toLowerCase().contains(cleanQuery);
          final authorMatch = matn.author.toLowerCase().contains(cleanQuery);
          final descMatch = matn.description.toLowerCase().contains(cleanQuery);

          return titleMatch || authorMatch || descMatch;
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خزانة المتون'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // حقل البحث
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: _filterMutoon,
              decoration: InputDecoration(
                hintText: 'ابحث باسم المتن أو المؤلف...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterMutoon('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // منطقة عرض المتون أو حالات التحميل/الخطأ
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text('حدث خطأ أثناء تحميل البيانات: $_errorMessage'),
      );
    }

    if (_filteredMutoon.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 54, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            const Text(
              'لم يتم العثور على أي متن يطابق بحثك',
              style: TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredMutoon.length,
      itemBuilder: (context, index) {
        final matn = _filteredMutoon[index];

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: const CircleAvatar(
              child: Icon(Icons.menu_book),
            ),
            title: Text(
              matn.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'المؤلف: ${matn.author}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                  ),
                ),
                if (matn.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    matn.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MatnDetailScreen(matn: matn),
                ),
              );
            },
          ),
        );
      },
    );
  }
}