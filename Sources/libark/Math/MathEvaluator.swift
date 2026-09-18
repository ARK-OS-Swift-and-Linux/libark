// Copyright 2026 Aarav Ravindra Kharade
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

/// A simple integer arithmetic expression evaluator.
/// Supports +, -, *, /, % and parentheses ().
public struct MathEvaluator {
    
    enum Token {
        case number(Int)
        case identifier(String)
        case plus, minus, multiply, divide, modulo
        case leftParen, rightParen
    }
    
    public init() {}
    
    public func evaluate(_ expression: String, variables: [String: String] = [:]) throws -> Int {
        var tokens = try tokenize(expression)
        return try parseExpression(tokens: &tokens, variables: variables)
    }
    
    private func tokenize(_ input: String) throws -> [Token] {
        var tokens: [Token] = []
        var i = input.startIndex
        
        while i < input.endIndex {
            let char = input[i]
            
            if char.isWhitespace {
                i = input.index(after: i)
                continue
            }
            
            switch char {
            case "+": tokens.append(.plus); i = input.index(after: i)
            case "-": tokens.append(.minus); i = input.index(after: i)
            case "*": tokens.append(.multiply); i = input.index(after: i)
            case "/": tokens.append(.divide); i = input.index(after: i)
            case "%": tokens.append(.modulo); i = input.index(after: i)
            case "(": tokens.append(.leftParen); i = input.index(after: i)
            case ")": tokens.append(.rightParen); i = input.index(after: i)
            default:
                if char.isNumber {
                    var numStr = ""
                    while i < input.endIndex && input[i].isNumber {
                        numStr.append(input[i])
                        i = input.index(after: i)
                    }
                    if let val = Int(numStr) {
                        tokens.append(.number(val))
                    } else {
                        throw NSError(domain: "MathEvaluator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid number"])
                    }
                } else if char.isLetter || char == "_" || char == "$" {
                    var idStr = ""
                    // Skip $ if present
                    if char == "$" {
                        i = input.index(after: i)
                    }
                    while i < input.endIndex && (input[i].isLetter || input[i].isNumber || input[i] == "_") {
                        idStr.append(input[i])
                        i = input.index(after: i)
                    }
                    tokens.append(.identifier(idStr))
                } else {
                    throw NSError(domain: "MathEvaluator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Invalid character '\(char)'"])
                }
            }
        }
        return tokens
    }
    
    private func parseExpression(tokens: inout [Token], variables: [String: String]) throws -> Int {
        return try parseTerm(tokens: &tokens, variables: variables)
    }
    
    private func parseTerm(tokens: inout [Token], variables: [String: String]) throws -> Int {
        var result = try parseFactor(tokens: &tokens, variables: variables)
        
        while !tokens.isEmpty {
            let next = tokens[0]
            if case .plus = next {
                tokens.removeFirst()
                result += try parseFactor(tokens: &tokens, variables: variables)
            } else if case .minus = next {
                tokens.removeFirst()
                result -= try parseFactor(tokens: &tokens, variables: variables)
            } else {
                break
            }
        }
        
        return result
    }
    
    private func parseFactor(tokens: inout [Token], variables: [String: String]) throws -> Int {
        var result = try parsePrimary(tokens: &tokens, variables: variables)
        
        while !tokens.isEmpty {
            let next = tokens[0]
            if case .multiply = next {
                tokens.removeFirst()
                result *= try parsePrimary(tokens: &tokens, variables: variables)
            } else if case .divide = next {
                tokens.removeFirst()
                let divisor = try parsePrimary(tokens: &tokens, variables: variables)
                if divisor == 0 { throw NSError(domain: "MathEvaluator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Division by zero"]) }
                result /= divisor
            } else if case .modulo = next {
                tokens.removeFirst()
                let divisor = try parsePrimary(tokens: &tokens, variables: variables)
                if divisor == 0 { throw NSError(domain: "MathEvaluator", code: 3, userInfo: [NSLocalizedDescriptionKey: "Modulo by zero"]) }
                result %= divisor
            } else {
                break
            }
        }
        return result
    }
    
    private func parsePrimary(tokens: inout [Token], variables: [String: String]) throws -> Int {
        guard !tokens.isEmpty else {
            throw NSError(domain: "MathEvaluator", code: 4, userInfo: [NSLocalizedDescriptionKey: "Unexpected end of expression"])
        }
        
        let token = tokens.removeFirst()
        switch token {
        case .number(let val):
            return val
        case .identifier(let name):
            if let strVal = variables[name], let intVal = Int(strVal) {
                return intVal
            }
            return 0 // Default to 0 for undefined/invalid vars
        case .leftParen:
            let val = try parseExpression(tokens: &tokens, variables: variables)
            guard !tokens.isEmpty, case .rightParen = tokens.removeFirst() else {
                throw NSError(domain: "MathEvaluator", code: 5, userInfo: [NSLocalizedDescriptionKey: "Expected ')'"])
            }
            return val
        case .minus:
            return try -parsePrimary(tokens: &tokens, variables: variables)
        case .plus:
            return try parsePrimary(tokens: &tokens, variables: variables)
        default:
            throw NSError(domain: "MathEvaluator", code: 6, userInfo: [NSLocalizedDescriptionKey: "Unexpected token"])
        }
    }
}
