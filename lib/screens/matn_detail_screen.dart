import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import '../models/matn_model.dart';
import '../services/favorites_service.dart';
import '../services/history_service.dart';

class MatnDetailScreen extends StatefulWidget {
  final Matn matn;

  const MatnDetailScreen({
    super.key,
    required this.matn,
  });

  @override
  State<MatnDetailScreen> createState() => _MatnDetailScreenState();
}

class _MatnDetailScreenState extends State<MatnDetailScreen> {
  double _fontSize = 18.0;
  late bool _isFav;
  bool _isNightMode = false;

  final Map<int, GlobalKey> _chapterKeys = {};
  final List<_ChapterIndexItem> _chapters = [];

  @override
  void initState() {
    super.initState();
    _isFav = FavoritesService.isFavorite(widget.matn);
    HistoryService.addToHistory(widget.matn);
    _extractChapters();
  }

  void _extractChapters() {
    final lines = widget.matn.content.split('\n');
    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      if (trimmed.startsWith('#')) {
        final title = trimmed.replaceFirst('#', '').trim();
        _chapterKeys[i] = GlobalKey();
        _chapters.add(_ChapterIndexItem(lineIndex: i, title: title));
      }
    }
  }

  void _scrollToChapter(int lineIndex) {
    final key = _chapterKeys[lineIndex];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showChaptersIndex() {
    if (_chapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا توجد أبواب أو فصول معرّفة في هذا المتن'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: _isNightMode ? const Color(0xFF2C2C2C) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'فهرس الأبواب والفصول',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: _isNightMode ? Colors.white : Colors.black87,
                ),
              ),
              const Divider(height: 24),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _chapters.length,
                  itemBuilder: (context, idx) {
                    final chapter = _chapters[idx];
                    return ListTile(
                      leading: CircleAvatar(
                        radius: 14,
                        backgroundColor: const Color(0xFFD4A574).withOpacity(0.2),
                        child: Text(
                          '${idx + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4A574),
                          ),
                        ),
                      ),
                      title: Text(
                        chapter.title,
                        style: TextStyle(
                          fontSize: 15,
                          color: _isNightMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_back_ios_new, size: 14),
                      onTap: () {
                        Navigator.pop(ctx);
                        _scrollToChapter(chapter.lineIndex);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _increaseFontSize() {
    if (_fontSize < 32.0) {
      setState(() {
        _fontSize += 2.0;
      });
    }
  }

  void _decreaseFontSize() {
    if (_fontSize > 14.0) {
      setState(() {
        _fontSize -= 2.0;
      });
    }
  }

  void _toggleNightMode() {
    setState(() {
      _isNightMode = !_isNightMode;
    });
  }

  Future<void> _toggleFavorite() async {
    final added = await FavoritesService.toggleFavorite(widget.matn);
    if (!mounted) return;

    setState(() {
      _isFav = added;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          added ? 'تمت إضافة المتن إلى المفضلة ❤️' : 'تمت إزالة المتن من المفضلة',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _copyContent() {
    final cleanContent = widget.matn.content.replaceAll('# ', '');
    final textToCopy =
        '${widget.matn.title}\nالمؤلف: ${widget.matn.author}\n\n$cleanContent';
    Clipboard.setData(ClipboardData(text: textToCopy));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ نص المتن إلى الحافظة'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _shareContent() {
    final cleanContent = widget.matn.content.replaceAll('# ', '');
    Share.share(
      '📖 ${widget.matn.title}\nالمؤلف: ${widget.matn.author}\n\n$cleanContent\n\n— من تطبيق زاد الطالب',
    );
  }

  // بناء السطر مع دعم تلوين الشطرين
  Widget _buildLineItem(int index, String line) {
    final trimmed = line.trim();

    if (trimmed.isEmpty) {
      return const SizedBox(height: 12);
    }

    // 1. عنوان الباب أو الفصل
    if (trimmed.startsWith('#')) {
      final headerTitle = trimmed.replaceFirst('#', '').trim();
      return Container(
        key: _chapterKeys[index],
        margin: const EdgeInsets.symmetric(vertical: 18),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          color: _isNightMode
              ? const Color(0xFF38332B)
              : const Color(0xFFF3ECE2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFFD4A574).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          headerTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _fontSize + 2.0,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFD4A574),
            height: 1.8,
          ),
        ),
      );
    }

    // تحديد ألوان الشطرين حسب الوضع الليلي أو النهاري
    final firstPartColor = _isNightMode ? const Color(0xFFE8D5B5) : const Color(0xFF2C2523);
    final secondPartColor = _isNightMode ? const Color(0xFFB3C2B8) : const Color(0xFF4A5859);
    const starColor = Color(0xFFD4A574);

    // 2. فحص ما إذا كان البيت مقسوماً بفاصل (...)
    if (trimmed.contains('...')) {
      final parts = trimmed.split('...');
      final shatr1 = parts[0].trim();
      final shatr2 = parts.length > 1 ? parts[1].trim() : '';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: SelectableText.rich(
          TextSpan(
            children: [
              // الشطر الأول
              TextSpan(
                text: shatr1,
                style: TextStyle(
                  color: firstPartColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // فاصل وسيط أنيق
              const TextSpan(
                text: '   ✦   ',
                style: TextStyle(
                  color: starColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // الشطر الثاني
              TextSpan(
                text: shatr2,
                style: TextStyle(
                  color: secondPartColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _fontSize,
            height: 2.3,
          ),
        ),
      );
    }

    // 3. أسطر النثر أو الأبيات التي لا تحتوي فاصلاً
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SelectableText(
        trimmed,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: _fontSize,
          height: 2.2,
          color: firstPartColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = _isNightMode ? const Color(0xFF1E1E1E) : Colors.white;
    final cardColor = _isNightMode ? const Color(0xFF2C2C2C) : Colors.grey.shade100;
    final primaryTextColor = _isNightMode ? const Color(0xFFEDEDED) : Colors.black87;
    final secondaryTextColor = _isNightMode ? Colors.grey.shade400 : Colors.grey.shade700;

    final lines = widget.matn.content.split('\n');

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.matn.title),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.format_list_bulleted),
            tooltip: 'فهرس الأبواب',
            onPressed: _showChaptersIndex,
          ),
          IconButton(
            icon: Icon(
              _isNightMode ? Icons.light_mode : Icons.dark_mode,
              color: _isNightMode ? Colors.amber : null,
            ),
            tooltip: _isNightMode ? 'الوضع النهاري' : 'الوضع الليلي',
            onPressed: _toggleNightMode,
          ),
          IconButton(
            icon: Icon(
              _isFav ? Icons.favorite : Icons.favorite_border,
              color: _isFav ? Colors.red : null,
            ),
            tooltip: _isFav ? 'إزالة من المفضلة' : 'إضافة إلى المفضلة',
            onPressed: _toggleFavorite,
          ),
          IconButton(
            icon: const Icon(Icons.text_decrease),
            tooltip: 'تصغير الخط',
            onPressed: _decreaseFontSize,
          ),
          IconButton(
            icon: const Icon(Icons.text_increase),
            tooltip: 'تكبير الخط',
            onPressed: _increaseFontSize,
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'نسخ المتن',
            onPressed: _copyContent,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة',
            onPressed: _shareContent,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              color: cardColor,
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'المؤلف: ${widget.matn.author}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primaryTextColor,
                      ),
                    ),
                    if (widget.matn.description.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        widget.matn.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < lines.length; i++)
              _buildLineItem(i, lines[i]),
          ],
        ),
      ),
    );
  }
}

class _ChapterIndexItem {
  final int lineIndex;
  final String title;

  _ChapterIndexItem({
    required this.lineIndex,
    required this.title,
  });
}