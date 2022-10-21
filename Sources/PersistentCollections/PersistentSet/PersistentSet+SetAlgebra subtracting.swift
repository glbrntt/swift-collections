//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift Collections open source project
//
// Copyright (c) 2022 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
//
//===----------------------------------------------------------------------===//

extension PersistentSet {
  /// Returns a new set containing the elements of this set that do not occur
  /// in the given other set.
  ///
  ///     var a: PersistentSet = [1, 2, 3, 4]
  ///     let b: PersistentSet = [0, 2, 4, 6]
  ///     let c = a.subtracting(b)
  ///     // `c` is some permutation of `[1, 3]`
  ///
  /// - Parameter other: An arbitrary set of elements.
  ///
  /// - Complexity: Expected complexity is O(`self.count` + `other.count`) in
  ///     the worst case, if `Element` properly implements hashing.
  ///     However, the implementation is careful to make the best use of
  ///     hash tree structure to minimize work when possible, e.g. by linking
  ///     parts of the input trees directly into the result.
  @inlinable
  public __consuming func subtracting(_ other: Self) -> Self {
    _subtracting(other._root)
  }

  /// Returns a new set containing the elements of this set that do not occur
  /// in the given keys view of a persistent dictionary.
  ///
  ///     var a: PersistentSet = [1, 2, 3, 4]
  ///     let b: PersistentDictionary = [0: "a", 2: "b", 4: "c", 6: "d"]
  ///     let c = a.subtracting(b.keys)
  ///     // `c` is some permutation of `[1, 3]`
  ///
  /// - Parameter other: The keys view of a persistent dictionary.
  ///
  /// - Complexity: Expected complexity is O(`self.count` + `other.count`) in
  ///     the worst case, if `Element` properly implements hashing.
  ///     However, the implementation is careful to make the best use of
  ///     hash tree structure to minimize work when possible, e.g. by linking
  ///     parts of the input trees directly into the result.
  @inlinable
  public __consuming func subtracting<V>(
    _ other: PersistentDictionary<Element, V>.Keys
  ) -> Self {
    _subtracting(other._base._root)
  }

  @inlinable
  internal __consuming func _subtracting<V>(
    _ other: PersistentCollections._Node<Element, V>
  ) -> Self {
    let builder = _root.subtracting(.top, other)
    guard let builder = builder else { return self }
    let root = builder.finalize(.top)
    root._fullInvariantCheck()
    return Self(_new: root)
  }

  /// Returns a new set containing the elements of this set that do not occur
  /// in the given sequence.
  ///
  ///     var a: PersistentSet = [1, 2, 3, 4]
  ///     let b = [0, 2, 4, 6]
  ///     let c = a.subtracting(b)
  ///     // `c` is some permutation of `[1, 3]`
  ///
  /// - Parameter other: An arbitrary finite sequence.
  ///
  /// - Complexity: O(*n*) where *n* is the number of elements in `other`,
  ///    as long as `Element` properly implements hashing.
  @inlinable
  public __consuming func subtracting<S: Sequence>(
    _ other: S
  ) -> Self
  where S.Element == Element {
    if S.self == Self.self {
      return subtracting(other as! Self)
    }

    guard let first = self.first else { return Self() }
    if other._customContainsEquatableElement(first) != nil {
      // Fast path: the sequence has fast containment checks.
      return self.filter { !other.contains($0) }
    }

    var root = self._root
    for item in other {
      let hash = _Hash(item)
      _ = root.remove(.top, item, hash)
    }
    return Self(_new: root)
  }
}
