// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import '../main.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../utils/translations.dart';
import 'dart:async';

// ─────────────────────────────────────────────────────────────────────────────
//  MAIN SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class MagbasaScreen extends StatefulWidget {
  const MagbasaScreen({super.key});

  @override
  State<MagbasaScreen> createState() => _MagbasaScreenState();
}

class _MagbasaScreenState extends State<MagbasaScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late SharedPreferences _prefs;
  bool _isLoading = true;

  // ── Progress ───────────────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _categoryProgress = {
    'tula': {
      'total': 5,
      'completed': 0,
      'icon': '📖',
      'color': const Color(0xFFFF6B6B),
      'image': 'assets/images/category_tula.png',
      'activities': [
        {
          'title': 'Sipsipat',
          'completed': false,
          'type': 'poem',
          'image': 'assets/images/poem1.png'
        },
        {
          'title': 'Adda Asok',
          'completed': false,
          'type': 'poem',
          'image': 'assets/images/poem2.png'
        },
        {
          'title': 'Ti Pusak',
          'completed': false,
          'type': 'poem',
          'image': 'assets/images/poem3.png'
        },
        {
          'title': 'Ni Tatang',
          'completed': false,
          'type': 'poem',
          'image': 'assets/images/poem4.png'
        },
        {
          'title': 'Panagsepilio',
          'completed': false,
          'type': 'poem',
          'image': 'assets/images/poem5.png'
        },
      ]
    },
    'kwento': {
      'total': 5,
      'completed': 0,
      'icon': '📚',
      'color': const Color(0xFFFFB347),
      'image': 'assets/images/category_kwento.png',
      'activities': [
        {
          'title': 'Ni Marti ken Kalapati',
          'completed': false,
          'type': 'story',
          'image': 'assets/images/kwento1.png'
        },
        {
          'title': 'Ni Didi a Naayat iti Kendi',
          'completed': false,
          'type': 'story',
          'image': 'assets/images/kwento2.png'
        },
        {
          'title': 'Ni Milio a Managsepilio',
          'completed': false,
          'type': 'story',
          'image': 'assets/images/kwento3.png'
        },
        {
          'title': 'Ni Neneng a Dina Kayat ti Nateng',
          'completed': false,
          'type': 'story',
          'image': 'assets/images/kwento4.png'
        },
        {
          'title': 'Ni Kikay a di Agsagsaysay',
          'completed': false,
          'type': 'story',
          'image': 'assets/images/kwento5.png'
        },
      ]
    },
    'kanta': {
      'total': 13,
      'completed': 0,
      'icon': '🎵',
      'color': const Color(0xFFA8E6CF),
      'image': 'assets/images/category_kanta.png',
      'activities': [
        {
          'title': 'Ania ti Naganmo?',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_nagan.png'
        },
        {
          'title': 'Ania ti Nagan Mo (Full)',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_nagan.png'
        },
        {
          'title': 'Uppat a Pato',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_pato.png'
        },
        {
          'title': 'Duat\' Imak',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_imak.png'
        },
        {
          'title': 'Agrimat-rimat Bassit a Bituen',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_bituen.png'
        },
        {
          'title': 'Bassit a Lawwalawwa',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_lawwa.png'
        },
        {
          'title': 'Lay, Lay, Lay, Apo Lakay',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_lakay.png'
        },
        {
          'title': 'Maysa, Dua, Baduya',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_baduya.png'
        },
        {
          'title': 'Ni Nanangko',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_nanang.png'
        },
        {
          'title': 'Adda Bullilisingko',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_bullilis.png'
        },
        {
          'title': 'Da Tarong, Kamatis ken Paria',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_tarong.png'
        },
        {
          'title': 'Nanumo a Kalapaw',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_kalapaw.png'
        },
        {
          'title': 'Nagmulaak iti Katuday',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_katuday.png'
        },
        {
          'title': 'Lima a Tinapay ken dua nga Ikan',
          'completed': false,
          'type': 'song',
          'image': 'assets/images/song_tinapay.png'
        },
      ]
    },
  };

  // ── Poem data ──────────────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _poemData = {
    'Sipsipat': {
      'title': 'Sipsipat',
      'content': [
        'Sipsipat, sipsipat',
        'Addaanak patupat',
        'Kanek ti agpatpatnag',
        'Bayat ti panagbasak',
      ],
      'image': 'assets/images/poem1.png',
    },
    'Adda Asok': {
      'title': 'Adda Asok',
      'content': [
        'Adda asok',
        'Bond Puraw a burbor',
        'Gog-gog-gog-gog',
        'No agtaul',
        'Titit, asok, gog-gog-gog',
        'Titit, asok, gog-gog-gog-gog!',
      ],
      'image': 'assets/images/poem2.png',
    },
    'Ti Pusak': {
      'title': 'Ti Pusak',
      'content': [
        'Adda pusak a bassit',
        'Kolornat nangisit',
        'Dina kayat ti pansit',
        'Ngem kayatnat ikan a babassit.',
        '',
        'Tunggal makitanak ti pusak',
        'Dagus nga asitgannak',
        'Miaw-miaw-miaw kunana',
        'Ikkak metten iti kanenna',
      ],
      'image': 'assets/images/poem3.png',
    },
    'Ni Tatang': {
      'title': 'Ni Tatang',
      'content': [
        'Ni Tatang naanus unay',
        'No tiempo ti tudtudo',
        'Isu pay ti nangted balay',
        'Isu pay ti mangituray',
        'Kadakami nga agkakabbalay.',
        '',
        'Mapan latta agarado',
        'Agmulmulat nadumaduma',
        'A taraon ti pamiliana.',
      ],
      'image': 'assets/images/poem4.png',
    },
    'Panagsepilio': {
      'title': 'Panagsepilio',
      'content': [
        'Panagsepilio',
        'Agmalem, mamitlo',
        'Sang-aw, nabanglo',
        'Nakaprespresko',
      ],
      'image': 'assets/images/poem5.png',
    },
  };

  // ── Story data ─────────────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _storyData = {
    'Ni Marti ken Kalapati': {
      'title': 'Ni Marti ken Kalapati',
      'content': [
        'Maysa nga aldaw, nagpasiar ni Marti idiay igid ti kali.',
        'Nakakita ni Marti iti kalapati idiay igid ti kali.',
        'Nakita ni Marti a tukkol gayam ti payyak ti kalapati.',
        'Pinidut ni Marti ti kalapati ket inyawidna idiay balayda.',
        'Impupok ni Marti ti kalapati sana inagasan.',
        'Pinakan ken pinainum ni Marti ti kalapati.',
        'Idi immimbagen, pinalsutan ni Marti ti kalapati.',
        'Makaay-ayat ni Marti ta natulonganna ti kalapati.',
      ],
      'image': 'assets/images/kwento1.png',
    },
    'Ni Didi a Naayat iti Kendi': {
      'title': 'Ni Didi a Naayat iti Kendi',
      'content': [
        'Naayat ni Didi iti kendi.',
        'Tunggal ikkan ni Nanangna iti balonna a kuarta iti inaldaw, igatang amin ni Didi iti kendi.',
        'Inaldaw latta a mangmangan ni Didi iti kendi.',
        'Uray idiay balayda, adda latta kendi a kankanen ni Didi.',
        'Kasta unay sakit ti ngipenna.',
        'Maysa nga aldaw, nangliwat ni Didi idiay eskuelada.',
        'Impakita ni Nanangna iti dentista.',
        'Naduktalan ti dentista nga adu ti naperdi a ngipen ni Didi.',
        'Nanipud idin, saanen a mangmangan ni Didi iti kendi.',
      ],
      'image': 'assets/images/kwento2.png',
    },
    'Ni Milio a Managsepilio': {
      'title': 'Ni Milio a Managsepilio',
      'content': [
        'Managsepilio ni Milio.',
        'Tunggal malpas a mangan, agsepilio a kanayon ni Milio.',
        'Maysa nga aldaw, nagtsek ni Maestrana iti ngipen dagiti adalanna.',
        'Nadlaw ni Maestrana a nadalus dagiti ngipen ni Milio.',
        'Pinalakpakanda ni Milio.',
        'Naragsak a nagawid ni Milio.',
        'Intultuloy ni Milio ti kanayon nga inna panagsepilio.',
      ],
      'image': 'assets/images/kwento3.png',
    },
    'Ni Neneng a Dina Kayat ti Nateng': {
      'title': 'Ni Neneng a Dina Kayat ti Nateng',
      'content': [
        'Di pulos kayat ni Neneng ti agsida iti nateng.',
        'Uray no ibaga ni Nanangna nga agsida iti nateng, di latta kayat ni Neneng.',
        'Maysa nga aldaw, nagkapsut ni Neneng idiay eskuelada.',
        'Impan ti Maestrana ni Neneng iti klinika.',
        'Naammuan ti doktor a saan nga agsidsida ni Neneng iti nateng.',
        'Imbaga ti doktor nga agsida ni Neneng iti nateng.',
        'Manipud idin, kanayonen nga agsidsida ni Neneng iti nateng.',
      ],
      'image': 'assets/images/kwento4.png',
    },
    'Ni Kikay a di Agsagsaysay': {
      'title': 'Ni Kikay a di Agsagsaysay',
      'content': [
        'Di pulos kayat ni Kikay ti agsagaysay.',
        'Uray ayaban ni Nanangna, di latta pulos kayat ni Kikay ti agsagaysay.',
        'Idiay eskuelada, awan manggayat a makikatugaw kenni Kikay.',
        'Rugpaw ti buokna ken adu pay ti kutona.',
        'Nagsangsangit ni Kikay ta awan mayat a makiay-ayam kenkuana.',
        'Idi agawid idiay balayda kalpasan ti klaseda, nakasabat iti baket.',
        'Rugpaw ti buok ti baket.',
        'Nagbuteng ni Kikay ket nagtartaray a nagawid balayda.',
        'Manipud idin, kanayonen nga agsagsagaysay ni Kikay.',
        'Immadu dagiti gagayyemna ket kanayon payen a naragsak ni Kikay.',
      ],
      'image': 'assets/images/kwento5.png',
    },
  };

  // ── Song data ──────────────────────────────────────────────────────────────
  final Map<String, Map<String, dynamic>> _songData = {
    'Ania ti Naganmo?': {
      'title': 'Ania ti Naganmo?',
      'tune': 'Audio Recording',
      'lyrics': [
        'Ania ti naganmo',
        'Ibagam man gayyemko',
        'Abrasaenta man',
        'Dayta dakulapmo',
        'Aginnisemta pay',
        'Iti makaay-ayo',
        'Agsala, agkanta',
        'Itung-ed ti ulo.',
      ],
      'image': 'assets/images/song_nagan.png',
      'audioPath': 'audio/Ania ti Nagan Mo by Kurtjam Kyle Silva Nono.mp3',
      'action': 'Wave hands and dance',
    },
    'Ania ti Nagan Mo (Full)': {
      'title': 'Ania ti Nagan Mo (Full)',
      'tune': 'Leron, Leron Sinta',
      'lyrics': [
        'Ania ti naganmo',
        'Ibagam man gayyemko',
        'Abrasaenta man',
        'Dayta dakulapmo',
        'Aginnisemta pay',
        'Iti makaay-ayo',
        'Agsala, agkanta',
        'Itung-ed ti ulo.',
      ],
      'image': 'assets/images/song_nagan.png',
      'action': 'Listen and follow the song',
    },
    'Uppat a Pato': {
      'title': 'Uppat a Pato',
      'tune': 'Original',
      'lyrics': [
        'Uppat a pato',
        'Ti nakitak',
        'Dua ti nalukmeg',
        'Dua ti nakuttong',
        'Agkukuyogda',
        'Ngem tay kabassitan',
        'Atiddog ti ipusna',
        'Karinggoran kunana',
        '"Kuak-kuak-kuak!"',
      ],
      'image': 'assets/images/song_pato.png',
      'action': 'Count with fingers and waddle like a duck',
    },
    'Duat\' Imak': {
      'title': 'Duat\' Imak',
      'tune': 'I Have Two Hands',
      'lyrics': [
        'Duat imak',
        'Kannigid ken kannawan',
        'Ingatok ida nadalusda',
        'Agsipatda, maysa, dua',
        '',
        'Nadalus nga ima, makaay-ayoda.',
      ],
      'image': 'assets/images/song_imak.png',
      'action': 'Show your hands and clap',
    },
    'Agrimat-rimat Bassit a Bituen': {
      'title': 'Agrimat-rimat Bassit a Bituen',
      'tune': 'Twinkle, Twinkle Little Star',
      'lyrics': [
        'Agrimat-rimat, bassit a bituen',
        'Masdaawannak no aniaka',
        'Idiay ngatuen ti lubong',
        'Kasla diamante idiay langit',
        'Agrimat-rimat, bassit a bituen',
        'Masdaawannak no aniaka.',
      ],
      'image': 'assets/images/song_bituen.png',
      'action': 'Twinkle fingers like stars',
    },
    'Bassit a Lawwalawwa': {
      'title': 'Bassit a Lawwalawwa',
      'tune': 'Itsy Bitsy Spider',
      'lyrics': [
        'Bassit a lawwalawwa',
        'Immuli diay sanga',
        'Rimmuar ti tudo',
        'Dagus nagbasa',
        'Rimmuar ti init',
        'Amin nagmaga',
        'Bassit a lawwalawwa',
        'Immuli diay sanga',
      ],
      'image': 'assets/images/song_lawwa.png',
      'action': 'Spider hand movements climbing up',
    },
    'Lay, Lay, Lay, Apo Lakay': {
      'title': 'Lay, Lay, Lay, Apo Lakay',
      'tune': 'Fly, Fly, the Butterfly',
      'lyrics': [
        'Lay, lay, lay, Apo Lakay',
        'Pimmasiar idiay Paoay',
        'Gimmatang iti wasay',
        'Lay, lay, lay, Apo Lakay.',
        '',
        'Lay, lay, lay, Apo Lakay',
        'Nagbaklay iti pagay',
        'Iti tambak nagtalaytay',
        'Lay, lay, lay, Apo Lakay.',
        '',
        'Lay, lay, lay, Apo Lakay',
        'Simmang-at sadiay bantay',
        'Agala iti lipay',
        'Lay, lay, lay, Apo Lakay.',
        '',
        'Lay, lay, lay, Apo Lakay',
        'Nagpakat iti sigay',
        'Pagala iti layalay',
        'Lay, lay, lay, Apo Lakay.',
      ],
      'image': 'assets/images/song_lakay.png',
      'action': 'Flutter like a butterfly',
    },
    'Maysa, Dua, Baduya': {
      'title': 'Maysa, Dua, Baduya',
      'tune': 'Original',
      'lyrics': [
        'Maysa, dua, baduya',
        'Tallo, uppat, patupat',
        'Lima, innem, kankanen',
        'Pito, walo, ginao',
        'Siam, pullo, mangantayo',
        'Lubi-lubi.',
      ],
      'image': 'assets/images/song_baduya.png',
      'action': 'Count with fingers 1-10',
    },
    'Ni Nanangko': {
      'title': 'Ni Nanangko',
      'tune': 'Original',
      'lyrics': [
        'Ni Nanangko ay-ayatennak',
        'Ub-ubbaennak no masakitak',
        'Barukongnat pagsadsadagak',
        'Ayatna nga agbiagak.',
        '',
        'Naragsak ti aldaw ni Nanangko',
        'Nayanak iti bulan ti Mayo',
        'Panaglalangto ti kaykayo',
        'Bungbungadat adu.',
      ],
      'image': 'assets/images/song_nanang.png',
      'action': 'Hug yourself and sway',
    },
    'Adda Bullilisingko': {
      'title': 'Adda Bullilisingko',
      'tune': 'Original',
      'lyrics': [
        'Adda bullilisingko',
        'A nalaing nga agsirko',
        'Dutdotnat makaayayo',
        'Adu ti agrayo.',
        '',
        'Gustona ti saba',
        'Ibusennat maysa',
        'Ngem no ngadan kumanta',
        'Ay maayayoka.',
      ],
      'image': 'assets/images/song_bullilis.png',
      'action': 'Flap arms like a chicken',
    },
    'Da Tarong, Kamatis ken Paria': {
      'title': 'Da Tarong, Kamatis ken Paria',
      'tune': 'Original',
      'lyrics': [
        'Iti bigbigat nga agsapa',
        'Agtatamdagak man idiay tawa',
        'Adda da Tarong, Kamatis Paria',
        'Nangngegko ida nga agsasarita',
        '',
        'Ti kunan Tarong kadakuada',
        'Siak kaimasan kadakay a dua',
        'Ni ngarud Paria simmungbat ita',
        'Bay-am man, Tarong napalangguadka.',
        '',
        'Ni Kamatis immisem laeng',
        'Ay kakabsatko inkay agparbeng',
        'Ta no addaak iti dinengdeng',
        'Ni pinakbet naimas laeng.',
      ],
      'image': 'assets/images/song_tarong.png',
      'action': 'Point to different vegetables',
    },
    'Nanumo a Kalapaw': {
      'title': 'Nanumo a Kalapaw',
      'tune': 'Bahay Kubo',
      'lyrics': [
        'Nanumo a kalapaw',
        'Kawayan ken pan-aw',
        'Ngem napno ti aglawlaw',
        'Natnateng naimas unay',
        'Karabasa, tabungaw',
        'Kamatis, marunggay',
        'Tarong, sili, patani',
      ],
      'image': 'assets/images/song_kalapaw.png',
      'action': 'Make roof shape with hands',
    },
    'Nagmulaak iti Katuday': {
      'title': 'Nagmulaak iti Katuday',
      'tune': 'Magtanim ay di Biro',
      'lyrics': [
        'Nagmulaak iti katuday',
        'Idiay igid ti bambantay',
        'Napan met kinaraykay',
        'Ni nadawel a kannaway.',
        '',
        'Aluadam kannaway',
        'Ta putputdek ta ramramay',
        'Aramidek a sagaysay',
        'Sagaysay ni Lola Kikay.',
      ],
      'image': 'assets/images/song_katuday.png',
      'action': 'Planting motion',
    },
    'Lima a Tinapay ken dua nga Ikan': {
      'title': 'Lima a Tinapay ken dua nga Ikan',
      'tune': 'Original',
      'lyrics': [
        'Lima a tinapay ken dua nga ikan (3x)',
        'Intugot diay ubing',
        '',
        'Lima a tinapay ken dua nga ikan (3x)',
        'Ni Hesus nagkararag.',
        '',
        'Immadu tay tinapay, immadu met tay ikan (3x)',
        'Ket nabsogda amin.',
      ],
      'image': 'assets/images/song_tinapay.png',
      'action': 'Show five fingers then two fingers',
    },
  };

  // ─────────────────────────────────────────────────────────────────────────
  //  Lifecycle
  // ─────────────────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadProgress();
    _initSmartResume();
  }

  Future<void> _initSmartResume() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      int retryCount = 0;
      while (!userProvider.isInitialized && retryCount < 10) {
        await Future.delayed(const Duration(milliseconds: 200));
        retryCount++;
      }

      // Tab mapping: 0=Tula, 1=Kwento, 2=Kanta
      int targetTab = 0;
      bool found = false;

      // Check categories in order
      List<String> categories = ['tula', 'kwento', 'kanta'];
      for (int i = 0; i < categories.length; i++) {
        String cat = categories[i];
        List activities = _categoryProgress[cat]!['activities'];
        bool catCompleted = true;
        for (int j = 0; j < activities.length; j++) {
          if (!userProvider.isMagbasaActivityCompleted(cat, j)) {
            targetTab = i;
            catCompleted = false;
            found = true;
            break;
          }
        }
        if (found) break;
        if (!catCompleted) {
          targetTab = i;
          break;
        }
      }

      if (mounted) {
        _tabController.animateTo(targetTab);
      }
    } catch (e) {
      debugPrint('Magbasa Smart Resume failed: $e');
    }
  }

  Future<void> _loadProgress() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      for (final category in _categoryProgress.keys) {
        for (int i = 0;
            i < (_categoryProgress[category]!['activities'] as List).length;
            i++) {
          final done = _prefs.getBool('${category}_activity_$i') ?? false;
          (_categoryProgress[category]!['activities'] as List)[i]['completed'] =
              done;
        }
      }
      _updateAllCompletedCounts();
      _isLoading = false;
    });
  }

  void _updateAllCompletedCounts() {
    for (final category in _categoryProgress.keys) {
      int count = 0;
      for (final act in (_categoryProgress[category]!['activities'] as List)) {
        if (act['completed'] == true) count++;
      }
      _categoryProgress[category]!['completed'] = count;
    }
  }

  Future<void> _updateProgress(
      String category, int activityIndex, bool completed) async {
    setState(() {
      (_categoryProgress[category]!['activities'] as List)[activityIndex]
          ['completed'] = completed;
      _updateAllCompletedCounts();
    });
    await _prefs.setBool('${category}_activity_$activityIndex', completed);
    if (completed) {
      if (!mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.updateMagbasaProgress(category, activityIndex, true);
      userProvider.addStars(3);
    }
  }

  int _getTotalCompleted() {
    int t = 0;
    _categoryProgress.forEach((_, v) => t += v['completed'] as int);
    return t;
  }

  int _getTotalActivities() {
    int t = 0;
    _categoryProgress.forEach((_, v) => t += v['total'] as int);
    return t;
  }

  double _getCategoryProgress(String category) {
    final total = _categoryProgress[category]!['total'] as int;
    final done = _categoryProgress[category]!['completed'] as int;
    return total > 0 ? done / total : 0;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final totalCompleted = _getTotalCompleted();
    final totalActivities = _getTotalActivities();
    final overallProgress =
        totalActivities > 0 ? totalCompleted / totalActivities : 0.0;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textDark,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          Translations.getMagbasaTitle(context),
          style: const TextStyle(
              color: AppColors.textDark,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Column(children: [
        // Overall progress card
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade400],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Row(children: [
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/progress_icon.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.auto_stories,
                        color: Colors.white, size: 40),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      Translations.getTotalProgress(context),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: overallProgress,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${(overallProgress * 100).toInt()}%',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text(
                      '$totalCompleted/$totalActivities ${Translations.getCompleted(context).toLowerCase()}',
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ),

        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey.shade500,
            tabs: const [
              Tab(text: 'DANIW', icon: Icon(Icons.menu_book)),
              Tab(text: 'SARITA', icon: Icon(Icons.book)),
              Tab(text: 'KANTA', icon: Icon(Icons.music_note)),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCategoryTab('tula'),
              _buildCategoryTab('kwento'),
              _buildCategoryTab('kanta'),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildCategoryTab(String category) {
    final data = _categoryProgress[category]!;
    final activities = data['activities'] as List;
    final progress = _getCategoryProgress(category);
    final color = data['color'] as Color;
    final icon = data['icon'] as String;
    final catImage = data['image'] as String;

    String title = category == 'tula'
        ? Translations.getPoems(context)
        : category == 'kwento'
            ? Translations.getStories(context)
            : Translations.getSongs(context);

    return Container(
      color: Colors.grey.shade50,
      child: Column(children: [
        // Category header
        Container(
          height: 100,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 5,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: color.withOpacity(0.3), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: Image.asset(
                  catImage,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Center(
                      child: Text(icon, style: const TextStyle(fontSize: 30))),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(title.toUpperCase(),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16)),
                      child: Text(
                        '${data['completed']}/${data['total']}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: color),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          ]),
        ),

        // Activity list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: activities.length,
            itemBuilder: (_, index) {
              final activity = activities[index];
              return _buildActivityItem(
                title: activity['title'],
                type: activity['type'],
                isCompleted: activity['completed'],
                color: color,
                imagePath: activity['image'],
                onTap: () => _navigateToActivity(
                    category, index, activity['title'], activity['type']),
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget _buildActivityItem({
    required String title,
    required String type,
    required bool isCompleted,
    required Color color,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    final IconData typeIcon = type == 'poem'
        ? Icons.menu_book
        : type == 'story'
            ? Icons.book
            : Icons.music_note;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: isCompleted ? color.withOpacity(0.5) : Colors.grey.shade200,
            width: 1.5),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2))
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? color.withOpacity(0.1)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isCompleted
                          ? color.withOpacity(0.3)
                          : Colors.grey.shade300,
                      width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(typeIcon,
                          color: isCompleted ? color : Colors.grey.shade500,
                          size: 24),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isCompleted ? FontWeight.w600 : FontWeight.normal,
                          color: isCompleted ? color : AppColors.textDark,
                        ),
                      ),
                      if (isCompleted) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            Translations.getCompleted(context),
                            style: TextStyle(
                                fontSize: 11,
                                color: color,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ]),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: isCompleted
                        ? color.withOpacity(0.1)
                        : Colors.transparent,
                    shape: BoxShape.circle),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.arrow_forward_ios,
                  color: isCompleted ? color : Colors.grey.shade400,
                  size: 18,
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToActivity(
      String category, int index, String title, String type) async {
    Widget screen;
    if (category == 'tula') {
      screen = PoemScreen(poemTitle: title, poemData: _poemData[title]!);
    } else if (category == 'kwento') {
      screen = StoryScreen(storyTitle: title, storyData: _storyData[title]!);
    } else {
      screen = SongScreen(songTitle: title, songData: _songData[title]!);
    }

    final completed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );

    if (completed == true) {
      await _updateProgress(category, index, true);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  POEM SCREEN  — full single-scroll display
// ─────────────────────────────────────────────────────────────────────────────
class PoemScreen extends StatelessWidget {
  final String poemTitle;
  final Map<String, dynamic> poemData;

  static const Color _poemColor = Color(0xFFFF6B6B);

  const PoemScreen({
    super.key,
    required this.poemTitle,
    required this.poemData,
  });

  @override
  Widget build(BuildContext context) {
    final content = poemData['content'] as List;
    final imagePath = poemData['image'] as String;

    return Scaffold(
      backgroundColor: const Color(0xFFFFF5F5),
      body: CustomScrollView(
        slivers: [
          // ── Decorative header ─────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 260,
            pinned: true,
            backgroundColor: _poemColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context, false),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _markComplete(context),
                icon: const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 18),
                label: Text(
                  Translations.getDone(context),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                poemTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
                textAlign: TextAlign.center,
              ),
              background: Stack(fit: StackFit.expand, children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _poemColor.withOpacity(0.4),
                    child: const Center(
                        child: Text('📖', style: TextStyle(fontSize: 80))),
                  ),
                ),
                // Gradient overlay so title is readable
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _poemColor.withOpacity(0.85),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // ── Poem content ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _poemColor.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Decorative divider top
                    _decorativeDivider(),
                    const SizedBox(height: 20),

                    // All lines
                    ...content.map((line) {
                      final text = line as String;
                      if (text.isEmpty) {
                        return const SizedBox(height: 18); // stanza break
                      }
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.65,
                            color: Color(0xFF2D2D2D),
                            fontStyle: FontStyle.italic,
                            letterSpacing: 0.3,
                          ),
                        ),
                      );
                    }),

                    const SizedBox(height: 20),
                    _decorativeDivider(),
                  ],
                ),
              ),
            ),
          ),

          // ── "Basak" button ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(children: [
                // Small reading hint
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _poemColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline,
                            color: _poemColor, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Basaem ti intero a daniw sakbay iti panagsubli.',
                            style: TextStyle(
                                fontSize: 13,
                                color: _poemColor.withOpacity(0.9)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _markComplete(context),
                    icon: const Icon(Icons.check_circle_rounded,
                        color: Colors.white),
                    label: const Text(
                      'Basak ti Daniw! ✓',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _poemColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                      shadowColor: _poemColor.withOpacity(0.4),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _decorativeDivider() {
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(width: 40, height: 1.5, color: _poemColor.withOpacity(0.3)),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: Text('🌸', style: TextStyle(fontSize: 16, color: _poemColor)),
      ),
      Container(width: 40, height: 1.5, color: _poemColor.withOpacity(0.3)),
    ]);
  }

  void _markComplete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: _poemColor, size: 48),
            SizedBox(height: 16),
            Text('✓ Nalpas! Naimbag ti panagbasam!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        Navigator.pop(context); // Pop dialog
        Navigator.pop(context, true); // Pop screen
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  STORY SCREEN  — full single-scroll display
// ─────────────────────────────────────────────────────────────────────────────
class StoryScreen extends StatelessWidget {
  final String storyTitle;
  final Map<String, dynamic> storyData;

  static const Color _storyColor = Color(0xFFFFB347);

  // Decorative paragraph dividers
  static const List<String> _dividerEmojis = ['🌟', '🌿', '☀️', '🌙', '🍀'];

  const StoryScreen({
    super.key,
    required this.storyTitle,
    required this.storyData,
  });

  @override
  Widget build(BuildContext context) {
    final content = storyData['content'] as List;
    final imagePath = storyData['image'] as String;

    // Split paragraphs on empty strings
    final List<List<String>> paragraphs = _splitIntoParagraphs(content);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFAF0),
      body: CustomScrollView(
        slivers: [
          // ── Cover header ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: _storyColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context, false),
            ),
            actions: [
              TextButton.icon(
                onPressed: () => _markComplete(context),
                icon: const Icon(Icons.check_circle_outline,
                    color: Colors.white, size: 18),
                label: Text(
                  Translations.getDone(context),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(
                storyTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black26, blurRadius: 4)],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(fit: StackFit.expand, children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _storyColor.withOpacity(0.4),
                    child: const Center(
                        child: Text('📚', style: TextStyle(fontSize: 80))),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        _storyColor.withOpacity(0.9)
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),

          // ── Story body ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: _storyColor.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: Border.all(
                    color: _storyColor.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildStoryContent(paragraphs),
                ),
              ),
            ),
          ),

          // ── "Nabasa Kon" button ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
              child: Column(children: [
                // Reading progress hint
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _storyColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.auto_stories,
                            color: _storyColor, size: 16),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            'Basaem ti intero a sarita sakbay iti panagsubli.',
                            style: TextStyle(
                                fontSize: 13,
                                color: _storyColor.withOpacity(0.9)),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ]),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _markComplete(context),
                    icon: const Icon(Icons.menu_book, color: Colors.white),
                    label: const Text(
                      'Nabasa Kon! ✓',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _storyColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18)),
                      elevation: 4,
                      shadowColor: _storyColor.withOpacity(0.4),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  List<List<String>> _splitIntoParagraphs(List content) {
    final paragraphs = <List<String>>[];
    var current = <String>[];
    for (final line in content) {
      final text = line as String;
      if (text.isEmpty) {
        if (current.isNotEmpty) {
          paragraphs.add(List.from(current));
          current = [];
        }
      } else {
        current.add(text);
      }
    }
    if (current.isNotEmpty) paragraphs.add(current);
    return paragraphs;
  }

  List<Widget> _buildStoryContent(List<List<String>> paragraphs) {
    final widgets = <Widget>[];
    for (int pi = 0; pi < paragraphs.length; pi++) {
      // Paragraph lines
      for (final line in paragraphs[pi]) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            line,
            style: const TextStyle(
              fontSize: 17,
              height: 1.75,
              color: Color(0xFF2D2D2D),
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.justify,
          ),
        ));
      }

      // Decorative divider between paragraphs (not after last)
      if (pi < paragraphs.length - 1) {
        final emoji = _dividerEmojis[pi % _dividerEmojis.length];
        widgets.add(Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
                width: 50, height: 1, color: _storyColor.withOpacity(0.25)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(emoji, style: const TextStyle(fontSize: 16)),
            ),
            Container(
                width: 50, height: 1, color: _storyColor.withOpacity(0.25)),
          ]),
        ));
      }
    }
    return widgets;
  }

  void _markComplete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: _storyColor, size: 48),
            SizedBox(height: 16),
            Text('✓ Nalpas! Naragsak ti panagbasam!',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
    Future.delayed(const Duration(seconds: 1), () {
      if (context.mounted) {
        Navigator.pop(context); // Pop dialog
        Navigator.pop(context, true); // Pop screen
      }
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  SONG SCREEN  — unchanged (line-highlighting + play controls)
// ─────────────────────────────────────────────────────────────────────────────
class SongScreen extends StatefulWidget {
  final String songTitle;
  final Map<String, dynamic> songData;

  const SongScreen({
    super.key,
    required this.songTitle,
    required this.songData,
  });

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen>
    with SingleTickerProviderStateMixin {
  bool _isCompleted = false;
  int _currentLineIndex = 0;
  bool _isPlaying = false;
  late AnimationController _pulseController;
  late AudioPlayer _audioPlayer;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _completeSubscription;

  static const Color _songColor = Color(0xFFA8E6CF);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
        duration: const Duration(milliseconds: 800), vsync: this);
    _audioPlayer = AudioPlayer();

    // Listen for completion
    _completeSubscription = _audioPlayer.onPlayerComplete.listen((event) {
      if (mounted) {
        _stopPlayback();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _positionSubscription?.cancel();
    _completeSubscription?.cancel();
    _audioPlayer.dispose();

    // Ensure music is unmuted if we leave while playing
    if (_isPlaying) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        AudioManager.instance.resumeMusic();
      });
    }
    super.dispose();
  }

  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _stopPlayback();
    } else {
      await _startPlayback();
    }
  }

  Future<void> _startPlayback() async {
    final audioPath = widget.songData['audioPath'] as String?;

    setState(() {
      _isPlaying = true;
      _pulseController.repeat(reverse: true);
    });

    // Mute background music
    await AudioManager.instance.pauseMusic();

    if (audioPath != null) {
      try {
        await _audioPlayer.play(AssetSource(audioPath));
      } catch (e) {
        debugPrint('Error playing song audio: $e');
        // Fallback to auto-advance if audio fails
        _autoAdvance();
      }
    } else {
      // No audio, use timer-based advance
      _autoAdvance();
    }
  }

  Future<void> _stopPlayback() async {
    setState(() {
      _isPlaying = false;
      _pulseController.stop();
    });

    await _audioPlayer.stop();

    // Resume background music
    await AudioManager.instance.resumeMusic();
  }

  void _autoAdvance() {
    final lyrics = widget.songData['lyrics'] as List;
    final audioPath = widget.songData['audioPath'] as String?;

    // Only auto-advance if there is no actual audio file playing
    if (audioPath != null) return;

    Future.delayed(const Duration(seconds: 2), () {
      if (!_isPlaying || !mounted) return;
      if (_currentLineIndex < lyrics.length - 1) {
        setState(() => _currentLineIndex++);
        _autoAdvance();
      } else {
        _stopPlayback();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lyrics = widget.songData['lyrics'] as List;
    final tune = widget.songData['tune'] as String;
    final imagePath = widget.songData['image'] as String;
    final action = widget.songData['action'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: _songColor,
        title: Text(widget.songTitle,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context, _isCompleted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _isCompleted = true);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(Translations.getCompleted(context)),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ));
              Future.delayed(const Duration(seconds: 1), () {
                if (!context.mounted) return;
                Navigator.pop(context, true);
              });
            },
            child: Text(
              Translations.getDone(context),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // Song image
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: _songColor.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5))
                ],
              ),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: _songColor.withOpacity(0.1),
                  child:
                      const Icon(Icons.music_note, size: 50, color: _songColor),
                ),
              ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            '${Translations.getTune(context)}: $tune',
            style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),

          // Action chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _songColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.directions_run, color: _songColor),
              const SizedBox(width: 8),
              Text('${Translations.getAction(context)}: $action',
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ]),
          ),

          const SizedBox(height: 24),

          // Lyrics with highlight
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: List.generate(lyrics.length, (index) {
                final isActive = index == _currentLineIndex && _isPlaying;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive
                        ? _songColor.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    lyrics[index],
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                      color: isActive
                          ? const Color(0xFF2D7A5A)
                          : Colors.grey.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 28),

          // Playback controls
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              onPressed: _currentLineIndex > 0
                  ? () => setState(() => _currentLineIndex--)
                  : null,
              icon: const Icon(Icons.skip_previous, size: 40),
              color: _songColor,
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: _togglePlay,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _songColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: _songColor.withOpacity(0.35),
                        blurRadius: 12,
                        spreadRadius: 2)
                  ],
                ),
                child: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 42,
                ),
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: _currentLineIndex < lyrics.length - 1
                  ? () => setState(() => _currentLineIndex++)
                  : null,
              icon: const Icon(Icons.skip_next, size: 40),
              color: _songColor,
            ),
          ]),

          const SizedBox(height: 10),
          Text(
            '${_currentLineIndex + 1} / ${lyrics.length}',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}
