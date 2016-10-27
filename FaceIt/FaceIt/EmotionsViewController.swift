//
//  EmotionsViewController.swift
//  FaceIt
//
//  Created by Simen Gangstad on 27.10.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class EmotionsViewController: UIViewController {

    private let emotionalFaces: Dictionary<String, FacialExpression> = [
        "angry" : FacialExpression(eyes: .Closed, eyeBrows: .Furrowed, mouth: .Frown),
        "happy" : FacialExpression(eyes: .Open, eyeBrows: .Normal, mouth: .Smile),
        "worried" : FacialExpression(eyes: .Open, eyeBrows: .Relaxed, mouth: .Smirk),
        "mischievious" : FacialExpression(eyes: .Open, eyeBrows: .Furrowed, mouth: .Grin)
    ]
     
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        var destinationViewController = segue.destination
        
        // Retrieve the view controller which is the child of the navigation controller, and if it
        // doesn't exists, just set destination view controller to itself
        // This has to be done because further down we're setting the model for the FaceViewController, and the
        // UINavigationController of course doesn't have this model
        if let navigationViewController = destinationViewController as? UINavigationController {
            destinationViewController = navigationViewController.visibleViewController ?? destinationViewController
        }
        
        if let faceViewController = destinationViewController as? FaceViewController {
            if let identifier = segue.identifier {
                if let expression = emotionalFaces[identifier] {
                    faceViewController.expression = expression
                    
                    if let button = sender as? UIButton {
                            faceViewController.navigationItem.title = button.currentTitle
                    }
                }
            }
        }
    }
}
