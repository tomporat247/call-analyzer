class MyHeap<T> {
  final int Function(T a, T b) compareFunction;
  List<T> _heap;
  int _size;

  get size => _size;

  MyHeap(this.compareFunction) {
    _heap = new List<T>();
    _size = 0;
  }

  T getHead() {
    return _size == 0 ? null : _heap.first;
  }

  insert(T item) {
    int ix = _size++;

    _heap.add(item);

    int parent = (ix - 1) >> 1;

    while ((ix > 0) && compareFunction(_heap[parent], item) > 0) {
      T tmp = _heap[parent];
      _heap[parent] = _heap[ix];
      _heap[ix] = tmp;
      ix = parent;
      parent = (ix - 1) >> 1;
    }
  }

  T removeHead() {
    if (_size == 0) return null;

    T out = _heap.first;

    _bubble(0);

    return out;
  }

  bool remove(T item) {
    for (int i = 0; i < _size; ++i) {
      if (_heap[i] == item) {
        _bubble(i);
        return true;
      }
    }

    return false;
  }

  _bubble(int ix) {
    _heap[ix] = _heap[--_size];
    _heap.removeLast();

    while (true) {
      int leftIx = (ix << 1) + 1;
      int rightIx = (ix << 1) + 2;
      int minIx = ix;

      if (leftIx < this.size &&
          compareFunction(_heap[leftIx], _heap[minIx]) < 0) {
        minIx = leftIx;
      }

      if (rightIx < this.size &&
          compareFunction(_heap[rightIx], _heap[minIx]) < 0) {
        minIx = rightIx;
      }

      if (minIx != ix) {
        T tmp = _heap[ix];
        _heap[ix] = _heap[minIx];
        _heap[minIx] = tmp;
        ix = minIx;
      } else {
        break;
      }
    }
  }

  List<T> asList() {
    return List.from(_heap)..sort(compareFunction);
  }
}
