//
//  Decoder.swift
//  
//
//  Created by Markus Pfeifer on 21.11.20.
//

import Foundation


@usableFromInline
func splitString<S : StringProtocol>(_ separator: Character) -> (S) -> [S.SubSequence] {
    
    {(s : S) in
        s.split(separator: separator)
    }
}

fileprivate struct Input {
    
    let keys : [String : Int]
    let values : [String.SubSequence]
    
    func string(codingPath: [CodingKey],
                keySeparator: String) throws -> String.SubSequence {
        let theKey = (codingPath).map(\.stringValue).joined(separator: keySeparator)
        guard let intKey = keys[theKey] else {
            guard let key = codingPath.last else {
                throw DecodingError.dataCorrupted(.init(codingPath: codingPath,
                                                        debugDescription: "No values!"))
            }
            throw DecodingError.keyNotFound(key, .init(codingPath: codingPath,
                                                       debugDescription: "\(key) not found."))
        }
        return values[intKey]
    }
    
}

struct CSVContainerDecoder : Decoder {
    
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey : Any]
    let opts: CSVParsingOptions
    
    fileprivate let input : Input
    
    init (input: (keys: [String : Int],
                  values: [String.SubSequence]),
          opts: CSVParsingOptions,
          userInfo: [CodingUserInfoKey : Any],
          codingPath: [CodingKey]) {
        self.opts = opts
        self.input = Input(keys: input.keys, values: input.values)
        self.userInfo = userInfo
        self.codingPath = codingPath
    }
    
    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        KeyedDecodingContainer(KeyedCSVDecodingContainer(decoder: self))
    }
    
    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        throw NotImplemented()
    }
    
    func singleValueContainer() throws -> SingleValueDecodingContainer {
        SingleValueCSVContainer(decoder: self)
    }
    
    
}


fileprivate struct KeyedCSVDecodingContainer<Key : CodingKey> : KeyedDecodingContainerProtocol {
    
    let decoder : CSVContainerDecoder
    
    var codingPath: [CodingKey]{
        decoder.codingPath
    }
    var input : Input{
        decoder.input
    }
    var options : CSVParsingOptions{
        decoder.opts
    }
    var userInfo : [CodingUserInfoKey : Any]{
        decoder.userInfo
    }
  
    var allKeys: [Key] {
        input.keys.keys.compactMap{Key(stringValue: $0) ?? options.numberFormatter.number(from: $0).flatMap{Key(intValue: $0.intValue)}}
    }
    
    func string(for key: Key) throws -> String.SubSequence {
        try input.string(codingPath: codingPath + [key], keySeparator: options.keySeparator)
    }
    
    func contains(_ key: Key) -> Bool {
        input.keys.keys.contains(where: {key.stringValue == $0})
    }
    
    func decodeNil(forKey key: Key) throws -> Bool {
        let value = try string(for: key)
        return String(value) == options.nilSymbol
    }
    
    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        let value = try string(for: key)
        if let bool = Bool(String(value)){
            return bool
        }
        else {
            throw DecodingError.typeMismatch(Bool.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not a bool."))
        }
    }
    
    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        return try String(string(for: key))
    }
    
    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        let value = try string(for: key)
        if let value = Double(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(Double.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not a double."))
        }
    }
    
    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        let value = try string(for: key)
        if let value = Float(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(Float.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not a float."))
        }
    }
    
    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        let value = try string(for: key)
        if let value = Int(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(Int.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not an integer."))
        }
    }
    
    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        let value = try string(for: key)
        if let value = Int8(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(Int8.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not an Int8."))
        }
    }
    
    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        let value = try string(for: key)
        if let value = Int16(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(Int16.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not an Int16."))
        }
    }
    
    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        let value = try string(for: key)
        if let value = Int32(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(Int32.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not an Int32."))
        }
    }
    
    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        let value = try string(for: key)
        if let value = Int64(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(Int64.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not an Int64."))
        }
    }
    
    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        let value = try string(for: key)
        if let value = UInt(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(UInt.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not an UInt."))
        }
    }
    
    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        let value = try string(for: key)
        if let value = UInt8(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(UInt8.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not an UInt8."))
        }
    }
    
    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        let value = try string(for: key)
        if let value = UInt16(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(UInt16.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not an UInt16."))
        }
    }
    
    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        let value = try string(for: key)
        if let value = UInt32(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(UInt32.self,
                                             .init(codingPath: codingPath,
                                                    debugDescription: "\(value) is not an UInt32."))
        }
    }
    
    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        let value = try string(for: key)
        if let value = UInt64(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(UInt64.self,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not an UInt64."))
        }
    }
    
    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        try T(from: CSVContainerDecoder(input: (input.keys, input.values),
                                        opts: options,
                                        userInfo: userInfo,
                                        codingPath: codingPath + [key]))
    }
    
    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        KeyedDecodingContainer(KeyedCSVDecodingContainer<NestedKey>(
                                decoder: CSVContainerDecoder(input: (input.keys, input.values),
                                                             opts: options,
                                                             userInfo: userInfo,
                                                             codingPath: codingPath + [key])))
    }
    
    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        throw NotImplemented()
    }
    
    func superDecoder() throws -> Decoder {
        CSVContainerDecoder(input: (input.keys, input.values),
                            opts: options,
                            userInfo: userInfo,
                            codingPath: codingPath)
    }
    
    func superDecoder(forKey key: Key) throws -> Decoder {
        CSVContainerDecoder(input: (input.keys, input.values),
                            opts: options,
                            userInfo: userInfo,
                            codingPath: codingPath)
    }
    
    
}


public struct NotImplemented : Error {}


fileprivate struct SingleValueCSVContainer : SingleValueDecodingContainer {
    
    let decoder : CSVContainerDecoder
    
    var input : Input {
        decoder.input
    }
    
    var codingPath: [CodingKey]{
        decoder.codingPath
    }
    
    var options : CSVParsingOptions {
        decoder.opts
    }
    
    func getString() throws -> String {
        try String(input.string(codingPath: codingPath, keySeparator: options.keySeparator))
    }
    
    func decodeNil() -> Bool {
        guard let value = try? getString() else {
            return false
        }
        return value == options.nilSymbol
    }
    
    func decode(_ type: Bool.Type) throws -> Bool {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: String.Type) throws -> String {
        try getString()
    }
    
    func decode(_ type: Double.Type) throws -> Double {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: Float.Type) throws -> Float {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: Int.Type) throws -> Int {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: Int8.Type) throws -> Int8 {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: Int16.Type) throws -> Int16 {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: Int32.Type) throws -> Int32 {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: Int64.Type) throws -> Int64 {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: UInt.Type) throws -> UInt {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: UInt8.Type) throws -> UInt8 {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: UInt16.Type) throws -> UInt16 {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: UInt32.Type) throws -> UInt32 {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode(_ type: UInt64.Type) throws -> UInt64 {
        let value = try getString()
        if let value = type.init(String(value)){
            return value
        }
        else {
            throw DecodingError.typeMismatch(type,
                                             .init(codingPath: codingPath,
                                                   debugDescription: "\(value) is not a(n) \(String(describing: type))."))
        }
    }
    
    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try T(from: decoder)
    }
    
    
}
