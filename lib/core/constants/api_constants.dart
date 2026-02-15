class ApiConstants {
  static const String baseUrl = 'http://127.0.0.1:8000/api';
}

/* =========================== */
/*            AUTH             */
/* =========================== */

class AuthEndpoints {
  static const String login = "${ApiConstants.baseUrl}/login";
  static const String logout = "${ApiConstants.baseUrl}/logout";
  static const String register = "${ApiConstants.baseUrl}/register";
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
  static String detail(int id) => "${ApiConstants.baseUrl}/chauffeurs/$id";
}

/* ===========================
            RELEVES
=========================== */

class ReleveEndpoints {
  static const String base = "${ApiConstants.baseUrl}/releves";

  static String detail(int id) => "${ApiConstants.baseUrl}/releves/$id";
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

  static String detail(int id) => "${ApiConstants.baseUrl}/tournees/$id";
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
