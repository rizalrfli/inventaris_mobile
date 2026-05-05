import 'package:dio/dio.dart';

class AiService {
  final Dio _dio = Dio();
  
  // TODO: Replace with real Gemini / OpenAI API Key from secure storage / dotenv
  final String _apiKey = 'AIzaSyByiGKXb3JDkQnFaH-3apRBGf2vxkyPsIc';

  Future<String> getChatbotResponse(String message, String contextData) async {
    // If there is no real API key, return a mock response based on keywords
    if (_apiKey == 'YOUR_API_KEY_HERE' || _apiKey.isEmpty) {
      await Future.delayed(const Duration(seconds: 1)); // simulate network delay
      return _generateMockResponse(message.toLowerCase());
    }

    try {
      // Example using Gemini API (Generative Language API)
      final response = await _dio.post(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$_apiKey',
        data: {
          "contents": [
            {
              "parts": [
                {
                  "text": "Anda adalah Antigravity, asisten keuangan pribadi yang ramah dan pintar. "
                          "Berikut adalah data transaksi user bulan ini: $contextData. "
                          "Pertanyaan user: $message"
                }
              ]
            }
          ]
        },
      );

      if (response.statusCode == 200) {
        final content = response.data['candidates'][0]['content']['parts'][0]['text'];
        return content.toString();
      } else {
        return "Maaf, saya sedang mengalami gangguan server. Silakan coba lagi nanti.";
      }
    } catch (e) {
      if (e is DioException) {
        return "Terjadi kesalahan jaringan/API: ${e.response?.statusCode} - ${e.response?.data['error']['message'] ?? e.message}";
      }
      return "Terjadi kesalahan: $e";
    }
  }

  String _generateMockResponse(String msg) {
    if (msg.contains('pengeluaran') && msg.contains('minggu')) {
      return 'Berdasarkan data Anda, pengeluaran minggu ini sebesar Rp 450.000. Sebagian besar untuk kategori Makanan.';
    } else if (msg.contains('kategori') && msg.contains('banyak')) {
      return 'Kategori pengeluaran terbesar Anda bulan ini adalah "Hiburan" (40% dari total pengeluaran). Hati-hati ya!';
    } else if (msg.contains('budget') || msg.contains('sisa')) {
      return 'Anda masih memiliki sisa budget yang cukup aman. Pengeluaran Anda baru mencapai 30% dari total pemasukan bulan ini.';
    } else if (msg.contains('saran') || msg.contains('hemat')) {
      return 'Saya sarankan kurangi frekuensi jajan di luar. Anda bisa menghemat hingga Rp 500.000 jika membawa bekal makan siang!';
    } else {
      return 'Halo! Saya Antigravity. Ada yang bisa saya bantu terkait laporan keuangan atau tips hemat hari ini?';
    }
  }
}
