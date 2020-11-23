//
//  Encoder.swift
//  
//
//  Created by Markus Pfeifer on 21.11.20.
//

import Foundation

fileprivate class Output {
    
    var keys : [String : Int] = [:]
    var values : [String] = []
    
    func insert(value: String,
                for key: CodingKey?,
                codingPath: [CodingKey],
                options: CSVParsingOptions) throws {
        
        let key = (key.map{k in (codingPath + [k])} ?? codingPath).map(\.stringValue)
            .joined(separator: options.keySeparator)
        
        if keys[key] != nil {
            throw EncodingError.invalidValue(key, .init(codingPath: codingPath,
                                                        debugDescription: "Attempted to store the value twice."))
        }
        else {
            keys[key] = values.count
            values.append(value)
        }
    }
    
}

struct CSVContainerEncoder : Encoder {
    
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    fileprivate let result : Output
    let options : CSVParsingOptions
    
    init(userInfo: [CodingUserInfoKey : Any],
         options: CSVParsingOptions) {
        self.codingPath = []
        self.userInfo = userInfo
        self.result = Output()
        self.options = options
    }
    
    fileprivate init(codingPath: [CodingKey],
         userInfo: [CodingUserInfoKey : Any],
         result: Output,
         options: CSVParsingOptions) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.result = result
        self.options = options
    }
    
    func getData() throws -> (keys: [String : Int], values: [String]){
        (result.keys, result.values)
    }
    
    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        KeyedEncodingContainer(KeyedCSVEncodingContainer(encoder: self))
    }
    
    func unkeyedContainer() -> UnkeyedEncodingContainer {
        UnkeyedCSVEncodingContainer(encoder: self)
    }
    
    func singleValueContainer() -> SingleValueEncodingContainer {
        SingleValueCSVEncodingContainer(encoder: self)
    }
    
}


fileprivate struct SingleValueCSVEncodingContainer : SingleValueEncodingContainer {
    
    let encoder : CSVContainerEncoder
    var codingPath: [CodingKey]{
        encoder.codingPath
    }
    var options : CSVParsingOptions{
        encoder.options
    }
    
    mutating func insert(value: String) throws {
        try encoder.result.insert(value: value,
                              for: nil,
                              codingPath: codingPath,
                              options: options)
    }
    
    mutating func encodeNil() throws {
        try insert(value: options.nilSymbol)
    }
    
    mutating func encode(_ value: Bool) throws {
        try insert(value: "\(value)")
    }
    
    mutating func encode(_ value: String) throws {
        try insert(value: value)
    }
    
    mutating func encode(_ value: Double) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Float) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Int) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Int8) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Int16) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Int32) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Int64) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: UInt) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: UInt8) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: UInt16) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: UInt32) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: UInt64) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        try value.encode(to: encoder)
    }
    
    
}


fileprivate struct KeyedCSVEncodingContainer<Key : CodingKey> : KeyedEncodingContainerProtocol {
    
    let encoder : CSVContainerEncoder
    
    var codingPath: [CodingKey] {
        encoder.codingPath
    }
    
    var output : Output {
        encoder.result
    }
    
    var options : CSVParsingOptions {
        encoder.options
    }
    
    mutating func insert(value: String, for key: Key) throws {
        try output.insert(value: value, for: key, codingPath: codingPath, options: options)
    }
    
    mutating func encodeNil(forKey key: Key) throws {
        try insert(value: options.nilSymbol, for: key)
    }
    
    mutating func encode(_ value: Bool, forKey key: Key) throws {
        try insert(value: "\(value)", for: key)
    }
    
    mutating func encode(_ value: String, forKey key: Key) throws {
        try insert(value: value, for: key)
    }
    
    mutating func encode(_ value: Double, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode(_ value: Float, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode(_ value: Int, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode(_ value: Int8, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode(_ value: Int16, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode(_ value: Int32, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode(_ value: Int64, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode(_ value: UInt, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode(_ value: UInt8, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode(_ value: UInt16, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode(_ value: UInt32, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode(_ value: UInt64, forKey key: Key) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string, for: key)
    }
    
    mutating func encode<T>(_ value: T, forKey key: Key) throws where T : Encodable {
        try value.encode(to: CSVContainerEncoder(codingPath: codingPath + [key],
                                                 userInfo: encoder.userInfo,
                                                 result: output,
                                                 options: options))
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: Key) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedEncodingContainer(
            KeyedCSVEncodingContainer<NestedKey>(encoder: CSVContainerEncoder(
                                                    codingPath: codingPath + [key],
                                                    userInfo: encoder.userInfo,
                                                    result: output,
                                                    options: options)))
    }
    
    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        let path = codingPath + [key]
        return UnkeyedCSVEncodingContainer(encoder: CSVContainerEncoder(codingPath: path,
                                                                 userInfo: encoder.userInfo,
                                                                 result: output,
                                                                 options: options))
    }
    
    mutating func superEncoder() -> Encoder {
        encoder
    }
    
    mutating func superEncoder(forKey key: Key) -> Encoder {
        encoder
    }
    
}


struct UnkeyedCSVEncodingContainer : UnkeyedEncodingContainer {
    
    var count: Int = 0
    var codingPath : [CodingKey] {
        encoder.codingPath
    }
    
    let encoder : CSVContainerEncoder
    
    init(encoder: CSVContainerEncoder) {
        self.encoder = encoder
    }
    
    var options : CSVParsingOptions {
        encoder.options
    }
    
    private struct IndexKey : CodingKey {
        
        var intValue: Int?
        var stringValue: String{
            intValue!.description
        }
        
        init?(stringValue: String) {
            fatalError()
        }
        
        init?(intValue: Int) {
            fatalError()
        }
        
        init(intValue: inout Int) {
            self.intValue = intValue
            intValue += 1
        }
        
    }
    
    mutating func insert(value: String) throws {
        try encoder.result.insert(value: value,
                                  for: IndexKey(intValue: &count),
                                  codingPath: codingPath,
                                  options: options)
    }
    
    mutating func encodeNil() throws {
        try insert(value: options.nilSymbol)
    }
    
    mutating func encode(_ value: String) throws {
        try insert(value: value)
    }
    
    mutating func encode(_ value: Double) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Float) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Int) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Int8) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Int16) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Int32) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: Int64) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: UInt) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: UInt8) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: UInt16) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: UInt32) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode(_ value: UInt64) throws {
        guard let string = options.numberFormatter.string(from: NSNumber(value: value)) else {
            throw InvalidNumber(number: value, formatter: options.numberFormatter)
        }
        try insert(value: string)
    }
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        try value
            .encode(to: CSVContainerEncoder(codingPath: codingPath + [IndexKey(intValue: &count)],
                                            userInfo: encoder.userInfo,
                                            result: encoder.result,
                                            options: options))
    }
    
    mutating func encode(_ value: Bool) throws {
        try insert(value: "\(value)")
    }
    
    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedEncodingContainer(
            KeyedCSVEncodingContainer(
                encoder: CSVContainerEncoder(codingPath: codingPath + [IndexKey(intValue: &count)],
                                             userInfo: encoder.userInfo,
                                             result: encoder.result,
                                             options: options)))
    }
    
    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let codingPath = self.codingPath + [IndexKey(intValue: &count)]
        return Self(encoder: CSVContainerEncoder(codingPath: codingPath,
                                                 userInfo: encoder.userInfo,
                                                 result: encoder.result,
                                                 options: options))
    }
    
    mutating func superEncoder() -> Encoder {
        encoder
    }
    
    
}
