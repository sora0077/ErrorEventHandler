//
//  ErrorLog.swift
//  ErrorEventHandler
//
//  Created by 林達也 on 2016/08/20.
//  Copyright © 2016年 jp.sora0077. All rights reserved.
//

import Foundation


private func doOnMainThread(async: Bool = true, execute: @autoclosure @escaping  () -> Void) -> Bool {
    guard Thread.isMainThread else {
        if async {
            DispatchQueue.main.async(execute: execute)
        } else {
            DispatchQueue.main.sync(execute: execute)
        }
        return false
    }
    return true
}


private func doOnMainThread<T>(execute: () -> T) -> T {
    if Thread.isMainThread {
        return execute()
    }
    return DispatchQueue.main.sync(execute: execute)
}


public final class ErrorLog {
    
    public final class Event {
        enum State {
            case waiting, running, done
        }
        public let error: Error
        public let level: ErrorLevel
        public let errorAt = Date()
        fileprivate var state: State
        
        private lazy var mark: () -> Void = {
            DispatchQueue.main.async {
                self.state = .done
                _ = ErrorLog.dequeue()
                ErrorLog.nextRun()
            }
            return {}
        }()
        
        fileprivate init(error: Error, level: ErrorLevel) {
            self.error = error
            self.level = level
            self.state = .waiting
        }
        
        public func resolved() {
            mark()
        }
    }
    
    private static var queue: ArraySlice<Event> = []
    private static var closure: (Event) -> Void = { _ in }
    
    private init() {}
    
    private static func dequeue() -> Event? {
        return doOnMainThread {
            queue.popFirst()
        }
    }
    
    private static func nextRun() {
        if let event = queue.first, event.state == .waiting {
            event.state = .running
            closure(event)
        }
    }
    
    public static func observe(_ closure: @escaping (Event) -> Void) {
        self.closure = closure
    }
    
    public static func enqueue(error: Swift.Error? = nil, with errorType: Error.Type, level: ErrorLevel) {
        guard doOnMainThread(execute: self.enqueue(error: error, with: errorType, level: level)) else {
            return
        }
        let isEmpty = queue.isEmpty
        defer {
            DispatchQueue.main.async {
                if isEmpty {
                    nextRun()
                }
            }
        }
        
        queue.append(Event(error: errorType.init(error: error), level: level))
    }
}
