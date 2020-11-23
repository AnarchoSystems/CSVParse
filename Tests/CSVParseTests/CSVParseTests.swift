import XCTest
@testable import CSVParse

final class CSVParseTests: XCTestCase {
    func testExample() {
        
        let encoder = CSVEncoder(options: CSVParsingOptions(keySeparator: " - "))
        let decoder = CSVDecoder()
        
        let csv = "a1,a2,a3\n1,2,3\n4,5,6\n7,8,9"
        
        guard let parsed = try? decoder.decode(rowType: FooBarBaz.self,
                                               from: csv) else {
            return XCTFail()
        }
        
        guard let string = try? encoder.encode(csv: parsed) else {
            return XCTFail()
        }
        
        XCTAssertEqual(csv, string)
        
        guard let parsed2 = try? decoder.decode(rowType: FooBarBaz.self,
                                                from: csv)
                .formula(key: "a2^2", {$0.a2 * $0.a2}) else {
            return XCTFail()
        }
        
        guard let string2 = try? encoder.encode(csv: parsed2) else {
            return XCTFail()
        }
        
        XCTAssertEqual(string2,
                       "a1,a2,a3,a2^2\n1,2,3,4\n4,5,6,25\n7,8,9,64")
        
    }

    static var allTests = [
        ("testExample", testExample),
    ]
}


struct FooBarBaz : Codable {
    
    let a1 : Int
    let a2 : Int
    let a3 : Int
    
}
