import 'package:incasa_app/core/error/failures.dart';

/// Sealed class para representar o resultado de operações
/// Substitui Either do Dartz usando pattern matching nativo do Dart
sealed class Result<T> {
  const Result();
}

/// Representa um resultado bem-sucedido
class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

/// Representa uma falha
class Error<T> extends Result<T> {
  final Failure failure;
  const Error(this.failure);
}
