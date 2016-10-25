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
    
    enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) -> Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
    }
    
    let operations = [
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
    
    private var accumulator = 0.0
    private var internalProgram = [AnyObject]()
    var variableValues = [String:Double]() {
        
        didSet {
            refresh(program: program)
        }
    }
    
    func setOperand(variableName: String) {
        accumulator = variableValues[variableName] ?? 0.0
        internalProgram.append(variableName as AnyObject)
    }
    
    func setOperand(operand: Double) {
        accumulator = operand
        internalProgram.append(operand as AnyObject)
    }
    
    func performOperation(symbol: String) {
        
        internalProgram.append(symbol as AnyObject)
        
        if let operation = operations[symbol] {
            
            switch operation {
            case .Constant(let associatedConstantValue):
                accumulator = associatedConstantValue
            
            case .UnaryOperation(let unaryOperation):
                
                // Updates the accumulator with the correct value if a pending binary operation exists, so
                // that the unary operation gets the proper value
                // If this wasn't done something like
                // 3 * 3 * 3, sqrt would result in sqrt of 3 * 3, not 3 * 3 * 3
                executePendingBinaryOperation()
                accumulator = unaryOperation(accumulator)
                
            case .BinaryOperation(let binaryOperation):
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryOperation: binaryOperation, firstOperand: accumulator)

            case .Equals:

                executePendingBinaryOperation()
            }
        }
    }
    
    private func executePendingBinaryOperation() {
        if (pending != nil) {
            accumulator = pending!.binaryOperation(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            variableValues.removeAll()
            refresh(program: newValue)
        }
    }
    
    private func refresh(program: PropertyList) {
        
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
        
        if let arrayOfOps = program as? [AnyObject] {
            for op in arrayOfOps {
                if let operand = op as? Double {
                    setOperand(operand: operand)
                }
                else if let operationOrVariableName = op as? String {
                    
                    // check if the string is an operation or variable
                    if (operations.keys.contains(where: { $0 == operationOrVariableName })) {
                        performOperation(symbol: operationOrVariableName)
                    }
                    else {
                        setOperand(variableName: operationOrVariableName)
                    }
                }
            }
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
    
    func clear() {
        variableValues.removeAll()
        accumulator = 0.0
        pending = nil
        internalProgram.removeAll()
    }
    
    var description: String {
        get {
            
            var operationStack = Stack<String>()
            var currentOperation = ""
            
            for op in internalProgram {
                
                if let operand = op as? Double {
                    currentOperation.append(String(operand))
                }
                else if let operationOrVariableName = op as? String {
                    
                    if (operations.keys.contains(where: { $0 == operationOrVariableName })) {
                        switch operations[operationOrVariableName]! {
                            
                        case .Constant:
                            currentOperation.append(operationOrVariableName)
                        case .UnaryOperation:
                            operationStack.push(currentOperation)
                            currentOperation = "\(operationOrVariableName)_"
                        case .BinaryOperation:
                            if (operationOrVariableName == "^" || operationOrVariableName == "/" || operationOrVariableName == "⨯") {
                                currentOperation.insert("(", at: currentOperation.startIndex)
                                currentOperation.insert(")", at: currentOperation.endIndex)
                            }
                            currentOperation.append(operationOrVariableName)
                            
                        case .Equals:
                            break
                        }
                        
                    }
                    else {
                        currentOperation.append(operationOrVariableName)
                    }
                }
            }
            
            operationStack.push(currentOperation)
            
            var completeOperation = operationStack.pop()
            
            while (!operationStack.isEmpty()) {
                let next = operationStack.pop()
                // If the next operation in the stack is an operation which uses items in the next operation after that,
                // fill in with an underscore make a reference to that.
                completeOperation = completeOperation.replacingOccurrences(of: "_", with: operations[next] != nil ? ("\(next)_") : ("(\(next))"))
            }
            
            return completeOperation
        }
    }
    
    func undoLastAction() -> AnyObject? {
        
        if (internalProgram.count > 0) {
            
            if let operation = internalProgram[internalProgram.count - 1] as? String {
                
                if (operation == "=") {
                    internalProgram.remove(at: internalProgram.count - 1)
                }
            }
            
            let op = internalProgram.remove(at: internalProgram.count - 1)
            refresh(program: program)
            
            return op
        }
        
        return nil
    }
    
    var result: Double {
        get {
            return accumulator
        }
    }
}
