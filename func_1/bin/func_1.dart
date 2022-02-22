import 'package:fpdart/fpdart.dart';

void main(List<String> arguments) {
  final e = EmailAddress('kl@om123');
  final p = Password('tes@ter23');
  final klue = UserEntity(password: p, emailAddress: e);
  print(klue.isValid());
  print(p.failureOrVal());
  print(e.failureOrVal());
  print(p.returnIfValid());
  print(e.returnIfValid());
  // Either.tryCatch(() => null, (o, s) => null);
}

class ValueFailure<T> {
  final T val;
  ValueFailure(this.val);
  @override
  String toString() => 'Failed: $val';
}

class UserEntity {
  final Password password;
  final EmailAddress emailAddress;

  UserEntity({required this.password, required this.emailAddress});

  /// Validates the state of [this] enitity
  bool isValid() => password.failureOrVal().isSome().fold(() => false,
      () => emailAddress.failureOrVal().isSome().fold(() => false, () => true));
}

/// Base class for ValueObjects
abstract class ValueObject<T> {
  late final Either<ValueFailure<T>, T> val;
  T returnIfValid() =>
      val.fold((l) => throw Exception('Invalid value of: $val'), (r) => r);

  Option<T> failureOrVal() => Option.tryCatch(returnIfValid);
}

class EmailAddress extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> val;
  factory EmailAddress(String v) {
    return EmailAddress._(validateAt(v).flatMap(validateLen));
  }

  EmailAddress._(this.val);

  @override
  String toString() => 'EmailAddress($val)';
}

class Password extends ValueObject<String> {
  @override
  final Either<ValueFailure<String>, String> val;
  factory Password(String v) {
    return Password._(validateLen(v));
  }

  Password._(this.val);

  @override
  String toString() => 'Password($val)';
}

// Validators
Either<ValueFailure<String>, String> validateAt(String e) {
  return Either.fromPredicate(e, (r) => r.contains('@'),
      (_) => ValueFailure('"Does not contain the @ symbol'));
}

Either<ValueFailure<String>, String> validateLen(String e) {
  return Either.fromPredicate(
      e, (r) => r.length > 5, (_) => ValueFailure('Length was less then 5'));
}
