//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Simen Gangstad on 10/10/2016.
//  Copyright © 2016 Simen Gangstad. All rights reserved.
//

import Foundation

struct Stack<Element> {
    var items = [Element]()
    mutating func push(_ item: Element) {
        items.append(item)
    }
    mutating func pop() -> Element {
        return items.removeLast()
    }
    mutating func clear() {
        items.removeAll()
    }
    func isEmpty() -> Bool {
        return items.isEmpty
    }
}

class CalculatorBrain {
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    private let operations = [
        "⨯" : Operation.BinaryOperation({$0 * $1}),
        "/" : Operation.BinaryOperation({$0 / $1}),
        "+" : Operation.BinaryOperation({$0 + $1}),
        "-" : Operation.BinaryOperation({$0 - $1}),
        "=" : Operation.Equals,
        "π" : Operation.Constant(M_PI),
        "sin" : Operation.UnaryOperation(sin),
        "cos" : Operation.UnaryOperation(cos),
        "tan" : Operation.UnaryOperation(tan),
        "log" : Operation.UnaryOperation(log10),
        "ln" : Operation.UnaryOperation(log),
        "e" : Operation.Constant(M_E),
        "^" : Operation.BinaryOperation({pow($0, $1)}),
        "√" : Operation.UnaryOperation(sqrt)
    ]
    
    private var lastOperationWasAnUnaryOperation = false

    
    private var accumulator = 0.0
    
    func setOperand(operand: Double) {
        accumulator = operand
        
        if (lastOperationWasAnUnaryOperation) {
            operationStack.clear()
            currentOperationChain = ""
        }
        
        if (!isPartialResult) {
            clearOperations()
        }
    }
    
    private var operationStack = Stack<String>()
    private var currentOperationChain = ""

    private var requestedEreaseOfOperationStack = false
    
    func performOperation(symbol: String) {
        
        if let operation = operations[symbol] {
            
            switch operation {
            case .Constant(let associatedConstantValue):
                accumulator = associatedConstantValue
            
            case .UnaryOperation(let unaryOperation):
                
                // Passing !lastOperationWasAnUnaryOperation prevents the accumulator being
                // pushed onto the stack if the last operation was an unary operation.
                // Say a case where the user presses 4 * 4, sqrt, sqrt. If we pass the
                // accumulator with the second sqrt the stack would look like this
                // 4 * 4
                // sqrt(_) (the underscore refers to the operation under the current operation in the stack, aka 4 * 4)
                // sqrt(4)
                // which makes it sqrt(4)(sqrt(4 * 4)) when the stack is resolved later
                //
                // This passes the current operation chain – without the unary operation – to the stack
                pushCurrentOperationChainToOperationStack(withAccumulator: !lastOperationWasAnUnaryOperation)
                
                // Updates the accumulator with the correct value if a pending binary operation exists, so
                // that the unary operation gets the proper value
                // If this wasn't done something like
                // 3 * 3 * 3, sqrt would result in sqrt of 3 * 3, not 3 * 3 * 3
                executePendingBinaryOperation()
                
                operationStack.push(symbol)
                accumulator = unaryOperation(accumulator)
                
                lastOperationWasAnUnaryOperation = true
                
            case .BinaryOperation(let binaryOperation):
                
                // If the last operation was power for example, this will make sure that an underscore is placed
                // in the current operation chain to represent that. Kind of like a reference to the last operation
                // in the stack:
                //
                // 3 ^ 2
                // _ + 3
                // This will result in (3 ^ 2) + 3
                
                currentOperationChain += " " + (lastOperationWasAnUnaryOperation ? "_" : (String(accumulator)) + " \(symbol)")
                
                // Put parentheses around the current operation if multiplication, division or raising to the power
                // 3 + 3 + 3 * 3 -> (3 + 3 + 3) * 3
                if (symbol == "⨯" || symbol == "/" || symbol == "^") {
                    currentOperationChain = "(\(currentOperationChain.substring(to: currentOperationChain.index(currentOperationChain.endIndex, offsetBy: -1))))\(symbol)"
                }
                
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryOperation: binaryOperation, firstOperand: accumulator)
                lastOperationWasAnUnaryOperation = false

            case .Equals:

                if (isPartialResult) { pushCurrentOperationChainToOperationStack(withAccumulator: true) }
                executePendingBinaryOperation()
            }
        }
    }
    
    private func pushCurrentOperationChainToOperationStack(withAccumulator: Bool) {
        currentOperationChain += withAccumulator ? " \(accumulator)" : "_"
        operationStack.push(currentOperationChain)
        currentOperationChain = ""
    }
    
    private func resolveOperationStack() -> String {
        
        if (operationStack.isEmpty()) {return currentOperationChain}
        
        var stackCopy = operationStack;
        var completeOperation = stackCopy.pop()
        
        // If the first item of the stack is an unary operation we have to include a underscore so the rest 
        // of the stack is filled in correctly
        if let operation = operations[completeOperation] {
            switch operation {
            case .UnaryOperation:
                completeOperation += "_"
            default:
                break;
            }
        }
        
        while (!stackCopy.isEmpty()) {
            let next = stackCopy.pop()
            // If the next operation in the stack is an operation which uses items in the next operation after that,
            // fill in with an underscore make a reference to that.
            completeOperation = completeOperation.replacingOccurrences(of: "_", with: operations[next] != nil ? ("\(next)_") : ("(\(next))"))
        }
        
        return completeOperation
    }
    
    private func executePendingBinaryOperation() {
        if (pending != nil) {
            accumulator = pending!.binaryOperation(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    // Only there if there's a pending binary operation such as add, multiply, etc., therefore optional
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryOperation: (Double, Double) -> Double
        var firstOperand: Double
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    func clearOperations() {
        
        operationStack.clear()
        currentOperationChain = ""
    }
    
    var description: String {
        get {
            return resolveOperationStack()
        }
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
