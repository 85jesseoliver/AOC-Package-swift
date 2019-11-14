//
//  Day25.swift
//  test
//
//  Created by Dave DeLong on 12/22/17.
//  Copyright © 2017 Dave DeLong. All rights reserved.
//

class Day25: Day {
    
    struct TuringState {
        let ifOne: (Int, Int, String)
        let ifZero: (Int, Int, String)
        func actions(for: Int) -> (Int, Int, String) {
            return `for` == 0 ? ifZero : ifOne
        }
    }
    
    enum State {
        case A
        case B
        case C
        case D
        case E
        case F
    }
    
    var startingState: String = ""
    var iterations: Int = 0
    var states = Dictionary<String, TuringState>()
    
    @objc override init() {
        super.init()
        
        let begin = Regex(pattern: #"Begin in state ([A-Z])\."#)
        let steps = Regex(pattern: #"Perform a diagnostic checksum after (\d+) steps\."#)
        
        let name = Regex(pattern: #"\s*In state ([A-Z])\:"#)
        let write = Regex(pattern: #"\s*- Write the value (\d)\."#)
        let move = Regex(pattern: #"\s*- Move one slot to the (left|right)\."#)
        let state = Regex(pattern: #"\s*- Continue with state ([A-Z])\."#)
        
        var sections = input.raw.components(separatedBy: "\n\n")
        
        let metaInfo = sections.removeFirst()
        let metaLines = metaInfo.components(separatedBy: .newlines)
        
        startingState = metaLines[0].match(begin)[1]!
        iterations = metaLines[1].match(steps).int(1)!
        
        sections.forEach { section in
            let lines = section.components(separatedBy: .newlines)
            
            let n = lines[0].match(name)[1]!
            let zeroWrite = lines[2].match(write).int(1)!
            let zeroMove = (lines[3].match(move)[1] == "left") ? -1 : 1
            let zeroState = lines[4].match(state)[1]!
            
            let oneWrite = lines[6].match(write).int(1)!
            let oneMove = (lines[7].match(move)[1] == "left") ? -1 : 1
            let oneState = lines[8].match(state)[1]!
            
            let s = TuringState(ifOne: (oneWrite, oneMove, oneState), ifZero: (zeroWrite, zeroMove, zeroState))
            states[n] = s
        }
        
        
    }
    
    override func part1() -> String {
        var tape = Dictionary<Int, Int>()
        var cursor = 0
        var state = State.A
        
        for _ in 0 ..< 12302209 {
            
            let currentValue = tape[cursor] ?? 0
            switch state {
                case .A:
                    if currentValue == 0 {
                        tape[cursor] = 1
                        cursor += 1
                        state = .B
                    } else {
                        tape[cursor] = 0
                        cursor -= 1
                        state = .D
                    }
                case .B:
                    if currentValue == 0 {
                        tape[cursor] = 1
                        cursor += 1
                        state = .C
                    } else {
                        tape[cursor] = 0
                        cursor += 1
                        state = .F
                    }
                case .C:
                    if currentValue == 0 {
                        tape[cursor] = 1
                        cursor -= 1
                        state = .C
                    } else {
                        tape[cursor] = 1
                        cursor -= 1
                        state = .A
                    }
                case .D:
                    if currentValue == 0 {
                        tape[cursor] = 0
                        cursor -= 1
                        state = .E
                    } else {
                        tape[cursor] = 1
                        cursor += 1
                        state = .A
                    }
                case .E:
                    if currentValue == 0 {
                        tape[cursor] = 1
                        cursor -= 1
                        state = .A
                    } else {
                        tape[cursor] = 0
                        cursor += 1
                        state = .B
                    }
                case .F:
                    if currentValue == 0 {
                        tape[cursor] = 0
                        cursor += 1
                        state = .C
                    } else {
                        tape[cursor] = 0
                        cursor += 1
                        state = .E
                    }
                
            }
            
        }
        
        let checksum = tape.values.sum()
        
        return "\(checksum)"
    }
    
    override func part2() -> String {
        var tape = Dictionary<Int, Int>()
        var cursor = 0
        var current = startingState
        
        for _ in 0 ..< iterations {
            let value = tape[cursor] ?? 0
            let actions = states[current]!.actions(for: value)
            tape[cursor] = actions.0
            cursor += actions.1
            current = actions.2
        }
        
        let checksum = tape.values.sum()
        return "\(checksum)"
    }
    
}
