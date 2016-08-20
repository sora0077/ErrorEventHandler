//
//  Action.swift
//  ErrorEventHandler
//
//  Created by 林達也 on 2016/08/20.
//  Copyright © 2016年 jp.sora0077. All rights reserved.
//

import Foundation


public protocol FetchAction {
    
    func request(refresh: Bool, force: Bool, ifError errorType: Error.Type, level: ErrorLevel)
}

public protocol PushAction {
    
    func request(ifError errorType: Error.Type, level: ErrorLevel)
}
