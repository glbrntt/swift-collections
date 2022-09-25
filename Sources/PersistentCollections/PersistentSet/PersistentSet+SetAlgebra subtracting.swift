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
  @inlinable
  public __consuming func subtracting(_ other: Self) -> Self {
    let result = _root.subtracting(.top, .emptyPrefix, other._root)
    return Self(_new: result.finalize(.top))
  }
}
