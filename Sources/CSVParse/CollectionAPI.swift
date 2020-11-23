//
//  CollectionAPI.swift
//  
//
//  Created by Markus Pfeifer on 20.11.20.
//

import Foundation


extension CSV : Sequence {
    public typealias Iterator = IndexingIterator<[S]>
    
    public typealias Element = S
    
    
    @inlinable
    public func makeIterator() -> IndexingIterator<[S]> {
        stored.makeIterator()
    }
    
}


extension CSV: MutableCollection {
   
    @inlinable
    public var startIndex: Int {
        stored.startIndex
    }
    
    @inlinable
    public var endIndex: Int {
        stored.endIndex
    }
    
    @inlinable
    public func index(after i: Int) -> Int {
        stored.index(after: i)
    }
   
}


extension CSV : RangeReplaceableCollection {
    
    @inlinable
    public init() {
        stored = [S]()
    }
    
}


extension CSV : RandomAccessCollection {
    
}
