class Tablas{

    Map<String,dynamic> tablas = new Map();

    Tablas(){

      tablas['projects'] = '''
      CREATE TABLE `projects` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `name` varchar(255) DEFAULT NULL,
        `description` text DEFAULT NULL,
        `content` text DEFAULT NULL,
        `content2` text DEFAULT NULL,
        `image` varchar(255) DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';

      tablas['phases'] = '''
      CREATE TABLE `phases` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `slug` varchar(255) DEFAULT NULL,
        `name` varchar(255) DEFAULT NULL,
        `image` varchar(255) DEFAULT NULL,
        `description` text DEFAULT NULL,
        `order` int DEFAULT NULL,
        `status` int DEFAULT NULL,
        `project` int DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';

      tablas['consultations'] = '''
      CREATE TABLE `consultations` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `slug` varchar(255) DEFAULT NULL,
        `name` varchar(255) DEFAULT NULL,
        `icon` varchar(255) DEFAULT NULL,
        `order` int DEFAULT NULL,
        `status` text DEFAULT NULL,
        `finish_date` DATETIME DEFAULT NULL,
        `start_date` DATETIME DEFAULT NULL,
        `phase_id` int DEFAULT NULL,
        `description` text DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';

      tablas['surveys'] = '''
      CREATE TABLE `surveys` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `name` varchar(255) DEFAULT NULL,
        `questions` text DEFAULT NULL,
        `consultation_id` int DEFAULT NULL,
        `json` text DEFAULT NULL,
        `finish` int DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';

      tablas['questions'] = '''
      CREATE TABLE `questions` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `content` varchar(255) DEFAULT NULL,
        `indicator` text DEFAULT NULL,
        `options` text DEFAULT NULL,
        `type` varchar(255) DEFAULT NULL,
        `spatial_data` text DEFAULT NULL,
        `mapName` varchar(255) DEFAULT NULL,
        `mapFile` varchar(255) DEFAULT NULL,
        `mapUrl` text DEFAULT NULL,
        
        UNIQUE (`id`)
      );
      ''';

      tablas['questionsSurvey'] = '''
      CREATE TABLE `questionsSurvey` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `survey_id` int DEFAULT NULL,
        `question_id` int DEFAULT NULL,
        `order` int DEFAULT NULL,
        UNIQUE (`id`),
        UNIQUE (`survey_id`,`question_id`)
      );
      ''';

      tablas['options'] = '''
      CREATE TABLE `options` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `option` text DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';

      tablas['answers'] = '''
      CREATE TABLE `answers` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `idServer` int DEFAULT NULL,
        `survey_id` int DEFAULT NULL,
        `question_id` int DEFAULT NULL,
        `value` text DEFAULT NULL,
        `new` int DEFAULT NULL,
        `edit` int DEFAULT NULL,
        UNIQUE (`id`),
        UNIQUE (`survey_id`,`question_id`)
      );
      ''';

      tablas['responses'] = '''
      CREATE TABLE `responses` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `idServer` int DEFAULT NULL,
        `survey_id` int DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';

      tablas['polls'] = '''
      CREATE TABLE `polls` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `name` varchar(255) DEFAULT NULL,
        `consultation_id` int DEFAULT NULL,
        `questions` text DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';

      tablas['pollsQuestions'] = '''
      CREATE TABLE `pollsQuestions` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `content` text DEFAULT NULL,
        `type` varchar(255) DEFAULT NULL,
        `poll_id` int DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';



      tablas['pollsAnswers'] = '''
      CREATE TABLE `pollsAnswers` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `poll_id` varchar(255) DEFAULT NULL,
        `question_id` int DEFAULT NULL,
        `value` text DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';
      
//      DE ACÁ PARA ABAJO ES LO QUE TENÍAMOS CON CM

      tablas['categories'] = '''
      CREATE TABLE `categories` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `name` varchar(255) DEFAULT NULL,
        `description` text DEFAULT NULL,
        `group` int(11) DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';

//      tablas['consultations'] = '''
//      CREATE TABLE `consultations` (
//        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
//        `name` text DEFAULT NULL,
//        `code` varchar(255) DEFAULT NULL,
//        `json` text DEFAULT NULL,
//        `status` int(11) DEFAULT NULL,
//        `finish_date` DATETIME,
//        `edit_inputs` int(11) DEFAULT NULL,
//        UNIQUE (`id`)
//      );
//      ''';

      tablas['categoriesSurvey'] = '''
      CREATE TABLE `categoriesSurvey` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `survey_id` int(11) DEFAULT NULL,
        `category_id` int(11) DEFAULT NULL,
        `owner` int(11) DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';

      tablas['groups'] = '''
      CREATE TABLE `groups` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `name` varchar(255) DEFAULT NULL,
        `description` text DEFAULT NULL,
        `color` varchar(9) DEFAULT NULL,
        UNIQUE (`id`)
      );
      ''';

      tablas['problems'] = '''
      CREATE TABLE `problems` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `idServer` int(11) DEFAULT NULL,
        `type` varchar(255) DEFAULT NULL,
        `name` varchar(255) DEFAULT NULL,
        `input` text DEFAULT NULL,
        `catId` int(11) DEFAULT NULL,
        `consultationsId` int(11) DEFAULT NULL,
        `answers_id` int(11) DEFAULT NULL,
        `photo` varchar(255) DEFAULT NULL,
        `send` int(11) DEFAULT NULL,
        `edit` int(11) DEFAULT NULL,
        `del` int(11) DEFAULT NULL,
        `draft` int(11) DEFAULT NULL
      );
      ''';

      tablas['points'] = '''
      CREATE TABLE `points` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `problemsId` int(11) DEFAULT NULL,
        `lat` double DEFAULT NULL,
        `lng` double DEFAULT NULL
      );
      ''';
    }

    Map getTablas(){
        return tablas;
    }

}