import 'package:flutter/material.dart';

void main() {
  runApp(const SmartTaskApp());
}

class SmartTaskApp extends StatelessWidget {
  const SmartTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // uygulamanın ismi burada mailtask pro olarak geçiyor hocam
      title: 'MailTask Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
      ),
      home: const MainNavigator(),
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _bottomIndex = 0;
  String _currentFolder =
      'Gelen İletiler'; // varsayılan olarak gelen kutusu açılıyor
  String _searchQuery = "";

  final TextEditingController _toController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();

  final List<String> _subjects = [
    'Staj Hakkında',
    'Ders Notları',
    'Proje Ödevi',
    'Toplantı',
    'Genel',
  ];
  String _selectedSubject = 'Staj Hakkında';

  // geçici veri havuzumuz burası hocam verileri burada tutuyorum
  List<Map<String, dynamic>> allMessages = [
    {
      'id': 1,
      'sender': 'Giresun Belediyesi',
      'title': 'Staj Raporu Eksikliği',
      'body':
          'Belediye staj raporunuzun eksik kısımlarını tamamlayıp teslim etmeniz gerekmektedir.',
      'date': '10:30',
      'color': Colors.blue,
      'folder': 'Gelen İletiler',
      'originFolder': 'Gelen İletiler',
      'isTask': true,
      'isDone': false,
    },
    {
      'id': 2,
      'sender': 'Beşiktaş JK',
      'title': 'Maç Günü Hatırlatması',
      'body':
          'Bu akşamki kritik derbi öncesi biletlerini kontrol etmeyi unutma başarılar!',
      'date': '12:05',
      'color': Colors.black,
      'textColor': Colors.white,
      'folder': 'Gelen İletiler',
      'originFolder': 'Gelen İletiler',
      'isTask': true,
      'isDone': false,
    },
  ];

  // görevlerin yapılıp yapılmadığını setstate ile burada güncelliyorum
  void updateTaskStatus(int id, bool status) {
    setState(() {
      final index = allMessages.indexWhere((m) => m['id'] == id);
      if (index != -1) {
        allMessages[index]['isDone'] = status;
        if (status) allMessages[index]['folder'] = 'Arşivlenenler';
      }
    });
    Navigator.pop(context);
  }

  // kaydırma veya butona basınca dosyalar arası taşıma yapan fonksiyon
  void moveMessage(int id, String targetFolder, {bool isUndo = false}) {
    setState(() {
      final index = allMessages.indexWhere((m) => m['id'] == id);
      if (index != -1) {
        if (isUndo) {
          allMessages[index]['folder'] = allMessages[index]['originFolder'];
        } else {
          allMessages[index]['folder'] = targetFolder;
        }
      }
    });
  }

  // hem normal mail hem de görev ataması için bu ortak fonksiyonu kullanıyorum
  void _sendMessage({required bool isGorevAtamasi}) {
    if (_toController.text.isEmpty) return;
    String folderName = isGorevAtamasi ? 'Aktif Görevler' : 'Gönderilenler';
    setState(() {
      allMessages.add({
        'id': DateTime.now().millisecondsSinceEpoch,
        'sender': _toController.text,
        'title': isGorevAtamasi
            ? "[GÖREV] $_selectedSubject"
            : _selectedSubject,
        'body': _bodyController.text,
        'date':
            '${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}',
        'color': isGorevAtamasi ? Colors.orange : Colors.red,
        'folder': folderName,
        'originFolder': folderName,
        'isTask': isGorevAtamasi,
        'isDone': false,
      });
    });
    _toController.clear();
    _bodyController.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // başlıklar sayfa değiştikçe otomatik güncelleniyor hocam
        title: Text(_bottomIndex == 0 ? _currentFolder : "Performans Paneli"),
        bottom: _bottomIndex == 0 ? _buildSearchBar() : null,
      ),
      drawer: _buildDrawer(),
      body: _bottomIndex == 0 ? _buildMailList() : _buildAnalysisPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomIndex,
        onTap: (i) => setState(() => _bottomIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.mail_outline),
            label: 'İletiler',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            label: 'Analiz',
          ),
        ],
      ),
      floatingActionButton: _bottomIndex == 0
          ? FloatingActionButton(
              onPressed: _showComposeSheet,
              backgroundColor: Colors.red,
              child: const Icon(Icons.edit_note, color: Colors.white),
            )
          : null,
    );
  }

  // anlık arama yaptığımız search bar kısmı
  PreferredSize _buildSearchBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: TextField(
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: "sistem içinde ara...",
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
    );
  }

  // mesaj listesi ve dismissible ile yana kaydırma özelliği burada hocam
  Widget _buildMailList() {
    final filtered = allMessages.where((m) {
      bool folderMatch = m['folder'] == _currentFolder;
      bool searchMatch =
          m['sender'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          m['title'].toLowerCase().contains(_searchQuery.toLowerCase());
      return folderMatch && searchMatch;
    }).toList();

    return ListView.separated(
      itemCount: filtered.length,
      separatorBuilder: (context, index) =>
          const Divider(color: Colors.black, height: 1, thickness: 0.1),
      itemBuilder: (c, i) {
        final msg = filtered[i];
        return Dismissible(
          key: Key(msg['id'].toString()),
          background: Container(
            color: Colors.green.shade400,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Icon(Icons.archive_outlined, color: Colors.white),
          ),
          secondaryBackground: Container(
            color: Colors.red.shade400,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete_sweep_outlined, color: Colors.white),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              moveMessage(msg['id'], 'Arşivlenenler');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("ileti başarıyla arşivlendi.")),
              );
            } else {
              moveMessage(msg['id'], 'Silinen Ögeler');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("ileti silinenlere taşındı.")),
              );
            }
          },
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: msg['color'],
              child: Text(
                msg['sender'][0],
                style: TextStyle(color: msg['textColor'] ?? Colors.white),
              ),
            ),
            title: Text(
              msg['sender'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              msg['title'],
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _showDetailDialog(msg),
          ),
        );
      },
    );
  }

  // bir iletiye basınca açılan detay penceresi
  void _showDetailDialog(Map<String, dynamic> msg) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        height: 350,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg['sender'],
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            Text(
              msg['title'],
              style: const TextStyle(fontSize: 17, color: Colors.red),
            ),
            const SizedBox(height: 10),
            Text(msg['body'] ?? ""),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    moveMessage(
                      msg['id'],
                      'Arşivlenenler',
                      isUndo: msg['folder'] == 'Arşivlenenler',
                    );
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    msg['folder'] == 'Arşivlenenler'
                        ? Icons.undo
                        : Icons.archive,
                  ),
                  label: Text(
                    msg['folder'] == 'Arşivlenenler' ? "Geri Al" : "Arşivle",
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    moveMessage(
                      msg['id'],
                      'Silinen Ögeler',
                      isUndo: msg['folder'] == 'Silinen Ögeler',
                    );
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    msg['folder'] == 'Silinen Ögeler'
                        ? Icons.undo
                        : Icons.delete_forever,
                  ),
                  label: Text(
                    msg['folder'] == 'Silinen Ögeler' ? "Geri Al" : "Kaldır",
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // görevli iletilerde onay veya erteleme yaptığımız yer
  void _showTaskActionDialog(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(25),
        height: 250,
        child: Column(
          children: [
            Text(
              task['title'],
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => updateTaskStatus(task['id'], true),
                  child: const Text("Süreci Onayla"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => updateTaskStatus(task['id'], false),
                  child: const Text("İşlemi Ertele"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // yeni ileti veya görev oluşturma sayfası
  void _showComposeSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            top: 20,
            left: 20,
            right: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _toController,
                decoration: const InputDecoration(labelText: "Hedef Adres"),
              ),
              const SizedBox(height: 15),
              const Text(
                "kategori seçimi",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedSubject,
                items: _subjects
                    .map(
                      (String val) =>
                          DropdownMenuItem(value: val, child: Text(val)),
                    )
                    .toList(),
                onChanged: (newVal) =>
                    setModalState(() => _selectedSubject = newVal!),
              ),
              TextField(
                controller: _bodyController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: "İçerik Detayı"),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _sendMessage(isGorevAtamasi: false),
                    child: const Text("İletiyi Gönder"),
                  ),
                  ElevatedButton(
                    onPressed: () => _sendMessage(isGorevAtamasi: true),
                    child: const Text("Görev Tanımla"),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // yan taraftan açılan çekmece menüsü
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          const UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Colors.red),
            accountName: Text("Emirhan Kaplan"),
            accountEmail: Text("g952906@gmail.com"),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text("EK"),
            ),
          ),
          _drawerTile(Icons.mark_email_unread_outlined, "Gelen İletiler"),
          _drawerTile(Icons.task_alt_outlined, "Arşivlenenler"),
          _drawerTile(Icons.outbox_outlined, "Gönderilenler"),
          _drawerTile(Icons.assignment_turned_in_outlined, "Aktif Görevler"),
          _drawerTile(Icons.auto_delete_outlined, "Silinen Ögeler"),
        ],
      ),
    );
  }

  Widget _drawerTile(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: _currentFolder == title,
      onTap: () {
        setState(() {
          _currentFolder = title;
          _bottomIndex = 0;
        });
        Navigator.pop(context);
      },
    );
  }

  // hocanın istediği performans ve analiz sayfası burada hesaplanıyor hocam
  Widget _buildAnalysisPage() {
    final tasks = allMessages
        .where(
          (m) =>
              m['isTask'] == true &&
              m['folder'] != 'Aktif Görevler' &&
              m['originFolder'] != 'Aktif Görevler',
        )
        .toList();

    int completedCount = tasks.where((t) => t['isDone'] == true).length;
    double progress = tasks.isEmpty ? 0 : completedCount / tasks.length;
    int percent = (progress * 100).toInt();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              CircularProgressIndicator(
                value: progress,
                color: Colors.red,
                strokeWidth: 8,
              ),
              const SizedBox(width: 25),
              Text(
                "Genel Verimlilik Skoru: %$percent",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "operasyonel takip listesi",
            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ),
        Expanded(
          child: tasks.isEmpty
              ? const Center(child: Text("analiz edilecek veri bulunamadı."))
              : ListView.separated(
                  itemCount: tasks.length,
                  separatorBuilder: (context, index) => const Divider(
                    color: Colors.black,
                    height: 1,
                    thickness: 0.1,
                  ),
                  itemBuilder: (context, index) {
                    final t = tasks[index];
                    return ListTile(
                      leading: Icon(
                        t['isDone']
                            ? Icons.verified_user
                            : Icons.hourglass_empty,
                        color: t['isDone'] ? Colors.green : Colors.orange,
                      ),
                      title: Text(t['title']),
                      subtitle: Text(
                        "Durum: ${t['isDone'] ? 'Onaylandı' : 'İşlem Bekliyor'}",
                      ),
                      onTap: () => _showTaskActionDialog(t),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
