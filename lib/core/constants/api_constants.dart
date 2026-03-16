class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
}
/* =========================== */
/*            EMAIL            */
/* =========================== */
class EmailEndpoints {
  static const String send = "${ApiConstants.baseUrl}/send-email";
}

/* =============================== */
/*            STATISTICS           */
/* =============================== */
class StatsEndpoint {
  static const String statistiques = "${ApiConstants.baseUrl}/stats";
}

/* =========================== */
/*            AUTH             */
/* =========================== */

class AuthEndpoints {
  static const String login = "${ApiConstants.baseUrl}/login";
  static const String logout = "${ApiConstants.baseUrl}/logout";
  static const String register = "${ApiConstants.baseUrl}/register";
}

/* =============================== */
/*           OPTIMIZATION          */
/* =============================== */
class OptimisationEndpoints {
  static const String base = "${ApiConstants.baseUrl}/optimiser";
}


/* =========================== */
/*           BENNES            */
/* =========================== */

class BenneEndpoints {
  static const String base = "${ApiConstants.baseUrl}/bennes";
  static const String search = "${ApiConstants.baseUrl}/bennes/search";
  static const String withSensors = "${ApiConstants.baseUrl}/bennes/with-sensors";

  static String detail(int id) => "${ApiConstants.baseUrl}/bennes/$id";
  static String vider(int id) => "${ApiConstants.baseUrl}/bennes/$id/vider";
}

/* =========================== */
/*           CAMIONS           */
/* =========================== */

class CamionEndpoints {
  static const String base = "${ApiConstants.baseUrl}/camions";

  static String detail(int id) => "${ApiConstants.baseUrl}/camions/$id";
}

/* =========================== */
/*           CAPTEURS          */
/* =========================== */

class CapteurEndpoints {
  static const String base = "${ApiConstants.baseUrl}/capteurs";
  static String byBenne(int id) => "${ApiConstants.baseUrl}/bennes/$id/capteurs";
  static String detail(int id) => "${ApiConstants.baseUrl}/capteurs/$id";
}

/* =========================== */
/*         CHAUFFEURS          */
/* =========================== */

class ChauffeurEndpoints {
  static const String base = "${ApiConstants.baseUrl}/chauffeurs";
  static const String myTournees = "${ApiConstants.baseUrl}/chauffeurs/me/tournees";
  static String detail(int id) => "${ApiConstants.baseUrl}/chauffeurs/$id";
}


/* =========================== */
/*            STATS            */
/* =========================== */

class StatsEndpoints {
  static const String base = "${ApiConstants.baseUrl}/stats";
}

/* =========================== */
/*           TOURNEES          */
/* =========================== */

class TourneeEndpoints {
  static const String base = "${ApiConstants.baseUrl}/tournees";
  static const String history = "${ApiConstants.baseUrl}/tournees/history";
  static const String search = "${ApiConstants.baseUrl}/tournees/search";
  static const String currentForChauffeur = "${ApiConstants.baseUrl}/tournees/chauffeur/current";
  static const String currentForChauffeurAlt1 = "${ApiConstants.baseUrl}/tournees/current/chauffeur";
  static const String currentForChauffeurAlt2 = "${ApiConstants.baseUrl}/tournees/current";

  static String detail(int id) => "${ApiConstants.baseUrl}/tournees/$id";
  static String start(int id) => "${ApiConstants.baseUrl}/tournees/$id/start";
  static String annuler(int id) => "${ApiConstants.baseUrl}/tournees/$id/annuler";
  static String terminer(int id) => "${ApiConstants.baseUrl}/tournees/$id/terminer";
}

/* =========================== */
/*            USERS            */
/* =========================== */

class UserEndpoints {
  static const String base = "${ApiConstants.baseUrl}/users";

  static String detail(int id) => "${ApiConstants.baseUrl}/users/$id";
}

/* =========================== */
/*            ZONES            */
/* =========================== */

class ZoneEndpoints {
  static const String base = "${ApiConstants.baseUrl}/zones";

  static String detail(int id) => "${ApiConstants.baseUrl}/zones/$id";
}
