//
//  FaceViewController.swift
//  FaceIt
//
//  Created by Simen Gangstad on 26/10/2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class FaceViewController: UIViewController {
    
    @IBOutlet weak var faceView: FaceView! {
        didSet {
            
            faceView.addGestureRecognizer(UIPinchGestureRecognizer(target: faceView, action: #selector(FaceView.changeScale)))
            
            let happierSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(FaceViewController.increaseHappiness))
            happierSwipeGestureRecognizer.direction = .up
            faceView.addGestureRecognizer(happierSwipeGestureRecognizer)
            
            let sadderSwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(FaceViewController.decreaseHappiness))
            sadderSwipeGestureRecognizer.direction = .down
            faceView.addGestureRecognizer(sadderSwipeGestureRecognizer)
            
            updateUI()
        }
    }
    
    @IBAction func toggleEyes(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            switch expression.eyes {
            case .Open: expression.eyes = .Closed
            case .Closed: expression.eyes = .Open
            case .Squinting: break
            }
        }
    }
    
    var expression: FacialExpression = FacialExpression(eyes: .Open, eyeBrows: .Normal, mouth: .Smile) {
        didSet {
            updateUI()
        }
    }
    
    private let mouthCurvatures = [
    FacialExpression.Mouth.Frown: -1.0,
    .Grin: 0.5,
    .Smile: 1.0,
    .Smirk: -0.5,
    .Neutral: 0.0
    ]
    
    private let eyeBrowTilts = [
        FacialExpression.EyeBrows.Relaxed: 0.5,
        .Furrowed: -0.5,
        .Normal: 0.0
    ]
    
    func increaseHappiness() {
        expression.mouth = expression.mouth.happierMouth()
    }
    
    func decreaseHappiness() {
        expression.mouth = expression.mouth.sadderMouth()
    }
    
    private func updateUI() {
        switch expression.eyes {
        case .Open: faceView.eyesOpen = true
        case .Closed: faceView.eyesOpen = false
        case .Squinting: faceView.eyesOpen = false
        }
        
        faceView.mouthCurcature = mouthCurvatures[expression.mouth] ?? 0.0
        faceView.eyeBrowTilt = eyeBrowTilts[expression.eyeBrows] ?? 0.0
    }
}

