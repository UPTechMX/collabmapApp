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

//      tablas['categories'] = '''
//      CREATE TABLE `categories` (
//        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
//        `name` varchar(255) DEFAULT NULL,
//        `description` text DEFAULT NULL,
//        `group` int(11) DEFAULT NULL,
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

//      tablas['problems'] = '''
//      CREATE TABLE `problems` (
//        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
//        `idServer` int(11) DEFAULT NULL,
//        `type` varchar(255) DEFAULT NULL,
//        `name` varchar(255) DEFAULT NULL,
//        `input` text DEFAULT NULL,
//        `catId` int(11) DEFAULT NULL,
//        `consultationsId` int(11) DEFAULT NULL,
//        `answers_id` int(11) DEFAULT NULL,
//        `photo` varchar(255) DEFAULT NULL,
//        `send` int(11) DEFAULT NULL,
//        `edit` int(11) DEFAULT NULL,
//        `del` int(11) DEFAULT NULL,
//        `draft` int(11) DEFAULT NULL
//      );
//      ''';


//////// SIAP ////////

      tablas['UsersTargets'] = '''
      CREATE TABLE `UsersTargets` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `usersId` int(11) DEFAULT NULL,
        `targetsId` int(11) DEFAULT NULL
      );
      ''';

      tablas['Targets'] = '''
      CREATE TABLE `Targets` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `name` varchar(45) DEFAULT NULL,
        `description` varchar(45) DEFAULT NULL,
        `projectsId` int(11) DEFAULT NULL,
        `addStructure` tinyint(4) DEFAULT NULL
      );
      ''';


      tablas['Checklist'] = '''
      CREATE TABLE `Checklist` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `nombre` varchar(200) DEFAULT NULL,
        `siglas` varchar(20) DEFAULT NULL,
        `elim` tinyint(4) DEFAULT NULL,
        `tipo` varchar(30) DEFAULT NULL,
        `marcasId` int(11) DEFAULT NULL,
        `resumen` text,
        `tipoProm` tinyint(4) DEFAULT NULL,
        `tipoAnalisis` tinyint(4) DEFAULT NULL,
        `listaFotos` text,
        `photos` tinyint(4) DEFAULT NULL,
        `est` largetext
      );
      ''';

      tablas['Studyarea'] = '''
      CREATE TABLE `Studyarea` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `preguntasId` int(11) DEFAULT NULL,
        `type` varchar(200) DEFAULT NULL,
        `geometry` largetext
      );
      ''';

      tablas['ChecklistEst'] = '''
      CREATE TABLE `ChecklistEst` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `checklistId` int(11) DEFAULT NULL,
        `estructura` largetext
      );
      ''';

      tablas['Areas'] = '''
      CREATE TABLE `Areas` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `bloquesId` int(11) DEFAULT NULL,
        `nombre` varchar(45) DEFAULT NULL,
        `orden` tinyint(4) DEFAULT NULL,
        `elim` tinyint(4) DEFAULT NULL,
        `identificador` varchar(45) DEFAULT NULL,
        `valMax` double DEFAULT NULL
      );
      ''';

      tablas['Bloques'] = '''
      CREATE TABLE `Bloques` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `checklistId` int(11) DEFAULT NULL,
        `nombre` varchar(100) DEFAULT NULL,
        `orden` tinyint(4) DEFAULT NULL,
        `elim` tinyint(4) DEFAULT NULL,
        `identificador` varchar(45) DEFAULT NULL,
        `encabezado` tinyint(4) DEFAULT NULL,
        `tipoProm` tinyint(4) DEFAULT NULL,
        `valMax` double DEFAULT NULL
      );
      ''';

      tablas['Dimensiones'] = '''
      CREATE TABLE `Dimensiones` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `nombre` varchar(200) DEFAULT NULL,
        `nivel` int(11) DEFAULT NULL,
        `elemId` int(11) DEFAULT NULL,
        `type` varchar(45) DEFAULT NULL
      );
      ''';

      tablas['DimensionesElem'] = '''
      CREATE TABLE `DimensionesElem` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `padre` int(11) DEFAULT NULL,
        `dimensionesId` int(11) DEFAULT NULL,
        `nombre` varchar(100) DEFAULT NULL,
        `offline` tinyint(4) DEFAULT NULL,
        `creadoOffline` tinyint(4) DEFAULT NULL

      );
      ''';

      tablas['TargetsElems'] = '''
      CREATE TABLE `TargetsElems` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `targetsId` int(11) DEFAULT NULL,
        `usersTargetsId` int(11) DEFAULT NULL,
        `name` varchar(50) DEFAULT NULL,
        `usersId` int(11) DEFAULT NULL,
        `dimensionesElemId` int(11) DEFAULT NULL,
        `offline` tinyint(4) DEFAULT NULL,
        `creadoOffline` tinyint(4) DEFAULT NULL

      );
      ''';

      tablas['Frequencies'] = '''
      CREATE TABLE `Frequencies` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `code` varchar(15) DEFAULT NULL,
        `orden` tinyint(4) DEFAULT NULL
      );
      ''';

      tablas['Visitas'] = '''
      CREATE TABLE `Visitas` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `serverId` int(11) DEFAULT NULL,
        `timestamp` timestamp NULL DEFAULT NULL,
        `estatus` varchar(45) DEFAULT NULL,
        `resumen` text,
        `finishDate` datetime DEFAULT NULL,
        `finalizada` tinyint(4) DEFAULT NULL,
        `checklistId` int(11) DEFAULT NULL,
        `type` varchar(5) DEFAULT NULL,
        `elemId` int(11) DEFAULT NULL,
        `offline` tinyint(4) DEFAULT NULL,
        `creadoOffline` tinyint(4) DEFAULT NULL
      );
      ''';

      tablas['Multimedia'] = '''
      CREATE TABLE `Multimedia` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `visitasId` int(11) DEFAULT NULL,
        `tipo` varchar(31) DEFAULT NULL,
        `nombre` varchar(255) DEFAULT NULL,
        `archivo` varchar(255) DEFAULT NULL,
        `descripcion` varchar(45) DEFAULT NULL
      );
      ''';


      tablas['RespuestasVisita'] = '''
      CREATE TABLE `RespuestasVisita` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `visitasId` int(11) DEFAULT NULL,
        `preguntasId` int(11) DEFAULT NULL,
        `respuesta` text,
        `justificacion` text,
        `identificador` varchar(45) DEFAULT NULL,
        `new` int DEFAULT NULL,
        UNIQUE (`visitasId`,`preguntasId`)
      );
      ''';


      tablas['Problems'] = '''
      CREATE TABLE `Problems` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `type` varchar(30) DEFAULT NULL,
        `name` varchar(100) DEFAULT NULL,
        `description` text DEFAULT NULL,
        `categoriesId` int(11) DEFAULT NULL,
        `respuestasVisitaId` int(11) DEFAULT NULL,
        `photo` varchar(100) DEFAULT NULL,
        `geometry` text DEFAULT NULL,
        `draft` int DEFAULT NULL,
        `edit` int DEFAULT NULL,
        `del` int DEFAULT NULL
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


      tablas['Categories'] = '''
      CREATE TABLE `Categories` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `preguntasId` int(11) DEFAULT NULL,
        `name` text DEFAULT NULL
      );
      ''';

      tablas['TargetsChecklist'] = '''
      CREATE TABLE `TargetsChecklist` (
        `id` INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        `checklistId` int(11) DEFAULT NULL,
        `targetsId` int(11) DEFAULT NULL,
        `frequency` int(11) DEFAULT NULL
        
      );
      ''';



    }

    Map getTablas(){
        return tablas;
    }

}