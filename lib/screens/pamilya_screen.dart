import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../widgets/success_modal.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';
import 'dart:async';

// ─────────────────────────────────────────────────────────────────────────────
//  BADGE MODEL
// ─────────────────────────────────────────────────────────────────────────────
class FamilyBadge {
  final String emoji;
  final String title;
  final String description;
  final Color color;
  bool isEarned;

  FamilyBadge({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
    this.isEarned = false,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class PamilyaScreen extends StatefulWidget {
  const PamilyaScreen({super.key});

  @override
  State<PamilyaScreen> createState() => _PamilyaScreenState();
}

class _PamilyaScreenState extends State<PamilyaScreen>
    with TickerProviderStateMixin {
  // ── Navigation ─────────────────────────────────────────────────────────────
  int _selectedMainCategory = 0;
  int _selectedLevel = 0;
  int _currentGameIndex = 0;

  // ── Scoring ────────────────────────────────────────────────────────────────
  int _totalScore = 0;
  int _totalStars = 0;
  int _levelStars = 0;
  int _wrongAttempts = 0;

  // ── Timer ──────────────────────────────────────────────────────────────────
  int _secondsLeft = 60;
  Timer? _timer;
  final bool _timerEnabled = true;

  // ── Feedback ───────────────────────────────────────────────────────────────
  String _feedbackMessage = '';
  Color _feedbackColor = Colors.transparent;
  bool _showCorrectOverlay = false;

  // ── Sarili states ──────────────────────────────────────────────────────────
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  int? _selectedGender;
  int? _selectedEmotionAnswer;
  bool _showEmotionExplanation = false;
  int? _selectedRoutineAnswer;
  int? _selectedFoodIndex;
  int? _selectedColorIndex;
  int? _selectedGameIndex;
  int? _selectedAnimalIndex;

  // ── Pamilya states ─────────────────────────────────────────────────────────
  int? _selectedFamilyAnswer;
  String? _selectedFamilyMember;
  bool _showingFamilyInfo = false;
  int? _selectedRoleAnswer;
  int? _selectedActivityAnswer;
  bool _myHomeCompleted = false;
  int? _selectedRoomIndex;

  // ── Badges ─────────────────────────────────────────────────────────────────
  late List<FamilyBadge> _badges;
  List<FamilyBadge> _newlyEarnedBadges = [];

  // ── Animations ─────────────────────────────────────────────────────────────
  late AnimationController _starBurstController;
  late AnimationController _timerPulseController;
  late AnimationController _celebrationController;
  late AnimationController _characterController;
  late Animation<double> _starBurstAnim;
  late Animation<double> _timerPulseAnim;
  late Animation<double> _characterAnim;

  bool _characterHappy = false;
  late AudioPlayer _audioPlayer;

  // ─────────────────────────────────────────────────────────────────────────
  //  DATA
  // ─────────────────────────────────────────────────────────────────────────

  final List<Map<String, dynamic>> _mainCategories = const [
    {'title': 'Ti Bagik', 'icon': Icons.person, 'color': Color(0xFFFF6B6B)},
    {
      'title': 'Ti Pamilyak',
      'icon': Icons.family_restroom,
      'color': Color(0xFF4ECDC4)
    },
  ];

  final List<List<String>> _categoryLevelTitles = [
    ['Maipanggep Kaniak', 'Dagiti Riknak', 'Inaldaw nga Aramid', 'Paboritok'],
    [
      'Dagiti Miyembro ti Pamilya',
      'Trabaho iti Pamilya',
      'Aramid ti Pamilya',
      'Puno ti Pamilya',
      'Ti Balaymi'
    ],
  ];

  final List<List<IconData>> _categoryLevelIcons = [
    [
      Icons.person,
      Icons.emoji_emotions_rounded,
      Icons.schedule_rounded,
      Icons.favorite
    ],
    [
      Icons.group_rounded,
      Icons.work_rounded,
      Icons.celebration_rounded,
      Icons.account_tree_rounded,
      Icons.home_rounded
    ],
  ];

  final List<List<String>> _categoryLevelSubtitles = [
    [
      'Ammom ti bagim',
      'Ilawlawagmo ti riknam',
      'Ammuem dagiti inaldaw nga aramid',
      'Ania ti kayatmo?'
    ],
    [
      'Sino-sino dagiti pamilyam?',
      'Ania ti trabaho ti tunggal maysa?',
      'Ania ti aramidendayo a sangsangkamaysa?',
      'Sino-sino dagiti kabagianmo?',
      'Sadino kayo nagtaeng?'
    ],
  ];

  // ── Sarili Level 1 ─────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _sariliLevel1Games = [
    {
      'id': 'about_name',
      'question': 'Ania ti naganmo?',
      'type': 'text_input',
      'hint': 'I-type ti naganmo ditoy',
      'icon': '👤',
      'description':
          'Ti naganmo ket ti tawag kenka ti pamilyam ken gagayyemmo. Napateg dayta!',
    },
    {
      'id': 'about_age',
      'question': 'Mano ti tawenmo?',
      'type': 'age_input',
      'hint': 'Kas pagarigan: 5, 7, 10',
      'icon': '🎂',
      'description':
          'Ti tawenmo ket ti bilang dagiti tawen manipud idi nayanakka. Kapadas ti selebrar!',
    },
    {
      'id': 'about_gender',
      'question': 'Babai ka kadi wenno lalaki?',
      'type': 'choice',
      'options': ['👧 Babai', '👦 Lalaki'],
      'values': [0, 1],
      'icon': '👤',
      'description':
          'Ti kasarianmo ket paset ti kinataom. Napateg ken naan-anay.',
    },
    {
      'id': 'about_birthday',
      'question': 'Kaano ti pannakayanakmo?',
      'type': 'info',
      'icon': '🎉',
      'info': 'Ti pannakayanakmo ket ti aldaw idi nayanakka.',
      'example': 'Kas pagarigan: Enero 15, 2018 — Aldaw ti Pannakayanak!',
      'description': 'Selebrasyon ti pannakayanakmo kadua ti pamilyam.',
    },
    {
      'id': 'about_home',
      'question': 'Sadino ti pagtaengam?',
      'type': 'text_input',
      'hint': 'Nagan ti siudad wenno ili',
      'icon': '🏠',
      'description':
          'Ti pagtaengam ket ti lugar a pagyanam a kadua ti pamilyam. Naimbag ti balay!',
    },
  ];

  // ── Sarili Level 2: Emotions (full Ilocano) ────────────────────────────────
  final List<Map<String, dynamic>> _sariliLevel2Games = const [
    {
      'id': 'emotion_happy',
      'question': 'Kaano ka NARAG-O?',
      'choices': [
        '🎁 No adda regalo wenno sorpresa',
        '😢 No mananatangken',
        '😴 No matuturog'
      ],
      'correct': 0,
      'explanation':
          'Nalinteg! Narag-o tayo no adda nasayaat a mapasamak kas ti regalo wenno pesta.',
      'tip': 'Ngumingiti ka ken ibagam ti ragsak mo iti pamilyam!'
    },
    {
      'id': 'emotion_sad',
      'question': 'Kaano ka NALUNLUNGOT?',
      'choices': [
        '🎂 No adda kasangay',
        '🧸 No mawanen ti paboritom a laruan',
        '🍦 No kumkumanen ti ice cream'
      ],
      'correct': 1,
      'explanation':
          'Nalinteg! Normal ti maglunglungot no adda mawanen wenno no adda di nasayaat a napasamak.',
      'tip': 'No nalunglungot ka, yakap ti nanangmo wenno amam.'
    },
    {
      'id': 'emotion_angry',
      'question': 'Kaano ka NAALIGUTGET?',
      'choices': [
        '🎮 No nanalo iti laro',
        '🧸 No adda baro a laruan',
        '👊 No inala ti laruanmo nga awan pannakaisuro'
      ],
      'correct': 2,
      'explanation':
          'Nalinteg! Naaligutgettayo no adda di umiso wenno di nalinteg a napasamak.',
      'tip': 'No naaligutget ka, sumrek ti angin ken bilangen iti lima.'
    },
    {
      'id': 'emotion_surprised',
      'question': 'Kaano ka NASDAAW?',
      'choices': [
        '🎁 No adda di inayan a sorpresa',
        '🍚 No mangan',
        '😴 No matulog'
      ],
      'correct': 0,
      'explanation': 'Nalinteg! Nasdaaw tayo no adda di inayan a napasamak.',
      'tip': 'Mabalin a mangsdaaw — simmuroten ti pannakaadal!'
    },
    {
      'id': 'emotion_sleepy',
      'question': 'Kaano ka MAUYONG?',
      'choices': [
        '🌅 No bigbigat kalpasan ti panagtilmon',
        '🌙 No rabii na',
        '☀️ No agalagad'
      ],
      'correct': 1,
      'explanation':
          'Nalinteg! Mauyong tayo no rabii na ta oras na ti matulog.',
      'tip': 'Agtugaw nang nasapa tapno lumaki nang naruay!'
    },
    {
      'id': 'emotion_scared',
      'question': 'Kaano ka NATAKOT?',
      'choices': [
        '🌈 No adda balangaw',
        '⚡ No adda kimat ken kulog',
        '☀️ No init ti aldaw'
      ],
      'correct': 1,
      'explanation': 'Nalinteg! Natakot tayo iti nalaing a sirak kas ti kulog.',
      'tip': 'No natakot ka, yakap ti nanangmo wenno amam.'
    },
  ];

  // ── Sarili Level 3: Daily Routines ─────────────────────────────────────────
  final List<Map<String, dynamic>> _sariliLevel3Games = const [
    {
      'id': 'routine_morning',
      'question':
          'Ania ti umuna nga aramidenmo no BIGBIGAT kalpasan ti panagtilmon?',
      'choices': [
        '🛏️ Agtilmon ken agbangon',
        '🍳 Kumanen ti agahon',
        '📺 Ag-TV'
      ],
      'correct': 0,
      'explanation':
          'Nalinteg! Umuna nga agtilmon ken agbangon sakbay ti sabali nga gapuanan.',
      'tip': 'Agbangon nang nasapa tapno naandam iti intero nga aldaw!'
    },
    {
      'id': 'routine_afternoon',
      'question': 'Ania ti kaslakami nga aramidenmo iti MALEM?',
      'choices': [
        '📚 Agadal wenno aglaro',
        '🍚 Kumanen ti pangaldaw',
        '😴 Matulog ti intero nga malem'
      ],
      'correct': 0,
      'explanation': 'Nalinteg! Iti malem, agadal tayo wenno aglaro.',
      'tip': 'Pagtalinaeden ti oras para iti panagadal ken panaglaro!'
    },
    {
      'id': 'routine_evening',
      'question': 'Ania ti mabalin nga aramidenmo sakbay ti PANAGTUROG?',
      'choices': [
        '🪥 Agsuplit',
        '🍪 Kumanen ti merienda',
        '📱 Aglaro iti cellphone'
      ],
      'correct': 0,
      'explanation':
          'Nalinteg! Napateg ti panagsuplit sakbay ti panagturog tapno maprotektaran ti ngipen.',
      'tip': 'Ti nasuyat nga ngipen ket iwas sakit!'
    },
    {
      'id': 'routine_hygiene',
      'question': 'Kasano ti maprotektaranmo ti bagim iti sakit?',
      'choices': [
        '🧼 Aghugas iti ima',
        '🪥 Agsuplit laeng',
        '💧 Uminom iti danum'
      ],
      'correct': 0,
      'explanation': 'Nalinteg! Ti panaghugas iti ima ket iwas sakit.',
      'tip': 'Aghugas iti ima sakbay ti panangan ken kalpasan ti banio!'
    },
  ];

  // ── Sarili Level 4: Preferences ────────────────────────────────────────────
  final List<Map<String, dynamic>> _sariliLevel4Games = const [
    {
      'id': 'preference_food',
      'question': 'Ania ti paboritom nga MAKAN?',
      'options': ['🍚 Sinanglaw', '🐟 Pinakbet', '🍛 Dinengdeng', '🍖 Bagnet'],
      'emojis': ['🍚', '🐟', '🍛', '🍖'],
      'description': 'Dagiti nailian nga makan ti Ilocos! Umili ka!'
    },
    {
      'id': 'preference_color',
      'question': 'Ania ti paboritom nga KULOR?',
      'options': [
        '🔴 Nalabbaga',
        '🔵 Natimgas',
        '🟢 Nalabbag-o',
        '🟡 Nadarang'
      ],
      'emojis': ['🔴', '🔵', '🟢', '🟡'],
      'description': 'Pumili ka iti paboritom nga kulor!'
    },
    {
      'id': 'preference_game',
      'question': 'Ania ti paboritom nga LARO?',
      'options': ['🪀 Piko', '🏃 Taguan', '🧩 Puzzle', '🎯 Tumbang Preso'],
      'emojis': ['🪀', '🏃', '🧩', '🎯'],
      'description': 'Dagiti nailian nga laro! Maymaysa a naraig!'
    },
    {
      'id': 'preference_animal',
      'question': 'Ania ti paboritom nga HAYOP?',
      'options': ['🐶 Aso', '🐱 Pusa', '🐓 Manok', '🐃 Nuang'],
      'emojis': ['🐶', '🐱', '🐓', '🐃'],
      'description': 'Pumili iti paboritom nga ayup!'
    },
  ];

  // ── Pamilya Level 1: Family Members ────────────────────────────────────────
  final List<Map<String, dynamic>> _pamilyaLevel1Games = const [
    {
      'id': 'family_nanay',
      'question': 'Sino ti ag-alagad kenka no aggagar ken nagluto iti makan?',
      'choices': ['👩 Nanang', '👨 Amang', '👧 Manang', '🧑 Manong'],
      'correct': 0,
      'member': 'Nanang',
      'emoji': '👩',
      'roles': 'nagluluto, ag-alagad, naglalambing',
      'description':
          'Si Nanang ti ag-alagad kadatayo ken nagluto iti nasayaat nga makan.',
      'ilocano_note':
          'Iti Ilocos, awagentayo ti ina iti "Nanang" wenno "Inang".',
      'audioPath': 'audio/ni nanang.mp3'
    },
    {
      'id': 'family_tatay',
      'question': 'Sino ti nagtatrabaho para iti pamilya ken kalaro iti ruar?',
      'choices': ['👩 Nanang', '👨 Amang', '👧 Manang', '🧑 Manong'],
      'correct': 1,
      'member': 'Amang',
      'emoji': '👨',
      'roles': 'nagtatrabaho, naglalaro, nagpoprotekta',
      'description':
          'Si Amang ti nagtatrabaho para iti pamilya ken naimus aglaro.',
      'ilocano_note':
          'Iti Ilocos, awagentayo ti ama iti "Amang" wenno "Tatang".',
      'audioPath': 'audio/si amang.mp3'
    },
    {
      'id': 'family_manong',
      'question': 'Sino ti nataengan nga kabsatmo a lalaki?',
      'choices': ['👩 Nanang', '👨 Amang', '👧 Manang', '🧑 Manong'],
      'correct': 3,
      'member': 'Manong',
      'emoji': '🧑',
      'roles': 'nataengan nga kabsat, mangikuyog, kalaro',
      'description': 'Si Manong ti nataengan nga kabsatmo a lalaki.',
      'ilocano_note':
          'Iti Ilocos, awagentayo iti napateg nga kabsat iti "Manong".',
      'audioPath': 'audio/ni manong.mp3'
    },
    {
      'id': 'family_manang',
      'question': 'Sino ti nataengan nga kabsatmo a babai?',
      'choices': ['👩 Nanang', '👨 Amang', '👧 Manang', '🧑 Manong'],
      'correct': 2,
      'member': 'Manang',
      'emoji': '👧',
      'roles': 'nataengan nga kabsat, tumulong iti balay, kaobraobra',
      'description': 'Si Manang ti nataengan nga kabsatmo a babai.',
      'ilocano_note':
          'Iti Ilocos, awagentayo iti napateg nga kabsat a babai iti "Manang".',
      'audioPath': 'audio/ni manang.mp3'
    },
    {
      'id': 'family_kaanakan',
      'question': 'Sino ti kaungpusam nga miyembro ti pamilya?',
      'choices': ['👶 Kaungpus', '👧 Manang', '🧑 Manong', '👴 Lelong'],
      'correct': 0,
      'member': 'Kaungpus',
      'emoji': '👶',
      'roles': 'kaungpus nga kabsat, inaalagaan',
      'description': 'Ti kaungpus ti kaungpus nga miyembro ti pamilya.',
      'ilocano_note':
          'Iti Ilocos, awagentayo iti kaungpus nga kabsat iti "Kaungpus" wenno "Bunsoy".',
      'audioPath': 'audio/ni bunsoy.mp3'
    },
    {
      'id': 'family_lelong',
      'question': 'Sino ti ama ti nanangmo wenno amangmo?',
      'choices': ['👴 Lelong', '👵 Leling', '👨 Amang', '👩 Nanang'],
      'correct': 0,
      'member': 'Lelong',
      'emoji': '👴',
      'roles': 'Lelong dagiti annaknak, nagkukuwento iti tao',
      'description': 'Si Lelong ti ama ti nanang wenno amang tayo.',
      'ilocano_note': 'Iti Ilocos, awagentayo ti apo a lalaki iti "Lelong".',
      'audioPath': 'audio/ni lelong.mp3'
    },
    {
      'id': 'family_leling',
      'question': 'Sino ti ina ti nanangmo wenno amangmo?',
      'choices': ['👴 Lelong', '👵 Leling', '👨 Amang', '👩 Nanang'],
      'correct': 1,
      'member': 'Leling',
      'emoji': '👵',
      'roles': 'Leling dagiti annaknak, nagluluto iti naimas',
      'description': 'Si Leling ti ina ti nanang wenno amang tayo.',
      'ilocano_note': 'Iti Ilocos, awagentayo ti apo a babai iti "Leling".',
      'audioPath': 'audio/ni leling.mp3'
    },
  ];

  // ── Pamilya Level 2: Family Roles ──────────────────────────────────────────
  final List<Map<String, dynamic>> _pamilyaLevel2Games = const [
    {
      'id': 'role_cook',
      'question': 'Sino ti kaslakami nga nagluluto iti balaymi?',
      'choices': [
        'Nanang laeng',
        'Amang laeng',
        'Leling laeng',
        'Mabalin ti aniaman'
      ],
      'correct': 3,
      'explanation': 'Nalinteg! Mabalin ti aniaman iti pamilya ti magluto.'
    },
    {
      'id': 'role_work',
      'question': 'Sino ti nagtatrabaho para iti pamilya?',
      'choices': [
        'Amang laeng',
        'Nanang laeng',
        'Lelong laeng',
        'Mabalin ti adu'
      ],
      'correct': 3,
      'explanation': 'Nalinteg! Mabalin ti adu iti pamilya ti nagtatrabaho.'
    },
    {
      'id': 'role_story',
      'question': 'Sino ti nalablabes a nagkukuwento iti daan?',
      'choices': ['Manong', 'Manang', 'Lelong ken Leling', 'Amang'],
      'correct': 2,
      'explanation':
          'Nalinteg! Dagiti Lelong ken Leling ti kaslakami nga nagkukuwento.'
    },
    {
      'id': 'role_care',
      'question': 'Sino ti ag-alagad kenka no aggagarika?',
      'choices': ['Nanang', 'Amang', 'Leling', 'Amin da'],
      'correct': 3,
      'explanation': 'Nalinteg! Amin nga miyembro ti pamilya ag-alagad.'
    },
    {
      'id': 'role_play',
      'question': 'Sino ti kalarom iti balay?',
      'choices': ['Manong', 'Manang', 'Kaungpus', 'Amin dagiti kabsat'],
      'correct': 3,
      'explanation': 'Nalinteg! Mabalin ka aglaro kadagiti aniaman.'
    },
  ];

  // ── Pamilya Level 3: Family Activities ─────────────────────────────────────
  final List<Map<String, dynamic>> _pamilyaLevel3Games = const [
    {
      'id': 'activity_dinner',
      'question':
          'Ania ti nasayaat nga aramidem a sangsangkamaysa iti panagannak?',
      'choices': [
        'Kumanen ken agkukuwentuan',
        'Mangar-ay iti TV',
        'Matulog',
        'Ag-cellphone'
      ],
      'correct': 0,
      'explanation':
          'Nalinteg! Naraig ti kumanen a sangsangkamaysa ken magkukuwentuan.'
    },
    {
      'id': 'activity_weekend',
      'question': 'Ania ti mabalin nga aramiden ti pamilya iti weekend?',
      'choices': [
        'Agmanmano iti parke',
        'Agbilibilang iti grocery',
        'Aglinlinis a sangsangkamaysa',
        'Amin dagiti naibaga'
      ],
      'correct': 3,
      'explanation': 'Nalinteg! Amin nga aramiden a sangsangkamaysa ket naraig.'
    },
    {
      'id': 'activity_celebration',
      'question': 'Ania ti aramidem ti pamilya no adda kasangay?',
      'choices': [
        'Kumanen ti kek',
        'Mangited iti regalo',
        'Selebrasyon a sangsangkamaysa',
        'Amin dagiti naibaga'
      ],
      'correct': 3,
      'explanation': 'Nalinteg! Ti kasangay ket selebrasyon a sangsangkamaysa!'
    },
    {
      'id': 'activity_help',
      'question': 'Kasano ka makatutulongen iti pamilyam?',
      'choices': [
        'Agurnos iti laruan',
        'Agwaswas',
        'Agurnos iti pinggan',
        'Amin dagiti naibaga'
      ],
      'correct': 3,
      'explanation':
          'Nalinteg! Ti pangtulongen iti balay ket pannakaayat iti pamilya.'
    },
  ];

  // ── Family Tree ────────────────────────────────────────────────────────────
  final Map<String, dynamic> _familyTreeData = {
    'generations': [
      {
        'title': 'Dagiti Apo (Lelong ken Leling)',
        'color': const Color(0xFF9B59B6),
        'members': [
          {'relation': 'Lelong (ama ni Amang)', 'emoji': '👴'},
          {'relation': 'Leling (ina ni Amang)', 'emoji': '👵'},
          {'relation': 'Lelong (ama ni Nanang)', 'emoji': '👴'},
          {'relation': 'Leling (ina ni Nanang)', 'emoji': '👵'},
        ]
      },
      {
        'title': 'Dagiti Nagannak',
        'color': const Color(0xFF2980B9),
        'members': [
          {'relation': 'Amang', 'emoji': '👨'},
          {'relation': 'Nanang', 'emoji': '👩'},
        ]
      },
      {
        'title': 'Dagiti Kabsat',
        'color': const Color(0xFF27AE60),
        'members': [
          {'relation': 'Manong (panganay)', 'emoji': '🧑'},
          {'relation': 'Manang (maikadua)', 'emoji': '👧'},
          {'relation': 'Kaungpus', 'emoji': '👶'},
        ]
      },
    ]
  };

  // ── My Home ────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _homeRooms = [
    {
      'name': 'Sala',
      'emoji': '🛋️',
      'activity': 'agmanmano ken mangar-ay iti TV ti pamilya',
      'color': const Color(0xFFE74C3C)
    },
    {
      'name': 'Kusina',
      'emoji': '🍳',
      'activity': 'nagluto ken kumanen ti pamilya',
      'color': const Color(0xFFE67E22)
    },
    {
      'name': 'Kuarto',
      'emoji': '🛏️',
      'activity': 'nagatiddog ken nagsarsarita ti pamilya',
      'color': const Color(0xFF3498DB)
    },
    {
      'name': 'Banio',
      'emoji': '🚿',
      'activity': 'naligo ken naglinabas ti pamilya',
      'color': const Color(0xFF1ABC9C)
    },
    {
      'name': 'Bakir',
      'emoji': '🌿',
      'activity': 'naglalaruan ken nagannak iti pamilya',
      'color': const Color(0xFF2ECC71)
    },
  ];

  // ─────────────────────────────────────────────────────────────────────────
  //  Computed getters
  // ─────────────────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _currentGames {
    if (_selectedMainCategory == 0) {
      switch (_selectedLevel) {
        case 0:
          return _sariliLevel1Games;
        case 1:
          return _sariliLevel2Games;
        case 2:
          return _sariliLevel3Games;
        case 3:
          return _sariliLevel4Games;
        default:
          return _sariliLevel1Games;
      }
    } else {
      switch (_selectedLevel) {
        case 0:
          return _pamilyaLevel1Games;
        case 1:
          return _pamilyaLevel2Games;
        case 2:
          return _pamilyaLevel3Games;
        case 3:
          return _pamilyaLevel1Games;
        case 4:
          return _pamilyaLevel1Games;
        default:
          return _pamilyaLevel1Games;
      }
    }
  }

  int get _starsFromWrong {
    if (_wrongAttempts == 0) return 3;
    if (_wrongAttempts == 1) return 2;
    return 1;
  }

  double get _levelProgress => _currentGames.isEmpty
      ? 0
      : (_currentGameIndex + 1) / _currentGames.length;

  String get _currentMainTitle =>
      _mainCategories[_selectedMainCategory]['title'];
  Color get _currentMainColor =>
      _mainCategories[_selectedMainCategory]['color'];

  // ─────────────────────────────────────────────────────────────────────────
  //  Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    _badges = [
      FamilyBadge(
          emoji: '👤',
          title: 'Ammok ti Bagik',
          description: 'Nakompleto ti "Ti Bagik"',
          color: const Color(0xFFFF6B6B)),
      FamilyBadge(
          emoji: '😊',
          title: 'Rikna Esperto',
          description: 'Nakompleto ti "Dagiti Riknak"',
          color: const Color(0xFFFF9F43)),
      FamilyBadge(
          emoji: '⏰',
          title: 'Aramid Esperto',
          description: 'Nakompleto ti "Inaldaw nga Aramid"',
          color: const Color(0xFF4ECDC4)),
      FamilyBadge(
          emoji: '❤️',
          title: 'Ammok ti Kayatko',
          description: 'Nakompleto ti "Paboritok"',
          color: const Color(0xFFFF6B9D)),
      FamilyBadge(
          emoji: '👨‍👩‍👧‍👦',
          title: 'Miyembro Esperto',
          description: 'Nakompleto ti "Dagiti Miyembro"',
          color: const Color(0xFF6C5CE7)),
      FamilyBadge(
          emoji: '🏆',
          title: 'Trabaho Esperto',
          description: 'Nakompleto ti "Trabaho iti Pamilya"',
          color: const Color(0xFFFD79A8)),
      FamilyBadge(
          emoji: '🎉',
          title: 'Aramid Esperto',
          description: 'Nakompleto ti "Aramid ti Pamilya"',
          color: const Color(0xFF00B894)),
      FamilyBadge(
          emoji: '🌳',
          title: 'Puno Esperto',
          description: 'Nakompleto ti "Puno ti Pamilya"',
          color: const Color(0xFF55EFC4)),
      FamilyBadge(
          emoji: '🏠',
          title: 'Balay Esperto',
          description: 'Nakompleto ti "Ti Balaymi"',
          color: const Color(0xFF74B9FF)),
    ];

    _starBurstController = AnimationController(
        duration: const Duration(milliseconds: 700), vsync: this);
    _timerPulseController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    _celebrationController = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);
    _characterController = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);

    _starBurstAnim =
        CurvedAnimation(parent: _starBurstController, curve: Curves.elasticOut);
    _timerPulseAnim =
        Tween<double>(begin: 1.0, end: 1.18).animate(_timerPulseController);
    _characterAnim = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _characterController, curve: Curves.elasticOut),
    );

    _audioPlayer = AudioPlayer();

    _initSmartResume();

    if (_timerEnabled) _startTimer();
  }

  Future<void> _initSmartResume() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      // Safety wait for provider initialization (same as SplashScreen fix)
      int retryCount = 0;
      while (!userProvider.isInitialized && retryCount < 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        retryCount++;
      }

      // 1. Find the first uncompleted CATEGORY and LEVEL
      int savedMainCat = 0;
      int savedLevel = 0;
      bool found = false;

      for (int c = 0; c < _mainCategories.length; c++) {
        for (int l = 0; l < _categoryLevelTitles[c].length; l++) {
          if (!userProvider.isPamilyaLevelCompleted(c, l)) {
            savedMainCat = c;
            savedLevel = l;
            found = true;
            break;
          }
        }
        if (found) break;
      }

      // If all completed, default to last
      if (!found) {
        savedMainCat = _mainCategories.length - 1;
        savedLevel = _categoryLevelTitles[savedMainCat].length - 1;
      }

      if (mounted) {
        setState(() {
          _selectedMainCategory = savedMainCat;
          _selectedLevel = savedLevel;

          // Sync badges based on UserProvider before resetting level state
          for (int i = 0; i < _badges.length; i++) {
            int cat = i < 4 ? 0 : 1;
            int lvl = i < 4 ? i : i - 4;
            _badges[i].isEarned =
                userProvider.isPamilyaLevelCompleted(cat, lvl);
          }

          _resetLevelState();
        });
      }
    } catch (e) {
      debugPrint('Pamilya Smart Resume failed: $e');
      _resetLevelState();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nameController.dispose();
    _ageController.dispose();
    _placeController.dispose();
    _starBurstController.dispose();
    _timerPulseController.dispose();
    _celebrationController.dispose();
    _characterController.dispose();
    _audioPlayer.dispose();

    // Ensure music unmuted
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AudioManager.instance.resumeMusic();
    });
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Timer
  // ─────────────────────────────────────────────────────────────────────────

  void _startTimer() {
    _timer?.cancel();
    _secondsLeft = 60;
    _timerPulseController.repeat(reverse: true);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() => _secondsLeft--);
      if (_secondsLeft <= 0) {
        t.cancel();
        _timerPulseController.stop();
        _onTimeout();
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timerPulseController.stop();
  }

  void _pauseTimer() {
    _timer?.cancel();
    _timerPulseController.stop();
  }

  void _resumeTimer() {
    if (_timerEnabled && _secondsLeft > 0) _startTimer();
  }

  void _onTimeout() {
    _showFeedback('⏰ Nabayagen ti oras! Subukanen manen.', Colors.orange);
    _resetQuestionState();
    if (_timerEnabled) _startTimer();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  State reset
  // ─────────────────────────────────────────────────────────────────────────

  void _resetLevelState() {
    // Determine the first uncompleted game index for the current level
    int firstUncompleted = 0;
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final total = _currentGames.length;
      for (int i = 0; i < total; i++) {
        if (!userProvider.isPamilyaGameCompleted(
            _selectedMainCategory, _selectedLevel, i)) {
          firstUncompleted = i;
          break;
        }
        if (i == total - 1) firstUncompleted = total - 1;
      }
    } catch (_) {
      firstUncompleted = 0;
    }

    _currentGameIndex = firstUncompleted;
    _levelStars = 0;
    _wrongAttempts = 0;
    _resetQuestionState();
  }

  void _resetQuestionState() {
    setState(() {
      _selectedGender = null;
      _selectedEmotionAnswer = null;
      _showEmotionExplanation = false;
      _selectedRoutineAnswer = null;
      _selectedFoodIndex = null;
      _selectedColorIndex = null;
      _selectedGameIndex = null;
      _selectedAnimalIndex = null;
      _selectedFamilyAnswer = null;
      _selectedFamilyMember = null;
      _showingFamilyInfo = false;
      _selectedRoleAnswer = null;
      _selectedActivityAnswer = null;
      _myHomeCompleted = false;
      _selectedRoomIndex = null;
      _showCorrectOverlay = false;
      _feedbackMessage = '';
      _characterHappy = false;
    });
  }

  void _switchMainCategory(int index) {
    _stopTimer();
    setState(() {
      _selectedMainCategory = index;
      _selectedLevel = 0;
      _resetLevelState();
    });
    if (_timerEnabled) _startTimer();
  }

  void _switchLevel(int level) {
    _stopTimer();
    setState(() {
      _selectedLevel = level;
      _resetLevelState();
    });
    if (_timerEnabled) _startTimer();
  }

  void _advanceOrComplete() {
    final total = _currentGames.length;
    if (_currentGameIndex < total - 1) {
      setState(() {
        _currentGameIndex++;
        _wrongAttempts = 0;
        _resetQuestionState();
      });
      if (_timerEnabled) _startTimer();
    } else {
      _awardBadge();
      _showLevelComplete();
    }
  }

  void _awardBadge() {
    // Determine which badge index to award
    int badgeIdx;
    if (_selectedMainCategory == 0) {
      badgeIdx = _selectedLevel;
    } else {
      badgeIdx = 4 + _selectedLevel;
    }
    if (badgeIdx < _badges.length && !_badges[badgeIdx].isEarned) {
      setState(() {
        _badges[badgeIdx].isEarned = true;
        _newlyEarnedBadges = [_badges[badgeIdx]];
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Correct / Wrong
  // ─────────────────────────────────────────────────────────────────────────

  void _onCorrect() {
    if (_showCorrectOverlay) return;
    HapticFeedback.heavyImpact();
    _stopTimer();

    final earned = _starsFromWrong;
    setState(() {
      _totalScore += 10 * earned;
      _totalStars += earned;
      _levelStars += earned;
      _showCorrectOverlay = true;
      _characterHappy = true;
    });

    _starBurstController.forward(from: 0);
    _celebrationController.forward(from: 0);
    _characterController
        .forward(from: 0)
        .then((_) => _characterController.reverse());

    final msg = earned == 3
        ? '⭐ NALINTEG UNAY! ⭐ +${10 * earned} puntos'
        : earned == 2
            ? '⭐ NAIMBAG! ⭐ +${10 * earned} puntos'
            : '⭐ MABUTI! ⭐ +${10 * earned} puntos';
    _showFeedback(msg, const Color(0xFF2E7D32));
    _saveQuestionProgress(earned);

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      setState(() {
        _showCorrectOverlay = false;
        _celebrationController.reset();
        _characterHappy = false;
      });
      _advanceOrComplete();
    });
  }

  void _saveQuestionProgress(int earned) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    userProvider.updatePamilyaProgress(
        _selectedMainCategory, _selectedLevel, _currentGameIndex, true);
    userProvider.addStars(earned);
  }

  void _onWrong() {
    if (_showCorrectOverlay) return;
    HapticFeedback.vibrate();
    _stopTimer();

    setState(() {
      _wrongAttempts++;
      _characterHappy = false;
      // We don't have a wrong overlay in PamilyaScreen yet?
      // I'll just show feedback.
    });

    _showFeedback('❌ MALI TI SUNGBAT', Colors.red);
    _saveQuestionProgress(0);

    Future.delayed(const Duration(milliseconds: 1600), () {
      if (!mounted) return;
      _advanceOrComplete();
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Game handlers
  // ─────────────────────────────────────────────────────────────────────────

  void _handleTextSubmit(String value) {
    _pauseTimer();
    final trimmed = value.trim();

    // Smart Checker: Prevent random junk/single letters
    if (trimmed.length < 2) {
      _showFeedback('❌ Subukanen ti naan-anay a sungbat', Colors.red);
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 800), _resumeTimer);
      return;
    }

    // Pattern check: Ensure it's not just random repeated characters (e.g., "aaaaa")
    final uniqueChars = trimmed.toLowerCase().split('').toSet();
    if (uniqueChars.length == 1 && trimmed.length > 2) {
      _showFeedback('❌ Saan a valido a sungbat', Colors.red);
      HapticFeedback.vibrate();
      Future.delayed(const Duration(milliseconds: 800), _resumeTimer);
      return;
    }

    if (trimmed.isNotEmpty) {
      _showFeedback('✓ Naidulin na!', Colors.green);
      Future.delayed(const Duration(seconds: 1), _onCorrect);
    } else {
      _showFeedback('✗ Pakitype ti sungbat', Colors.orange);
      Future.delayed(const Duration(milliseconds: 500), _resumeTimer);
    }
  }

  void _handleGenderSelection(int index) {
    _pauseTimer();
    setState(() => _selectedGender = index);
    _showFeedback('✓ Napili mo na!', Colors.green);
    Future.delayed(const Duration(seconds: 1), _onCorrect);
  }

  void _handleEmotionAnswer(
      int index, int correct, String explanation, String tip) {
    _pauseTimer();
    setState(() => _selectedEmotionAnswer = index);
    if (index == correct) {
      _showEmojiExplation(explanation, tip);
    } else {
      _onWrong();
    }
  }

  void _showEmojiExplation(String explanation, String tip) {
    setState(() => _showEmotionExplanation = true);
    _showFeedback('✓ Nalinteg!', Colors.green);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) _showFeedback('💡 $tip', Colors.blue);
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showEmotionExplanation = false);
        _onCorrect();
      }
    });
  }

  void _handleRoutineAnswer(
      int index, int correct, String explanation, String tip) {
    _pauseTimer();
    setState(() => _selectedRoutineAnswer = index);
    if (index == correct) {
      _showFeedback('✓ Nalinteg! $explanation', Colors.green);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _showFeedback('💡 $tip', Colors.blue);
      });
      Future.delayed(const Duration(seconds: 3), _onCorrect);
    } else {
      _onWrong();
    }
  }

  void _handlePreferenceSelection(int index, String type) {
    _pauseTimer();
    setState(() {
      if (type == 'food') {
        _selectedFoodIndex = index;
      } else if (type == 'color') {
        _selectedColorIndex = index;
      } else if (type == 'game') {
        _selectedGameIndex = index;
      } else if (type == 'animal') {
        _selectedAnimalIndex = index;
      }
    });
    _showFeedback('✓ Napili mo na!', Colors.green);
    Future.delayed(const Duration(seconds: 1), _onCorrect);
  }

  void _handleFamilyAnswer(int index, int correct, Map<String, dynamic> game) {
    _pauseTimer();
    setState(() => _selectedFamilyAnswer = index);
    if (index == correct) {
      setState(() {
        _selectedFamilyMember = game['member'];
        _showingFamilyInfo = true;
      });
      _showFeedback('✓ Nalinteg! Si ${game['member']}!', Colors.green);

      // Play audio if available
      if (game['audioPath'] != null) {
        _playItemAudio(game['audioPath']);
      }

      Future.delayed(const Duration(seconds: 2), _onCorrect);
    } else {
      _onWrong();
    }
  }

  void _handleRoleAnswer(int index, int correct, String explanation) {
    _pauseTimer();
    setState(() => _selectedRoleAnswer = index);
    if (index == correct) {
      _showFeedback('✓ $explanation', Colors.green);
      Future.delayed(const Duration(seconds: 2), _onCorrect);
    } else {
      _onWrong();
    }
  }

  void _handleActivityAnswer(int index, int correct, String explanation) {
    _pauseTimer();
    setState(() => _selectedActivityAnswer = index);
    if (index == correct) {
      _showFeedback('✓ $explanation', Colors.green);
      Future.delayed(const Duration(seconds: 2), _onCorrect);
    } else {
      _showFeedback('✗ Subukanen ti sabali', Colors.red);
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() => _selectedActivityAnswer = null);
        _resumeTimer();
      });
    }
  }

  void _handleFamilyTreeComplete() {
    _pauseTimer();
    _showFeedback('✓ Naammuanmo ti Puno ti Pamilya!', Colors.green);
    Future.delayed(const Duration(seconds: 2), _onCorrect);
  }

  void _handleRoomTap(int index) {
    _pauseTimer();
    setState(() => _selectedRoomIndex = index);
    final room = _homeRooms[index];
    _showFeedback('🏠 ${room['name']}: ${room['activity']}', _currentMainColor);
    Future.delayed(const Duration(seconds: 2), () {
      if (index == _homeRooms.length - 1 ||
          _selectedRoomIndex == _homeRooms.length - 1) {
        _handleMyHomeComplete();
      } else {
        _resumeTimer();
      }
    });
  }

  void _handleMyHomeComplete() {
    _pauseTimer();
    setState(() => _myHomeCompleted = true);
    _showFeedback('✓ Dayta ti balaymi!', Colors.green);
    Future.delayed(const Duration(seconds: 2), _onCorrect);
  }

  void _showFeedback(String msg, Color color) {
    setState(() {
      _feedbackMessage = msg;
      _feedbackColor = color;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _feedbackMessage == msg) {
        setState(() {
          _feedbackMessage = '';
          _feedbackColor = Colors.transparent;
        });
      }
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Dialogs
  // ─────────────────────────────────────────────────────────────────────────

  void _showLevelComplete() {
    _stopTimer();
    final total = _currentGames.length;
    final avgStars = total == 0 ? 1 : (_levelStars / total).ceil().clamp(1, 3);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessModal(
        title: 'Level ${_selectedLevel + 1} Nalpasen!',
        subtitle: _categoryLevelTitles[_selectedMainCategory][_selectedLevel],
        score: _totalScore,
        stars: avgStars,
        badges: _newlyEarnedBadges.map((b) => '${b.emoji} ${b.title}').toList(),
        primaryLabel: _selectedLevel <
                _categoryLevelTitles[_selectedMainCategory].length - 1
            ? 'Sumaruno'
            : 'Nalpas! 🏆',
        onPrimaryTap: () {
          Navigator.pop(context);
          _newlyEarnedBadges = [];
          if (_selectedLevel <
              _categoryLevelTitles[_selectedMainCategory].length - 1) {
            _switchLevel(_selectedLevel + 1);
          } else {
            _showCategoryComplete();
          }
        },
        secondaryLabel: 'Ulitennak',
        onSecondaryTap: () {
          Navigator.pop(context);
          _newlyEarnedBadges = [];
          _switchLevel(_selectedLevel);
        },
        mainColor: _currentMainColor,
      ),
    );
  }

  void _showCategoryComplete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => SuccessModal(
        title: 'Ipagpannakkel ka!',
        subtitle: 'Nalpasem amin dagiti levels iti $_currentMainTitle!',
        score: _totalScore,
        stars: 3,
        badges: _badges
            .where((b) => b.isEarned)
            .map((b) => '${b.emoji} ${b.title}')
            .toList(),
        primaryLabel: 'Agtuloy (Continue)',
        onPrimaryTap: () {
          Navigator.pop(context);
        },
        secondaryLabel: 'Dadduma pay (Back)',
        onSecondaryTap: () {
          Navigator.pop(context);
        },
        mainColor: _currentMainColor,
      ),
    );
  }

  void _showBadgesModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('🏅 Dagiti Badge',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  childAspectRatio: 1,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemCount: _badges.length,
              itemBuilder: (_, i) {
                final b = _badges[i];
                return Container(
                  decoration: BoxDecoration(
                    color: b.isEarned
                        ? b.color.withOpacity(0.15)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: b.isEarned ? b.color : Colors.grey.shade300),
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(b.isEarned ? b.emoji : '🔒',
                            style: const TextStyle(fontSize: 28)),
                        const SizedBox(height: 4),
                        Text(b.isEarned ? b.title : '???',
                            style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: b.isEarned
                                    ? b.color
                                    : Colors.grey.shade400),
                            textAlign: TextAlign.center),
                      ]),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _playItemAudio(String path) async {
    try {
      await AudioManager.instance.pauseMusic();
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(path));

      // Resume background music when item audio finishes
      _audioPlayer.onPlayerComplete.first.then((_) {
        if (mounted) {
          AudioManager.instance.resumeMusic();
        }
      });
    } catch (e) {
      debugPrint('Error playing item audio: $e');
      AudioManager.instance.resumeMusic();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              _buildMainCategoryTabs(),
              _buildLevelTabs(),
              _buildProgressHeader(),
              Expanded(child: _buildGameContent()),
              _buildFeedbackBanner(),
            ],
          ),
          if (_showCorrectOverlay) _buildCorrectOverlay(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
        color: AppColors.textDark,
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(_currentMainTitle,
          style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold)),
      actions: [
        // Badges button
        GestureDetector(
          onTap: _showBadgesModal,
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Text('🏅', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 4),
              Text('${_badges.where((b) => b.isEarned).length}',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.amber)),
            ]),
          ),
        ),
        // Timer
        AnimatedBuilder(
          animation: _timerPulseAnim,
          builder: (_, __) {
            final urgent = _secondsLeft <= 10;
            return Transform.scale(
              scale: urgent ? _timerPulseAnim.value : 1.0,
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: urgent
                      ? Colors.red.withOpacity(0.15)
                      : _currentMainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.timer_rounded,
                      color: urgent ? Colors.red : _currentMainColor, size: 16),
                  const SizedBox(width: 4),
                  Text('$_secondsLeft',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: urgent ? Colors.red : _currentMainColor)),
                ]),
              ),
            );
          },
        ),
        // Stars
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
            const SizedBox(width: 4),
            Text('$_totalStars',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.amber)),
          ]),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  TABS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMainCategoryTabs() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: List.generate(_mainCategories.length, (i) {
          final active = _selectedMainCategory == i;
          final color = _mainCategories[i]['color'] as Color;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchMainCategory(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: active ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: active ? color : color.withOpacity(0.3), width: 2),
                  boxShadow: active
                      ? [
                          BoxShadow(
                              color: color.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3))
                        ]
                      : [],
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(_mainCategories[i]['icon'],
                      color: active ? Colors.white : color, size: 20),
                  const SizedBox(width: 8),
                  Text(_mainCategories[i]['title'],
                      style: TextStyle(
                          color: active ? Colors.white : color,
                          fontWeight:
                              active ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14)),
                ]),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildLevelTabs() {
    final titles = _categoryLevelTitles[_selectedMainCategory];
    final icons = _categoryLevelIcons[_selectedMainCategory];
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: List.generate(titles.length, (i) {
            final active = _selectedLevel == i;
            final badgeIdx = _selectedMainCategory == 0 ? i : 4 + i;
            final earned =
                badgeIdx < _badges.length && _badges[badgeIdx].isEarned;
            return GestureDetector(
              onTap: () {
                if (earned && !active) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: const Text('Nalpasem daytoyen! (Done already!)'),
                    backgroundColor: _currentMainColor,
                    duration: const Duration(seconds: 1),
                  ));
                  return;
                }
                _switchLevel(i);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? _currentMainColor : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(icons[i],
                      size: 16,
                      color: active ? Colors.white : Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text('L${i + 1}',
                      style: TextStyle(
                          color: active ? Colors.white : Colors.grey.shade600,
                          fontWeight:
                              active ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13)),
                  if (earned) ...[
                    const SizedBox(width: 4),
                    const Text('✓',
                        style: TextStyle(
                            color: Colors.amber,
                            fontSize: 11,
                            fontWeight: FontWeight.bold))
                  ],
                ]),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        _categoryLevelTitles[_selectedMainCategory]
                            [_selectedLevel],
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _currentMainColor)),
                    Text(
                        _categoryLevelSubtitles[_selectedMainCategory]
                            [_selectedLevel],
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600)),
                  ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: _currentMainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16)),
              child: Text('${_currentGameIndex + 1} / ${_currentGames.length}',
                  style: TextStyle(
                      fontSize: 12,
                      color: _currentMainColor,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _levelProgress,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_currentMainColor),
            minHeight: 6,
          ),
        ),
      ]),
    );
  }

  Widget _buildFeedbackBanner() {
    if (_feedbackMessage.isEmpty) return const SizedBox(height: 16);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
          color: _feedbackColor, borderRadius: BorderRadius.circular(12)),
      child: Text(_feedbackMessage,
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildCorrectOverlay() {
    return IgnorePointer(
      child: Center(
        child: ScaleTransition(
          scale: _starBurstAnim,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32).withOpacity(0.92),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.green.withOpacity(0.5),
                    blurRadius: 30,
                    spreadRadius: 10)
              ],
            ),
            child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: Colors.white, size: 60),
                  SizedBox(height: 6),
                  Text('Nalinteg!',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                ]),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  GAME CONTENT ROUTER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildGameContent() {
    if (_selectedMainCategory == 0) {
      switch (_selectedLevel) {
        case 0:
          return _buildSariliGame1();
        case 1:
          return _buildSariliGame2();
        case 2:
          return _buildSariliGame3();
        case 3:
          return _buildSariliGame4();
        default:
          return _buildSariliGame1();
      }
    } else {
      switch (_selectedLevel) {
        case 0:
          return _buildFamilyMembersGame();
        case 1:
          return _buildFamilyRolesGame();
        case 2:
          return _buildFamilyActivitiesGame();
        case 3:
          return _buildFamilyTreeGame();
        case 4:
          return _buildMyHomeGame();
        default:
          return _buildFamilyMembersGame();
      }
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SHARED CARD WRAPPER
  // ─────────────────────────────────────────────────────────────────────────

  Widget _gameCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: child,
    );
  }

  Widget _choiceTile({
    required String label,
    required bool isSelected,
    required bool? isCorrect,
    required VoidCallback onTap,
    double minHeight = 54,
  }) {
    Color borderColor;
    Color bgColor;
    Color textColor;

    if (isSelected && isCorrect == true) {
      borderColor = Colors.green;
      bgColor = Colors.green.withOpacity(0.1);
      textColor = Colors.green.shade800;
    } else if (isSelected && isCorrect == false) {
      borderColor = Colors.red;
      bgColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red.shade800;
    } else {
      borderColor = Colors.grey.shade300;
      bgColor = Colors.white;
      textColor = Colors.grey.shade800;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        width: double.infinity,
        constraints: BoxConstraints(minHeight: minHeight),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(children: [
          if (isSelected && isCorrect == true)
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
          if (isSelected && isCorrect == false)
            const Icon(Icons.cancel, color: Colors.red, size: 20),
          if (!isSelected || isCorrect == null) const SizedBox(width: 4),
          const SizedBox(width: 8),
          Expanded(
              child: Text(label,
                  style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal))),
        ]),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SARILI GAME 1: All About Me
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSariliGame1() {
    final game = _sariliLevel1Games[_currentGameIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: _currentMainColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16)),
              child: Text(game['icon'], style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 14),
            Expanded(
                child: Text(game['question'],
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold))),
          ]),
          const SizedBox(height: 20),
          if (game['type'] == 'text_input') _buildTextInput(game),
          if (game['type'] == 'age_input') _buildAgeInput(game),
          if (game['type'] == 'choice' && game['id'] == 'about_gender')
            _buildGenderChoice(game),
          if (game['type'] == 'info') _buildInfoCard(game),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _currentMainColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Icon(Icons.lightbulb_rounded, color: _currentMainColor, size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(game['description'],
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade700))),
            ]),
          ),
        ])),
      ]),
    );
  }

  Widget _buildCharacterWidget() {
    return AnimatedBuilder(
      animation: _characterAnim,
      builder: (_, __) => Transform.scale(
        scale: _characterAnim.value,
        child: SizedBox(
          height: 80,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(_characterHappy ? '😊' : '🙂',
                style: const TextStyle(fontSize: 52)),
            const SizedBox(width: 12),
            if (_characterHappy)
              const Text('Nalinteg!',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green))
            else
              Text(_currentMainTitle,
                  style: TextStyle(
                      fontSize: 15,
                      color: _currentMainColor,
                      fontWeight: FontWeight.w500)),
          ]),
        ),
      ),
    );
  }

  Widget _buildTextInput(Map<String, dynamic> game) {
    final ctrl =
        game['id'] == 'about_home' ? _placeController : _nameController;
    return Column(children: [
      TextField(
        controller: ctrl,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: game['hint'],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      const SizedBox(height: 14),
      ElevatedButton(
        onPressed: () => _handleTextSubmit(ctrl.text),
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentMainColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Idulin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  Widget _buildAgeInput(Map<String, dynamic> game) {
    return Column(children: [
      TextField(
        controller: _ageController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: game['hint'],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
      const SizedBox(height: 14),
      ElevatedButton(
        onPressed: () => _handleTextSubmit(_ageController.text),
        style: ElevatedButton.styleFrom(
          backgroundColor: _currentMainColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: const Text('Idulin',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    ]);
  }

  Widget _buildGenderChoice(Map<String, dynamic> game) {
    return Row(
      children: List.generate(game['options'].length, (i) {
        final sel = _selectedGender == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => _handleGenderSelection(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: sel ? _currentMainColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: sel ? _currentMainColor : Colors.grey.shade300,
                    width: 2),
                boxShadow: sel
                    ? [
                        BoxShadow(
                            color: _currentMainColor.withOpacity(0.3),
                            blurRadius: 10)
                      ]
                    : [],
              ),
              child: Column(children: [
                Text(game['options'][i].split(' ').first,
                    style: const TextStyle(fontSize: 36)),
                const SizedBox(height: 6),
                Text(game['options'][i].split(' ').last,
                    style: TextStyle(
                        color: sel ? Colors.white : Colors.grey.shade800,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
              ]),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoCard(Map<String, dynamic> game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withOpacity(0.25)),
      ),
      child: Column(children: [
        Text(game['info'],
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(game['example'],
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _onCorrect,
          style: ElevatedButton.styleFrom(
              backgroundColor: _currentMainColor,
              foregroundColor: Colors.white),
          child: const Text('Naammuak!', style: TextStyle(fontSize: 15)),
        ),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SARILI GAME 2: Emotions
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSariliGame2() {
    final game = _sariliLevel2Games[_currentGameIndex];
    final choices = game['choices'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: _currentMainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16)),
            child: Text(game['question'],
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _currentMainColor),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          ...List.generate(choices.length, (i) {
            final sel = _selectedEmotionAnswer == i;
            final correct = i == game['correct'];
            return _choiceTile(
              label: choices[i],
              isSelected: sel,
              isCorrect: sel ? correct : null,
              onTap: () => _handleEmotionAnswer(
                  i, game['correct'], game['explanation'], game['tip']),
            );
          }),
          if (_showEmotionExplanation)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14)),
              child: Text(game['explanation'],
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center),
            ),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SARILI GAME 3: Daily Routines
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSariliGame3() {
    final game = _sariliLevel3Games[_currentGameIndex];
    final choices = game['choices'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          Text(game['question'],
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: _currentMainColor),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ...List.generate(choices.length, (i) {
            final sel = _selectedRoutineAnswer == i;
            final correct = i == game['correct'];
            return _choiceTile(
              label: choices[i],
              isSelected: sel,
              isCorrect: sel ? correct : null,
              onTap: () => _handleRoutineAnswer(
                  i, game['correct'], game['explanation'], game['tip']),
            );
          }),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  SARILI GAME 4: Preferences
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSariliGame4() {
    final game = _sariliLevel4Games[_currentGameIndex];
    final options = game['options'] as List;
    final emojis = game['emojis'] as List;
    final type = game['id'].toString().replaceFirst('preference_', '');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          Text(game['question'],
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _currentMainColor),
              textAlign: TextAlign.center),
          const SizedBox(height: 6),
          Text(game['description'],
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          const SizedBox(height: 20),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: List.generate(options.length, (i) {
              bool sel = false;
              if (type == 'food') {
                sel = _selectedFoodIndex == i;
              } else if (type == 'color') {
                sel = _selectedColorIndex == i;
              } else if (type == 'game') {
                sel = _selectedGameIndex == i;
              } else if (type == 'animal') {
                sel = _selectedAnimalIndex == i;
              }

              return GestureDetector(
                onTap: () => _handlePreferenceSelection(i, type),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    color: sel ? _currentMainColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: sel ? _currentMainColor : Colors.grey.shade300,
                        width: 2),
                    boxShadow: sel
                        ? [
                            BoxShadow(
                                color: _currentMainColor.withOpacity(0.3),
                                blurRadius: 10)
                          ]
                        : [],
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(emojis[i], style: const TextStyle(fontSize: 32)),
                        const SizedBox(height: 6),
                        Text(options[i],
                            style: TextStyle(
                                color:
                                    sel ? Colors.white : Colors.grey.shade700,
                                fontWeight:
                                    sel ? FontWeight.bold : FontWeight.normal,
                                fontSize: 12),
                            textAlign: TextAlign.center),
                      ]),
                ),
              );
            }),
          ),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAMILYA GAME 1: Family Members
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFamilyMembersGame() {
    final game = _pamilyaLevel1Games[_currentGameIndex];
    final choices = game['choices'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _currentMainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Text(game['question'],
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: _currentMainColor),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          ...List.generate(choices.length, (i) {
            final sel = _selectedFamilyAnswer == i;
            final correct = i == game['correct'];
            return _choiceTile(
              label: choices[i],
              isSelected: sel,
              isCorrect: sel ? correct : null,
              onTap: () => _handleFamilyAnswer(i, game['correct'], game),
            );
          }),
          if (_showingFamilyInfo && _selectedFamilyMember != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _currentMainColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _currentMainColor.withOpacity(0.4)),
              ),
              child: Column(children: [
                Text(game['emoji'], style: const TextStyle(fontSize: 52)),
                const SizedBox(height: 8),
                Text('Si ${game['member']} ay ${game['roles']}.',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10)),
                  child: Text('📖 ${game['ilocano_note']}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber.shade900,
                          fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center),
                ),
              ]),
            ),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAMILYA GAME 2: Family Roles
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFamilyRolesGame() {
    final game = _pamilyaLevel2Games[_currentGameIndex];
    final choices = game['choices'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: _currentMainColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: Text(game['question'],
                style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: _currentMainColor),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          ...List.generate(choices.length, (i) {
            final sel = _selectedRoleAnswer == i;
            final correct = i == game['correct'];
            return _choiceTile(
              label: choices[i],
              isSelected: sel,
              isCorrect: sel ? correct : null,
              onTap: () =>
                  _handleRoleAnswer(i, game['correct'], game['explanation']),
            );
          }),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAMILYA GAME 3: Family Activities
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFamilyActivitiesGame() {
    final game = _pamilyaLevel3Games[_currentGameIndex];
    final choices = game['choices'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _buildCharacterWidget(),
        const SizedBox(height: 12),
        _gameCard(
            child: Column(children: [
          Text(game['question'],
              style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: _currentMainColor),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ...List.generate(choices.length, (i) {
            final sel = _selectedActivityAnswer == i;
            final correct = i == game['correct'];
            return _choiceTile(
              label: choices[i],
              isSelected: sel,
              isCorrect: sel ? correct : null,
              onTap: () => _handleActivityAnswer(
                  i, game['correct'], game['explanation']),
            );
          }),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAMILYA GAME 4: Family Tree (Interactive)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildFamilyTreeGame() {
    final generations = _familyTreeData['generations'] as List;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _gameCard(
            child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.account_tree_rounded,
                color: _currentMainColor, size: 24),
            const SizedBox(width: 8),
            Text('Puno ti Pamilya',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _currentMainColor)),
          ]),
          const SizedBox(height: 6),
          Text(
              'Ti puno ti pamilya ket nagpapakita dagiti miyembro ti pamilyam manipud iti nataengan agingga iti kaungpus.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),

          // Tree visualization
          ...List.generate(generations.length, (gi) {
            final gen = generations[gi];
            final members = gen['members'] as List;
            final genColor = gen['color'] as Color;

            return Column(children: [
              // Generation connector line
              if (gi > 0)
                Container(width: 2, height: 24, color: Colors.grey.shade300),

              // Generation container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: genColor.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(18),
                  border:
                      Border.all(color: genColor.withOpacity(0.3), width: 1.5),
                ),
                child: Column(children: [
                  Text(gen['title'],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: genColor)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    alignment: WrapAlignment.center,
                    children: members
                        .map((m) => GestureDetector(
                              onTap: () => _showFeedback(
                                  '${m['emoji']} ${m['relation']}', genColor),
                              child: Column(children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: genColor.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: genColor.withOpacity(0.5),
                                        width: 2),
                                  ),
                                  child: Center(
                                      child: Text(m['emoji'],
                                          style:
                                              const TextStyle(fontSize: 26))),
                                ),
                                const SizedBox(height: 4),
                                SizedBox(
                                  width: 72,
                                  child: Text(m['relation'],
                                      style: const TextStyle(fontSize: 9),
                                      textAlign: TextAlign.center),
                                ),
                              ]),
                            ))
                        .toList(),
                  ),
                ]),
              ),
              const SizedBox(height: 4),
            ]);
          }),

          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14)),
            child: const Text(
                '💡 Tiknapen dagiti miyembro tapno maammuan ti relasyon da!',
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleFamilyTreeComplete,
              icon: const Icon(Icons.check_circle, color: Colors.white),
              label: const Text('Naammuak ti Puno ti Pamilya!',
                  style: TextStyle(fontSize: 15, color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentMainColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ])),
      ]),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAMILYA GAME 5: My Home (Interactive Room Tap)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildMyHomeGame() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        _gameCard(
            child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.home_rounded, color: _currentMainColor, size: 26),
            const SizedBox(width: 8),
            Text('Ti Balaymi',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: _currentMainColor)),
          ]),
          const SizedBox(height: 6),
          Text('Tiknapen ti tunggal kuarto tapno maammuan ti aramidenyo ditoy!',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),

          // Simple house illustration
          _buildHouseIllustration(),

          const SizedBox(height: 20),

          // Room tiles
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: List.generate(_homeRooms.length, (i) {
              final room = _homeRooms[i];
              final visited =
                  _selectedRoomIndex != null && _selectedRoomIndex! >= i;
              final roomColor = room['color'] as Color;
              return GestureDetector(
                onTap: () => _handleRoomTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  decoration: BoxDecoration(
                    color: visited ? roomColor.withOpacity(0.15) : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                        color: visited ? roomColor : Colors.grey.shade300,
                        width: 2),
                    boxShadow: visited
                        ? [
                            BoxShadow(
                                color: roomColor.withOpacity(0.2),
                                blurRadius: 8)
                          ]
                        : [],
                  ),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(room['emoji'],
                            style: const TextStyle(fontSize: 30)),
                        const SizedBox(height: 6),
                        Text(room['name'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: visited
                                    ? roomColor
                                    : Colors.grey.shade700)),
                        if (visited)
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                      ]),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          if (_selectedRoomIndex != null)
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: (_homeRooms[_selectedRoomIndex!]['color'] as Color)
                    .withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                '🏠 ${_homeRooms[_selectedRoomIndex!]['name']}: ${_homeRooms[_selectedRoomIndex!]['activity']}',
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ),

          const SizedBox(height: 16),

          if (!_myHomeCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleMyHomeComplete,
                icon: const Icon(Icons.home, color: Colors.white),
                label: const Text('Dayta ti balaymi!',
                    style: TextStyle(fontSize: 15, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _currentMainColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
        ])),
      ]),
    );
  }

  Widget _buildHouseIllustration() {
    return SizedBox(
      height: 130,
      child: Stack(alignment: Alignment.bottomCenter, children: [
        // House body
        Positioned(
          bottom: 0,
          child: Container(
            width: 180,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.brown.shade200,
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8)),
            ),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Windows
                  Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: Colors.lightBlue.shade200,
                          borderRadius: BorderRadius.circular(4))),
                  // Door
                  Container(
                      width: 32,
                      height: 52,
                      margin: const EdgeInsets.only(top: 38),
                      decoration: BoxDecoration(
                          color: Colors.brown.shade600,
                          borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              topRight: Radius.circular(8)))),
                  Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                          color: Colors.lightBlue.shade200,
                          borderRadius: BorderRadius.circular(4))),
                ]),
          ),
        ),
        // Roof
        Positioned(
          top: 0,
          child: CustomPaint(
            painter: _TrianglePainter(Colors.brown.shade400),
            child: const SizedBox(width: 200, height: 55),
          ),
        ),
        // Chimney
        Positioned(
          top: 6,
          right: 52,
          child: Container(
              width: 16,
              height: 28,
              decoration: BoxDecoration(
                  color: Colors.brown.shade600,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)))),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  TRIANGLE PAINTER (house roof)
// ─────────────────────────────────────────────────────────────────────────────
class _TrianglePainter extends CustomPainter {
  final Color color;
  _TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Keep old TrianglePainter name for backward compatibility
class TrianglePainter extends _TrianglePainter {
  TrianglePainter(super.color);
}
