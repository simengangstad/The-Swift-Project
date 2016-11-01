//
//  GraphViewController.swift
//  Calculator
//
//  Created by Simen Gangstad on 30.10.2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController, Graphable {

    @IBOutlet private weak var graphView: GraphView! { didSet { updateGraphView() } }
    
    private var brain = CalculatorBrain()
    
    var program : [AnyObject] {
        
        set {
            brain.program = newValue as CalculatorBrain.PropertyList
            updateGraphView()
            navigationItem.title = brain.description
        }
        get { return brain.program as! [AnyObject] }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphView.delegate = self
    }
    

    private func updateGraphView() {
        if (graphView != nil) {
            graphView.setNeedsDisplay()
        }
    }
    
    func yValue(x: Double) -> Double {
        brain.variableValues["M"] = x
        return brain.result
    }
    
    @IBAction func translate(_ sender: UIPanGestureRecognizer) {
        
        let translation = sender.translation(in: graphView)
        graphView.position = CGPoint(x: graphView.position.x + translation.x, y: graphView.position.y + translation.y)
        
        sender.setTranslation(CGPoint(x: 0.0, y: 0.0), in: graphView)
    }
    
    @IBAction func doubleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: graphView)
            let difference = CGPoint(x: -((location.x - graphView.bounds.width / 2.0) - graphView.position.x), y: -((location.y - graphView.bounds.height / 2.0) - graphView.position.y))
            graphView.position = difference
            
        }
    }
    
    @IBAction func changeScale(_ sender: UIPinchGestureRecognizer) {
        switch sender.state {
        case .changed,.ended:
            graphView.amountOfPointsShownOnAxisPerUnit *= sender.scale
            sender.scale = 1.0
            
        default: break
        }
    }
}
