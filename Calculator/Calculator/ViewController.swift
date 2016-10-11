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
    private var decimalPointInNumber = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        
        let digit = sender.currentTitle!
        
        if (digit == ".") {
            if (!decimalPointInNumber) {
                decimalPointInNumber = true
            }
            else {
                return;
            }
        }

        if (userIsInTheMiddleOfTyping) {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        }
        else {
            display.text = digit
            if (!brain.isPartialResult) {descriptionLabel.text = "..."}
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
    
    @IBAction private func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
            decimalPointInNumber = false
        }
        
        // If we can let mathematical symbol equal to sender's current title...
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
            descriptionLabel.text = brain.description + (brain.isPartialResult ? "..." : "=")
        }
        
        displayValue = brain.result
    }
    
    @IBAction func clear(_ sender: UIButton) {
        
        userIsInTheMiddleOfTyping = false
        brain.clearOperations()
        brain.setOperand(operand: 0.0)
        displayValue = brain.result
        descriptionLabel.text = "..."
    }
}


