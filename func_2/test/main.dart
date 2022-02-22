import 'package:fpdart/fpdart.dart';

void main() async {
  //! Monads Implementation
  final i = some(4);
  bool isEven(int x) => (x % 2 == 0) ? true : false;
  int isEvenVal(int x) => (x % 2 == 0) ? x : -1;
  Option<int> halfs(int a) => isEven(a) ? some(a ~/ 2) : none();

  final s = some('smile');
  Option<String> addToSmile(String a) => some(a + ':)');
  print(s.flatMap(addToSmile));
  List<int> doubler(int x) => isEven(x) ? [2 * x] : [];
  final t = <int>[1, 2, 3];
  final emptyOp = none();
  print(emptyOp.pure(5).flatMap(halfs).flatMap(halfs));
  print(t.map(isEvenVal).flatMap(doubler));

  //! Functors Implementation
  int addOneFunctor(int i) => i + 1;
  final o = some(6);
  print(o.map(addOneFunctor));

  //! Applicatives implementation
  final addOneApplicative = i.map((t) => (t) => t + 1);
  print(o.ap(addOneApplicative));

  //! Functionaly handeling data from outside service
  final data = (await _fetchDataFromService().run()).match(id, id);
  print(data);
}

class OutsideHttpService {
  Future<List<Map<String, dynamic>>> getAllusers() => Future.delayed(
      Duration(seconds: 2),
      () =>
          // [
          //       {'name': 'klue', 'age': 21},
          //       {'name': 'flames', 'age': 21},
          //     ]
          throw Exception('Could not fetch users'));
}

class User {
  final String name;
  final int age;
  User(this.name, this.age);

  factory User.fromJson(Map<String, dynamic> json) =>
      User(json['name'], json['age']);

  @override
  String toString() {
    return 'User(name: $name, age: $age)';
  }
}

class Failure {
  final String message;
  Failure(this.message);

  @override
  String toString() {
    return 'Failure($message)';
  }
}

TaskEither<Failure, List<User>> _fetchDataFromService() => TaskEither.tryCatch(
      () async {
        final _service = OutsideHttpService();
        final _res = await _service.getAllusers();
        return _res.map((m) => User.fromJson(m)).toList();
      },
      (error, __) => Failure(
        error.toString(),
      ),
    );
