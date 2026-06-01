class SafeCounter {
  int _value = 0;

  int get value => _value;

  void increment() {
    _value++;
  }

  void decrement() {
    if (_value == 0) {
      throw StateError('Counter cannot be negative');
    }
    _value--;
  }
}
