//
//  UIView+Extensions.swift
//  iOS12-HW17-Alexey-Cherebayev
//
//  Created by  Alexey on 21.03.2024.
//

import UIKit

extension UIView {
    func addSubviews(_ views: [UIView]) {
        views.forEach({ self.addSubview($0) })
    }
}
