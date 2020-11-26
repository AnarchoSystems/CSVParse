import XCTest
@testable import CSVParse

final class CSVParseTests: XCTestCase {
    
    let testCSV = "a1,a2,a3\n1,2,3\n4,5,6\n7,8,9"
    
    let encoder = CSVEncoder()
    let decoder = CSVDecoder()
    
    func testEncodeDecodeEquality() {
        
        guard let parsed = try? decoder.decode(rowType: FooBarBaz.self,
                                               from: testCSV) else {
            return XCTFail()
        }
        
        guard let string = try? encoder.encode(csv: parsed) else {
            return XCTFail()
        }
        
        XCTAssertEqual(testCSV, string)
        
    }
        
    func testFormulaRepresentation() {
    
        guard let parsed2 = try? decoder.decode(rowType: FooBarBaz.self,
                                                from: testCSV)
                .formula(key: "a2^2", {$0.a2 * $0.a2}) else {
            return XCTFail()
        }
        
        guard let string2 = try? encoder.encode(csv: parsed2) else {
            return XCTFail()
        }
        
        XCTAssertEqual(string2,
                       "a1,a2,a3,a2^2\n1,2,3,4\n4,5,6,25\n7,8,9,64")
        
    }
    
    func testKeySeparation() {
        
        struct Foo : Codable, Equatable {
            let foo : Bar
        }
        struct Bar : Codable, Equatable {
            let bar : Int
        }
        
        let opts = CSVParsingOptions(keySeparator: " - ")
        
        let encoder = CSVEncoder(options: opts)
        let decoder = CSVDecoder(options: opts)
        
        let typed : CSV = [Foo(foo: Bar(bar: 42))]
        
        guard let csv = try? encoder.encode(csv: typed) else {
            return XCTFail()
        }
        
        XCTAssertEqual(csv, "foo - bar\n42")
        
        guard let decoded = try? decoder.decode(rowType: Foo.self, from: csv) else {
            return XCTFail()
        }
        
        XCTAssertEqual(typed, decoded)
        
    }

    static var allTests = [
        ("testEncodeDecodeEquality", testEncodeDecodeEquality),
        ("testFormulaRepresentation", testFormulaRepresentation),
    ]
}


struct FooBarBaz : Codable {
    
    let a1 : Int
    let a2 : Int
    let a3 : Int
    
}
