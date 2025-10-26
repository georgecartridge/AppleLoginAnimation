//
//  ApproximatelyEqual.swift
//  AppleLoginAnimation
//
//  Created by George on 14/10/2025.
//

import CoreGraphics

extension CGPoint {
    func isApproximatelyEqual(to other: CGPoint, tolerance delta: CGFloat = 0.01) -> Bool {
        return abs(self.x - other.x) < delta &&
               abs(self.y - other.y) < delta
    }
}
