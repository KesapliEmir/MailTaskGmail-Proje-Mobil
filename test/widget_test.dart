import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// buradaki myapp kısmı pubspec.yaml ile aynı olmalı hocam
// yoksa vs code hata veriyor o yüzden burayı düzelttim.
import 'package:myapp/main.dart';

void main() {
  // hocam burada uygulamamızın genel akışını ve
  // sayfalar arası veri geçişlerini kontrol ediyoruz.
  testWidgets('mailtask pro genel arayüz ve geçiş testleri', (
    WidgetTester tester,
  ) async {
    // uygulamayı sanal olarak başlatıyoruz
    await tester.pumpWidget(const SmartTaskApp());

    // --- 1. test: ana liste ve veri kontrolü ---
    // açılışta giresun belediyesi mesajı ekrana geliyor mu diye bakıyoruz
    expect(find.text('Giresun Belediyesi'), findsAtLeastNWidgets(1));

    // beşiktaş jk verisinin de listede olup olmadığını teyit ediyoruz hocam
    expect(find.text('Beşiktaş JK'), findsAtLeastNWidgets(1));

    // --- 2. test: menü geçiş kontrolü ---
    // alt taraftaki analiz (performans paneli) butonuna basıyoruz
    await tester.tap(find.byIcon(Icons.analytics_outlined));

    // sayfa değişirken animasyonların bitmesini bekliyoruz
    await tester.pumpAndSettle();

    // --- 3. test: panel doğrulama ---
    // performans paneline geçtiğimizde "performans" ve "skor"
    // kelimelerini görüyorsak sayfa başarıyla yüklenmiş demektir.
    expect(find.textContaining('Performans'), findsOneWidget);
    expect(find.textContaining('Skor'), findsOneWidget);

    // buraya kadar sorun çıkmadıysa mimari sağlam çalışıyor demektir hocam.
  });
}
