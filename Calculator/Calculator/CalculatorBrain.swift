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
    
    // Create arithmetic enum with autoclosures?
    
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
    private var variable: Character?
    private var internalProgram = [AnyObject]()
    
    var variableValues = [Character:Double]()
    
    private var usedVariableInOperation = false
    
    func setOperand(variable: Character) {
        self.variable = variable
        setOperand(operand: variableValues[variable] ?? 0.0)
        internalProgram[internalProgram.count - 1] = variable as AnyObject
        
        usedVariableInOperation = true
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        
        if (pending != nil && pending!.secondOperand == nil) {
            pending!.secondOperand = accumulator
        }
                
        internalProgram.append(operand as AnyObject)
    }
    
    private var operationStack = Stack<String>()
    private var currentOperationChain = ""

    private var requestedEreaseOfOperationStack = false
    
    func performOperation(symbol: String) {
        
        internalProgram.append(symbol as AnyObject)
        
        if let operation = operations[symbol] {
            
            switch operation {
            case .Constant(let associatedConstantValue):
                accumulator = associatedConstantValue
            
            case .UnaryOperation(let unaryOperation):
                
                if (pending != nil && pending!.secondOperand == nil) {
                    break
                }
                
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
                
                if (pending != nil && pending!.secondOperand == nil) {
                    break
                }
                
                // If the last operation was power for example, this will make sure that an underscore is placed
                // in the current operation chain to represent that. Kind of like a reference to the last operation
                // in the stack:
                //
                // 3 ^ 2
                // _ + 3
                // This will result in (3 ^ 2) + 3
                
                currentOperationChain += (lastOperationWasAnUnaryOperation ? "_\(symbol)" : (usedVariableInOperation ? String(variable!) : String(accumulator)) + "\(symbol)")
                
                // Put parentheses around the current operation if multiplication, division or raising to the power
                // 3 + 3 + 3 * 3 -> (3 + 3 + 3) * 3
                if (symbol == "⨯" || symbol == "/" || symbol == "^") {
                    currentOperationChain = "(\(currentOperationChain.substring(to: currentOperationChain.index(currentOperationChain.endIndex, offsetBy: -1))))\(symbol)"
                }
                
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryOperation: binaryOperation, firstOperand: accumulator, secondOperand: nil)
                lastOperationWasAnUnaryOperation = false

            case .Equals:

                if (pending != nil && pending!.secondOperand == nil) {
                    break
                }
                
                if (isPartialResult) {
                    pushCurrentOperationChainToOperationStack(withAccumulator: true)
                    executePendingBinaryOperation()
                }
            }
        }
        
        usedVariableInOperation = false
    }
    
    private func pushCurrentOperationChainToOperationStack(withAccumulator: Bool) {
        currentOperationChain += withAccumulator ? (usedVariableInOperation ? String(variable!) : "\(accumulator)") : "_"
        operationStack.push(currentOperationChain)
        currentOperationChain = ""
    }
    
    private func resolveOperationStack() -> String {
        
        if (operationStack.isEmpty()) { return currentOperationChain }
        
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
        if (pending != nil && pending!.secondOperand != nil) {
            accumulator = pending!.binaryOperation(pending!.firstOperand, pending!.secondOperand!)
            pending = nil
        }
    }
    
    public struct PropertyList {
        var program: [AnyObject]
        var operations: [AnyObject]
    }
    
     //typealias PropertyList = (program: [AnyObject], operations: [AnyObject])
    
    var program: PropertyList {
        get {
            
            var ops = [AnyObject]()
            
            for item in operationStack.items {
                ops.append(item as AnyObject)
            }
            
            return PropertyList(program: internalProgram, operations: ops)
        }
        set {
            rebuildFromPropertyList(propertyList: newValue)
        }
    }
    
    private func rebuildFromPropertyList(propertyList: PropertyList) {
        
        clear()
        clearOperations()
        
        for op in propertyList.program {
            if let operand = op as? Double { setOperand(operand: operand) }
            else if let operation = op as? String { performOperation(symbol: operation) }
            else if let variable = op as? Character { setOperand(variable: variable) }
        }
        
        for item in propertyList.operations {
            operationStack.push(item as! String)
        }
    }
    
    // Only there if there's a pending binary operation such as add, multiply, etc., therefore optional
    private var pending: PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryOperation: (Double, Double) -> Double
        var firstOperand: Double
        var secondOperand: Double?
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    func clear() {
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
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
