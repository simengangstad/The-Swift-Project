//
//  BlinkingFaceViewController.swift
//  FaceIt
//
//  Created by Simen Gangstad on 15.11.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class BlinkingFaceViewController: FaceViewController {

    var blinking: Bool = false {
        didSet {
            startBlink()
        }
    }
    
    private struct BlinkRate {
        static let ClosedDuration = 0.4
        static let OpenDuration = 2.5
    }
    
    @objc
    private func startBlink() {
        if blinking {
            faceView.eyesOpen = false
            
            Timer.scheduledTimer(timeInterval: BlinkRate.ClosedDuration, target: self, selector: #selector(BlinkingFaceViewController.endBlink), userInfo: nil, repeats: false)
        }
    }
    
    @objc
    private func endBlink() {
        faceView.eyesOpen = true
        Timer.scheduledTimer(timeInterval: BlinkRate.OpenDuration, target: self, selector: #selector(BlinkingFaceViewController.startBlink), userInfo: nil, repeats: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        blinking = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        blinking = false
    }
}
