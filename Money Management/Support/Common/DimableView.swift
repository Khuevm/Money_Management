//
//  DimableView.swift
//  Money Management
//
//  Created by Khue on 27/05/2023.
//

import Foundation
import UIKit

class DimableView: UIControl {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.animate(alpha: 0.6)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.animate(alpha: 1)
        
        let location = touches.first!.location(in: self)
        if self.bounds.contains(location) {
            self.sendActions(for: .touchUpInside)
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.animate(alpha: 1)
    }

    private func animate(alpha: CGFloat) {
        UIView.animate(withDuration: 0.3) {
            self.alpha = alpha
        }
    }
}
