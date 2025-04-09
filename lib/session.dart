class SessionManager {
  static String _session = "";

  static String getSession() {
    return _session;
  }

  static void setSession(String session) {
    _session = session;
  }
}
