class MagbasaContent {
  static String _lang = 'ilo';

  static void setLanguage(String lang) {
    _lang = lang;
  }

  // ── Category Progress Activities ──────────────────────────────────────
  static List<Map<String, dynamic>> getPoemActivities() {
    return _poemActivities[_lang] ?? _poemActivities['ilo']!;
  }

  static List<Map<String, dynamic>> getStoryActivities() {
    return _storyActivities[_lang] ?? _storyActivities['ilo']!;
  }

  static List<Map<String, dynamic>> getSongActivities() {
    return _songActivities[_lang] ?? _songActivities['ilo']!;
  }

  static const Map<String, List<Map<String, dynamic>>> _poemActivities = {
    'en': [
      {
        'id': 'sipsipat',
        'title': 'Dragonfly',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem1.png'
      },
      {
        'id': 'adda_asok',
        'title': 'My Dog',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem2.png'
      },
      {
        'id': 'ti_pusak',
        'title': 'The Kitty',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem3.png'
      },
      {
        'id': 'ni_tatang',
        'title': 'My Father',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem4.png'
      },
      {
        'id': 'panagsepilio',
        'title': 'Brushing Teeth',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem5.png'
      },
    ],
    'fil': [
      {
        'id': 'sipsipat',
        'title': 'Alitaptap',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem1.png'
      },
      {
        'id': 'adda_asok',
        'title': 'Ang Aso Ko',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem2.png'
      },
      {
        'id': 'ti_pusak',
        'title': 'Ang Pusa',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem3.png'
      },
      {
        'id': 'ni_tatang',
        'title': 'Ang Tatay Ko',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem4.png'
      },
      {
        'id': 'panagsepilio',
        'title': 'Pagsisepilyo',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem5.png'
      },
    ],
    'ilo': [
      {
        'id': 'sipsipat',
        'title': 'Sipsipat',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem1.png'
      },
      {
        'id': 'adda_asok',
        'title': 'Adda Asok',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem2.png'
      },
      {
        'id': 'ti_pusak',
        'title': 'Ti Pusak',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem3.png'
      },
      {
        'id': 'ni_tatang',
        'title': 'Ni Tatang',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem4.png'
      },
      {
        'id': 'panagsepilio',
        'title': 'Panagsepilio',
        'completed': false,
        'type': 'poem',
        'image': 'assets/images/poem5.png'
      },
    ],
  };

  static const Map<String, List<Map<String, dynamic>>> _storyActivities = {
    'en': [
      {
        'id': 'ni_marti',
        'title': 'Marti and the Dove',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento1.png'
      },
      {
        'id': 'ni_didi',
        'title': 'Didi Who Loved Candy',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento2.png'
      },
      {
        'id': 'ni_milio',
        'title': 'Milio Who Brushes',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento3.png'
      },
      {
        'id': 'ni_neneng',
        'title': 'Neneng Who Doesn\'t Like Vegetables',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento4.png'
      },
      {
        'id': 'ni_kikay',
        'title': 'Kikay Who Doesn\'t Comb',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento5.png'
      },
    ],
    'fil': [
      {
        'id': 'ni_marti',
        'title': 'Si Marti at ang Kalapati',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento1.png'
      },
      {
        'id': 'ni_didi',
        'title': 'Si Didi na Mahilig sa Kendi',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento2.png'
      },
      {
        'id': 'ni_milio',
        'title': 'Si Milio na Mahilig Magsipilyo',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento3.png'
      },
      {
        'id': 'ni_neneng',
        'title': 'Si Neneng na Ayaw Kumain ng Gulay',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento4.png'
      },
      {
        'id': 'ni_kikay',
        'title': 'Si Kikay na Ayaw Magsuklay',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento5.png'
      },
    ],
    'ilo': [
      {
        'id': 'ni_marti',
        'title': 'Ni Marti ken Kalapati',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento1.png'
      },
      {
        'id': 'ni_didi',
        'title': 'Ni Didi a Naayat iti Kendi',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento2.png'
      },
      {
        'id': 'ni_milio',
        'title': 'Ni Milio a Managsepilio',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento3.png'
      },
      {
        'id': 'ni_neneng',
        'title': 'Ni Neneng a Dina Kayat ti Nateng',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento4.png'
      },
      {
        'id': 'ni_kikay',
        'title': 'Ni Kikay a di Agsagsaysay',
        'completed': false,
        'type': 'story',
        'image': 'assets/images/kwento5.png'
      },
    ],
  };

  static const Map<String, List<Map<String, dynamic>>> _songActivities = {
    'en': [
      {
        'id': 'ania_ti_naganmo',
        'title': 'What Is Your Name?',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_nagan.png'
      },
      {
        'id': 'ania_ti_naganmo_full',
        'title': 'What Is Your Name? (Full)',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_nagan.png'
      },
      {
        'id': 'uppat_a_pato',
        'title': 'Four Little Ducks',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_pato.png'
      },
      {
        'id': 'duat_imak',
        'title': 'Two Hands',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_imak.png'
      },
      {
        'id': 'agrimat_rimat',
        'title': 'Twinkle, Twinkle Little Star',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_bituen.png'
      },
      {
        'id': 'bassit_a_lawwalawwa',
        'title': 'Itsy Bitsy Spider',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_lawwa.png'
      },
      {
        'id': 'lay_lay_lay',
        'title': 'Fly, Fly, Grandfather',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_lakay.png'
      },
      {
        'id': 'maysa_dua_baduya',
        'title': 'One, Two, Three',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_baduya.png'
      },
      {
        'id': 'ni_nanangko',
        'title': 'My Mother',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_nanang.png'
      },
      {
        'id': 'adda_bullilisingko',
        'title': 'My Little Chick',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_bullilis.png'
      },
      {
        'id': 'da_tarong',
        'title': 'Eggplant, Tomato and Bitter Melon',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_tarong.png'
      },
      {
        'id': 'nanumo_a_kalapaw',
        'title': 'Small Hut',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_kalapaw.png'
      },
      {
        'id': 'nagmulaak_iti_katuday',
        'title': 'I Planted a Flower',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_katuday.png'
      },
      {
        'id': 'lima_a_tinapay',
        'title': 'Five Loaves and Two Fish',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_tinapay.png'
      },
    ],
    'fil': [
      {
        'id': 'ania_ti_naganmo',
        'title': 'Ano ang Pangalan Mo?',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_nagan.png'
      },
      {
        'id': 'ania_ti_naganmo_full',
        'title': 'Ano ang Pangalan Mo? (Buong)',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_nagan.png'
      },
      {
        'id': 'uppat_a_pato',
        'title': 'Apat na Pato',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_pato.png'
      },
      {
        'id': 'duat_imak',
        'title': 'Dalawa Kong Kamay',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_imak.png'
      },
      {
        'id': 'agrimat_rimat',
        'title': 'Kumikislap-kislap Maliit na Bituin',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_bituen.png'
      },
      {
        'id': 'bassit_a_lawwalawwa',
        'title': 'Maliit na Gagamba',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_lawwa.png'
      },
      {
        'id': 'lay_lay_lay',
        'title': 'Lipad, Lipad, Lolo',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_lakay.png'
      },
      {
        'id': 'maysa_dua_baduya',
        'title': 'Isa, Dalawa, Tatlo',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_baduya.png'
      },
      {
        'id': 'ni_nanangko',
        'title': 'Ang Nanay Ko',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_nanang.png'
      },
      {
        'id': 'adda_bullilisingko',
        'title': 'Ang Sisiw Ko',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_bullilis.png'
      },
      {
        'id': 'da_tarong',
        'title': 'Talong, Kamatis at Ampalaya',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_tarong.png'
      },
      {
        'id': 'nanumo_a_kalapaw',
        'title': 'Maliit na Kubo',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_kalapaw.png'
      },
      {
        'id': 'nagmulaak_iti_katuday',
        'title': 'Nagtanim Ako ng Bulaklak',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_katuday.png'
      },
      {
        'id': 'lima_a_tinapay',
        'title': 'Limang Tinapay at Dalawang Isda',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_tinapay.png'
      },
    ],
    'ilo': [
      {
        'id': 'ania_ti_naganmo',
        'title': 'Ania ti Naganmo?',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_nagan.png'
      },
      {
        'id': 'ania_ti_naganmo_full',
        'title': 'Ania ti Nagan Mo (Full)',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_nagan.png'
      },
      {
        'id': 'uppat_a_pato',
        'title': 'Uppat a Pato',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_pato.png'
      },
      {
        'id': 'duat_imak',
        'title': 'Duat\' Imak',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_imak.png'
      },
      {
        'id': 'agrimat_rimat',
        'title': 'Agrimat-rimat Bassit a Bituen',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_bituen.png'
      },
      {
        'id': 'bassit_a_lawwalawwa',
        'title': 'Bassit a Lawwalawwa',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_lawwa.png'
      },
      {
        'id': 'lay_lay_lay',
        'title': 'Lay, Lay, Lay, Apo Lakay',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_lakay.png'
      },
      {
        'id': 'maysa_dua_baduya',
        'title': 'Maysa, Dua, Baduya',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_baduya.png'
      },
      {
        'id': 'ni_nanangko',
        'title': 'Ni Nanangko',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_nanang.png'
      },
      {
        'id': 'adda_bullilisingko',
        'title': 'Adda Bullilisingko',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_bullilis.png'
      },
      {
        'id': 'da_tarong',
        'title': 'Da Tarong, Kamatis ken Paria',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_tarong.png'
      },
      {
        'id': 'nanumo_a_kalapaw',
        'title': 'Nanumo a Kalapaw',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_kalapaw.png'
      },
      {
        'id': 'nagmulaak_iti_katuday',
        'title': 'Nagmulaak iti Katuday',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_katuday.png'
      },
      {
        'id': 'lima_a_tinapay',
        'title': 'Lima a Tinapay ken dua nga Ikan',
        'completed': false,
        'type': 'song',
        'image': 'assets/images/song_tinapay.png'
      },
    ],
  };

  // ── Poem Data ──────────────────────────────────────────────────────────
  static Map<String, Map<String, dynamic>> getPoemData() {
    return _poemData[_lang] ?? _poemData['ilo']!;
  }

  static const Map<String, Map<String, Map<String, dynamic>>> _poemData = {
    'en': {
      'sipsipat': {
        'title': 'Dragonfly',
        'content': [
          'Dragonfly, dragonfly',
          'I have a kite so high',
          'I love to watch it fly',
          'Up, up in the sky.',
        ],
        'image': 'assets/images/poem1.png',
      },
      'adda_asok': {
        'title': 'My Dog',
        'content': [
          'I have a dog',
          'White and fluffy fur',
          'Bark-bark-bark-bark',
          'When he wants to play',
          'My dog, bark-bark-bark',
          'My dog, bark-bark-bark-bark!',
        ],
        'image': 'assets/images/poem2.png',
      },
      'ti_pusak': {
        'title': 'The Kitty',
        'content': [
          'I have a little kitty',
          'Her color is so pretty',
          'She does not like spaghetti',
          'But she loves little fishies.',
          '',
          'Every time the kitty sees me',
          'She runs to me so quickly',
          'Meow-meow-meow she says',
          'Please give me food today.',
        ],
        'image': 'assets/images/poem3.png',
      },
      'ni_tatang': {
        'title': 'My Father',
        'content': [
          'My father is so kind',
          'When the rain starts to fall',
          'He built our house so fine',
          'He takes care of us all.',
          '',
          'He goes to work each day',
          'Planting many things to grow',
          'Food for our family always.',
        ],
        'image': 'assets/images/poem4.png',
      },
      'panagsepilio': {
        'title': 'Brushing Teeth',
        'content': [
          'Brushing teeth',
          'Morning and night, three times',
          'Fresh breath, so clean',
          'Feeling so bright.',
        ],
        'image': 'assets/images/poem5.png',
      },
    },
    'fil': {
      'sipsipat': {
        'title': 'Alitaptap',
        'content': [
          'Alitaptap, alitaptap',
          'May saranggola ako',
          'Gustong ipalipad',
          'Habang nagbabasa.',
        ],
        'image': 'assets/images/poem1.png',
      },
      'adda_asok': {
        'title': 'Ang Aso Ko',
        'content': [
          'May aso ako',
          'Puti at malambot',
          'Aw-aw-aw-aw',
          'Kapag gusto maglaro',
          'Aso ko, aw-aw-aw',
          'Aso ko, aw-aw-aw-aw!',
        ],
        'image': 'assets/images/poem2.png',
      },
      'ti_pusak': {
        'title': 'Ang Pusa',
        'content': [
          'May pusa akong maliit',
          'Kulay niya ay ganda',
          'Ayaw niya ng pansit',
          'Pero mahilig sa isda.',
          '',
          'Kapag nakita ako ng pusa',
          'Tumatakbo siya agad',
          'Miyaw-miyaw-miyaw sabi niya',
          'Bigyan mo ako ng pagkain.',
        ],
        'image': 'assets/images/poem3.png',
      },
      'ni_tatang': {
        'title': 'Ang Tatay Ko',
        'content': [
          'Ang tatay ko ay mabait',
          'Kapag umuulan sa labas',
          'Siya ang nagtayo ng bahay',
          'Siya ang nag-aalaga sa amin.',
          '',
          'Pumapasok siya sa bukid',
          'Nagtatanim ng iba-iba',
          'Pagkain ng pamilya namin.',
        ],
        'image': 'assets/images/poem4.png',
      },
      'panagsepilio': {
        'title': 'Pagsisepilyo',
        'content': [
          'Pagsisepilyo',
          'Umaga at gabi, tatlong beses',
          'Sariwang hininga, malinis',
          'Pakiramdam ay ginhawa.',
        ],
        'image': 'assets/images/poem5.png',
      },
    },
    'ilo': {
      'sipsipat': {
        'title': 'Sipsipat',
        'content': [
          'Sipsipat, sipsipat',
          'Addaanak patupat',
          'Kanek ti agpatpatnag',
          'Bayat ti panagbasak',
        ],
        'image': 'assets/images/poem1.png',
      },
      'adda_asok': {
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
      'ti_pusak': {
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
      'ni_tatang': {
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
      'panagsepilio': {
        'title': 'Panagsepilio',
        'content': [
          'Panagsepilio',
          'Agmalem, mamitlo',
          'Sang-aw, nabanglo',
          'Nakaprespresko',
        ],
        'image': 'assets/images/poem5.png',
      },
    },
  };

  // ── Story Data ─────────────────────────────────────────────────────────
  static Map<String, Map<String, dynamic>> getStoryData() {
    return _storyData[_lang] ?? _storyData['ilo']!;
  }

  static const Map<String, Map<String, Map<String, dynamic>>> _storyData = {
    'en': {
      'ni_marti': {
        'title': 'Marti and the Dove',
        'content': [
          'One day, Marti was walking by the river.',
          'Marti saw a dove by the riverside.',
          'Marti saw that the dove had a hurt wing.',
          'Marti picked up the dove and brought it home.',
          'Marti cleaned and took care of the dove.',
          'Marti fed and gave water to the dove.',
          'When it got better, Marti set the dove free.',
          'Marti was happy because she helped the dove.',
        ],
        'image': 'assets/images/kwento1.png',
      },
      'ni_didi': {
        'title': 'Didi Who Loved Candy',
        'content': [
          'Didi loved candy very much.',
          'Every time his mother gave him money, he bought candy.',
          'Didi ate candy every single day.',
          'Even at home, Didi always had candy to eat.',
          'Soon, his teeth hurt so much.',
          'One day, Didi had a toothache at school.',
          'His mother took him to the dentist.',
          'The dentist found many cavities in Didi\'s teeth.',
          'From then on, Didi stopped eating candy.',
        ],
        'image': 'assets/images/kwento2.png',
      },
      'ni_milio': {
        'title': 'Milio Who Brushes',
        'content': [
          'Milio always brushes his teeth.',
          'Every time after eating, Milio brushes his teeth.',
          'One day, the teacher checked the students\' teeth.',
          'The teacher noticed that Milio\'s teeth were very clean.',
          'The class clapped for Milio.',
          'Milio went home happy.',
          'Milio continued to brush his teeth every day.',
        ],
        'image': 'assets/images/kwento3.png',
      },
      'ni_neneng': {
        'title': 'Neneng Who Doesn\'t Like Vegetables',
        'content': [
          'Neneng never liked eating vegetables.',
          'Even when her mother told her to eat vegetables, Neneng refused.',
          'One day, Neneng got weak at school.',
          'The teacher took Neneng to the clinic.',
          'The doctor found out Neneng never ate vegetables.',
          'The doctor told Neneng to eat vegetables.',
          'From then on, Neneng always ate her vegetables.',
        ],
        'image': 'assets/images/kwento4.png',
      },
      'ni_kikay': {
        'title': 'Kikay Who Doesn\'t Comb',
        'content': [
          'Kikay never liked to comb her hair.',
          'Even when her mother called her, Kikay never wanted to comb.',
          'At school, no one wanted to sit with Kikay.',
          'Her hair was messy and she had many lice.',
          'Kikay cried because no one wanted to play with her.',
          'When she went home after class, she met an old woman.',
          'The old woman\'s hair was also messy.',
          'Kikay got scared and ran straight home.',
          'From then on, Kikay always combed her hair.',
          'She made many friends and was always happy.',
        ],
        'image': 'assets/images/kwento5.png',
      },
    },
    'fil': {
      'ni_marti': {
        'title': 'Si Marti at ang Kalapati',
        'content': [
          'Isang araw, naglalakad si Marti sa tabi ng ilog.',
          'Nakakita si Marti ng kalapati sa tabi ng ilog.',
          'Nakita ni Marti na sugatan ang pakpak ng kalapati.',
          'Kinuha ni Marti ang kalapati at dinala sa kanilang bahay.',
          'Linisan at inalagaan ni Marti ang kalapati.',
          'Pinakain at pinainom ni Marti ang kalapati.',
          'Nang gumaling, pinakawalan ni Marti ang kalapati.',
          'Masaya si Marti dahil tinulungan niya ang kalapati.',
        ],
        'image': 'assets/images/kwento1.png',
      },
      'ni_didi': {
        'title': 'Si Didi na Mahilig sa Kendi',
        'content': [
          'Mahilig si Didi sa kendi.',
          'Tuwing binibigyan siya ng pera ng kanyang nanay, binibili niya ng kendi.',
          'Araw-araw kumakain si Didi ng kendi.',
          'Kahit sa bahay, may kendi lagi si Didi.',
          'Maya-maya, sumakit ang ngipin niya.',
          'Isang araw, sumakit ang ngipin ni Didi sa paaralan.',
          'Dinala siya ng nanay niya sa dentista.',
          'Nadiskubre ng dentista na maraming sira ang ngipin ni Didi.',
          'Mula noon, huminto na si Didi sa pagkain ng kendi.',
        ],
        'image': 'assets/images/kwento2.png',
      },
      'ni_milio': {
        'title': 'Si Milio na Mahilig Magsipilyo',
        'content': [
          'Palaging nagsisipilyo si Milio.',
          'Tuwing tapos kumain, nagsisipilyo si Milio.',
          'Isang araw, sinuri ng guro ang ngipin ng mga estudyante.',
          'Napansin ng guro na malinis ang ngipin ni Milio.',
          'Pinagpalakpakan nila si Milio.',
          'Masayang umuwi si Milio.',
          'Ipinagpatuloy ni Milio ang palagiang pagsisipilyo.',
        ],
        'image': 'assets/images/kwento3.png',
      },
      'ni_neneng': {
        'title': 'Si Neneng na Ayaw Kumain ng Gulay',
        'content': [
          'Hindi kumakain ng gulay si Neneng.',
          'Kahit pinapakain ng nanay niya, ayaw ni Neneng.',
          'Isang araw, nanghina si Neneng sa paaralan.',
          'Dinala siya ng guro sa klinika.',
          'Nalaman ng doktor na hindi kumakain ng gulay si Neneng.',
          'Sinabi ng doktor na kumain ng gulay si Neneng.',
          'Mula noon, palaging kumakain ng gulay si Neneng.',
        ],
        'image': 'assets/images/kwento4.png',
      },
      'ni_kikay': {
        'title': 'Si Kikay na Ayaw Magsuklay',
        'content': [
          'Ayaw magsuklay si Kikay.',
          'Kahit tawagin ng nanay niya, ayaw pa rin magsuklay si Kikay.',
          'Sa paaralan, walang gustong katabi si Kikay.',
          'Gulo-gulo ang buhok niya at maraming kuto.',
          'Umiyak si Kikay dahil walang gustong makipaglaro sa kanya.',
          'Nang umuwi siya, nakasalubong niya ang isang matandang babae.',
          'Gulo-gulo rin ang buhok ng matanda.',
          'Natakot si Kikay at tumakbo pauwi.',
          'Mula noon, palaging nagsusuklay si Kikay.',
          'Dumami ang kaibigan niya at palaging masaya si Kikay.',
        ],
        'image': 'assets/images/kwento5.png',
      },
    },
    'ilo': {
      'ni_marti': {
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
      'ni_didi': {
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
      'ni_milio': {
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
      'ni_neneng': {
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
      'ni_kikay': {
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
    },
  };

  // ── Song Data ──────────────────────────────────────────────────────────
  static Map<String, Map<String, dynamic>> getSongData() {
    return _songData[_lang] ?? _songData['ilo']!;
  }

  static const Map<String, Map<String, Map<String, dynamic>>> _songData = {
    'en': {
      'ania_ti_naganmo': {
        'title': 'What Is Your Name?',
        'tune': 'Audio Recording',
        'lyrics': [
          'What is your name?',
          'Tell me, my friend',
          'Give me a hug',
          'You are so dear',
          'Let us smile together',
          'It is so lovely',
          'Dance and sing',
          'Bow your head.',
        ],
        'image': 'assets/images/song_nagan.png',
        'audioPath': 'audio/Ania ti Nagan Mo by Kurtjam Kyle Silva Nono.mp3',
        'action': 'Wave hands and dance',
      },
      'ania_ti_naganmo_full': {
        'title': 'What Is Your Name? (Full)',
        'tune': 'Leron, Leron Sinta',
        'lyrics': [
          'What is your name?',
          'Tell me, my friend',
          'Give me a hug',
          'You are so dear',
          'Let us smile together',
          'It is so lovely',
          'Dance and sing',
          'Bow your head.',
        ],
        'image': 'assets/images/song_nagan.png',
        'action': 'Listen and follow the song',
      },
      'uppat_a_pato': {
        'title': 'Four Little Ducks',
        'tune': 'Original',
        'lyrics': [
          'Four little ducks',
          'That I saw',
          'Two were chubby',
          'Two were small',
          'They walk together',
          'But the smallest one',
          'Has the longest tail',
          'Quacking she says',
          '"Quack-quack-quack!"',
        ],
        'image': 'assets/images/song_pato.png',
        'action': 'Count with fingers and waddle like a duck',
      },
      'duat_imak': {
        'title': 'Two Hands',
        'tune': 'I Have Two Hands',
        'lyrics': [
          'Two hands I have',
          'Left and right',
          'I keep them clean',
          'Wash them, one, two',
          '',
          'Clean hands are happy hands.',
        ],
        'image': 'assets/images/song_imak.png',
        'action': 'Show your hands and clap',
      },
      'agrimat_rimat': {
        'title': 'Twinkle, Twinkle Little Star',
        'tune': 'Twinkle, Twinkle Little Star',
        'lyrics': [
          'Twinkle, twinkle, little star',
          'How I wonder what you are',
          'Up above the world so high',
          'Like a diamond in the sky',
          'Twinkle, twinkle, little star',
          'How I wonder what you are.',
        ],
        'image': 'assets/images/song_bituen.png',
        'action': 'Twinkle fingers like stars',
      },
      'bassit_a_lawwalawwa': {
        'title': 'Itsy Bitsy Spider',
        'tune': 'Itsy Bitsy Spider',
        'lyrics': [
          'The itsy bitsy spider',
          'Climbed up the water spout',
          'Down came the rain',
          'And washed the spider out',
          'Out came the sun',
          'And dried up all the rain',
          'And the itsy bitsy spider',
          'Climbed up the spout again.',
        ],
        'image': 'assets/images/song_lawwa.png',
        'action': 'Spider hand movements climbing up',
      },
      'lay_lay_lay': {
        'title': 'Fly, Fly, Grandfather',
        'tune': 'Fly, Fly, the Butterfly',
        'lyrics': [
          'Fly, fly, fly, Grandfather',
          'Went to visit Paoay',
          'Bought an axe',
          'Fly, fly, fly, Grandfather.',
          '',
          'Fly, fly, fly, Grandfather',
          'Carried rice on his back',
          'Resting on the heap',
          'Fly, fly, fly, Grandfather.',
        ],
        'image': 'assets/images/song_lakay.png',
        'action': 'Flutter like a butterfly',
      },
      'maysa_dua_baduya': {
        'title': 'One, Two, Three',
        'tune': 'Original',
        'lyrics': [
          'One, two, three',
          'Four, five, six',
          'Six, seven, eight',
          'Nine, ten, let us eat',
          'Coconut-coconut.',
        ],
        'image': 'assets/images/song_baduya.png',
        'action': 'Count with fingers 1-10',
      },
      'ni_nanangko': {
        'title': 'My Mother',
        'tune': 'Original',
        'lyrics': [
          'My mother loves me so',
          'She holds me when I am sick',
          'Her chest is where I rest',
          'Her love gives me life.',
          '',
          'Happy is my mother\'s day',
          'Born in the month of May',
          'She plants the trees',
          'And flowers bloom so many.',
        ],
        'image': 'assets/images/song_nanang.png',
        'action': 'Hug yourself and sway',
      },
      'adda_bullilisingko': {
        'title': 'My Little Chick',
        'tune': 'Original',
        'lyrics': [
          'I have a little chick',
          'That loves to peck',
          'Her beak is so cute',
          'She has many chicks.',
          '',
          'She loves bananas',
          'She eats them all',
          'But when I sing',
          'Oh, she is happy.',
        ],
        'image': 'assets/images/song_bullilis.png',
        'action': 'Flap arms like a chicken',
      },
      'da_tarong': {
        'title': 'Eggplant, Tomato and Bitter Melon',
        'tune': 'Original',
        'lyrics': [
          'Early in the morning',
          'I looked out the window',
          'There were Eggplant, Tomato, Bitter Melon',
          'I heard them talking',
          '',
          'Eggplant said to them',
          'I am the best of you two',
          'Then Bitter Melon answered',
          'Wait, Eggplant, you are too round.',
          '',
          'Tomato just smiled',
          'Oh my siblings, behave',
          'For when I am in the stew',
          'The pinakbet is so tasty.',
        ],
        'image': 'assets/images/song_tarong.png',
        'action': 'Point to different vegetables',
      },
      'nanumo_a_kalapaw': {
        'title': 'Small Hut',
        'tune': 'Bahay Kubo',
        'lyrics': [
          'Small nipa hut',
          'Bamboo and thatch',
          'Though small all around',
          'Vegetables are plenty',
          'Squash, gourd',
          'Tomato, moringa',
          'Eggplant, chili, string bean',
        ],
        'image': 'assets/images/song_kalapaw.png',
        'action': 'Make roof shape with hands',
      },
      'nagmulaak_iti_katuday': {
        'title': 'I Planted a Flower',
        'tune': 'Magtanim ay di Biro',
        'lyrics': [
          'I planted a flower',
          'By the mountainside',
          'But it was pulled out',
          'By the wild grass.',
          '',
          'Grass, oh grass',
          'Do not pull my flower',
          'I will make it into a fence',
          'A fence for Grandma Kikay.',
        ],
        'image': 'assets/images/song_katuday.png',
        'action': 'Planting motion',
      },
      'lima_a_tinapay': {
        'title': 'Five Loaves and Two Fish',
        'tune': 'Original',
        'lyrics': [
          'Five loaves and two fish (3x)',
          'The boy brought them',
          '',
          'Five loaves and two fish (3x)',
          'Jesus gave thanks.',
          '',
          'The bread multiplied, the fish multiplied (3x)',
          'And everyone was full.',
        ],
        'image': 'assets/images/song_tinapay.png',
        'action': 'Show five fingers then two fingers',
      },
    },
    'fil': {
      'ania_ti_naganmo': {
        'title': 'Ano ang Pangalan Mo?',
        'tune': 'Audio Recording',
        'lyrics': [
          'Ano ang pangalan mo',
          'Ibigay mo, kaibigan ko',
          'Yakapin mo ako',
          'Mahalaga ka sa akin',
          'Ngumiti tayo nang sama-sama',
          'Napakaganda',
          'Sumayaw, umawit',
          'Yuko ang ulo.',
        ],
        'image': 'assets/images/song_nagan.png',
        'audioPath': 'audio/Ania ti Nagan Mo by Kurtjam Kyle Silva Nono.mp3',
        'action': 'Wave hands and dance',
      },
      'ania_ti_naganmo_full': {
        'title': 'Ano ang Pangalan Mo? (Buong)',
        'tune': 'Leron, Leron Sinta',
        'lyrics': [
          'Ano ang pangalan mo',
          'Ibigay mo, kaibigan ko',
          'Yakapin mo ako',
          'Mahalaga ka sa akin',
          'Ngumiti tayo nang sama-sama',
          'Napakaganda',
          'Sumayaw, umawit',
          'Yuko ang ulo.',
        ],
        'image': 'assets/images/song_nagan.png',
        'action': 'Listen and follow the song',
      },
      'uppat_a_pato': {
        'title': 'Apat na Pato',
        'tune': 'Original',
        'lyrics': [
          'Apat na pato',
          'Ang nakita ko',
          'Dalawang mataba',
          'Dalawang maliit',
          'Magkakasama sila',
          'Ngunit ang pinakamaliit',
          'Ang pinakamahabang buntot',
          'Sabi niya ngak-ngak',
          '"Kwak-kwak-kwak!"',
        ],
        'image': 'assets/images/song_pato.png',
        'action': 'Count with fingers and waddle like a duck',
      },
      'duat_imak': {
        'title': 'Dalawa Kong Kamay',
        'tune': 'I Have Two Hands',
        'lyrics': [
          'Dalawa kong kamay',
          'Kaliwa at kanan',
          'Ingatan ko silang malinis',
          'Hugasan, isa, dalawa',
          '',
          'Malinis na kamay, masayang-masaya.',
        ],
        'image': 'assets/images/song_imak.png',
        'action': 'Show your hands and clap',
      },
      'agrimat_rimat': {
        'title': 'Kumikislap-kislap Maliit na Bituin',
        'tune': 'Twinkle, Twinkle Little Star',
        'lyrics': [
          'Kumikislap-kislap maliit na bituin',
          'Nagtataka ako kung ano ka ba',
          'Nasa itaas ng mundo',
          'Parang diyamante sa langit',
          'Kumikislap-kislap maliit na bituin',
          'Nagtataka ako kung ano ka ba.',
        ],
        'image': 'assets/images/song_bituen.png',
        'action': 'Twinkle fingers like stars',
      },
      'bassit_a_lawwalawwa': {
        'title': 'Maliit na Gagamba',
        'tune': 'Itsy Bitsy Spider',
        'lyrics': [
          'Maliit na gagamba',
          'Umakyat sa tubo',
          'Umulan nang malakas',
          'Natangay ang gagamba',
          'Lumabas ang araw',
          'Natuyo ang ulan',
          'Maliit na gagamba',
          'Umakyat na muli.',
        ],
        'image': 'assets/images/song_lawwa.png',
        'action': 'Spider hand movements climbing up',
      },
      'lay_lay_lay': {
        'title': 'Lipad, Lipad, Lolo',
        'tune': 'Fly, Fly, the Butterfly',
        'lyrics': [
          'Lipad, lipad, lolo ko',
          'Nagpunta sa Paoay',
          'Bumili ng wasay',
          'Lipad, lipad, lolo ko.',
          '',
          'Lipad, lipad, lolo ko',
          'Nagbuhat ng palay',
          'Sa tambak nagpahinga',
          'Lipad, lipad, lolo ko.',
        ],
        'image': 'assets/images/song_lakay.png',
        'action': 'Flutter like a butterfly',
      },
      'maysa_dua_baduya': {
        'title': 'Isa, Dalawa, Tatlo',
        'tune': 'Original',
        'lyrics': [
          'Isa, dalawa, tatlo',
          'Apat, lima, anim',
          'Pito, walo, siyam',
          'Sampu, kumain tayo',
          'Niyog-niyog.',
        ],
        'image': 'assets/images/song_baduya.png',
        'action': 'Count with fingers 1-10',
      },
      'ni_nanangko': {
        'title': 'Ang Nanay Ko',
        'tune': 'Original',
        'lyrics': [
          'Ang nanay ko ay mahal ako',
          'Yayakapin ako kapag may sakit',
          'Sa dibdib niya ako magpahinga',
          'Ang pagmamahal niya ay buhay ko.',
          '',
          'Masaya ang kaarawan ng nanay ko',
          'Ipinanganak sa buwan ng Mayo',
          'Nagtatanim ng puno',
          'At maraming bulaklak ang namumukadkad.',
        ],
        'image': 'assets/images/song_nanang.png',
        'action': 'Hug yourself and sway',
      },
      'adda_bullilisingko': {
        'title': 'Ang Sisiw Ko',
        'tune': 'Original',
        'lyrics': [
          'May sisiw ako',
          'Na mahilig sumisiw',
          'Ang tuka niya ay cute',
          'Marami siyang anak.',
          '',
          'Mahilig siya sa saging',
          'Ubusin niya ang isa',
          'Pero kapag kumakanta ako',
          'Ay, masaya siya.',
        ],
        'image': 'assets/images/song_bullilis.png',
        'action': 'Flap arms like a chicken',
      },
      'da_tarong': {
        'title': 'Talong, Kamatis at Ampalaya',
        'tune': 'Original',
        'lyrics': [
          'Maaga sa umaga',
          'Tumitingin ako sa bintana',
          'Nandoon ang Talong, Kamatis, Ampalaya',
          'Naririnig ko silang nag-uusap',
          '',
          'Sabi ng Talong sa kanila',
          'Ako ang pinakamasarap sa inyong dalawa',
          'Sumagot naman ang Ampalaya',
          'Hintay, Talong, masyado kang bilog.',
          '',
          'Si Kamatis ay ngumiti lang',
          'Ay kapatid ko, magpakabait kayo',
          'Dahil kapag nasa dinengdeng ako',
          'Ang pinakbet ay napakasarap.',
        ],
        'image': 'assets/images/song_tarong.png',
        'action': 'Point to different vegetables',
      },
      'nanumo_a_kalapaw': {
        'title': 'Maliit na Kubo',
        'tune': 'Bahay Kubo',
        'lyrics': [
          'Maliit na kubo',
          'Kawayan at pawid',
          'Maliit man sa labas',
          'Maraming gulay',
          'Kalabasa, upo',
          'Kamatis, malunggay',
          'Talong, sili, patani',
        ],
        'image': 'assets/images/song_kalapaw.png',
        'action': 'Make roof shape with hands',
      },
      'nagmulaak_iti_katuday': {
        'title': 'Nagtanim Ako ng Bulaklak',
        'tune': 'Magtanim ay di Biro',
        'lyrics': [
          'Nagtanim ako ng bulaklak',
          'Sa tabi ng bundok',
          'Pero inagaw ito',
          'Ng matigas na damo.',
          '',
          'Damong matigas',
          'Huwag agawin ang bulaklak ko',
          'Gagawin kitang bakod',
          'Bakod ni Lola Kikay.',
        ],
        'image': 'assets/images/song_katuday.png',
        'action': 'Planting motion',
      },
      'lima_a_tinapay': {
        'title': 'Limang Tinapay at Dalawang Isda',
        'tune': 'Original',
        'lyrics': [
          'Limang tinapay at dalawang isda (3x)',
          'Dinala ng bata',
          '',
          'Limang tinapay at dalawang isda (3x)',
          'Si Jesus ay nagpasalamat.',
          '',
          'Dumami ang tinapay, dumami ang isda (3x)',
          'At nabusog silang lahat.',
        ],
        'image': 'assets/images/song_tinapay.png',
        'action': 'Show five fingers then two fingers',
      },
    },
    'ilo': {
      'ania_ti_naganmo': {
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
      'ania_ti_naganmo_full': {
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
      'uppat_a_pato': {
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
      'duat_imak': {
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
      'agrimat_rimat': {
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
      'bassit_a_lawwalawwa': {
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
      'lay_lay_lay': {
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
        ],
        'image': 'assets/images/song_lakay.png',
        'action': 'Flutter like a butterfly',
      },
      'maysa_dua_baduya': {
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
      'ni_nanangko': {
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
      'adda_bullilisingko': {
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
      'da_tarong': {
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
      'nanumo_a_kalapaw': {
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
      'nagmulaak_iti_katuday': {
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
      'lima_a_tinapay': {
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
    },
  };
}
