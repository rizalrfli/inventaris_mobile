import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SavingIconHelper {
  static const Map<String, IconData> _iconMap = {
    'home': LucideIcons.home,
    'shoe': LucideIcons.footprints,
    'smartphone': LucideIcons.smartphone,
    'electronics': LucideIcons.monitor,
    'bike': LucideIcons.bike,
    'car': LucideIcons.car,
    'mountain': LucideIcons.mountain,
    'vacation': LucideIcons.plane,
    'more': LucideIcons.moreHorizontal,
  };

  static final List<Map<String, dynamic>> iconList = [
    {'id': 'home', 'icon': LucideIcons.home, 'label': 'Rumah'},
    {'id': 'shoe', 'icon': LucideIcons.footprints, 'label': 'Sepatu'},
    {'id': 'smartphone', 'icon': LucideIcons.smartphone, 'label': 'HP'},
    {'id': 'electronics', 'icon': LucideIcons.monitor, 'label': 'Elektronik'},
    {'id': 'bike', 'icon': LucideIcons.bike, 'label': 'Sepeda'},
    {'id': 'car', 'icon': LucideIcons.car, 'label': 'Mobil'},
    {'id': 'mountain', 'icon': LucideIcons.mountain, 'label': 'Gunung'},
    {'id': 'vacation', 'icon': LucideIcons.plane, 'label': 'Liburan'},
    {'id': 'more', 'icon': LucideIcons.moreHorizontal, 'label': 'Lainnya'},
  ];

  static IconData getIcon(String id) {
    return _iconMap[id] ?? LucideIcons.target;
  }
}
