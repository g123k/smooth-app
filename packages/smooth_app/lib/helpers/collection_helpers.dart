extension ListExtensions<T> on List<T> {
  void addAllSafe(Iterable<T>? elements) {
    if (elements != null) {
      addAll(elements);
    }
  }
}

extension SetExtensions<T> on Set<T> {
  void addAllSafe(Iterable<T>? elements) {
    if (elements != null) {
      addAll(elements);
    }
  }
}

extension IterableExtensions<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final T element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
