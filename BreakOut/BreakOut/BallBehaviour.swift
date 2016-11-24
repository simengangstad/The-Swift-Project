//
//  BallBehaviour.swift
//  BreakOut
//
//  Created by Simen Gangstad on 20.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class BallBehaviour: UIDynamicBehavior {

    let gravity = UIGravityBehavior()

    let itemBehavior: UIDynamicItemBehavior = {
        let dib = UIDynamicItemBehavior()
        dib.allowsRotation = false
        dib.elasticity = 1.0
        dib.resistance = 0.0
        dib.friction = 0.0
        return dib
    }()
    
    let pushBehavior: UIPushBehavior = {
        let pb = UIPushBehavior(items: [], mode: .instantaneous)
        pb.pushDirection = CGVector(dx: 0.05, dy: 0.1)
        pb.active = true
        return pb
    }()
    
    override init() {
        super.init()
        //addChildBehavior(gravity)
        addChildBehavior(itemBehavior)
        addChildBehavior(pushBehavior)
    }
    
    func add(item: UIDynamicItem) {
        //gravity.addItem(item)
        itemBehavior.addItem(item)
        pushBehavior.addItem(item)
    }
    
    
    func remove(item: UIDynamicItem) {
//        gravity.removeItem(item)
        itemBehavior.removeItem(item)
        pushBehavior.removeItem(item)
    }
}
