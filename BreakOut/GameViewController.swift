
//
//  GameViewController.swift
//  BreakOut
//
//  Created by Simen Gangstad on 19.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    @IBOutlet weak var gameView: BreakOutView! {
        
        didSet {
            gameView.addGestureRecognizer(UIPanGestureRecognizer(target: gameView, action: #selector(BreakOutView.movedPaddle(recognizer:))))
            gameView.addGestureRecognizer(UITapGestureRecognizer(target: gameView, action: #selector(BreakOutView.tapped(recognizer:))))
            gameView.amountOfBalls = 1
            gameView.brickCount = Rect(rows: 5, columns: 4)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        gameView.animating = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        gameView.animating = false
    }
}
