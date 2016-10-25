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
<<<<<<< HEAD
=======
    private var decimalPointInNumber = false
    private var operationNext = false
>>>>>>> new_description_system
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        
        if (operationNext) {
            return
        }
        
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
    private var lastOperation = ""
    
    private func updateDescriptionLabel() {
        descriptionLabel.text = brain.description + (brain.isPartialResult ? "..." : "=")
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        else {
            if let operation = brain.operations[lastOperation] {
                switch operation {
                case .BinaryOperation:
                    switch brain.operations[sender.currentTitle!]! {
                    case .BinaryOperation:
                        return
                    default:
                        break
                    }
                default:
                    break
                }
            }
        }
        
        if (sender.currentTitle != "=") {
            lastOperation = sender.currentTitle!
        }
        
        // If we can let mathematical symbol equal to sender's current title...
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
            updateDescriptionLabel()
        }
        
        displayValue = brain.result
        
        operationNext = false
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
<<<<<<< HEAD
=======
    @IBAction func save() {
     
        if (!brain.isPartialResult) {
            brain.variableValues["M"] = displayValue
            displayValue = brain.result
            userIsInTheMiddleOfTyping = false
        }
    }
    
    @IBAction func recall() {
        brain.setOperand(variableName: "M")
        displayValue = brain.result
        descriptionLabel.text = brain.description + (brain.isPartialResult ? "..." : "=")
        operationNext = true
    }
    
>>>>>>> new_description_system
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
    
    @IBAction func undo() {
        if (userIsInTheMiddleOfTyping) {
            
            if (display.text!.characters.count > 1 && displayValue != 0.0) {
                var string = display.text!
                string.remove(at: string.index(string.endIndex, offsetBy: -1))
                display.text = string
            }
        }
        else {
            let objectRemoved = brain.undoLastAction()
            
            if let operation = objectRemoved as? String {
                
                switch brain.operations[operation]! {
                case CalculatorBrain.Operation.UnaryOperation:
                    lastOperation = operation
                default:
                    lastOperation = ""
                    break
                }
            }
            
            displayValue = brain.result
            descriptionLabel.text = brain.description + (brain.isPartialResult ? "..." : "=")
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        userIsInTheMiddleOfTyping = false
        brain.clear()
        displayValue = brain.result
        descriptionLabel.text = "..."
        brain.variableValues["M"] = 0.0
    }
}


