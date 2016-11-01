//
//  ViewController.swift
//  Calculator
//
//  Created by Simen Gangstad on 06/10/2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController {

    @IBOutlet private weak var display: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    private var decimalPointInNumber = false
    private var operationNext = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        
        if (operationNext) {
            return
        }
        
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
    
    @IBAction private func performOperation(_ sender: UIButton) {
        
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
            decimalPointInNumber = false
        }
        /*else {
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
        }*/
        
        if (sender.currentTitle != "=") {
            lastOperation = sender.currentTitle!
        }
        
        // If we can let mathematical symbol equal to sender's current title...
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
            descriptionLabel.text = brain.description + (brain.isPartialResult ? "..." : "=")
        }
        
        displayValue = brain.result
        
        operationNext = false
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
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
    
    @IBAction func store() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if (savedProgram != nil) {
            brain.program = savedProgram!
            displayValue = brain.result
            descriptionLabel.text = brain.description + (brain.isPartialResult ? "..." : "=")
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
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationController = segue.destination
        if let description = segue.identifier {
            
            switch description {
            case "Show Graph":
                
            if let navigationVC = destinationController as? UINavigationController {
                if let graphViewController = navigationVC.viewControllers[0] as? GraphViewController {
                    graphViewController.program = brain.program as! [AnyObject]
                }
            }
            default: break
            }
        }
    }
}


