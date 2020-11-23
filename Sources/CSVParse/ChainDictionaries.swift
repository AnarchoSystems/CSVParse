//
//  ChainDictionaries.swift
//  
//
//  Created by Markus Pfeifer on 21.11.20.
//

import Foundation


public extension Dictionary where Value : Hashable {
    
    func chained<U>(with other: [Value : U]) -> [Key : U] {
        [Key : U](uniqueKeysWithValues: compactMap{key, value in
            other[value].map{(key, $0)}
        })
    }
    
}
