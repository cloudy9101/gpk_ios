//
//  Topic.swift
//  Demo
//
//  Created by cloud on 8/29/15.
//  Copyright (c) 2015 cloud. All rights reserved.
//

import Foundation

class Topic {
    var title: String?
    var description: String?
    
    init(title:String?, description:String?){
        if let t = title {
            self.title = t
        }
        if let d = description {
            self.description = d
        }
    }
    
}
