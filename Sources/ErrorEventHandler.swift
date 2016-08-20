//
//  ErrorEventHandler.swift
//  ErrorEventHandler
//
//  Created by 林達也 on 2016/08/20.
//  Copyright © 2016年 jp.sora0077. All rights reserved.
//

import Foundation


public protocol Error: Swift.Error {
    init(error: Swift.Error?)
    
    func level(initial: ErrorLevel) -> ErrorLevel
}

extension Error {
    
    public func level(initial: ErrorLevel) -> ErrorLevel {
        return initial
    }
}

public protocol ErrorLevel {}
