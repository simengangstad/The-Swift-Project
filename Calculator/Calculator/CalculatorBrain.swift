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
    
<<<<<<< HEAD
    // Create arithmetic enum with autoclosures?
    
    private enum Operation {
=======
    enum Operation {
>>>>>>> new_description_system
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
    private var variable: Character?
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
<<<<<<< HEAD
        
        if (pending != nil && pending!.secondOperand == nil) {
            pending!.secondOperand = accumulator
        }
                
=======
>>>>>>> new_description_system
        internalProgram.append(operand as AnyObject)
    }
    
    func performOperation(symbol: String) {
        
        internalProgram.append(symbol as AnyObject)
        
        if let operation = operations[symbol] {
            
            switch operation {
            case .Constant(let associatedConstantValue):
                accumulator = associatedConstantValue
            
            case .UnaryOperation(let unaryOperation):
                
<<<<<<< HEAD
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
                
=======
>>>>>>> new_description_system
                // Updates the accumulator with the correct value if a pending binary operation exists, so
                // that the unary operation gets the proper value
                // If this wasn't done something like
                // 3 * 3 * 3, sqrt would result in sqrt of 3 * 3, not 3 * 3 * 3
                executePendingBinaryOperation()
                accumulator = unaryOperation(accumulator)
                
            case .BinaryOperation(let binaryOperation):
<<<<<<< HEAD
                
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
=======
                executePendingBinaryOperation()
                pending = PendingBinaryOperationInfo(binaryOperation: binaryOperation, firstOperand: accumulator)

            case .Equals:

                executePendingBinaryOperation()
>>>>>>> new_description_system
            }
        }
        
        usedVariableInOperation = false
    }
    
<<<<<<< HEAD
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
    
=======
>>>>>>> new_description_system
    private func executePendingBinaryOperation() {
        if (pending != nil && pending!.secondOperand != nil) {
            accumulator = pending!.binaryOperation(pending!.firstOperand, pending!.secondOperand!)
            pending = nil
        }
    }
    
    typealias PropertyList = AnyObject
    
    var program: PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
<<<<<<< HEAD
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
=======
            variableValues.removeAll()
            refresh(program: newValue)
>>>>>>> new_description_system
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
        var secondOperand: Double?
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
