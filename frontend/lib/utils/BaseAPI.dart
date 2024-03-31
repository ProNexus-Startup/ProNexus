class BaseAPI {
  static String api =
      "http://localhost:8080"; //"https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"
  Uri userPath = Uri.parse('$api/me');
  Uri loginPath = Uri.parse('$api/login');
  Uri logoutPath = Uri.parse("$api/logout");
  Uri makeOrgPath = Uri.parse("$api/makeorg");
  Uri getOrg = Uri.parse("$api/org");
  Uri signupPath = Uri.parse("$api/signup");
  Uri questionnairePath = Uri.parse("$api/user/profile");
  Uri expertsPath = Uri.parse("$api/experts");
  Uri callsPath = Uri.parse("$api/calls");
  // more routes
  Map<String, String> headers = {
    "Content-Type": "application/json; charset=UTF-8"
  };
}

// Signup takes username email and password
/*
0 - not applied
1 - applied
2 - interview
3 - offer
4 - rejection
*/