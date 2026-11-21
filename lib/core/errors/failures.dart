/// Hiérarchie scellée d'échecs métier (Clean Architecture Domain)
sealed class Failure {
  final String message;
  final String? technicalDetails;

  const Failure(this.message, [this.technicalDetails]);

  @override
  String toString() => '$runtimeType: $message';
}

/// Échec lié au moteur de synthèse vocale ou de retours haptiques
final class TtsFailure extends Failure {
  const TtsFailure(super.message, [super.technicalDetails]);
}

/// Échec lié à la numérisation ou à l'OCR de document
final class OcrFailure extends Failure {
  const OcrFailure(super.message, [super.technicalDetails]);
}

/// Échec lié au traitement linguistique ou au découpage phonétique
final class TextProcessingFailure extends Failure {
  const TextProcessingFailure(super.message, [super.technicalDetails]);
}

/// Échec lié à la persistance locale ou aux préférences
final class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.technicalDetails]);
}

/// Pattern Result fonctionnel, immuable et exhaustif pour Dart 3
sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  T? get dataOrNull => switch (this) {
        Success(data: final d) => d,
        FailureResult() => null,
      };

  Failure? get failureOrNull => switch (this) {
        Success() => null,
        FailureResult(failure: final f) => f,
      };

  /// Traitement fonctionnel exhaustif (fold)
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) =>
      switch (this) {
        Success(data: final d) => onSuccess(d),
        FailureResult(failure: final f) => onFailure(f),
      };

  /// Mappage d'un succès vers une autre valeur
  Result<R> map<R>(R Function(T data) transform) => switch (this) {
        Success(data: final d) => Success(transform(d)),
        FailureResult(failure: final f) => FailureResult(f),
      };
}

/// Représente une opération réussie
final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);

  @override
  String toString() => 'Success($data)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Success<T> && other.data == data);

  @override
  int get hashCode => data.hashCode;
}

/// Représente une opération en échec avec son objet Failure associé
final class FailureResult<T> extends Result<T> {
  final Failure failure;
  const FailureResult(this.failure);

  @override
  String toString() => 'FailureResult($failure)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FailureResult<T> && other.failure == failure);

  @override
  int get hashCode => failure.hashCode;
}
