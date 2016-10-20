//
//  ViewController.swift
//  Calculator
//
//  Created by Simen Gangstad on 06/10/2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        // If the number isn't an integer it includes a decimal point..
        if (digit == "." && display.text!.range(of: ".") != nil && display.text! != "0.0") { return }
        
        if (userIsInTheMiddleOfTyping) {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        }
        else {
            
            display.text = digit
        }
        
        userIsInTheMiddleOfTyping = true        
    }
    
    private var displayValue: Double {
        
        get { return Double(display.text!)! }
        set {
            // newValue is the new value display value is set to
            display.text = String(newValue)
        }
    }
    
    private var brain = CalculatorBrain()
    
    private func updateDescriptionLabel() {
        descriptionLabel.text = brain.description + (brain.isPartialResult ? "..." : "=")
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        
        // If we can let mathematical symbol equal to sender's current title...
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
            updateDescriptionLabel()
        }
        
        displayValue = brain.result
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    @IBAction func store() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if (savedProgram != nil) {
            brain.program = savedProgram!
            displayValue = brain.result
            updateDescriptionLabel()
        }
    }
    
    @IBAction func storeInVariable(_ sender: UIButton) {
        if (!brain.isPartialResult) {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
            brain.variableValues["M"] = brain.result
        }
    }
    
    @IBAction func retrieveFromVariable(_ sender: UIButton) {
        brain.setOperand(variable: "M")
        // Update in case the user hasn't previously done any other operations
        if (!brain.isPartialResult) {
            displayValue = brain.result
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        brain.clearOperations()
        brain.clear()
        displayValue = brain.result
        descriptionLabel.text = "..."
        brain.variableValues["M"] = 0.0
    }
}


