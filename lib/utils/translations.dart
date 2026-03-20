import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/language_provider.dart';

class Translations {
  // ========== COMMON ==========
  static String getBack(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Back', 'Aga', 'Bumalik');
  }

  static String getDone(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Done', 'Nalpas', 'Tapos');
  }

  static String getSave(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Save', 'Idulin', 'I-save');
  }

  static String getCancel(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Cancel', 'Ubusan', 'Kanselahin');
  }

  static String getNext(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Next', 'Sumaruno', 'Susunod');
  }

  static String getPrevious(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Previous', 'Ngauna', 'Nauna');
  }

  static String getCompleted(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Completed', 'Nalpas', 'Tapos na');
  }

  static String getInProgress(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('In Progress', 'Agsasakay', 'Isinasagawa');
  }

  static String getEarned(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('earned', 'nagun-od', 'natamo');
  }

  static String getLevels(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Levels', 'Levels', 'Levels');
  }

  static String getActivities(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('activities', 'aktibidad', 'mga aktibidad');
  }

  // ========== HOME SCREEN ==========
  static String getAppTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('E Tarabay', 'E Tarabay', 'E Tarabay');
  }

  static String getParents(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('PARENTS', 'NAKATATAKENG', 'MGA MAGULANG');
  }

  static String getLessons(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Lessons', 'Adal', 'Aral');
  }

  static String getStars(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Stars', 'Bituen', 'Bituin');
  }

  static String getAwards(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Awards', 'Premio', 'Gantimpala');
  }

  static String getHomeAge(BuildContext context, int age) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Age $age', '$age Tawen', '$age Taon');
  }

  static String getMatematika(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('MATEMATIKA', 'MATEMATIKA', 'MATEMATIKA');
  }

  static String getSundanMoKayaMo(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'SUNDAN MO, KAYA MO!', 'SUROTEM, KAYAM!', 'SUNDAN MO, KAYA MO!');
  }

  static String getAngAkingSarili(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('ANG AKING\nSARILI', 'BAGIK', 'ANG AKING\nSARILI');
  }

  static String getAtAkingPamilya(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'AT AKING PAMILYA', 'KEN PAMILIAK', 'AT AKING PAMILYA');
  }

  static String getKulaySaya(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('KULAY-SAYA', 'KOLOR-SAYA', 'KULAY-SAYA');
  }

  static String getMagkulayTayo(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('MAGKULAY TAYO!', 'AGKOLORTANTAY!', 'MAGKULAY TAYO!');
  }

  static String getSundanMo(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('SUNDAN MO,', 'SUROTEM,', 'SUNDAN MO,');
  }

  static String getMagbasaTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Magbasa Tayo', 'Agbasatayo', 'Magbasa Tayo');
  }

  static String getAlpabetoAtMgaSalita(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('MGA TULA, KWENTO AT KANTA',
        'DANIW, SARITA KEN KANKANTA', 'MGA TULA, KWENTO AT KANTA');
  }

  static String getHome(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Home', 'Balay', 'Home');
  }

  static String getProfile(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Profile', 'Profil', 'Profile');
  }

  static String getSettingsTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Settings', 'Pangpaandar', 'Settings');
  }

  // ========== MAGBASA SCREEN ==========
  static String getTotalProgress(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Total Progress', 'Dagup a Progress', 'Kabuuang Progress');
  }

  static String getPoems(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Poems', 'Daniw', 'Mga Tula');
  }

  static String getStories(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Stories', 'Sarita', 'Mga Kwento');
  }

  static String getSongs(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Songs', 'Kankanta', 'Mga Kanta');
  }

  static String getReadStory(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Read Story', 'Basaen ti Sarita', 'Basahin ang Kwento');
  }

  static String getListenToSong(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Listen to Song', 'Denggen ti Kanta', 'Pakinggan ang Kanta');
  }

  static String getReadPoem(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Read Poem', 'Basaen ti Daniw', 'Basahin ang Tula');
  }

  static String getSwipeToRead(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Swipe to read', 'I-swipe tapno basaen', 'Swipe para magbasa');
  }

  static String getTune(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Tune', 'Tono', 'Tono');
  }

  static String getAction(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Action', 'Galaw', 'Galaw');
  }

  static String getCounting(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Count the Objects', 'Bilangen dagiti Banag', 'Bilangin ang mga Bagay');
  }

  static String getDragNumber(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Drag the Number', 'Iyalis ti Numero', 'I-drag ang Numero');
  }

  static String getLineMatch(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Match with Line', 'Itugma iti Linia', 'Itugma gamit ang Linya');
  }

  static String getPopBalloon(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Pop the Balloon', 'Paspiaran ti Balloon', 'I-pop ang Balloon');
  }

  static String getMoreOrLess(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'More or Less?', 'Adu wenno Bassit?', 'Marami o Kaunti?');
  }

  static String getNumberPuzzle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Number Puzzle', 'Numero a Puzzle', 'Number Puzzle');
  }

  static String getNumberSequence(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Number Sequence', 'Panagsasaruno ti Numero', 'Number Sequence');
  }

  static String getChooseAnswer(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Choose the correct answer:',
        'Piliem ti umiso a sungbat:', 'Piliin ang tamang sagot:');
  }

  static String getCheck(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Check', 'Kitaen', 'Suriin');
  }

  static String getCorrect(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Correct!', 'Naimbag!', 'Tama!');
  }

  static String getWrong(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Wrong! Try again!', 'Biddot! Padasem manen!', 'Mali! Subukan muli!');
  }

  static String getTimeOut(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate("Time's up! Try again.",
        'Nalpas ti oras! Padasem manen.', 'Ubos na ang oras! Subukan muli.');
  }

  static String getLevel(BuildContext context, int level) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Level $level', 'Level $level', 'Level $level');
  }

  static String getPerfect(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Perfect!', 'Perpekto!', 'Perpekto!');
  }

  static String getGreat(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Great!', 'Nagsayaat!', 'Magaling!');
  }

  static String getGood(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Good!', 'Nasayaat!', 'Mabuti!');
  }

  static String getMathPoints(BuildContext context, int points) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        '+$points points', '+$points a puntos', '+$points puntos');
  }

  static String getStreak(BuildContext context, int streak) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('$streak day streak!', '$streak nga aldaw a strek!',
        '$streak araw na streak!');
  }

  static String getMathTotalScore(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Total Score', 'Dagup a Puntos', 'Kabuuang Puntos');
  }

  static String getMathTotalStars(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Total Stars', 'Dagup a Bituen', 'Kabuuang Bituin');
  }

  static String getRepeat(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Repeat', 'Uliten', 'Ulitin');
  }

  static String getNextLevel(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Next Level', 'Sumaruno a Level', 'Susunod na Level');
  }

  static String getCongratulations(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Congratulations!', 'Kablaaw!', 'Binabati Kita!');
  }

  static String getCompletedAllLevels(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('You completed all levels!', 'Nalpasmo amin a level!',
        'Natapos mo ang lahat ng levels!');
  }

  static String getContinue(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Continue', 'Ituloy', 'Magpatuloy');
  }

  static String getChooseFirst(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Choose an answer first!',
        'Piliem ti sungbat nga umuna!', 'Pumili muna ng sagot!');
  }

  static String getChooseLeftFirst(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Choose a number on the left first!',
        'Piliem ti numero iti igid nga umuna!',
        'Pumili muna ng numero sa kaliwa!');
  }

  static String getDropHere(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Drop here!', 'Ikkam ditoy!', 'I-drop dito!');
  }

  static String getDragHere(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Drag here', 'Iyalis ditoy', 'I-drag dito');
  }

  static String getTapLeftThenRight(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Tap left then right', 'Pisuen ti igid ken kanawan',
        'Pindutin ang kaliwa at kanan');
  }

  static String getMatched(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('matched', 'natugma', 'natugma');
  }

  static String getPopAllBalloonsWith(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Pop all balloons with',
        'Paspiaran amin a balloon nga addaan',
        'I-pop ang lahat ng balloon na may');
  }

  static String getLeft(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Left', 'Igrid', 'Kaliwa');
  }

  static String getRight(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Right', 'Kawanan', 'Kanan');
  }

  static String getTheyAreEqual(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('They are equal!', 'Agpapada!', 'Pareho sila!');
  }

  static String getTapTwoToSwap(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Tap two numbers to swap',
        'Pisuen dua nga numero tapno agsinnukat',
        'Pindutin ang dalawang numero para magpalit');
  }

  static String getCorrectOrder(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Correct order', 'Umiso nga urnos', 'Tamang ayos');
  }

  static String getSelected(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Selected', 'Napili', 'Napili');
  }

  static String getTapAnotherToSwap(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'tap another to swap',
        'pisuem ti sabali tapno agsinnukat',
        'pindutin ang isa pa para magpalit');
  }

  static String getWhatsMissing(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'What\'s missing?', 'Ania ti kurang?', 'Ano ang kulang?');
  }

  static String getNoGames(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'No games available', 'Awan ti ay-ayam', 'Walang laro');
  }

  // ========== PAMILYA SCREEN ==========
  static String getAngAkingSariliTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Ang Aking Sarili', 'Ti Bagik', 'Ang Aking Sarili');
  }

  static String getAngAkingPamilyaTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Ang Aking Pamilya', 'Ti Pamilyak', 'Ang Aking Pamilya');
  }

  static String getAllAboutMe(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'All About Me', 'Maipanggep Kaniak', 'Tungkol sa Akin');
  }

  static String getMyEmotions(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('My Emotions', 'Dagiti Riknak', 'Aking Damdamin');
  }

  static String getDailyRoutines(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Daily Routines', 'Inaldaw nga Aramid', 'Araw-araw na Gawain');
  }

  static String getMyPreferences(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'My Preferences', 'Dagiti Kaykayatko', 'Aking Paborito');
  }

  static String getFamilyMembers(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Family Members', 'Kameng ti Pamilya', 'Mga Miyembro ng Pamilya');
  }

  static String getFamilyRoles(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Family Roles', 'Trabaho ti Pamilya', 'Tungkulin sa Pamilya');
  }

  static String getFamilyActivities(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Family Activities', 'Aramid ti Pamilya', 'Gawaing Pampamilya');
  }

  static String getFamilyTree(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Family Tree', 'Punuan ti Pamilya', 'Family Tree');
  }

  static String getMyHome(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('My Home', 'Balayko', 'Aming Tahanan');
  }

  static String getWhatIsYourName(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'What is your name?', 'Ania ti naganmo?', 'Ano ang pangalan mo?');
  }

  static String getHowOldAreYou(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'How old are you?', 'Mano ti tawenmo?', 'Ilang taon ka na?');
  }

  static String getAreYouBoyOrGirl(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Are you a boy or a girl?', 'Lalaki ka wenno babai?',
        'Ikaw ba ay babae o lalaki?');
  }

  static String getWhenIsYourBirthday(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('When is your birthday?', 'Kaano ti kasangaymo?',
        'Kailan ang iyong kaarawan?');
  }

  static String getWhereDoYouLive(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Where do you live?', 'Sadino ti pagtaengam?', 'Saan ka nakatira?');
  }

  static String getHappy(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Happy', 'Naragsak', 'Masaya');
  }

  static String getSad(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Sad', 'Liday', 'Malungkot');
  }

  static String getAngry(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Angry', 'Pungtot', 'Galit');
  }

  static String getSurprised(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Surprised', 'Nakigtot', 'Nagulat');
  }

  static String getSleepy(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Sleepy', 'Nakadurukay', 'Inaantok');
  }

  static String getScared(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Scared', 'Mabuteng', 'Takot');
  }

  static String getMother(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Mother', 'Nanang', 'Nanay');
  }

  static String getFather(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Father', 'Tatang', 'Tatay');
  }

  static String getOlderBrother(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Older Brother', 'Manong', 'Kuya');
  }

  static String getOlderSister(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Older Sister', 'Manang', 'Ate');
  }

  static String getYoungerSibling(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Younger Sibling', 'Ading', 'Bunso');
  }

  static String getGrandfather(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Grandfather', 'Lolo', 'Lolo');
  }

  static String getGrandmother(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Grandmother', 'Lola', 'Lola');
  }

  // ========== KULAY SCREEN ==========
  static String getColoringBook(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Coloring Book', 'Libro ti Panagkolor', 'Coloring Book');
  }

  static String getMyCreations(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'My Creations', 'Dagiti Pinarsuak', 'Aking mga Likha');
  }

  static String getColor(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Color', 'Kolor', 'Kulay');
  }

  static String getAnimals(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Animals', 'Ay-ayup', 'Mga Hayop');
  }

  static String getFlowers(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Flowers', 'Sabong', 'Mga Bulaklak');
  }

  static String getFruits(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Fruits', 'Prutas', 'Mga Prutas');
  }

  static String getToys(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Toys', 'Al-aliwa', 'Mga Laruan');
  }

  static String getRed(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Red', 'Nalabaga', 'Pula');
  }

  static String getBlue(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Blue', 'Asul', 'Asul');
  }

  static String getGreen(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Green', 'Berde', 'Berde');
  }

  static String getYellow(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Yellow', 'Duyaw', 'Dilaw');
  }

  static String getOrange(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Orange', 'Narangha', 'Kahel');
  }

  static String getPurple(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Purple', 'Lila', 'Lila');
  }

  static String getPink(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Pink', 'Rosa', 'Rosas');
  }

  static String getBrown(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Brown', 'Kayumanggi', 'Kayumanggi');
  }

  static String getBlack(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Black', 'Nangisit', 'Itim');
  }

  static String getWhite(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('White', 'Puraw', 'Puti');
  }

  static String getEasy(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Easy', 'Nalaka', 'Madali');
  }

  static String getMedium(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Medium', 'Kalalainganna', 'Katamtaman');
  }

  static String getHard(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Hard', 'Narigat', 'Mahirap');
  }

  static String getBrush(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Brush', 'Brosa', 'Brush');
  }

  static String getEraser(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Eraser', 'Punas', 'Pambura');
  }

  static String getUndo(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Undo', 'Ibangon', 'Urong');
  }

  static String getClear(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Clear', 'Ikkaten', 'Burahin');
  }

  // ========== SUNDAN SCREEN ==========
  static String getTraceTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Sundan Mo, Kaya Mo!', 'Surotem, Kayam!', 'Sundan Mo, Kaya Mo!');
  }

  static String getUppercase(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Uppercase', 'Dakkel a Letra', 'Malaking Titik');
  }

  static String getLowercase(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Lowercase', 'Bassit a Letra', 'Maliit na Titik');
  }

  static String getNumbers(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Numbers', 'Numero', 'Mga Numero');
  }

  static String getLetter(BuildContext context, String letter) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Letter $letter', 'Letra $letter', 'Titik $letter');
  }

  static String getSundanPoints(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Points', 'Puntos', 'Puntos');
  }

  static String getReset(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Reset', 'Ireser', 'Ulitin');
  }

  // ========== FOR PARENTS SCREEN ==========
  static String getForParentsTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'For Parents', 'Para kadagiti Nagannak', 'Para sa mga Magulang');
  }

  static String getOverallProgress(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Overall Progress', 'Dagup a Progress', 'Kabuuang Progress');
  }

  static String getTula(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Tula', 'Daniw', 'Tula');
  }

  static String getKwento(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Kwento', 'Sarita', 'Kwento');
  }

  static String getKanta(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Kanta', 'Kanta', 'Kanta');
  }

  static String getUppercaseProgress(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Uppercase', 'Dakkel a Letra', 'Malaking Titik');
  }

  static String getLowercaseProgress(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Lowercase', 'Bassit a Letra', 'Maliit na Titik');
  }

  static String getNumbersProgress(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Numbers', 'Numero', 'Mga Numero');
  }

  static String getBasicColors(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Basic Colors', 'Batayan a Kolor', 'Mga Pangunahing Kulay');
  }

  static String getColorMixing(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Color Mixing', 'Panaglaok ti Kolor', 'Paghahalo ng Kulay');
  }

  static String getColorObjects(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Color Objects', 'Kolor dagiti Banag', 'Kulay ng mga Bagay');
  }

  static String getCompletedLevels(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Completed Levels', 'Nalpas a Level', 'Natapos na Levels');
  }

  static String getGamesCompleted(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Games Completed', 'Nalpas nga Ay-ayam', 'Natapos na Laro');
  }

  static String getParentsTotalScore(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Total Score', 'Dagup a Puntos', 'Kabuuang Puntos');
  }

  static String getCurrentStreak(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Current Streak', 'Taudan a Streak', 'Kasalukuyang Streak');
  }

  static String getDays(BuildContext context, int days) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('$days days', '$days nga aldaw', '$days araw');
  }

  static String getParentsTotalStars(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Total Stars', 'Dagup a Bituen', 'Kabuuang Bituin');
  }

  static String getBadges(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('badges', 'badges', 'badges');
  }

  // ========== PROFILE SCREEN ==========
  static String getMyProfile(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('My Profile', 'Profilko', 'Aking Profile');
  }

  static String getYearsOld(BuildContext context, int age) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        '$age years old', '$age a tawen', '$age taong gulang');
  }

  static String getMale(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Male', 'Lalaki', 'Lalaki');
  }

  static String getFemale(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Female', 'Babai', 'Babae');
  }

  static String getBirthday(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Birthday', 'Kasangay', 'Kaarawan');
  }

  static String getProfileAge(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Age', 'Tawen', 'Edad');
  }

  static String getGender(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Gender', 'Sekso', 'Kasarian');
  }

  static String getMemberSince(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Member Since', 'Kameng Nanipud', 'Miyembro Mula');
  }

  static String getEditProfile(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Edit Profile', 'Baliwan ti Profil', 'I-edit ang Profile');
  }

  static String getNoProfileData(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'No profile data', 'Awan datos ti profil', 'Walang data ng profile');
  }

  static String getComingSoon(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Coming soon!', 'Umayto!', 'Malapit na!');
  }

  // ========== SETTINGS SCREEN ==========
  static String getSettings(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Settings', 'Pangpaandar', 'Settings');
  }

  static String getLanguage(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Language', 'Pagsasao', 'Wika');
  }

  static String getSound(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Sound', 'Uni', 'Tunog');
  }

  static String getMusic(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Music', 'Musika', 'Musika');
  }

  static String getNotifications(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Notifications', 'Pakaammo', 'Mga Abiso');
  }

  // ========== ACHIEVEMENTS SCREEN ==========
  static String getAchievements(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Achievements', 'Nagun-od', 'Mga Natamo');
  }

  static String getFirstSteps(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('First Steps', 'Umuna nga Addang', 'Unang Hakbang');
  }

  static String getAlphabetMaster(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Alphabet Master', 'Master ti Alpabeto', 'Alphabet Master');
  }

  static String getNumberWizard(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Number Wizard', 'Number Wizard', 'Number Wizard');
  }

  static String getColorArtist(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Color Artist', 'Color Artist', 'Color Artist');
  }

  static String getShapeCreator(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Shape Creator', 'Shape Creator', 'Shape Creator');
  }

  static String getAnimalFriend(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Animal Friend', 'Animal Friend', 'Animal Friend');
  }

  static String getBookworm(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Bookworm', 'Bookworm', 'Bookworm');
  }

  static String getStarStudent(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Star Student', 'Star Student', 'Star Student');
  }

  static String getMathWhiz(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Math Whiz', 'Math Whiz', 'Math Whiz');
  }

  static String getFamilyHero(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Family Hero', 'Family Hero', 'Family Hero');
  }

  static String getWritingStar(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Writing Star', 'Writing Star', 'Writing Star');
  }

  static String getSongbird(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Songbird', 'Songbird', 'Songbird');
  }

  static String getPerfectScore(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Perfect Score', 'Perpekto nga Puntos', 'Perpektong Puntos');
  }

  // Achievement Descriptions
  static String getFirstStepsDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Complete your first activity',
        'Lpasen ti umuna nga aktibidad', 'Kumpletuhin ang unang aktibidad');
  }

  static String getAlphabetMasterDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Complete all Magbasa Tayo activities',
        'Lpasen amin nga aktibidad ti Magbasa Tayo',
        'Kumpletuhin lahat ng Magbasa Tayo activities');
  }

  static String getNumberWizardDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Complete 20 Matematika games',
        'Lpasen ti 20 nga ay-ayam ti Matematika',
        'Kumpletuhin ang 20 Matematika games');
  }

  static String getColorArtistDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Complete all Kulay-Saya activities',
        'Lpasen amin nga aktibidad ti Kulay-Saya',
        'Kumpletuhin lahat ng Kulay-Saya activities');
  }

  static String getShapeCreatorDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Complete all uppercase letters',
        'Lpasen amin a dakkel a letra', 'Kumpletuhin lahat ng malaking titik');
  }

  static String getAnimalFriendDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Complete all lowercase letters',
        'Lpasen amin a bassit a letra', 'Kumpletuhin lahat ng maliit na titik');
  }

  static String getBookwormDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Complete all stories', 'Lpasen amin a sarita',
        'Kumpletuhin lahat ng kwento');
  }

  static String getStarStudentDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Complete 20 Ang Aking Sarili games',
        'Lpasen ti 20 nga ay-ayam ti Ang Aking Sarili',
        'Kumpletuhin ang 20 Ang Aking Sarili games');
  }

  static String getFamilyHeroDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Complete all family levels',
        'Lpasen amin a family level', 'Kumpletuhin lahat ng family levels');
  }

  static String getWritingStarDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Trace all letters and numbers',
        'Suroten amin a letra ken numero', 'Sundan lahat ng titik at numero');
  }

  static String getSongbirdDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Learn all 13 songs', 'Adalen amin a 13 a kanta',
        'Matutunan lahat ng 13 kanta');
  }

  static String getPerfectScoreDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Get perfect score in 3 games',
        'Agperpekto iti 3 nga ay-ayam', 'Mag-perpekto sa 3 laro');
  }

  static String getNoAwardsYet(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'No Awards Yet', 'Awan pay ti Premio', 'Wala pang Gantimpala');
  }

  static String getCompleteActivitiesToEarn(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Complete activities to earn awards!',
        'Lpasen dagiti aktibidad tapno makapremio!',
        'Kumpletuhin ang mga aktibidad para makakuha ng gantimpala!');
  }

  // ========== TEACHER DASHBOARD ==========
  static String getTeacherDashboard(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Teacher Dashboard', 'Dashboard ti Mistra', 'Teacher Dashboard');
  }

  static String getEnrollStudent(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Enroll Student', 'Ilista ti Estudiante', 'I-enroll ang Estudyante');
  }

  static String getFirstName(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('First Name', 'Umuna a Nagan', 'Unang Pangalan');
  }

  static String getLastName(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Last Name', 'Apelyido', 'Apelyido');
  }

  static String getLRN(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('LRN (Password)', 'LRN (Password)', 'LRN (Password)');
  }

  static String getUsernameLabel(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Username (Auto-generated)',
        'Username (Auto-generated)', 'Username (Auto-generated)');
  }

  static String getGenderLabel(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Gender', 'Sekso', 'Kasarian');
  }

  static String getStudentInfo(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Student Info', 'Informasyon ti Estudiante',
        'Impormasyon ng Estudyante');
  }

  static String getRemoveStudent(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Remove Student?', 'Iruuar ti Estudiante?',
        'Tanggalin ang Estudyante?');
  }

  static String getProgressLabel(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Progress', 'Progress', 'Progress');
  }

  static String getLogout(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Logout', 'Agruuar', 'Mag-logout');
  }

  static String getConfirmLogout(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
      'Are you sure you want to log out?',
      'Sigurado ka kadi a kayatmo ti agruuar?',
      'Sigurado ka bang gusto mong mag-logout?',
    );
  }

  static String getVerifyLRN(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Verify LRN', 'I-verify ti LRN', 'I-verify ang LRN');
  }

  static String getEnterLRN(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Please enter your LRN to proceed',
        'Isuurat ti LRN tapno agtuloy',
        'Mangyaring ilagay ang iyong LRN para magpatuloy');
  }

  static String getInvalidLRN(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Invalid LRN. Please try again.',
        'Madi a LRN. Padasen manen.', 'Maling LRN. Pakisubukan muli.');
  }

  static String getPassword(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Password', 'Password', 'Password');
  }

  static String getEnrollmentInfo(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Give the username and LRN to the parent/student for login.',
        'Ited ti username ken LRN ti nagannak/estudiante tapno makapag-login.',
        'Ibigay ang username at LRN sa magulang/estudyante para sa login.');
  }

  static String getFillAllFields(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Please fill in all fields.',
        'Pakiusapan a punnuan amin a field.',
        'Pakisuyong punan ang lahat ng fields.');
  }

  static String getParentsInfo(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Parents Info', 'Informasyon ti Nagannak', 'Impormasyon ng Magulang');
  }

  static String getParentNameLabel(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        "Parent's Name", "Nagan ti Nagannak", "Pangalan ng Magulang");
  }

  static String getParentContactLabel(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate("Parent's Contact (11 digits)",
        "Contact ti Nagannak (11 digits)", "Contact ng Magulang (11 digits)");
  }

  static String getContactLengthError(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Contact number must be exactly 11 digits.',
        'Ti numero ti contact ket masapul nga 11 a numero.',
        'Ang numero ng contact ay dapat eksaktong 11 digits.');
  }

  static String getBirthdayGreeting(BuildContext context, String name) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Happy Birthday, $name!',
        'Naimbag a Panagkasangay, $name!', 'Maligayang Kaarawan, $name!');
  }

  static String getSwipeToDeleteGuide(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Swipe left on a student to delete',
        'I-swipe iti kannigid tapno maikkat',
        'I-swipe pakaliwa para matanggal');
  }

  static String getEnrollmentFailed(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Enrollment failed.', 'Saanko a nairehistro.', 'Bigo ang pag-enroll.');
  }

  static String getEnroll(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Enroll', 'Ilista', 'I-enroll');
  }

  static String getStudentEnrolled(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Student Enrolled!', 'Nairehistro ti Estudiante!',
        'Nai-enroll na ang Estudyante!');
  }

  static String getStudentEnrolledSuccessfully(
      BuildContext context, String name) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        '$name has been enrolled successfully.',
        'Nairehistro ni $name a naimbag.',
        'Matagumpay na nai-enroll si $name.');
  }

  static String getLoginCredentials(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Login Credentials:', 'Credentials ti Login:', 'Login Credentials:');
  }

  static String getUserLabel(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('User:', 'User:', 'User:');
  }

  static String getUsernameCopied(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Username copied!', 'Username ket nakopia!', 'Username ay nakopya!');
  }

  static String getPasswordLabel(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Pass:', 'Pass:', 'Pass:');
  }

  static String getPasswordCopied(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Password copied!', 'Password ket nakopia!', 'Password ay nakopya!');
  }

  static String getFullName(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Full Name', 'Intero a Nagan', 'Buong Pangalan');
  }

  static String getLRNPassword(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('LRN (Password)', 'LRN (Password)', 'LRN (Password)');
  }

  static String getConfirmRemoveStudent(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Are you sure you want to remove this student? This cannot be undone.',
        'Sigurado ka kadi a kayatmo nga ikkaten daytoy nga estudiante? Saanto a mabalin a masubli.',
        'Sigurado ka bang gusto mong tanggalin ang estudyanteng ito? Hindi na ito mababawi.');
  }

  static String getRemove(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Remove', 'Ikkaten', 'Tanggalin');
  }

  static String getUpdate(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Update', 'E-update', 'I-update');
  }

  static String getCopied(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Copied!', 'Nakopia!', 'Nakopya!');
  }

  static String getNoStudentsEnrolled(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'No students enrolled yet.',
        'Awan pay ti estudiante nga nairehistro.',
        'Wala pang nai-enroll na estudyante.');
  }

  static String getTapToEnroll(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Tap "Enroll Student" to add one.',
        'Pisuen ti "Ilista ti Estudiante" tapno manginayon.',
        'I-tap ang "I-enroll ang Estudyante" para magdagdag.');
  }

  static String getUsernameHeader(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Username:', 'Username:', 'Username:');
  }

  static String getStudentProgressTitle(BuildContext context, String name) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        "$name's Progress", "Progress ni $name", "Progress ni $name");
  }

  static String getModuleBreakdown(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Module Breakdown', 'Breakdown ti Module', 'Breakdown ng Module');
  }

  static String getScoreLabel(BuildContext context, int score) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Score: $score', 'Puntos: $score', 'Puntos: $score');
  }

  static String getWelcome(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Welcome!', 'Naragsak a Pannakaidatun!', 'Maligayang Pagdating!');
  }

  static String getLoginPrompt(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Log in to continue your learning journey',
        'Ag-login tapno ituloy ti adalmo',
        'Mag-login para ituloy ang iyong pag-aaral');
  }

  static String getLoginButton(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Log In', 'Ag-login', 'Mag-login');
  }

  static String getTeacherLoginButton(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Continue as Teacher', 'Ituloy a kas Mistra', 'Magpatuloy bilang Guro');
  }

  static String getEnterUsernamePassword(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Please enter both username and password.',
        'Pakiusapan a isurat ti username ken password.',
        'Pakisuyong ilagay ang username at password.');
  }

  static String getLoginError(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Login failed. Please try again.',
        'Saanko a makapag-login. Padasen manen.',
        'Bigo ang pag-login. Pakisubukang muli.');
  }

  static String getUsername(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Username', 'Username', 'Username');
  }

  static String getTeacherLoginTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Teacher Login', 'Login ti Mistra', 'Login ng Guro');
  }

  static String getTeacherLoginPrompt(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Enter your teacher credentials to continue',
        'Isurat ti credentials ti mistra tapno agtuloy',
        'Ipasok ang iyong teacher credentials para magpatuloy');
  }

  static String getTeacherLoginButtonLabel(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Log In as Teacher', 'Ag-login a kas Mistra', 'Mag-login bilang Guro');
  }

  static String getInvalidTeacherCredentials(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Invalid teacher credentials. Please try again.',
        'Madi a credentials ti mistra. Padasen manen.',
        'Maling teacher credentials. Pakisubukang muli.');
  }

  static String getMonthName(BuildContext context, int month) {
    final lang = Provider.of<LanguageProvider>(context);
    const en = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    const il = [
      'Enero',
      'Pebrero',
      'Marso',
      'Abril',
      'Mayo',
      'Hunyo',
      'Hulyo',
      'Agosto',
      'Setiembre',
      'Oktubre',
      'Nobiembre',
      'Disiembre'
    ];
    const tl = [
      'Enero',
      'Pebrero',
      'Marso',
      'Abril',
      'Mayo',
      'Hunyo',
      'Hulyo',
      'Agosto',
      'Setyembre',
      'Oktubre',
      'Nobyembre',
      'Disyembre'
    ];
    return lang.translateList(en, il, tl)[month - 1];
  }

  static String getNotSet(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Not set', 'Saan a naiset', 'Hindi nakatakda');
  }

  static String getSaveChanges(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Save Changes', 'I-save ti Binaliw', 'I-save ang mga Pagbabago');
  }

  static String getEnterName(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Enter your name', 'Isurat ti naganmo', 'Ilagay ang iyong pangalan');
  }

  // ========== ONBOARDING SCREEN ==========
  static String getChooseLanguage(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Choose Language', 'Piliem ti Pagsasao', 'Pumili ng Wika');
  }

  static String getGetStarted(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Get Started', 'Irugi', 'Magsimula');
  }

  static String getNextLevelLearningTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Next Level Learning',
        'Sumaruno a Tukad ti Panagadal', 'Susunod na Antas ng Pag-aaral');
  }

  static String getNextLevelLearningDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Fun and interactive games for kids to learn and grow.',
        'Nakaragsak ken interaktibo nga ay-ayam para kadagiti ubbing tapno makaadal ken dumakkel.',
        'Masaya at interactive na mga laro para sa mga bata upang matuto at lumago.');
  }

  static String getLearnAnywhereTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Learn Anywhere', 'Agadal iti Sadinoman', 'Matuto Kahit Saan');
  }

  static String getLearnAnywhereDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Access lessons offline and keep learning on the go.',
        'Maala dagiti adal uray offline ken ituloy ti agadal sadiay man.',
        'I-access ang mga aralin kahit offline at ituloy ang pag-aaral kahit nasaan mang dako.');
  }

  static String getTrackProgressTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate('Track Progress', 'Suroten ti Panagrang-ay',
        'Subaybayan ang Pag-unlad');
  }

  static String getTrackProgressDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'See how well your child is doing with smart progress tracking.',
        'Kitaem no kasano ti panagrang-ay ti anakmo babaen ti smart progress tracking.',
        'Tignan kung gaano kagaling ang iyong anak sa pamamagitan ng smart progress tracking.');
  }

  static String getWelcomeOnboardingTitle(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Welcome to E Tarabay',
        'Naragsak a Isasangbay iti E Tarabay',
        'Maligayang Pagdating sa E Tarabay');
  }

  static String getWelcomeOnboardingDesc(BuildContext context) {
    final lang = Provider.of<LanguageProvider>(context);
    return lang.translate(
        'Your intelligent companion in learning and discovering the world.',
        'Ti nasaririt a kaduam iti panagadal ken panangdiskobre ti lubong.',
        'Ang iyong matalinong kasama sa pag-aaral at pagtuklas ng mundo.');
  }
}
