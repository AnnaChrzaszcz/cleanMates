class LogisticExpection implements Exception {
  final String message;
  LogisticExpection(this.message);

  @override
  String toString() {
    return message;
  }
}
