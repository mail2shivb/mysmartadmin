// B12 STATUS: IMPLEMENTED

/// Base class for all ViewModels
///
/// Provides common state fields for loading and error handling.
/// ViewModels are thin adapters between domain (ReportsRepository) and UI.
/// They contain NO business logic and NO persistence logic.
abstract class ViewModelBase {
  final bool isLoading;
  final Object? error;

  const ViewModelBase({
    this.isLoading = false,
    this.error,
  });

  /// Returns true if the ViewModel has an error
  bool get hasError => error != null;

  /// Returns true if the ViewModel is not loading and has no error
  bool get isReady => !isLoading && !hasError;
}

