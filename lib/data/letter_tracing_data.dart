import 'package:flutter/material.dart';

class LetterData {
  final String letter;
  final String sound;
  final String example;
  final Color color;
  final int difficulty;
  final List<Offset> points;

  const LetterData({
    required this.letter,
    required this.sound,
    required this.example,
    required this.color,
    required this.difficulty,
    required this.points,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  UPPERCASE LETTERS (A–Z)
// ─────────────────────────────────────────────────────────────────────────────

const List<LetterData> uppercaseLetters = [
  LetterData(
      letter: 'A',
      sound: 'ay',
      example: 'Apple',
      color: Colors.red,
      difficulty: 2,
      points: [
        Offset(150, 60),
        Offset(145, 75),
        Offset(140, 90),
        Offset(135, 105),
        Offset(130, 120),
        Offset(125, 135),
        Offset(120, 150),
        Offset(115, 165),
        Offset(110, 180),
        Offset(120, 160),
        Offset(130, 140),
        Offset(140, 120),
        Offset(145, 105),
        Offset(150, 90),
        Offset(150, 60),
        Offset(155, 75),
        Offset(160, 90),
        Offset(165, 105),
        Offset(170, 120),
        Offset(175, 135),
        Offset(180, 150),
        Offset(185, 165),
        Offset(190, 180),
        Offset(175, 155),
        Offset(165, 140),
        Offset(155, 130),
        Offset(145, 125),
        Offset(155, 125),
        Offset(165, 125)
      ]),
  LetterData(
      letter: 'B',
      sound: 'bee',
      example: 'Ball',
      color: Colors.blue,
      difficulty: 3,
      points: [
        Offset(120, 60),
        Offset(120, 75),
        Offset(120, 90),
        Offset(120, 105),
        Offset(120, 120),
        Offset(120, 135),
        Offset(120, 150),
        Offset(120, 165),
        Offset(120, 180),
        Offset(120, 165),
        Offset(120, 150),
        Offset(120, 135),
        Offset(120, 120),
        Offset(120, 105),
        Offset(120, 90),
        Offset(120, 75),
        Offset(120, 60),
        Offset(135, 60),
        Offset(150, 62),
        Offset(162, 68),
        Offset(170, 78),
        Offset(172, 88),
        Offset(170, 98),
        Offset(164, 106),
        Offset(154, 112),
        Offset(142, 116),
        Offset(130, 118),
        Offset(142, 120),
        Offset(154, 124),
        Offset(164, 132),
        Offset(172, 142),
        Offset(175, 154),
        Offset(172, 164),
        Offset(164, 172),
        Offset(152, 178),
        Offset(138, 180),
        Offset(120, 180)
      ]),
  LetterData(
      letter: 'C',
      sound: 'see',
      example: 'Cat',
      color: Colors.green,
      difficulty: 2,
      points: [
        Offset(160, 70),
        Offset(150, 65),
        Offset(140, 62),
        Offset(130, 60),
        Offset(122, 64),
        Offset(116, 72),
        Offset(114, 82),
        Offset(113, 94),
        Offset(113, 106),
        Offset(114, 118),
        Offset(116, 128),
        Offset(122, 136),
        Offset(130, 142),
        Offset(140, 146),
        Offset(150, 148),
        Offset(160, 150)
      ]),
  LetterData(
      letter: 'D',
      sound: 'dee',
      example: 'Dog',
      color: Colors.orange,
      difficulty: 3,
      points: [
        Offset(120, 60),
        Offset(120, 75),
        Offset(120, 90),
        Offset(120, 105),
        Offset(120, 120),
        Offset(120, 135),
        Offset(120, 150),
        Offset(120, 165),
        Offset(120, 180),
        Offset(120, 165),
        Offset(120, 150),
        Offset(120, 135),
        Offset(120, 120),
        Offset(120, 105),
        Offset(120, 90),
        Offset(120, 75),
        Offset(120, 60),
        Offset(135, 62),
        Offset(150, 68),
        Offset(160, 80),
        Offset(167, 95),
        Offset(170, 112),
        Offset(170, 128),
        Offset(167, 145),
        Offset(160, 158),
        Offset(150, 170),
        Offset(135, 176),
        Offset(120, 180)
      ]),
  LetterData(
      letter: 'E',
      sound: 'ee',
      example: 'Elephant',
      color: Colors.purple,
      difficulty: 2,
      points: [
        Offset(160, 60),
        Offset(148, 60),
        Offset(136, 60),
        Offset(124, 60),
        Offset(120, 72),
        Offset(120, 84),
        Offset(120, 96),
        Offset(120, 108),
        Offset(120, 120),
        Offset(132, 120),
        Offset(144, 120),
        Offset(120, 120),
        Offset(120, 132),
        Offset(120, 144),
        Offset(120, 156),
        Offset(120, 168),
        Offset(120, 180),
        Offset(132, 180),
        Offset(144, 180),
        Offset(156, 180),
        Offset(160, 180)
      ]),
  LetterData(
      letter: 'F',
      sound: 'ef',
      example: 'Fish',
      color: Colors.pink,
      difficulty: 2,
      points: [
        Offset(120, 60),
        Offset(120, 180),
        Offset(120, 60),
        Offset(160, 60),
        Offset(120, 120),
        Offset(150, 120)
      ]),
  LetterData(
      letter: 'G',
      sound: 'jee',
      example: 'Goat',
      color: Colors.teal,
      difficulty: 3,
      points: [
        Offset(160, 70),
        Offset(130, 60),
        Offset(115, 80),
        Offset(115, 120),
        Offset(130, 150),
        Offset(160, 160),
        Offset(175, 140),
        Offset(175, 110),
        Offset(150, 110)
      ]),
  LetterData(
      letter: 'H',
      sound: 'aych',
      example: 'Hat',
      color: Colors.brown,
      difficulty: 2,
      points: [
        Offset(120, 60),
        Offset(120, 180),
        Offset(170, 60),
        Offset(170, 180),
        Offset(120, 120),
        Offset(170, 120)
      ]),
  LetterData(
      letter: 'I',
      sound: 'eye',
      example: 'Igloo',
      color: Colors.indigo,
      difficulty: 1,
      points: [
        Offset(120, 60),
        Offset(170, 60),
        Offset(145, 60),
        Offset(145, 180),
        Offset(120, 180),
        Offset(170, 180)
      ]),
  LetterData(
      letter: 'J',
      sound: 'jay',
      example: 'Jet',
      color: Colors.cyan,
      difficulty: 2,
      points: [
        Offset(120, 60),
        Offset(170, 60),
        Offset(160, 60),
        Offset(160, 155),
        Offset(148, 172),
        Offset(128, 162)
      ]),
  LetterData(
      letter: 'K',
      sound: 'kay',
      example: 'Kite',
      color: Colors.lime,
      difficulty: 3,
      points: [
        Offset(120, 60),
        Offset(120, 180),
        Offset(120, 120),
        Offset(155, 60),
        Offset(120, 120),
        Offset(155, 180)
      ]),
  LetterData(
      letter: 'L',
      sound: 'el',
      example: 'Lion',
      color: Colors.amber,
      difficulty: 1,
      points: [Offset(120, 60), Offset(120, 180), Offset(160, 180)]),
  LetterData(
      letter: 'M',
      sound: 'em',
      example: 'Monkey',
      color: Colors.deepPurple,
      difficulty: 3,
      points: [
        Offset(110, 180),
        Offset(110, 60),
        Offset(145, 120),
        Offset(180, 60),
        Offset(180, 180)
      ]),
  LetterData(
      letter: 'N',
      sound: 'en',
      example: 'Nest',
      color: Colors.deepOrange,
      difficulty: 2,
      points: [
        Offset(120, 180),
        Offset(120, 60),
        Offset(170, 180),
        Offset(170, 60)
      ]),
  LetterData(
      letter: 'O',
      sound: 'oh',
      example: 'Orange',
      color: Colors.lightBlue,
      difficulty: 2,
      points: [
        Offset(150, 60),
        Offset(125, 75),
        Offset(115, 100),
        Offset(115, 140),
        Offset(125, 165),
        Offset(150, 180),
        Offset(175, 165),
        Offset(185, 140),
        Offset(185, 100),
        Offset(175, 75),
        Offset(150, 60)
      ]),
  LetterData(
      letter: 'P',
      sound: 'pee',
      example: 'Pig',
      color: Colors.lightGreen,
      difficulty: 2,
      points: [
        Offset(120, 60),
        Offset(120, 180),
        Offset(120, 60),
        Offset(155, 70),
        Offset(165, 90),
        Offset(155, 110),
        Offset(120, 110)
      ]),
  LetterData(
      letter: 'Q',
      sound: 'cue',
      example: 'Queen',
      color: Colors.pinkAccent,
      difficulty: 3,
      points: [
        Offset(150, 60),
        Offset(125, 75),
        Offset(115, 100),
        Offset(115, 140),
        Offset(125, 165),
        Offset(150, 180),
        Offset(175, 165),
        Offset(185, 140),
        Offset(185, 100),
        Offset(175, 75),
        Offset(150, 60),
        Offset(155, 155),
        Offset(175, 180)
      ]),
  LetterData(
      letter: 'R',
      sound: 'ar',
      example: 'Rabbit',
      color: Colors.purpleAccent,
      difficulty: 3,
      points: [
        Offset(120, 60),
        Offset(120, 180),
        Offset(120, 60),
        Offset(155, 70),
        Offset(165, 90),
        Offset(155, 110),
        Offset(120, 110),
        Offset(145, 110),
        Offset(170, 180)
      ]),
  LetterData(
      letter: 'S',
      sound: 'ess',
      example: 'Sun',
      color: Colors.teal,
      difficulty: 3,
      points: [
        Offset(165, 65),
        Offset(140, 60),
        Offset(120, 75),
        Offset(120, 100),
        Offset(145, 115),
        Offset(170, 130),
        Offset(170, 155),
        Offset(148, 170),
        Offset(120, 165)
      ]),
  LetterData(
      letter: 'T',
      sound: 'tee',
      example: 'Tree',
      color: Colors.cyan,
      difficulty: 1,
      points: [
        Offset(120, 60),
        Offset(170, 60),
        Offset(145, 60),
        Offset(145, 180)
      ]),
  LetterData(
      letter: 'U',
      sound: 'you',
      example: 'Umbrella',
      color: Colors.amber,
      difficulty: 2,
      points: [
        Offset(120, 60),
        Offset(120, 145),
        Offset(133, 165),
        Offset(150, 172),
        Offset(167, 165),
        Offset(180, 145),
        Offset(180, 60)
      ]),
  LetterData(
      letter: 'V',
      sound: 'vee',
      example: 'Violin',
      color: Colors.lightBlue,
      difficulty: 1,
      points: [Offset(120, 60), Offset(150, 180), Offset(180, 60)]),
  LetterData(
      letter: 'W',
      sound: 'double-you',
      example: 'Whale',
      color: Colors.lightGreen,
      difficulty: 3,
      points: [
        Offset(110, 60),
        Offset(130, 180),
        Offset(150, 110),
        Offset(170, 180),
        Offset(190, 60)
      ]),
  LetterData(
      letter: 'X',
      sound: 'ex',
      example: 'X-ray',
      color: Colors.red,
      difficulty: 2,
      points: [
        Offset(120, 60),
        Offset(180, 180),
        Offset(180, 60),
        Offset(120, 180)
      ]),
  LetterData(
      letter: 'Y',
      sound: 'why',
      example: 'Yarn',
      color: Colors.blue,
      difficulty: 2,
      points: [
        Offset(120, 60),
        Offset(150, 120),
        Offset(180, 60),
        Offset(150, 120),
        Offset(150, 180)
      ]),
  LetterData(
      letter: 'Z',
      sound: 'zee',
      example: 'Zebra',
      color: Colors.green,
      difficulty: 2,
      points: [
        Offset(120, 60),
        Offset(180, 60),
        Offset(120, 180),
        Offset(180, 180)
      ]),
];

// ─────────────────────────────────────────────────────────────────────────────
//  LOWERCASE LETTERS (a–z)
// ─────────────────────────────────────────────────────────────────────────────

const List<LetterData> lowercaseLetters = [
  LetterData(
      letter: 'a',
      sound: 'ay',
      example: 'apple',
      color: Colors.red,
      difficulty: 2,
      points: [
        Offset(170, 100),
        Offset(164, 90),
        Offset(156, 84),
        Offset(148, 80),
        Offset(138, 82),
        Offset(130, 88),
        Offset(125, 98),
        Offset(122, 110),
        Offset(122, 122),
        Offset(125, 135),
        Offset(132, 144),
        Offset(140, 148),
        Offset(148, 148),
        Offset(156, 146),
        Offset(164, 142),
        Offset(170, 140),
        Offset(170, 148),
        Offset(170, 156),
        Offset(170, 160),
        Offset(162, 166),
        Offset(154, 170),
        Offset(148, 170),
        Offset(138, 168),
        Offset(130, 162)
      ]),
  LetterData(
      letter: 'b',
      sound: 'bee',
      example: 'ball',
      color: Colors.blue,
      difficulty: 3,
      points: [
        Offset(120, 60),
        Offset(120, 75),
        Offset(120, 90),
        Offset(120, 105),
        Offset(120, 120),
        Offset(120, 135),
        Offset(120, 150),
        Offset(120, 165),
        Offset(120, 180),
        Offset(120, 165),
        Offset(120, 150),
        Offset(120, 135),
        Offset(120, 120),
        Offset(120, 108),
        Offset(126, 96),
        Offset(134, 88),
        Offset(145, 82),
        Offset(156, 84),
        Offset(165, 90),
        Offset(170, 100),
        Offset(172, 112),
        Offset(170, 124),
        Offset(164, 135),
        Offset(154, 144),
        Offset(142, 148),
        Offset(130, 145),
        Offset(120, 140)
      ]),
  LetterData(
      letter: 'c',
      sound: 'see',
      example: 'cat',
      color: Colors.green,
      difficulty: 1,
      points: [
        Offset(165, 82),
        Offset(156, 78),
        Offset(148, 76),
        Offset(140, 75),
        Offset(132, 78),
        Offset(126, 84),
        Offset(122, 94),
        Offset(120, 106),
        Offset(120, 118),
        Offset(122, 130),
        Offset(126, 140),
        Offset(132, 148),
        Offset(140, 154),
        Offset(148, 156),
        Offset(156, 158),
        Offset(165, 158)
      ]),
  LetterData(
      letter: 'd',
      sound: 'dee',
      example: 'dog',
      color: Colors.orange,
      difficulty: 3,
      points: [
        Offset(170, 60),
        Offset(170, 75),
        Offset(170, 90),
        Offset(170, 105),
        Offset(170, 120),
        Offset(170, 135),
        Offset(170, 150),
        Offset(170, 165),
        Offset(170, 180),
        Offset(170, 165),
        Offset(170, 150),
        Offset(170, 135),
        Offset(170, 120),
        Offset(170, 108),
        Offset(164, 96),
        Offset(156, 88),
        Offset(145, 82),
        Offset(134, 84),
        Offset(125, 90),
        Offset(120, 100),
        Offset(118, 112),
        Offset(118, 124),
        Offset(122, 136),
        Offset(130, 144),
        Offset(140, 148),
        Offset(150, 145),
        Offset(160, 142),
        Offset(170, 140)
      ]),
  LetterData(
      letter: 'e',
      sound: 'ee',
      example: 'elephant',
      color: Colors.purple,
      difficulty: 2,
      points: [
        Offset(120, 115),
        Offset(130, 115),
        Offset(140, 115),
        Offset(150, 115),
        Offset(160, 115),
        Offset(168, 112),
        Offset(172, 105),
        Offset(170, 95),
        Offset(164, 86),
        Offset(155, 79),
        Offset(144, 75),
        Offset(134, 76),
        Offset(126, 82),
        Offset(120, 92),
        Offset(118, 104),
        Offset(118, 116),
        Offset(120, 128),
        Offset(124, 138),
        Offset(132, 148),
        Offset(142, 154),
        Offset(154, 158),
        Offset(165, 158)
      ]),
  LetterData(
      letter: 'f',
      sound: 'ef',
      example: 'fish',
      color: Colors.pink,
      difficulty: 2,
      points: [
        Offset(165, 68),
        Offset(148, 60),
        Offset(138, 75),
        Offset(138, 180),
        Offset(122, 95),
        Offset(158, 95)
      ]),
  LetterData(
      letter: 'g',
      sound: 'jee',
      example: 'goat',
      color: Colors.teal,
      difficulty: 3,
      points: [
        Offset(170, 82),
        Offset(148, 72),
        Offset(125, 82),
        Offset(118, 105),
        Offset(125, 132),
        Offset(148, 145),
        Offset(170, 138),
        Offset(170, 185),
        Offset(155, 205),
        Offset(128, 202)
      ]),
  LetterData(
      letter: 'h',
      sound: 'aych',
      example: 'hat',
      color: Colors.brown,
      difficulty: 2,
      points: [
        Offset(120, 60),
        Offset(120, 180),
        Offset(120, 108),
        Offset(142, 85),
        Offset(162, 85),
        Offset(172, 100),
        Offset(172, 180)
      ]),
  LetterData(
      letter: 'i',
      sound: 'eye',
      example: 'igloo',
      color: Colors.indigo,
      difficulty: 1,
      points: [
        Offset(148, 85),
        Offset(148, 175),
        Offset(142, 50),
        Offset(148, 42),
        Offset(155, 50)
      ]),
  LetterData(
      letter: 'j',
      sound: 'jay',
      example: 'jet',
      color: Colors.cyan,
      difficulty: 2,
      points: [
        Offset(162, 85),
        Offset(162, 175),
        Offset(148, 195),
        Offset(132, 185),
        Offset(155, 50),
        Offset(162, 42),
        Offset(170, 50)
      ]),
  LetterData(
      letter: 'k',
      sound: 'kay',
      example: 'kite',
      color: Colors.lime,
      difficulty: 3,
      points: [
        Offset(120, 60),
        Offset(120, 180),
        Offset(120, 122),
        Offset(145, 100),
        Offset(168, 80),
        Offset(120, 122),
        Offset(145, 145),
        Offset(168, 168)
      ]),
  LetterData(
      letter: 'l',
      sound: 'el',
      example: 'lion',
      color: Colors.amber,
      difficulty: 1,
      points: [Offset(148, 60), Offset(148, 170), Offset(140, 182)]),
  LetterData(
      letter: 'm',
      sound: 'em',
      example: 'monkey',
      color: Colors.deepPurple,
      difficulty: 3,
      points: [
        Offset(112, 82),
        Offset(112, 180),
        Offset(112, 105),
        Offset(130, 85),
        Offset(152, 85),
        Offset(162, 100),
        Offset(162, 180),
        Offset(162, 105),
        Offset(180, 85),
        Offset(200, 85),
        Offset(210, 100),
        Offset(210, 180)
      ]),
  LetterData(
      letter: 'n',
      sound: 'en',
      example: 'nest',
      color: Colors.deepOrange,
      difficulty: 2,
      points: [
        Offset(120, 82),
        Offset(120, 180),
        Offset(120, 108),
        Offset(142, 85),
        Offset(162, 85),
        Offset(172, 100),
        Offset(172, 180)
      ]),
  LetterData(
      letter: 'o',
      sound: 'oh',
      example: 'orange',
      color: Colors.lightBlue,
      difficulty: 2,
      points: [
        Offset(148, 78),
        Offset(125, 88),
        Offset(115, 112),
        Offset(118, 140),
        Offset(135, 158),
        Offset(158, 162),
        Offset(178, 150),
        Offset(185, 128),
        Offset(182, 102),
        Offset(165, 82),
        Offset(148, 78)
      ]),
  LetterData(
      letter: 'p',
      sound: 'pee',
      example: 'pig',
      color: Colors.lightGreen,
      difficulty: 3,
      points: [
        Offset(120, 82),
        Offset(120, 215),
        Offset(120, 108),
        Offset(145, 85),
        Offset(168, 92),
        Offset(175, 115),
        Offset(165, 138),
        Offset(142, 148),
        Offset(120, 140)
      ]),
  LetterData(
      letter: 'q',
      sound: 'cue',
      example: 'queen',
      color: Colors.pinkAccent,
      difficulty: 3,
      points: [
        Offset(172, 82),
        Offset(172, 215),
        Offset(172, 108),
        Offset(148, 85),
        Offset(125, 92),
        Offset(118, 115),
        Offset(128, 138),
        Offset(150, 148),
        Offset(172, 140)
      ]),
  LetterData(
      letter: 'r',
      sound: 'ar',
      example: 'rabbit',
      color: Colors.purpleAccent,
      difficulty: 1,
      points: [
        Offset(120, 82),
        Offset(120, 180),
        Offset(120, 108),
        Offset(142, 85),
        Offset(165, 85)
      ]),
  LetterData(
      letter: 's',
      sound: 'ess',
      example: 'sun',
      color: Colors.teal,
      difficulty: 2,
      points: [
        Offset(165, 85),
        Offset(138, 80),
        Offset(120, 95),
        Offset(125, 118),
        Offset(148, 128),
        Offset(168, 140),
        Offset(165, 162),
        Offset(140, 170),
        Offset(118, 162)
      ]),
  LetterData(
      letter: 't',
      sound: 'tee',
      example: 'tree',
      color: Colors.cyan,
      difficulty: 2,
      points: [
        Offset(148, 60),
        Offset(148, 175),
        Offset(138, 185),
        Offset(128, 95),
        Offset(172, 95)
      ]),
  LetterData(
      letter: 'u',
      sound: 'you',
      example: 'umbrella',
      color: Colors.amber,
      difficulty: 2,
      points: [
        Offset(120, 82),
        Offset(120, 148),
        Offset(132, 168),
        Offset(150, 175),
        Offset(168, 168),
        Offset(178, 148),
        Offset(178, 82),
        Offset(178, 180)
      ]),
  LetterData(
      letter: 'v',
      sound: 'vee',
      example: 'violin',
      color: Colors.lightBlue,
      difficulty: 1,
      points: [Offset(120, 82), Offset(150, 175), Offset(180, 82)]),
  LetterData(
      letter: 'w',
      sound: 'double-you',
      example: 'whale',
      color: Colors.lightGreen,
      difficulty: 2,
      points: [
        Offset(112, 82),
        Offset(130, 175),
        Offset(150, 115),
        Offset(170, 175),
        Offset(190, 82)
      ]),
  LetterData(
      letter: 'x',
      sound: 'ex',
      example: 'x-ray',
      color: Colors.red,
      difficulty: 2,
      points: [
        Offset(120, 82),
        Offset(180, 175),
        Offset(180, 82),
        Offset(120, 175)
      ]),
  LetterData(
      letter: 'y',
      sound: 'why',
      example: 'yarn',
      color: Colors.blue,
      difficulty: 3,
      points: [
        Offset(120, 82),
        Offset(150, 145),
        Offset(180, 82),
        Offset(150, 145),
        Offset(138, 180),
        Offset(125, 205)
      ]),
  LetterData(
      letter: 'z',
      sound: 'zee',
      example: 'zebra',
      color: Colors.green,
      difficulty: 2,
      points: [
        Offset(120, 82),
        Offset(180, 82),
        Offset(120, 175),
        Offset(180, 175)
      ]),
];

// ─────────────────────────────────────────────────────────────────────────────
//  NUMBERS (1–10)
// ─────────────────────────────────────────────────────────────────────────────

const List<LetterData> numberLetters = [
  LetterData(
      letter: '1',
      sound: 'one',
      example: 'One',
      color: Colors.red,
      difficulty: 1,
      points: [
        Offset(130, 80),
        Offset(135, 75),
        Offset(140, 70),
        Offset(145, 65),
        Offset(150, 60),
        Offset(150, 75),
        Offset(150, 90),
        Offset(150, 105),
        Offset(150, 120),
        Offset(150, 135),
        Offset(150, 150),
        Offset(150, 165),
        Offset(150, 180)
      ]),
  LetterData(
      letter: '2',
      sound: 'two',
      example: 'Two',
      color: Colors.blue,
      difficulty: 2,
      points: [
        Offset(122, 75),
        Offset(130, 68),
        Offset(138, 64),
        Offset(148, 62),
        Offset(158, 64),
        Offset(166, 68),
        Offset(172, 75),
        Offset(174, 84),
        Offset(175, 92),
        Offset(172, 102),
        Offset(165, 112),
        Offset(155, 122),
        Offset(145, 132),
        Offset(135, 142),
        Offset(128, 148),
        Offset(122, 155),
        Offset(122, 165),
        Offset(122, 178),
        Offset(135, 178),
        Offset(150, 178),
        Offset(165, 178),
        Offset(178, 178)
      ]),
  LetterData(
      letter: '3',
      sound: 'three',
      example: 'Three',
      color: Colors.green,
      difficulty: 2,
      points: [
        Offset(122, 65),
        Offset(135, 62),
        Offset(148, 62),
        Offset(162, 64),
        Offset(172, 72),
        Offset(175, 84),
        Offset(174, 95),
        Offset(166, 104),
        Offset(154, 112),
        Offset(142, 116),
        Offset(154, 120),
        Offset(166, 126),
        Offset(174, 136),
        Offset(176, 150),
        Offset(172, 162),
        Offset(162, 170),
        Offset(148, 172),
        Offset(135, 172),
        Offset(122, 172)
      ]),
  LetterData(
      letter: '4',
      sound: 'four',
      example: 'Four',
      color: Colors.orange,
      difficulty: 2,
      points: [
        Offset(162, 60),
        Offset(158, 72),
        Offset(152, 86),
        Offset(146, 100),
        Offset(140, 112),
        Offset(134, 122),
        Offset(128, 128),
        Offset(138, 128),
        Offset(148, 128),
        Offset(158, 128),
        Offset(168, 128),
        Offset(178, 128),
        Offset(168, 128),
        Offset(162, 118),
        Offset(162, 105),
        Offset(162, 92),
        Offset(162, 78),
        Offset(162, 60),
        Offset(162, 75),
        Offset(162, 95),
        Offset(162, 120),
        Offset(162, 145),
        Offset(162, 165),
        Offset(162, 185)
      ]),
  LetterData(
      letter: '5',
      sound: 'five',
      example: 'Five',
      color: Colors.purple,
      difficulty: 2,
      points: [
        Offset(172, 62),
        Offset(160, 62),
        Offset(148, 62),
        Offset(136, 62),
        Offset(124, 62),
        Offset(118, 72),
        Offset(118, 84),
        Offset(118, 96),
        Offset(118, 108),
        Offset(118, 112),
        Offset(130, 112),
        Offset(142, 112),
        Offset(154, 112),
        Offset(166, 116),
        Offset(174, 126),
        Offset(176, 140),
        Offset(172, 154),
        Offset(162, 166),
        Offset(148, 170),
        Offset(134, 170),
        Offset(118, 168)
      ]),
  LetterData(
      letter: '6',
      sound: 'six',
      example: 'Six',
      color: Colors.teal,
      difficulty: 3,
      points: [
        Offset(172, 65),
        Offset(138, 62),
        Offset(118, 80),
        Offset(118, 148),
        Offset(132, 172),
        Offset(158, 178),
        Offset(178, 162),
        Offset(178, 138),
        Offset(162, 118),
        Offset(135, 115),
        Offset(118, 130)
      ]),
  LetterData(
      letter: '7',
      sound: 'seven',
      example: 'Seven',
      color: Colors.pink,
      difficulty: 1,
      points: [Offset(118, 62), Offset(178, 62), Offset(138, 185)]),
  LetterData(
      letter: '8',
      sound: 'eight',
      example: 'Eight',
      color: Colors.brown,
      difficulty: 3,
      points: [
        Offset(150, 62),
        Offset(128, 72),
        Offset(118, 90),
        Offset(125, 115),
        Offset(150, 125),
        Offset(175, 115),
        Offset(182, 90),
        Offset(172, 72),
        Offset(150, 62),
        Offset(150, 125),
        Offset(125, 138),
        Offset(118, 158),
        Offset(128, 178),
        Offset(150, 188),
        Offset(172, 178),
        Offset(182, 158),
        Offset(175, 138),
        Offset(150, 125)
      ]),
  LetterData(
      letter: '9',
      sound: 'nine',
      example: 'Nine',
      color: Colors.indigo,
      difficulty: 3,
      points: [
        Offset(178, 100),
        Offset(172, 72),
        Offset(150, 60),
        Offset(128, 70),
        Offset(118, 92),
        Offset(122, 118),
        Offset(142, 132),
        Offset(168, 128),
        Offset(178, 108),
        Offset(178, 155),
        Offset(165, 185)
      ]),
  LetterData(
      letter: '10',
      sound: 'ten',
      example: 'Ten',
      color: Colors.cyan,
      difficulty: 3,
      points: [
        Offset(78, 80),
        Offset(95, 65),
        Offset(95, 185),
        Offset(130, 62),
        Offset(112, 75),
        Offset(108, 110),
        Offset(112, 148),
        Offset(132, 172),
        Offset(158, 172),
        Offset(175, 148),
        Offset(178, 110),
        Offset(172, 75),
        Offset(150, 62),
        Offset(130, 62)
      ]),
];

// ─────────────────────────────────────────────────────────────────────────────
//  UPPERCASE STROKE SKELETONS (for the guided drag-to-fill mechanic)
// ─────────────────────────────────────────────────────────────────────────────
//
//  Each uppercase letter is described as an ORDERED list of strokes, where each
//  stroke is an ordered polyline of design-space points (same ~300x260 space,
//  glyph area ~x:110-190, y:60-180 used by the legacy tracing data). The child
//  drags along each stroke in order to fill it in. Single-motion letters have
//  one stroke; letters written with pen-lifts have several, in natural writing
//  order. Lowercase letters and numbers intentionally have NO skeletons here and
//  keep using the legacy freehand tracing mechanic.

const Map<String, List<List<Offset>>> uppercaseStrokes = {
  'A': [
    [Offset(150, 60), Offset(130, 120), Offset(110, 180)],
    [Offset(150, 60), Offset(170, 120), Offset(190, 180)],
    [Offset(126, 130), Offset(174, 130)],
  ],
  'B': [
    [Offset(120, 60), Offset(120, 180)],
    [Offset(120, 60), Offset(150, 64), Offset(168, 80), Offset(152, 106), Offset(120, 110)],
    [Offset(120, 110), Offset(154, 116), Offset(174, 145), Offset(150, 176), Offset(120, 180)],
  ],
  'C': [
    [Offset(170, 78), Offset(150, 62), Offset(128, 64), Offset(114, 88), Offset(112, 130), Offset(128, 158), Offset(150, 164), Offset(170, 150)],
  ],
  'D': [
    [Offset(120, 60), Offset(120, 180)],
    [Offset(120, 60), Offset(150, 66), Offset(168, 95), Offset(170, 120), Offset(160, 158), Offset(135, 176), Offset(120, 180)],
  ],
  'E': [
    [Offset(120, 60), Offset(120, 180)],
    [Offset(120, 60), Offset(162, 60)],
    [Offset(120, 120), Offset(150, 120)],
    [Offset(120, 180), Offset(162, 180)],
  ],
  'F': [
    [Offset(120, 60), Offset(120, 180)],
    [Offset(120, 60), Offset(162, 60)],
    [Offset(120, 120), Offset(150, 120)],
  ],
  'G': [
    [Offset(170, 78), Offset(150, 62), Offset(128, 64), Offset(114, 88), Offset(112, 130), Offset(128, 158), Offset(155, 164), Offset(176, 148), Offset(176, 120)],
    [Offset(176, 120), Offset(150, 120)],
  ],
  'H': [
    [Offset(120, 60), Offset(120, 180)],
    [Offset(170, 60), Offset(170, 180)],
    [Offset(120, 120), Offset(170, 120)],
  ],
  'I': [
    [Offset(120, 60), Offset(170, 60)],
    [Offset(145, 60), Offset(145, 180)],
    [Offset(120, 180), Offset(170, 180)],
  ],
  'J': [
    [Offset(160, 60), Offset(160, 150), Offset(148, 172), Offset(128, 168), Offset(120, 150)],
  ],
  'K': [
    [Offset(120, 60), Offset(120, 180)],
    [Offset(160, 60), Offset(120, 120)],
    [Offset(120, 120), Offset(160, 180)],
  ],
  'L': [
    [Offset(120, 60), Offset(120, 180), Offset(162, 180)],
  ],
  'M': [
    [Offset(110, 180), Offset(110, 60), Offset(150, 125), Offset(190, 60), Offset(190, 180)],
  ],
  'N': [
    [Offset(120, 180), Offset(120, 60), Offset(170, 180), Offset(170, 60)],
  ],
  'O': [
    [Offset(150, 60), Offset(122, 78), Offset(112, 120), Offset(122, 162), Offset(150, 180), Offset(178, 162), Offset(188, 120), Offset(178, 78), Offset(150, 60)],
  ],
  'P': [
    [Offset(120, 60), Offset(120, 180)],
    [Offset(120, 60), Offset(155, 66), Offset(168, 90), Offset(155, 112), Offset(120, 116)],
  ],
  'Q': [
    [Offset(150, 60), Offset(122, 78), Offset(112, 120), Offset(122, 162), Offset(150, 180), Offset(178, 162), Offset(188, 120), Offset(178, 78), Offset(150, 60)],
    [Offset(155, 150), Offset(182, 184)],
  ],
  'R': [
    [Offset(120, 60), Offset(120, 180)],
    [Offset(120, 60), Offset(155, 66), Offset(168, 90), Offset(155, 112), Offset(120, 116)],
    [Offset(120, 116), Offset(170, 180)],
  ],
  'S': [
    [Offset(168, 70), Offset(140, 60), Offset(120, 78), Offset(128, 104), Offset(155, 116), Offset(172, 140), Offset(160, 166), Offset(132, 170), Offset(116, 158)],
  ],
  'T': [
    [Offset(118, 60), Offset(172, 60)],
    [Offset(145, 60), Offset(145, 180)],
  ],
  'U': [
    [Offset(120, 60), Offset(120, 148), Offset(135, 170), Offset(150, 174), Offset(165, 170), Offset(180, 148), Offset(180, 60)],
  ],
  'V': [
    [Offset(120, 60), Offset(150, 180), Offset(180, 60)],
  ],
  'W': [
    [Offset(110, 60), Offset(130, 180), Offset(150, 110), Offset(170, 180), Offset(190, 60)],
  ],
  'X': [
    [Offset(120, 60), Offset(180, 180)],
    [Offset(180, 60), Offset(120, 180)],
  ],
  'Y': [
    [Offset(120, 60), Offset(150, 120)],
    [Offset(180, 60), Offset(150, 120)],
    [Offset(150, 120), Offset(150, 180)],
  ],
  'Z': [
    [Offset(120, 60), Offset(180, 60), Offset(120, 180), Offset(180, 180)],
  ],
};

/// Ordered stroke skeletons for the given mode and letter, or null.
/// Only uppercase (mode 0) has a Stroke_Set — lowercase and numbers always
/// use the legacy freehand tracing mechanic (Requirement 6).
List<List<Offset>>? strokesForMode(int mode, String letter) {
  if (mode != 0) return null;
  return uppercaseStrokes[letter];
}

/// Testing/verification helper: concatenates a Stroke_Set in order.
/// Not used at runtime — the runtime UI never needs the flattened form
/// (it already has `LetterData.points` for the background glyph and
/// `uppercaseStrokes` for the drag-fill mechanic separately).
List<Offset> flattenStrokes(List<List<Offset>> strokes) =>
    strokes.expand((s) => s).toList();
