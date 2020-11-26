//
//  ExtendedAPI.swift
//  
//
//  Created by Markus Pfeifer on 20.11.20.
//

import Foundation


public extension Sequence {
    
    func sorted<T : Comparable>(by comparable: (Element) -> T) -> [Element] {
        self.sorted(by: {comparable($0) < comparable($1)})
    }
    
}


public extension Array {
    
    mutating func sort<T : Comparable>(by comparable: (Element) -> T) {
        self.sort(by: {comparable($0) < comparable($1)})
    }
    
}


public extension CSV {
    
    func map<U>(_ transform: ([S]) -> [U]) -> CSV<U> {
        CSV<U>(stored: transform(stored))
    }
    
    func map<U>(_ transform: (S) -> U) -> CSV<U> {
        map({$0.map(transform)})
    }
    
    func map(_ transform: ([S]) -> [S]) -> CSV<S> {
        CSV(stored: transform(stored))
    }
    
    mutating func sort<C : Comparable>(by comparable: (S) -> C) {
        stored.sort(by: comparable)
    }
    
    func sorted<C : Comparable>(by comparable: (S) -> C) -> CSV {
        map{$0.sorted(by: comparable)}
    }
    
    func filter(_ predicate: (S) -> Bool) -> CSV {
        map{$0.filter(predicate)}
    }

}


extension CSV : ExpressibleByArrayLiteral {
    
    public init(arrayLiteral elements: S...) {
        self.stored = elements
    }
    
}
