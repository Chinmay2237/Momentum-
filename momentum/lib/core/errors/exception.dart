
// A generic class to represent a failure in the application,
// such as a network error or a parsing error.
class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}
