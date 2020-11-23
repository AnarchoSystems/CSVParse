//
//  CSVParser.swift
//  
//
//  Created by Markus Pfeifer on 20.11.20.
//

import Foundation

public struct CSVParsingOptions {
    
    public var separator: Character
    public var rowSeparator: Character
    public var keySeparator: String
    public var numberFormatter: NumberFormatter
    public var nilSymbol: String
    
    public init(separator: Character = ",",
                rowSeparator: Character = "\n",
                keySeparator: String = " ",
                numberFormatter: NumberFormatter = NumberFormatter(),
                nilSymbol: String = "?") {
        self.separator = separator
        self.rowSeparator = rowSeparator
        self.keySeparator = keySeparator
        self.numberFormatter = numberFormatter
        self.nilSymbol = nilSymbol
    }
    
}

public class CSVEncoder {
    
    public var options : CSVParsingOptions
    public var userInfo : [CodingUserInfoKey : Any]
    
    public enum HeaderOptions {
        case noHeader
        case inferHeader
        case mapHeader([String : String])
    }
    
    public init(options: CSVParsingOptions = CSVParsingOptions(),
                userInfo: [CodingUserInfoKey : Any] = [:]){
        self.options = options
        self.userInfo = userInfo
    }
    
    public func encode<Value : Encodable>(_ value: Value) throws -> (keys: [String : Int], values: [String]) {
        let encoder = CSVContainerEncoder(userInfo: userInfo,
                                          options: options)
        try value.encode(to: encoder)
        return try encoder.getData()
    }
    
    public func encode<Row : Encodable>(csv: CSV<Row>,
                                        opts: HeaderOptions = .inferHeader) throws -> String {
       
        let rows = try csv.stored.map{try self.encode($0)}
        
        let separator = String(options.separator)
        let rowSeparator = String(options.rowSeparator)
        
        switch opts {
        
        case .noHeader:
            return rows
                .map{$0.values.joined(separator: separator)}
                .joined(separator: rowSeparator)
        case .inferHeader:
            
            guard let (header, _) = rows.first else {
                return ""
            }
            
            let sortedHeader = header.sorted(by: \.value).map{$0.key}.joined(separator: separator)
            
            return ([sortedHeader] + rows.map{$0.values.joined(separator: separator)})
                .joined(separator: rowSeparator)
            
        case .mapHeader(let mapping):
            
            guard let (header, _) = rows.first else {
                return ""
            }
            
            let sortedHeader = mapping.chained(with: header)
                .sorted(by: \.value).map{$0.key}.joined(separator: separator)
            
            return ([sortedHeader] + rows.map{$0.values.joined(separator: separator)})
                .joined(separator: rowSeparator)
        }
        
    }
    
}

public class CSVDecoder {
    
    public var options : CSVParsingOptions
    public var userInfo : [CodingUserInfoKey : Any]
    
    public enum HeaderOptions {
        case assumeFirstLine
        case override(headerToUse: [String : Int], skipFirstLine: Bool)
        case mapHeader([String : String])
    }
    
    public init(options: CSVParsingOptions = CSVParsingOptions(),
                userInfo: [CodingUserInfoKey : Any] = [:]){
        self.options = options
        self.userInfo = userInfo
    }
    
    public func decode<Value : Decodable>(_ type: Value.Type,
                                          from data: (keys: [String : Int], values: [String.SubSequence])) throws -> Value {
        try Value(from: CSVContainerDecoder(input: data,
                                            opts: options,
                                            userInfo: userInfo,
                                            codingPath: []))
    }
    
    public func decode<Row : Decodable>(rowType: Row.Type,
                                        from data: String,
                                        opts: HeaderOptions = .assumeFirstLine) throws -> CSV<Row> {
        
        let input = data
            .split(separator: options.rowSeparator)
            .map(splitString(options.separator))
        
        guard let first = input.first else {
            throw DecodingError.dataCorrupted(.init(codingPath: [],
                                                    debugDescription: "Empty string!"))
        }
        
        let (header, skipFirst) = try getHeader(line: first, opts: opts)
        
        switch skipFirst {
        
        case true:
            
            return try CSV(stored: input.dropFirst().map{try self.decode(Row.self,
                                                                 from: (header, $0))})
            
        case false:
            
            return try CSV(stored: input.map{try self.decode(Row.self,
                                                                 from: (header, $0))})
        
        }
        
    }
    
}

fileprivate func getHeader(line: [String.SubSequence],
                           opts: CSVDecoder.HeaderOptions) throws -> ([String : Int], Bool) {
    
    switch opts {
    
    case .assumeFirstLine:
        return (try inferHeader(from: line), true)
    case .override(headerToUse: let headerToUse, skipFirstLine: let skipFirstLine):
        return (headerToUse, skipFirstLine)
    case .mapHeader(let map):
        let outValue = try inferHeader(from: line)
        return try (map.mapValues(outValue.valueOrThrow),
                    true)
    }
    
}

fileprivate extension Dictionary {
    func valueOrThrow(key: Key) throws -> Value {
        switch self[key] {
        case .none:
            throw ValueNotFound(key: key)
        case .some(let value):
            return value
        }
    }
}

struct ValueNotFound<Key> : Error {
    let key : Key
}

fileprivate func inferHeader(from line: [String.SubSequence]) throws -> [String : Int] {
    try [String : Int](line.enumerated().lazy.map{(String($0.element), $0.offset)})
    {old, new in throw KeysNotUnique(idx1: old,
                                     idx2: new,
                                     sharedValue: String(line[old]))}
}
 

struct KeysNotUnique : Error {
    let idx1 : Int
    let idx2: Int
    let sharedValue : String
}

#if canImport(Combine)
import Combine
extension CSVEncoder : TopLevelEncoder{}
extension CSVDecoder : TopLevelDecoder{}
#endif
