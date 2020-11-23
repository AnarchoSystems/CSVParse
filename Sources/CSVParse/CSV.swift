//
//  CSV.swift
//  
//
//  Created by Markus Pfeifer on 20.11.20.
//

import Foundation


public struct CSV<S> {
   
    public typealias Row = S
    
    @usableFromInline 
    var stored : [S]
    
    public subscript(row: Int) -> S {
        get{
            stored[row]
        }
        set{
            stored[row] = newValue
        }
    }
    
    public subscript<T>(row: Int, col: WritableKeyPath<Row,T>) -> T{
        get{
            stored[row][keyPath: col]
        }
        set{
            stored[row][keyPath: col] = newValue
        }
    }
    
    public subscript<T>(col: (Row) -> T) -> [T]{
        stored.map(col)
    }
    
}


extension CSV : Equatable where S : Equatable {
    
}
