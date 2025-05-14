//
// Copyright (c) 2018 Muukii <muukii.app@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import CoreImage
import UIKit

enum RadiusCalculator {

  static func radius(value: Double, max: Double, imageExtent: CGRect) -> Double {

    let base = Double(sqrt(pow(imageExtent.width, 2) + pow(imageExtent.height, 2)))
    let c = base / 20
    return c * value / max
  }
}

public protocol Filtering: Hashable {
  /// Asynchronously apply the filter to the image.
  func apply(to image: CIImage, sourceImage: CIImage) async -> CIImage
}

extension Filtering {
  public func asAny() -> AnyFilter {
    .init(filter: self)
  }
}

public struct AnyFilter: Filtering {
  public static func == (lhs: AnyFilter, rhs: AnyFilter) -> Bool {
    lhs.base == rhs.base
  }

  public func hash(into hasher: inout Hasher) {
    base.hash(into: &hasher)
  }

  // Store async function pointer for apply
  private let applier: (CIImage, CIImage) async -> CIImage
  public let base: AnyHashable

  public init<Filter: Filtering>(filter: Filter) {
    self.base = filter
    self.applier = { image, sourceImage in
      await filter.apply(to: image, sourceImage: sourceImage)
    }
  }

  public func apply(to image: CIImage, sourceImage: CIImage) async -> CIImage {
    await applier(image, sourceImage)
  }
}
