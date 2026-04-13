import 'package:flutter/material.dart';

class Character {
  const Character({
    required this.id,
    required this.name,
    required this.role,
    required this.emoji,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final String id;
  final String name;
  final String role;
  final String emoji;
  final Color primaryColor;
  final Color secondaryColor;

  static const Map<String, String> _legacyAliases = {
    'zippy': 'baby',
    'orin': 'owl',
  };

  static const List<Character> characters = [
    Character(
      id: 'lumi',
      name: 'Lumi',
      role: 'Enthusiastic Guide',
      emoji: '💡',
      primaryColor: Color(0xFFF4B942),
      secondaryColor: Color(0xFFFFF8E7),
    ),
    Character(
      id: 'baby',
      name: 'Baby',
      role: 'Gentle Confidence Builder',
      emoji: '🧸',
      primaryColor: Color(0xFFE76F51),
      secondaryColor: Color(0xFFFFF2EC),
    ),
    Character(
      id: 'nexo',
      name: 'Nexo',
      role: 'Logical Analyzer',
      emoji: '⚙️',
      primaryColor: Color(0xFF0E7C86),
      secondaryColor: Color(0xFFE6F4F5),
    ),
    Character(
      id: 'owl',
      name: 'Owl',
      role: 'Wise Listening Coach',
      emoji: '🦉',
      primaryColor: Color(0xFF8B5CF6),
      secondaryColor: Color(0xFFF3EEFF),
    ),
  ];

  static Character byId(String? rawId) {
    final normalizedId = _legacyAliases[rawId] ?? rawId ?? characters.first.id;
    return characters.firstWhere(
      (character) => character.id == normalizedId,
      orElse: () => characters.first,
    );
  }
}