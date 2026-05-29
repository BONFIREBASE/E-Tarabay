import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fil.dart';
import 'app_localizations_ilo.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fil'),
    Locale('ilo')
  ];

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @levelCompleted.
  ///
  /// In en, this message translates to:
  /// **'Level {level} Completed!'**
  String levelCompleted(int level);

  /// No description provided for @proudOfYou.
  ///
  /// In en, this message translates to:
  /// **'I am proud of you!'**
  String get proudOfYou;

  /// No description provided for @alreadyDone.
  ///
  /// In en, this message translates to:
  /// **'You already finished this!'**
  String get alreadyDone;

  /// No description provided for @categoryCompleted.
  ///
  /// In en, this message translates to:
  /// **'You completed all levels in {cat}!'**
  String categoryCompleted(String cat);

  /// No description provided for @finished.
  ///
  /// In en, this message translates to:
  /// **'Finished! 🏆'**
  String get finished;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @inProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get inProgress;

  /// No description provided for @earned.
  ///
  /// In en, this message translates to:
  /// **'earned'**
  String get earned;

  /// No description provided for @levels.
  ///
  /// In en, this message translates to:
  /// **'Levels'**
  String get levels;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'activities'**
  String get activities;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'E-Tarabay'**
  String get appTitle;

  /// No description provided for @parents.
  ///
  /// In en, this message translates to:
  /// **'PARENTS'**
  String get parents;

  /// No description provided for @lessons.
  ///
  /// In en, this message translates to:
  /// **'Lessons'**
  String get lessons;

  /// No description provided for @stars.
  ///
  /// In en, this message translates to:
  /// **'Stars'**
  String get stars;

  /// No description provided for @awards.
  ///
  /// In en, this message translates to:
  /// **'Awards'**
  String get awards;

  /// No description provided for @homeAge.
  ///
  /// In en, this message translates to:
  /// **'Age {age}'**
  String homeAge(int age);

  /// No description provided for @matematika.
  ///
  /// In en, this message translates to:
  /// **'Mathematics'**
  String get matematika;

  /// No description provided for @sundanMoKayaMo.
  ///
  /// In en, this message translates to:
  /// **'Follow Me, You Can Do It!'**
  String get sundanMoKayaMo;

  /// No description provided for @angAkingSarili.
  ///
  /// In en, this message translates to:
  /// **'About\nMyself'**
  String get angAkingSarili;

  /// No description provided for @atAkingPamilya.
  ///
  /// In en, this message translates to:
  /// **'And My Family'**
  String get atAkingPamilya;

  /// No description provided for @kulaySaya.
  ///
  /// In en, this message translates to:
  /// **'Color Fun'**
  String get kulaySaya;

  /// No description provided for @magkulayTayo.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Color!'**
  String get magkulayTayo;

  /// No description provided for @sundanMo.
  ///
  /// In en, this message translates to:
  /// **'Follow Me,'**
  String get sundanMo;

  /// No description provided for @magbasaTitle.
  ///
  /// In en, this message translates to:
  /// **'Let\'s Read'**
  String get magbasaTitle;

  /// No description provided for @alpabetoAtMgaSalita.
  ///
  /// In en, this message translates to:
  /// **'Poems, Stories and Songs'**
  String get alpabetoAtMgaSalita;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @totalProgress.
  ///
  /// In en, this message translates to:
  /// **'Total Progress'**
  String get totalProgress;

  /// No description provided for @poems.
  ///
  /// In en, this message translates to:
  /// **'Poems'**
  String get poems;

  /// No description provided for @stories.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get stories;

  /// No description provided for @songs.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get songs;

  /// No description provided for @readStory.
  ///
  /// In en, this message translates to:
  /// **'Read Story'**
  String get readStory;

  /// No description provided for @listenToSong.
  ///
  /// In en, this message translates to:
  /// **'Listen to Song'**
  String get listenToSong;

  /// No description provided for @readPoem.
  ///
  /// In en, this message translates to:
  /// **'Read Poem'**
  String get readPoem;

  /// No description provided for @swipeToRead.
  ///
  /// In en, this message translates to:
  /// **'Swipe to read'**
  String get swipeToRead;

  /// No description provided for @tune.
  ///
  /// In en, this message translates to:
  /// **'Tune'**
  String get tune;

  /// No description provided for @action.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get action;

  /// No description provided for @counting.
  ///
  /// In en, this message translates to:
  /// **'Count the Objects'**
  String get counting;

  /// No description provided for @dragNumber.
  ///
  /// In en, this message translates to:
  /// **'Drag the Number'**
  String get dragNumber;

  /// No description provided for @lineMatch.
  ///
  /// In en, this message translates to:
  /// **'Match with Line'**
  String get lineMatch;

  /// No description provided for @popBalloon.
  ///
  /// In en, this message translates to:
  /// **'Pop the Balloon'**
  String get popBalloon;

  /// No description provided for @moreOrLess.
  ///
  /// In en, this message translates to:
  /// **'More or Less?'**
  String get moreOrLess;

  /// No description provided for @numberPuzzle.
  ///
  /// In en, this message translates to:
  /// **'Number Puzzle'**
  String get numberPuzzle;

  /// No description provided for @numberSequence.
  ///
  /// In en, this message translates to:
  /// **'Number Sequence'**
  String get numberSequence;

  /// No description provided for @chooseAnswer.
  ///
  /// In en, this message translates to:
  /// **'Choose the correct answer:'**
  String get chooseAnswer;

  /// No description provided for @check.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get check;

  /// No description provided for @correct.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get correct;

  /// No description provided for @wrong.
  ///
  /// In en, this message translates to:
  /// **'Wrong! Try again!'**
  String get wrong;

  /// No description provided for @timeOut.
  ///
  /// In en, this message translates to:
  /// **'Time\'s up! Try again.'**
  String get timeOut;

  /// No description provided for @level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String level(int level);

  /// No description provided for @perfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get perfect;

  /// No description provided for @great.
  ///
  /// In en, this message translates to:
  /// **'Great!'**
  String get great;

  /// No description provided for @good.
  ///
  /// In en, this message translates to:
  /// **'Good!'**
  String get good;

  /// No description provided for @mathPoints.
  ///
  /// In en, this message translates to:
  /// **'+{points} points'**
  String mathPoints(int points);

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'{streak} day streak!'**
  String streak(int streak);

  /// No description provided for @mathTotalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get mathTotalScore;

  /// No description provided for @mathTotalStars.
  ///
  /// In en, this message translates to:
  /// **'Total Stars'**
  String get mathTotalStars;

  /// No description provided for @repeat.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeat;

  /// No description provided for @nextLevel.
  ///
  /// In en, this message translates to:
  /// **'Next Level'**
  String get nextLevel;

  /// No description provided for @congratulations.
  ///
  /// In en, this message translates to:
  /// **'Congratulations!'**
  String get congratulations;

  /// No description provided for @completedAllLevels.
  ///
  /// In en, this message translates to:
  /// **'You completed all levels!'**
  String get completedAllLevels;

  /// No description provided for @chooseFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose an answer first!'**
  String get chooseFirst;

  /// No description provided for @chooseLeftFirst.
  ///
  /// In en, this message translates to:
  /// **'Choose a number on the left first!'**
  String get chooseLeftFirst;

  /// No description provided for @dropHere.
  ///
  /// In en, this message translates to:
  /// **'Drop here!'**
  String get dropHere;

  /// No description provided for @dragHere.
  ///
  /// In en, this message translates to:
  /// **'Drag here'**
  String get dragHere;

  /// No description provided for @tapLeftThenRight.
  ///
  /// In en, this message translates to:
  /// **'Tap left then right'**
  String get tapLeftThenRight;

  /// No description provided for @matched.
  ///
  /// In en, this message translates to:
  /// **'matched'**
  String get matched;

  /// No description provided for @popAllBalloonsWith.
  ///
  /// In en, this message translates to:
  /// **'Pop all balloons with'**
  String get popAllBalloonsWith;

  /// No description provided for @left.
  ///
  /// In en, this message translates to:
  /// **'Left'**
  String get left;

  /// No description provided for @right.
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get right;

  /// No description provided for @theyAreEqual.
  ///
  /// In en, this message translates to:
  /// **'They are equal!'**
  String get theyAreEqual;

  /// No description provided for @tapTwoToSwap.
  ///
  /// In en, this message translates to:
  /// **'Tap two numbers to swap'**
  String get tapTwoToSwap;

  /// No description provided for @correctOrder.
  ///
  /// In en, this message translates to:
  /// **'Correct order'**
  String get correctOrder;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'Selected'**
  String get selected;

  /// No description provided for @tapAnotherToSwap.
  ///
  /// In en, this message translates to:
  /// **'tap another to swap'**
  String get tapAnotherToSwap;

  /// No description provided for @whatsMissing.
  ///
  /// In en, this message translates to:
  /// **'What\\\'s missing?'**
  String get whatsMissing;

  /// No description provided for @noGames.
  ///
  /// In en, this message translates to:
  /// **'No games available'**
  String get noGames;

  /// No description provided for @howMany.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String howMany(String item);

  /// No description provided for @matchWithNumber.
  ///
  /// In en, this message translates to:
  /// **'en'**
  String matchWithNumber(String category);

  /// No description provided for @whichIsMore.
  ///
  /// In en, this message translates to:
  /// **'Which is more?'**
  String get whichIsMore;

  /// No description provided for @whichIsLess.
  ///
  /// In en, this message translates to:
  /// **'Which is less?'**
  String get whichIsLess;

  /// No description provided for @isSameNumber.
  ///
  /// In en, this message translates to:
  /// **'Same number?'**
  String get isSameNumber;

  /// No description provided for @arrange.
  ///
  /// In en, this message translates to:
  /// **'Arrange: {sequence}'**
  String arrange(String sequence);

  /// No description provided for @incorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'❌ INCORRECT ANSWER'**
  String get incorrectAnswer;

  /// No description provided for @selectCorrectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Select the correct answer:'**
  String get selectCorrectAnswer;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @tapLeftTapRight.
  ///
  /// In en, this message translates to:
  /// **'Tap the group (left) → tap the number (right)'**
  String get tapLeftTapRight;

  /// No description provided for @angAkingSariliTitle.
  ///
  /// In en, this message translates to:
  /// **'Ang Aking Sarili'**
  String get angAkingSariliTitle;

  /// No description provided for @angAkingPamilyaTitle.
  ///
  /// In en, this message translates to:
  /// **'Ang Aking Pamilya'**
  String get angAkingPamilyaTitle;

  /// No description provided for @allAboutMe.
  ///
  /// In en, this message translates to:
  /// **'All About Me'**
  String get allAboutMe;

  /// No description provided for @myEmotions.
  ///
  /// In en, this message translates to:
  /// **'My Emotions'**
  String get myEmotions;

  /// No description provided for @dailyRoutines.
  ///
  /// In en, this message translates to:
  /// **'Daily Routines'**
  String get dailyRoutines;

  /// No description provided for @myPreferences.
  ///
  /// In en, this message translates to:
  /// **'My Preferences'**
  String get myPreferences;

  /// No description provided for @familyMembers.
  ///
  /// In en, this message translates to:
  /// **'Family Members'**
  String get familyMembers;

  /// No description provided for @familyRoles.
  ///
  /// In en, this message translates to:
  /// **'Family Roles'**
  String get familyRoles;

  /// No description provided for @familyActivities.
  ///
  /// In en, this message translates to:
  /// **'Family Activities'**
  String get familyActivities;

  /// No description provided for @familyTree.
  ///
  /// In en, this message translates to:
  /// **'Family Tree'**
  String get familyTree;

  /// No description provided for @myHome.
  ///
  /// In en, this message translates to:
  /// **'My Home'**
  String get myHome;

  /// No description provided for @whatIsYourName.
  ///
  /// In en, this message translates to:
  /// **'What is your name?'**
  String get whatIsYourName;

  /// No description provided for @howOldAreYou.
  ///
  /// In en, this message translates to:
  /// **'How old are you?'**
  String get howOldAreYou;

  /// No description provided for @areYouBoyOrGirl.
  ///
  /// In en, this message translates to:
  /// **'Are you a boy or a girl?'**
  String get areYouBoyOrGirl;

  /// No description provided for @girl.
  ///
  /// In en, this message translates to:
  /// **'Girl'**
  String get girl;

  /// No description provided for @boy.
  ///
  /// In en, this message translates to:
  /// **'Boy'**
  String get boy;

  /// No description provided for @whatIsYourNameDescription.
  ///
  /// In en, this message translates to:
  /// **'Your name is what your family and friends call you. It is important!'**
  String get whatIsYourNameDescription;

  /// No description provided for @howOldAreYouDescription.
  ///
  /// In en, this message translates to:
  /// **'Your age is the number of years since you were born. Celebrate every year!'**
  String get howOldAreYouDescription;

  /// No description provided for @genderDescription.
  ///
  /// In en, this message translates to:
  /// **'Knowing if you are a boy or a girl helps us know more about you!'**
  String get genderDescription;

  /// No description provided for @typeNameHint.
  ///
  /// In en, this message translates to:
  /// **'Type your name here'**
  String get typeNameHint;

  /// No description provided for @ageHint.
  ///
  /// In en, this message translates to:
  /// **'Example: 5, 7, 10'**
  String get ageHint;

  /// No description provided for @girlLabel.
  ///
  /// In en, this message translates to:
  /// **'👧 Girl'**
  String get girlLabel;

  /// No description provided for @boyLabel.
  ///
  /// In en, this message translates to:
  /// **'👦 Boy'**
  String get boyLabel;

  /// No description provided for @aboutMeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All About Me'**
  String get aboutMeSubtitle;

  /// No description provided for @myEmotionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Explain your feelings'**
  String get myEmotionsSubtitle;

  /// No description provided for @dailyRoutinesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Learn daily activities'**
  String get dailyRoutinesSubtitle;

  /// No description provided for @myPreferencesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What do you like?'**
  String get myPreferencesSubtitle;

  /// No description provided for @familyMembersSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who are your family members?'**
  String get familyMembersSubtitle;

  /// No description provided for @familyRolesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What is everyone\\\'s job?'**
  String get familyRolesSubtitle;

  /// No description provided for @familyActivitiesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'What do you do together?'**
  String get familyActivitiesSubtitle;

  /// No description provided for @familyTreeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Who are your relatives?'**
  String get familyTreeSubtitle;

  /// No description provided for @myHomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Where do you live?'**
  String get myHomeSubtitle;

  /// No description provided for @emotionHappyQuestion.
  ///
  /// In en, this message translates to:
  /// **'When are you HAPPY?'**
  String get emotionHappyQuestion;

  /// No description provided for @emotionSadQuestion.
  ///
  /// In en, this message translates to:
  /// **'When are you SAD?'**
  String get emotionSadQuestion;

  /// No description provided for @emotionAngryQuestion.
  ///
  /// In en, this message translates to:
  /// **'When are you ANGRY?'**
  String get emotionAngryQuestion;

  /// No description provided for @emotionSurprisedQuestion.
  ///
  /// In en, this message translates to:
  /// **'When are you SURPRISED?'**
  String get emotionSurprisedQuestion;

  /// No description provided for @routineWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Wake up in the morning'**
  String get routineWakeUp;

  /// No description provided for @routineBrushTeeth.
  ///
  /// In en, this message translates to:
  /// **'Brush your teeth'**
  String get routineBrushTeeth;

  /// No description provided for @routineTakeBath.
  ///
  /// In en, this message translates to:
  /// **'Take a bath'**
  String get routineTakeBath;

  /// No description provided for @routineEatBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Eat breakfast'**
  String get routineEatBreakfast;

  /// No description provided for @preferenceFood.
  ///
  /// In en, this message translates to:
  /// **'What is your favorite food?'**
  String get preferenceFood;

  /// No description provided for @preferenceColor.
  ///
  /// In en, this message translates to:
  /// **'What is your favorite color?'**
  String get preferenceColor;

  /// No description provided for @whenIsYourBirthday.
  ///
  /// In en, this message translates to:
  /// **'When is your birthday?'**
  String get whenIsYourBirthday;

  /// No description provided for @whereDoYouLive.
  ///
  /// In en, this message translates to:
  /// **'Where do you live?'**
  String get whereDoYouLive;

  /// No description provided for @happy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get happy;

  /// No description provided for @sad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get sad;

  /// No description provided for @angry.
  ///
  /// In en, this message translates to:
  /// **'Angry'**
  String get angry;

  /// No description provided for @surprised.
  ///
  /// In en, this message translates to:
  /// **'Surprised'**
  String get surprised;

  /// No description provided for @sleepy.
  ///
  /// In en, this message translates to:
  /// **'Sleepy'**
  String get sleepy;

  /// No description provided for @scared.
  ///
  /// In en, this message translates to:
  /// **'Scared'**
  String get scared;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @father.
  ///
  /// In en, this message translates to:
  /// **'Father'**
  String get father;

  /// No description provided for @olderBrother.
  ///
  /// In en, this message translates to:
  /// **'Older Brother'**
  String get olderBrother;

  /// No description provided for @olderSister.
  ///
  /// In en, this message translates to:
  /// **'Older Sister'**
  String get olderSister;

  /// No description provided for @youngerSibling.
  ///
  /// In en, this message translates to:
  /// **'Younger Sibling'**
  String get youngerSibling;

  /// No description provided for @grandfather.
  ///
  /// In en, this message translates to:
  /// **'Grandfather'**
  String get grandfather;

  /// No description provided for @grandmother.
  ///
  /// In en, this message translates to:
  /// **'Grandmother'**
  String get grandmother;

  /// No description provided for @searchColoringPages.
  ///
  /// In en, this message translates to:
  /// **'Search coloring pages...'**
  String get searchColoringPages;

  /// No description provided for @beautifulArtwork.
  ///
  /// In en, this message translates to:
  /// **'Beautiful Artwork!'**
  String get beautifulArtwork;

  /// No description provided for @finishedColoring.
  ///
  /// In en, this message translates to:
  /// **'You finished coloring {name}!'**
  String finishedColoring(String name);

  /// No description provided for @saveYourArtwork.
  ///
  /// In en, this message translates to:
  /// **'Save Your Artwork'**
  String get saveYourArtwork;

  /// No description provided for @giveArtworkName.
  ///
  /// In en, this message translates to:
  /// **'Give your artwork a name...'**
  String get giveArtworkName;

  /// No description provided for @colorSomethingFirst.
  ///
  /// In en, this message translates to:
  /// **'Color something first!'**
  String get colorSomethingFirst;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @timeAgo.
  ///
  /// In en, this message translates to:
  /// **'\${amount}m ago'**
  String timeAgo(int amount, String unit);

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved!'**
  String get saved;

  /// No description provided for @others.
  ///
  /// In en, this message translates to:
  /// **'Others'**
  String get others;

  /// No description provided for @coloringBook.
  ///
  /// In en, this message translates to:
  /// **'Coloring Book'**
  String get coloringBook;

  /// No description provided for @myCreations.
  ///
  /// In en, this message translates to:
  /// **'My Creations'**
  String get myCreations;

  /// No description provided for @color.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get color;

  /// No description provided for @animals.
  ///
  /// In en, this message translates to:
  /// **'Animals'**
  String get animals;

  /// No description provided for @flowers.
  ///
  /// In en, this message translates to:
  /// **'Flowers'**
  String get flowers;

  /// No description provided for @fruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get fruits;

  /// No description provided for @toys.
  ///
  /// In en, this message translates to:
  /// **'Toys'**
  String get toys;

  /// No description provided for @red.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get red;

  /// No description provided for @blue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get blue;

  /// No description provided for @green.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get green;

  /// No description provided for @yellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get yellow;

  /// No description provided for @orange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get orange;

  /// No description provided for @purple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get purple;

  /// No description provided for @pink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get pink;

  /// No description provided for @brown.
  ///
  /// In en, this message translates to:
  /// **'Brown'**
  String get brown;

  /// No description provided for @black.
  ///
  /// In en, this message translates to:
  /// **'Black'**
  String get black;

  /// No description provided for @white.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get white;

  /// No description provided for @easy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get easy;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @hard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get hard;

  /// No description provided for @brush.
  ///
  /// In en, this message translates to:
  /// **'Brush'**
  String get brush;

  /// No description provided for @eraser.
  ///
  /// In en, this message translates to:
  /// **'Eraser'**
  String get eraser;

  /// No description provided for @undo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In en, this message translates to:
  /// **'Redo'**
  String get redo;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @surotemKabaelam.
  ///
  /// In en, this message translates to:
  /// **'Trace It, You Can Do It!'**
  String get surotemKabaelam;

  /// No description provided for @upper.
  ///
  /// In en, this message translates to:
  /// **'Upper'**
  String get upper;

  /// No description provided for @lower.
  ///
  /// In en, this message translates to:
  /// **'Lower'**
  String get lower;

  /// No description provided for @letterLabel.
  ///
  /// In en, this message translates to:
  /// **'Letter {letter}'**
  String letterLabel(String letter);

  /// No description provided for @pointsLabel.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get pointsLabel;

  /// No description provided for @goodJob.
  ///
  /// In en, this message translates to:
  /// **'Good Job! 🌟'**
  String get goodJob;

  /// No description provided for @ulitin.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get ulitin;

  /// No description provided for @traceTitle.
  ///
  /// In en, this message translates to:
  /// **'Follow Me, You Can Do It!'**
  String get traceTitle;

  /// No description provided for @uppercase.
  ///
  /// In en, this message translates to:
  /// **'Uppercase'**
  String get uppercase;

  /// No description provided for @lowercase.
  ///
  /// In en, this message translates to:
  /// **'Lowercase'**
  String get lowercase;

  /// No description provided for @numbers.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get numbers;

  /// No description provided for @letter.
  ///
  /// In en, this message translates to:
  /// **'Letter {letter}'**
  String letter(String letter);

  /// No description provided for @sundanPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get sundanPoints;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @finishedThisLetter.
  ///
  /// In en, this message translates to:
  /// **'You finished this letter!'**
  String get finishedThisLetter;

  /// No description provided for @goodJobPoints.
  ///
  /// In en, this message translates to:
  /// **'🌟 Good Job! +{points} points'**
  String goodJobPoints(int points);

  /// No description provided for @tooHardSwitch.
  ///
  /// In en, this message translates to:
  /// **'Too hard? Let\\\'s try the next one!'**
  String get tooHardSwitch;

  /// No description provided for @reTrace.
  ///
  /// In en, this message translates to:
  /// **'Re-trace'**
  String get reTrace;

  /// No description provided for @forParentsTitle.
  ///
  /// In en, this message translates to:
  /// **'For Parents'**
  String get forParentsTitle;

  /// No description provided for @overallProgress.
  ///
  /// In en, this message translates to:
  /// **'Overall Progress'**
  String get overallProgress;

  /// No description provided for @tula.
  ///
  /// In en, this message translates to:
  /// **'Poems'**
  String get tula;

  /// No description provided for @kwento.
  ///
  /// In en, this message translates to:
  /// **'Stories'**
  String get kwento;

  /// No description provided for @kanta.
  ///
  /// In en, this message translates to:
  /// **'Songs'**
  String get kanta;

  /// No description provided for @uppercaseProgress.
  ///
  /// In en, this message translates to:
  /// **'Uppercase'**
  String get uppercaseProgress;

  /// No description provided for @lowercaseProgress.
  ///
  /// In en, this message translates to:
  /// **'Lowercase'**
  String get lowercaseProgress;

  /// No description provided for @numbersProgress.
  ///
  /// In en, this message translates to:
  /// **'Numbers'**
  String get numbersProgress;

  /// No description provided for @basicColors.
  ///
  /// In en, this message translates to:
  /// **'Basic Colors'**
  String get basicColors;

  /// No description provided for @colorMixing.
  ///
  /// In en, this message translates to:
  /// **'Color Mixing'**
  String get colorMixing;

  /// No description provided for @colorObjects.
  ///
  /// In en, this message translates to:
  /// **'Color Objects'**
  String get colorObjects;

  /// No description provided for @completedLevels.
  ///
  /// In en, this message translates to:
  /// **'Completed Levels'**
  String get completedLevels;

  /// No description provided for @gamesCompleted.
  ///
  /// In en, this message translates to:
  /// **'Games Completed'**
  String get gamesCompleted;

  /// No description provided for @parentsTotalScore.
  ///
  /// In en, this message translates to:
  /// **'Total Score'**
  String get parentsTotalScore;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current Streak'**
  String get currentStreak;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String days(int days);

  /// No description provided for @parentsTotalStars.
  ///
  /// In en, this message translates to:
  /// **'Total Stars'**
  String get parentsTotalStars;

  /// No description provided for @badges.
  ///
  /// In en, this message translates to:
  /// **'badges'**
  String get badges;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @yearsOld.
  ///
  /// In en, this message translates to:
  /// **'{age} years old'**
  String yearsOld(int age);

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @birthday.
  ///
  /// In en, this message translates to:
  /// **'Birthday'**
  String get birthday;

  /// No description provided for @profileAge.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get profileAge;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @memberSince.
  ///
  /// In en, this message translates to:
  /// **'Member Since'**
  String get memberSince;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @noProfileData.
  ///
  /// In en, this message translates to:
  /// **'No profile data'**
  String get noProfileData;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @sound.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get sound;

  /// No description provided for @music.
  ///
  /// In en, this message translates to:
  /// **'Music'**
  String get music;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @firstSteps.
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get firstSteps;

  /// No description provided for @alphabetMaster.
  ///
  /// In en, this message translates to:
  /// **'Alphabet Master'**
  String get alphabetMaster;

  /// No description provided for @numberWizard.
  ///
  /// In en, this message translates to:
  /// **'Number Wizard'**
  String get numberWizard;

  /// No description provided for @colorArtist.
  ///
  /// In en, this message translates to:
  /// **'Color Artist'**
  String get colorArtist;

  /// No description provided for @shapeCreator.
  ///
  /// In en, this message translates to:
  /// **'Shape Creator'**
  String get shapeCreator;

  /// No description provided for @animalFriend.
  ///
  /// In en, this message translates to:
  /// **'Animal Friend'**
  String get animalFriend;

  /// No description provided for @bookworm.
  ///
  /// In en, this message translates to:
  /// **'Bookworm'**
  String get bookworm;

  /// No description provided for @starStudent.
  ///
  /// In en, this message translates to:
  /// **'Star Student'**
  String get starStudent;

  /// No description provided for @mathWhiz.
  ///
  /// In en, this message translates to:
  /// **'Math Whiz'**
  String get mathWhiz;

  /// No description provided for @familyHero.
  ///
  /// In en, this message translates to:
  /// **'Family Hero'**
  String get familyHero;

  /// No description provided for @writingStar.
  ///
  /// In en, this message translates to:
  /// **'Writing Star'**
  String get writingStar;

  /// No description provided for @songbird.
  ///
  /// In en, this message translates to:
  /// **'Songbird'**
  String get songbird;

  /// No description provided for @perfectScore.
  ///
  /// In en, this message translates to:
  /// **'Perfect Score'**
  String get perfectScore;

  /// No description provided for @firstStepsDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first activity'**
  String get firstStepsDesc;

  /// No description provided for @alphabetMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all Magbasa Tayo activities'**
  String get alphabetMasterDesc;

  /// No description provided for @numberWizardDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 20 Matematika games'**
  String get numberWizardDesc;

  /// No description provided for @colorArtistDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all Kulay-Saya activities'**
  String get colorArtistDesc;

  /// No description provided for @shapeCreatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all uppercase letters'**
  String get shapeCreatorDesc;

  /// No description provided for @animalFriendDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all lowercase letters'**
  String get animalFriendDesc;

  /// No description provided for @bookwormDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all stories'**
  String get bookwormDesc;

  /// No description provided for @starStudentDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 20 Ang Aking Sarili games'**
  String get starStudentDesc;

  /// No description provided for @familyHeroDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all family levels'**
  String get familyHeroDesc;

  /// No description provided for @writingStarDesc.
  ///
  /// In en, this message translates to:
  /// **'Trace all letters and numbers'**
  String get writingStarDesc;

  /// No description provided for @songbirdDesc.
  ///
  /// In en, this message translates to:
  /// **'Learn all 13 songs'**
  String get songbirdDesc;

  /// No description provided for @perfectScoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Get perfect score in 3 games'**
  String get perfectScoreDesc;

  /// No description provided for @noAwardsYet.
  ///
  /// In en, this message translates to:
  /// **'No Awards Yet'**
  String get noAwardsYet;

  /// No description provided for @completeActivitiesToEarn.
  ///
  /// In en, this message translates to:
  /// **'Complete activities to earn awards!'**
  String get completeActivitiesToEarn;

  /// No description provided for @teacherDashboard.
  ///
  /// In en, this message translates to:
  /// **'Teacher Dashboard'**
  String get teacherDashboard;

  /// No description provided for @enrollStudent.
  ///
  /// In en, this message translates to:
  /// **'Enroll Student'**
  String get enrollStudent;

  /// No description provided for @firstName.
  ///
  /// In en, this message translates to:
  /// **'First Name'**
  String get firstName;

  /// No description provided for @lastName.
  ///
  /// In en, this message translates to:
  /// **'Last Name'**
  String get lastName;

  /// No description provided for @lRN.
  ///
  /// In en, this message translates to:
  /// **'LRN (Password)'**
  String get lRN;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username (Auto-generated)'**
  String get usernameLabel;

  /// No description provided for @genderLabel.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get genderLabel;

  /// No description provided for @studentInfo.
  ///
  /// In en, this message translates to:
  /// **'Student Info'**
  String get studentInfo;

  /// No description provided for @removeStudent.
  ///
  /// In en, this message translates to:
  /// **'Remove Student?'**
  String get removeStudent;

  /// No description provided for @progressLabel.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progressLabel;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get confirmLogout;

  /// No description provided for @verifyLRN.
  ///
  /// In en, this message translates to:
  /// **'Verify LRN'**
  String get verifyLRN;

  /// No description provided for @enterLRN.
  ///
  /// In en, this message translates to:
  /// **'Please enter your LRN to proceed'**
  String get enterLRN;

  /// No description provided for @invalidLRN.
  ///
  /// In en, this message translates to:
  /// **'Invalid LRN. Please try again.'**
  String get invalidLRN;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @enrollmentInfo.
  ///
  /// In en, this message translates to:
  /// **'Give the username and LRN to the parent/student for login.'**
  String get enrollmentInfo;

  /// No description provided for @fillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all fields.'**
  String get fillAllFields;

  /// No description provided for @parentsInfo.
  ///
  /// In en, this message translates to:
  /// **'Parents Info'**
  String get parentsInfo;

  /// No description provided for @parentNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent\'s Name'**
  String get parentNameLabel;

  /// No description provided for @parentContactLabel.
  ///
  /// In en, this message translates to:
  /// **'Parent\'s Contact (11 digits)'**
  String get parentContactLabel;

  /// No description provided for @contactLengthError.
  ///
  /// In en, this message translates to:
  /// **'Contact number must be exactly 11 digits.'**
  String get contactLengthError;

  /// No description provided for @birthdayGreeting.
  ///
  /// In en, this message translates to:
  /// **'Happy Birthday, {name}!'**
  String birthdayGreeting(String name);

  /// No description provided for @swipeToDeleteGuide.
  ///
  /// In en, this message translates to:
  /// **'Swipe left on a student to delete'**
  String get swipeToDeleteGuide;

  /// No description provided for @enrollmentFailed.
  ///
  /// In en, this message translates to:
  /// **'Enrollment failed.'**
  String get enrollmentFailed;

  /// No description provided for @enroll.
  ///
  /// In en, this message translates to:
  /// **'Enroll'**
  String get enroll;

  /// No description provided for @studentEnrolled.
  ///
  /// In en, this message translates to:
  /// **'Student Enrolled!'**
  String get studentEnrolled;

  /// No description provided for @studentEnrolledSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'{name} has been enrolled successfully.'**
  String studentEnrolledSuccessfully(String name);

  /// No description provided for @loginCredentials.
  ///
  /// In en, this message translates to:
  /// **'Login Credentials:'**
  String get loginCredentials;

  /// No description provided for @userLabel.
  ///
  /// In en, this message translates to:
  /// **'User:'**
  String get userLabel;

  /// No description provided for @usernameCopied.
  ///
  /// In en, this message translates to:
  /// **'Username copied!'**
  String get usernameCopied;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Pass:'**
  String get passwordLabel;

  /// No description provided for @passwordCopied.
  ///
  /// In en, this message translates to:
  /// **'Password copied!'**
  String get passwordCopied;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @lRNPassword.
  ///
  /// In en, this message translates to:
  /// **'LRN (Password)'**
  String get lRNPassword;

  /// No description provided for @confirmRemoveStudent.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this student? This cannot be undone.'**
  String get confirmRemoveStudent;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get copied;

  /// No description provided for @noStudentsEnrolled.
  ///
  /// In en, this message translates to:
  /// **'No students enrolled yet.'**
  String get noStudentsEnrolled;

  /// No description provided for @tapToEnroll.
  ///
  /// In en, this message translates to:
  /// **'Tap \"Enroll Student\" to add one.'**
  String get tapToEnroll;

  /// No description provided for @usernameHeader.
  ///
  /// In en, this message translates to:
  /// **'Username:'**
  String get usernameHeader;

  /// No description provided for @studentProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'{name}\'s Progress'**
  String studentProgressTitle(String name);

  /// No description provided for @moduleBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Module Breakdown'**
  String get moduleBreakdown;

  /// No description provided for @scoreLabel.
  ///
  /// In en, this message translates to:
  /// **'Score: {score}'**
  String scoreLabel(int score);

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcome;

  /// No description provided for @loginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Log in to continue your learning journey'**
  String get loginPrompt;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get loginButton;

  /// No description provided for @teacherLoginButton.
  ///
  /// In en, this message translates to:
  /// **'Continue as Teacher'**
  String get teacherLoginButton;

  /// No description provided for @enterUsernamePassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter both username and password.'**
  String get enterUsernamePassword;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again.'**
  String get loginError;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @teacherLoginTitle.
  ///
  /// In en, this message translates to:
  /// **'Teacher Login'**
  String get teacherLoginTitle;

  /// No description provided for @teacherLoginPrompt.
  ///
  /// In en, this message translates to:
  /// **'Enter your teacher credentials to continue'**
  String get teacherLoginPrompt;

  /// No description provided for @teacherLoginButtonLabel.
  ///
  /// In en, this message translates to:
  /// **'Log In as Teacher'**
  String get teacherLoginButtonLabel;

  /// No description provided for @invalidTeacherCredentials.
  ///
  /// In en, this message translates to:
  /// **'Invalid teacher credentials. Please try again.'**
  String get invalidTeacherCredentials;

  /// No description provided for @monthName.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String monthName(int month);

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get notSet;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @enterName.
  ///
  /// In en, this message translates to:
  /// **'Enter your name'**
  String get enterName;

  /// No description provided for @chooseLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @nextLevelLearningTitle.
  ///
  /// In en, this message translates to:
  /// **'Next Level Learning'**
  String get nextLevelLearningTitle;

  /// No description provided for @nextLevelLearningDesc.
  ///
  /// In en, this message translates to:
  /// **'Fun and interactive games for kids to learn and grow.'**
  String get nextLevelLearningDesc;

  /// No description provided for @learnAnywhereTitle.
  ///
  /// In en, this message translates to:
  /// **'Learn Anywhere'**
  String get learnAnywhereTitle;

  /// No description provided for @learnAnywhereDesc.
  ///
  /// In en, this message translates to:
  /// **'Access lessons offline and keep learning on the go.'**
  String get learnAnywhereDesc;

  /// No description provided for @trackProgressTitle.
  ///
  /// In en, this message translates to:
  /// **'Track Progress'**
  String get trackProgressTitle;

  /// No description provided for @trackProgressDesc.
  ///
  /// In en, this message translates to:
  /// **'See how well your child is doing with smart progress tracking.'**
  String get trackProgressDesc;

  /// No description provided for @welcomeOnboardingTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to E-Tarabay'**
  String get welcomeOnboardingTitle;

  /// No description provided for @welcomeOnboardingDesc.
  ///
  /// In en, this message translates to:
  /// **'Your intelligent companion in learning and discovering the world.'**
  String get welcomeOnboardingDesc;

  /// No description provided for @continueText.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueText;

  /// No description provided for @forParents.
  ///
  /// In en, this message translates to:
  /// **'For Parents'**
  String get forParents;

  /// No description provided for @hello.
  ///
  /// In en, this message translates to:
  /// **'Hello!'**
  String get hello;

  /// No description provided for @kulaySayaProgress.
  ///
  /// In en, this message translates to:
  /// **'Kulay-Saya Progress'**
  String get kulaySayaProgress;

  /// No description provided for @totalSaved.
  ///
  /// In en, this message translates to:
  /// **'Total Saved'**
  String get totalSaved;

  /// No description provided for @sundanMoProgress.
  ///
  /// In en, this message translates to:
  /// **'Sundan Mo Progress'**
  String get sundanMoProgress;

  /// No description provided for @magbasaProgress.
  ///
  /// In en, this message translates to:
  /// **'Magbasa Progress'**
  String get magbasaProgress;

  /// No description provided for @matematikaProgress.
  ///
  /// In en, this message translates to:
  /// **'Matematika Progress'**
  String get matematikaProgress;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results'**
  String get noResults;

  /// No description provided for @greatWorkKulay.
  ///
  /// In en, this message translates to:
  /// **'Finished! Great Work! 🌟'**
  String get greatWorkKulay;

  /// No description provided for @imageNotFound.
  ///
  /// In en, this message translates to:
  /// **'Image not found'**
  String get imageNotFound;

  /// No description provided for @clearCanvasQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear Canvas?'**
  String get clearCanvasQuestion;

  /// No description provided for @eraseColoringWarning.
  ///
  /// In en, this message translates to:
  /// **'This will erase all your coloring.'**
  String get eraseColoringWarning;

  /// No description provided for @noArtworksYet.
  ///
  /// In en, this message translates to:
  /// **'No artworks yet.'**
  String get noArtworksYet;

  /// No description provided for @colorPagePrompt.
  ///
  /// In en, this message translates to:
  /// **'Color a page\nand save your artwork!'**
  String get colorPagePrompt;

  /// No description provided for @startColoring.
  ///
  /// In en, this message translates to:
  /// **'Start Coloring'**
  String get startColoring;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @lessonFinishedPrompt.
  ///
  /// In en, this message translates to:
  /// **'You finished this lesson! Great job! Choose another game.'**
  String get lessonFinishedPrompt;

  /// No description provided for @okButton.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get okButton;

  /// No description provided for @storyFinishedGreatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job! You finished the story!'**
  String get storyFinishedGreatJob;

  /// No description provided for @finishedExclamation.
  ///
  /// In en, this message translates to:
  /// **'Finished!'**
  String get finishedExclamation;

  /// No description provided for @readingFinishedGood.
  ///
  /// In en, this message translates to:
  /// **'✓ Finished! Good reading!'**
  String get readingFinishedGood;

  /// No description provided for @readingFinishedHappy.
  ///
  /// In en, this message translates to:
  /// **'✓ Finished! Happy reading!'**
  String get readingFinishedHappy;

  /// No description provided for @poemFinishedGreatJob.
  ///
  /// In en, this message translates to:
  /// **'Great job! You finished the poem!'**
  String get poemFinishedGreatJob;

  /// No description provided for @doneAlready.
  ///
  /// In en, this message translates to:
  /// **'Done already!'**
  String get doneAlready;

  /// No description provided for @checkAnswer.
  ///
  /// In en, this message translates to:
  /// **'Check'**
  String get checkAnswer;

  /// No description provided for @noGamesAvailable2.
  ///
  /// In en, this message translates to:
  /// **'No games available'**
  String get noGamesAvailable2;

  /// No description provided for @countAndDragCorrectNumber.
  ///
  /// In en, this message translates to:
  /// **'Count and drag the correct number!'**
  String get countAndDragCorrectNumber;

  /// No description provided for @theyAreSame.
  ///
  /// In en, this message translates to:
  /// **'They are the same! ✓'**
  String get theyAreSame;

  /// No description provided for @whatIsMissingNumber.
  ///
  /// In en, this message translates to:
  /// **'What is the missing number?'**
  String get whatIsMissingNumber;

  /// No description provided for @badgesWithIcon.
  ///
  /// In en, this message translates to:
  /// **'🏅 Badges'**
  String get badgesWithIcon;

  /// No description provided for @straightOrCorrect.
  ///
  /// In en, this message translates to:
  /// **'Correct!'**
  String get straightOrCorrect;

  /// No description provided for @iKnowIt.
  ///
  /// In en, this message translates to:
  /// **'I learned it!'**
  String get iKnowIt;

  /// No description provided for @familyTreeTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Tree'**
  String get familyTreeTitle;

  /// No description provided for @iLearnedFamilyTree.
  ///
  /// In en, this message translates to:
  /// **'I learned the Family Tree!'**
  String get iLearnedFamilyTree;

  /// No description provided for @ourHomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Our Home'**
  String get ourHomeTitle;

  /// No description provided for @tapEachRoomPrompt.
  ///
  /// In en, this message translates to:
  /// **'Tap each room to know what you do here!'**
  String get tapEachRoomPrompt;

  /// No description provided for @thatIsOurHome.
  ///
  /// In en, this message translates to:
  /// **'That is our home!'**
  String get thatIsOurHome;

  /// No description provided for @startOnLine.
  ///
  /// In en, this message translates to:
  /// **'Start on the line!'**
  String get startOnLine;

  /// No description provided for @stayInsideLine.
  ///
  /// In en, this message translates to:
  /// **'Stay inside the line!'**
  String get stayInsideLine;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalidInput;

  /// No description provided for @tooShort.
  ///
  /// In en, this message translates to:
  /// **'Answer too short'**
  String get tooShort;

  /// No description provided for @selectAnswer.
  ///
  /// In en, this message translates to:
  /// **'Please select an answer'**
  String get selectAnswer;

  /// No description provided for @badgeKnowMyself.
  ///
  /// In en, this message translates to:
  /// **'Know Myself'**
  String get badgeKnowMyself;

  /// No description provided for @badgeEmotionExpert.
  ///
  /// In en, this message translates to:
  /// **'Emotion Expert'**
  String get badgeEmotionExpert;

  /// No description provided for @badgeRoutineExpert.
  ///
  /// In en, this message translates to:
  /// **'Routine Expert'**
  String get badgeRoutineExpert;

  /// No description provided for @badgePreferenceExpert.
  ///
  /// In en, this message translates to:
  /// **'Preference Expert'**
  String get badgePreferenceExpert;

  /// No description provided for @badgeMemberExpert.
  ///
  /// In en, this message translates to:
  /// **'Member Expert'**
  String get badgeMemberExpert;

  /// No description provided for @badgeWorkExpert.
  ///
  /// In en, this message translates to:
  /// **'Work Expert'**
  String get badgeWorkExpert;

  /// No description provided for @badgeActivityExpert.
  ///
  /// In en, this message translates to:
  /// **'Activity Expert'**
  String get badgeActivityExpert;

  /// No description provided for @badgeTreeExpert.
  ///
  /// In en, this message translates to:
  /// **'Tree Expert'**
  String get badgeTreeExpert;

  /// No description provided for @badgeHouseExpert.
  ///
  /// In en, this message translates to:
  /// **'House Expert'**
  String get badgeHouseExpert;

  /// No description provided for @forParentsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is your child\'s progress on E-Tarabay.'**
  String get forParentsSubtitle;

  /// No description provided for @artworks.
  ///
  /// In en, this message translates to:
  /// **'artworks'**
  String get artworks;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @recentColor.
  ///
  /// In en, this message translates to:
  /// **'Recent Color'**
  String get recentColor;

  /// No description provided for @unknownStudent.
  ///
  /// In en, this message translates to:
  /// **'Unknown Student'**
  String get unknownStudent;

  /// No description provided for @achievementFirstSteps.
  ///
  /// In en, this message translates to:
  /// **'First Steps'**
  String get achievementFirstSteps;

  /// No description provided for @achievementAlphabetMaster.
  ///
  /// In en, this message translates to:
  /// **'Alphabet Master'**
  String get achievementAlphabetMaster;

  /// No description provided for @achievementNumberWizard.
  ///
  /// In en, this message translates to:
  /// **'Number Wizard'**
  String get achievementNumberWizard;

  /// No description provided for @achievementColorArtist.
  ///
  /// In en, this message translates to:
  /// **'Color Artist'**
  String get achievementColorArtist;

  /// No description provided for @achievementShapeCreator.
  ///
  /// In en, this message translates to:
  /// **'Shape Creator'**
  String get achievementShapeCreator;

  /// No description provided for @achievementAnimalFriend.
  ///
  /// In en, this message translates to:
  /// **'Animal Friend'**
  String get achievementAnimalFriend;

  /// No description provided for @achievementBookworm.
  ///
  /// In en, this message translates to:
  /// **'Bookworm'**
  String get achievementBookworm;

  /// No description provided for @achievementMathWhiz.
  ///
  /// In en, this message translates to:
  /// **'Math Whiz'**
  String get achievementMathWhiz;

  /// No description provided for @achievementFamilyHero.
  ///
  /// In en, this message translates to:
  /// **'Family Hero'**
  String get achievementFamilyHero;

  /// No description provided for @achievementWritingStar.
  ///
  /// In en, this message translates to:
  /// **'Writing Star'**
  String get achievementWritingStar;

  /// No description provided for @achievementSongbird.
  ///
  /// In en, this message translates to:
  /// **'Songbird'**
  String get achievementSongbird;

  /// No description provided for @achievementStarStudent.
  ///
  /// In en, this message translates to:
  /// **'Star Student'**
  String get achievementStarStudent;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @backgroundMusicPlaying.
  ///
  /// In en, this message translates to:
  /// **'Background music playing'**
  String get backgroundMusicPlaying;

  /// No description provided for @myArtworkDefault.
  ///
  /// In en, this message translates to:
  /// **'My Art'**
  String get myArtworkDefault;

  /// No description provided for @errorSaveLocal.
  ///
  /// In en, this message translates to:
  /// **'Could not save artwork locally.'**
  String get errorSaveLocal;

  /// No description provided for @finishedAlready.
  ///
  /// In en, this message translates to:
  /// **'Finished already!'**
  String get finishedAlready;

  /// No description provided for @zoomMode.
  ///
  /// In en, this message translates to:
  /// **'Zoom mode: Multi-touch allowed'**
  String get zoomMode;

  /// No description provided for @brushMode.
  ///
  /// In en, this message translates to:
  /// **'Brush mode: Click to color'**
  String get brushMode;

  /// No description provided for @accessExpired.
  ///
  /// In en, this message translates to:
  /// **'Your access to this app has ended. Please consult your Teacher for the next steps.'**
  String get accessExpired;

  /// No description provided for @colorsLabel.
  ///
  /// In en, this message translates to:
  /// **'colors'**
  String get colorsLabel;

  /// No description provided for @overviewTab.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewTab;

  /// No description provided for @sundanMoTab.
  ///
  /// In en, this message translates to:
  /// **'Sundan Mo'**
  String get sundanMoTab;

  /// No description provided for @magbasaTab.
  ///
  /// In en, this message translates to:
  /// **'Magbasa'**
  String get magbasaTab;

  /// No description provided for @matematikaTab.
  ///
  /// In en, this message translates to:
  /// **'Matematika'**
  String get matematikaTab;

  /// No description provided for @artworksLabel.
  ///
  /// In en, this message translates to:
  /// **'Mga Obra'**
  String get artworksLabel;

  /// No description provided for @attemptsLabel.
  ///
  /// In en, this message translates to:
  /// **'Mga Subukan'**
  String get attemptsLabel;

  /// No description provided for @pagesLabel.
  ///
  /// In en, this message translates to:
  /// **'pages'**
  String get pagesLabel;

  /// No description provided for @lettersLabel.
  ///
  /// In en, this message translates to:
  /// **'letters'**
  String get lettersLabel;

  /// No description provided for @activitiesLabel.
  ///
  /// In en, this message translates to:
  /// **'activities'**
  String get activitiesLabel;

  /// No description provided for @gamesLabel.
  ///
  /// In en, this message translates to:
  /// **'games'**
  String get gamesLabel;

  /// No description provided for @savedCountLabel.
  ///
  /// In en, this message translates to:
  /// **'saved'**
  String get savedCountLabel;

  /// No description provided for @attemptsCountLabel.
  ///
  /// In en, this message translates to:
  /// **'attempts'**
  String get attemptsCountLabel;

  /// No description provided for @uppercaseLettersTitle.
  ///
  /// In en, this message translates to:
  /// **'Uppercase Letters (A–Z)'**
  String get uppercaseLettersTitle;

  /// No description provided for @lowercaseLettersTitle.
  ///
  /// In en, this message translates to:
  /// **'Lowercase Letters (a–z)'**
  String get lowercaseLettersTitle;

  /// No description provided for @numbersTitle.
  ///
  /// In en, this message translates to:
  /// **'Numbers (1–10)'**
  String get numbersTitle;

  /// No description provided for @levelComplete.
  ///
  /// In en, this message translates to:
  /// **'Level {level} Complete!'**
  String levelComplete(int level);

  /// No description provided for @achievementFirstStepsDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first activity'**
  String get achievementFirstStepsDesc;

  /// No description provided for @achievementAlphabetMasterDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all Magbasa Tayo activities'**
  String get achievementAlphabetMasterDesc;

  /// No description provided for @achievementNumberWizardDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 20 Matematika games'**
  String get achievementNumberWizardDesc;

  /// No description provided for @achievementColorArtistDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all Kulay-Saya activities'**
  String get achievementColorArtistDesc;

  /// No description provided for @achievementShapeCreatorDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all uppercase letters'**
  String get achievementShapeCreatorDesc;

  /// No description provided for @achievementAnimalFriendDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all lowercase letters'**
  String get achievementAnimalFriendDesc;

  /// No description provided for @achievementBookwormDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all stories'**
  String get achievementBookwormDesc;

  /// No description provided for @achievementMathWhizDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all Matematika levels'**
  String get achievementMathWhizDesc;

  /// No description provided for @achievementFamilyHeroDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all Ang Aking Sarili levels'**
  String get achievementFamilyHeroDesc;

  /// No description provided for @achievementWritingStarDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete all numbers'**
  String get achievementWritingStarDesc;

  /// No description provided for @achievementSongbirdDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 10 songs'**
  String get achievementSongbirdDesc;

  /// No description provided for @pagePuppy.
  ///
  /// In en, this message translates to:
  /// **'Puppy'**
  String get pagePuppy;

  /// No description provided for @pageKuting.
  ///
  /// In en, this message translates to:
  /// **'Kuting'**
  String get pageKuting;

  /// No description provided for @pageElepante.
  ///
  /// In en, this message translates to:
  /// **'Elepante'**
  String get pageElepante;

  /// No description provided for @pageFlowerBasket.
  ///
  /// In en, this message translates to:
  /// **'Flower Basket'**
  String get pageFlowerBasket;

  /// No description provided for @pageRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get pageRose;

  /// No description provided for @pageMansanas.
  ///
  /// In en, this message translates to:
  /// **'Mansanas'**
  String get pageMansanas;

  /// No description provided for @pageSaging.
  ///
  /// In en, this message translates to:
  /// **'Saging'**
  String get pageSaging;

  /// No description provided for @pageTeddyBear.
  ///
  /// In en, this message translates to:
  /// **'Teddy Bear'**
  String get pageTeddyBear;

  /// No description provided for @pageSodaPop.
  ///
  /// In en, this message translates to:
  /// **'Soda Pop'**
  String get pageSodaPop;

  /// No description provided for @achievementStarStudentDesc.
  ///
  /// In en, this message translates to:
  /// **'Complete 20 Ang Aking Sarili games'**
  String get achievementStarStudentDesc;

  /// No description provided for @badgeKnowMyselfDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed \'Myself\''**
  String get badgeKnowMyselfDesc;

  /// No description provided for @badgeEmotionExpertDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed \'My Emotions\''**
  String get badgeEmotionExpertDesc;

  /// No description provided for @badgeRoutineExpertDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed \'Daily Routines\''**
  String get badgeRoutineExpertDesc;

  /// No description provided for @badgePreferenceExpertDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed \'My Preferences\''**
  String get badgePreferenceExpertDesc;

  /// No description provided for @badgeMemberExpertDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed \'Family Members\''**
  String get badgeMemberExpertDesc;

  /// No description provided for @badgeWorkExpertDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed \'Family Work\''**
  String get badgeWorkExpertDesc;

  /// No description provided for @badgeActivityExpertDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed \'Family Activities\''**
  String get badgeActivityExpertDesc;

  /// No description provided for @badgeTreeExpertDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed \'Family Tree\''**
  String get badgeTreeExpertDesc;

  /// No description provided for @badgeHouseExpertDesc.
  ///
  /// In en, this message translates to:
  /// **'Completed \'Our Home\''**
  String get badgeHouseExpertDesc;

  /// No description provided for @familyRoleSentence.
  ///
  /// In en, this message translates to:
  /// **'{member} is {roles}.'**
  String familyRoleSentence(String member, String roles);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fil', 'ilo'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fil':
      return AppLocalizationsFil();
    case 'ilo':
      return AppLocalizationsIlo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
