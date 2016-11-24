//
//  NamedBezierPathsView.swift
//  DropIt
//
//  Created by Simen Gangstad on 18.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class NamedBezierPathsView: UIView {

    var bezierPaths = [String:UIBezierPath]() { didSet { setNeedsDisplay() } }

    override func draw(_ rect: CGRect) {
        for (_, path) in bezierPaths {
            path.stroke()
        }
    }
}
