import 'package:flutter/material.dart';

String t(BuildContext context, String key) {
  final localizations = AppLocalizations.of(context);
  
  switch (key) {
    // Common
    case 'cancel':
      return localizations.cancel;
    case 'ok':
      return localizations.ok;
    case 'yes':
      return localizations.yes;
    case 'no':
      return localizations.no;
    case 'close':
      return localizations.close;
    case 'next':
      return localizations.next;
    case 'previous':
      return localizations.previous;
    case 'done':
      return localizations.done;
    case 'search':
      return localizations.search;
    case 'send':
      return localizations.send;
    case 'save':
      return localizations.save;
    case 'delete':
      return localizations.delete;
    case 'edit':
      return localizations.edit;
    case 'listen':
      return 'Listen'; // Add this to your ARB files if needed
    
    // Onboarding
    case 'whatIsNameGender':
      return localizations.whatIsNameGender;
    case 'gender':
      return localizations.gender;
    case 'male':
      return localizations.male;
    case 'female':
      return localizations.female;
    case 'kidsName':
      return localizations.kidsName;
    case 'enterName':
      return localizations.enterName;
    
    // Home
    case 'goodMorning':
      return localizations.goodMorning;
    case 'stars':
      return localizations.stars;
    case 'lessons':
      return localizations.lessons;
    case 'stories':
      return localizations.stories;
    case 'songs':
      return localizations.songs;
    case 'games':
      return localizations.games;
    case 'achievements':
      return localizations.achievements;
    case 'forParents':
      return localizations.forParents;
    
    // Categories
    case 'alphabet':
      return localizations.alphabet;
    case 'numbers':
      return localizations.numbers;
    case 'colors':
      return localizations.colors;
    case 'shapes':
      return localizations.shapes;
    case 'animals':
      return localizations.animals;
    case 'myBody':
      return localizations.myBody;
    case 'myFamily':
      return localizations.myFamily;
    case 'math':
      return localizations.math;
    case 'reading':
      return localizations.reading;
    case 'bigAndSmall':
      return localizations.bigAndSmall;
    
    // Parents
    case 'yearsOld':
      return localizations.yearsOld;
    case 'progressReports':
      return localizations.progressReports;
    case 'recentAchievements':
      return localizations.recentAchievements;
    case 'firstSteps':
      return localizations.firstSteps;
    case 'bookworm':
      return localizations.bookworm;
    case 'starStudent':
      return localizations.starStudent;
    case 'fastLearner':
      return localizations.fastLearner;
    case 'tipsForParents':
      return localizations.tipsForParents;
    case 'dailyPractice':
      return localizations.dailyPractice;
    case 'dailyPracticeDesc':
      return localizations.dailyPracticeDesc;
    case 'praiseEffort':
      return localizations.praiseEffort;
    case 'praiseEffortDesc':
      return localizations.praiseEffortDesc;
    case 'talkAndLearn':
      return localizations.talkAndLearn;
    case 'talkAndLearnDesc':
      return localizations.talkAndLearnDesc;
    case 'makeItFun':
      return localizations.makeItFun;
    case 'makeItFunDesc':
      return localizations.makeItFunDesc;
    case 'messageToTeacher':
      return localizations.messageToTeacher;
    case 'sendMessage':
      return localizations.sendMessage;
    case 'typeMessage':
      return localizations.typeMessage;
    case 'messageSent':
      return localizations.messageSent;
    
    // Default fallback
    default:
      return key;
  }
}

class AppLocalizations {
  static of(BuildContext context) {}
}