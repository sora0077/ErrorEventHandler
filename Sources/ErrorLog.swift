//
//  ErrorLog.swift
//  ErrorEventHandler
//
//  Created by 林達也 on 2016/08/20.
//  Copyright © 2016年 jp.sora0077. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


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
    var ret: T!
    DispatchQueue.main.sync {
        ret = execute()
    }
    return ret
}


public final class ErrorLog {
    
    public final class Event {
        public let error: Error
        public let level: ErrorLevel
        public let errorAt = Date()
        
        private lazy var mark: () -> Void = {
            _ = ErrorLog.dequeue().map(ErrorLog._event.onNext)
            return {}
        }()
        
        fileprivate init(error: Error, level: ErrorLevel) {
            self.error = error
            self.level = level
        }
        
        public func resolved() {
            guard doOnMainThread(execute: self.resolved()) else {
                return
            }
            mark()
        }
    }
    
    private static var queue: ArraySlice<Event> = []
    
    private static let _event = PublishSubject<Event>()
    public private(set) static var event: Driver<Event> = _event.asDriver { error in
        _ = error
        fatalError()
    }
    
    private init() {}
    
    private static func dequeue() -> Event? {
        return doOnMainThread {
            queue.popFirst()
        }
    }
    
    public static func enqueue(error: Swift.Error? = nil, with errorType: Error.Type, level: ErrorLevel) {
        guard doOnMainThread(execute: self.enqueue(error: error, with: errorType, level: level)) else {
            return
        }
        let isEmpty = queue.isEmpty
        defer {
            DispatchQueue.main.async {
                if isEmpty {
                    _ = dequeue().map(ErrorLog._event.onNext)
                }
            }
        }
        
        queue.append(Event(error: errorType.init(error: error), level: level))
    }
}
