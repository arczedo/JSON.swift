//
//  File.swift
//  
//
//  Created by Z on 6/22/20.
//

import Foundation
import FoundationPlus


public let __je: JSONEncoder = {
    JSONEncoder() <- {$0.outputFormatting = .prettyPrinted}
}()

public extension Encodable {
    func js() throws -> String {
        try JSON.prettyPrinted(self)
    }
}

public enum JSONType {
    case array
    case dictionary
    case number
    case bool
    case string
    case unknown
}

public class JSON: NSObject {

    var object: Any

    public override init() {
        object = NSObject()
        super.init()
    }

    public convenience init?(string: String) {
        guard let data = string.data(using: .utf8) else { return nil }
        self.init(data:  data)
    }

    public init(_ object: Any) {
        self.object = object
        super.init()
    }

    public convenience init?(data: Data, options opt: JSONSerialization.ReadingOptions = .allowFragments) {
        if let object = try? JSONSerialization.jsonObject(with: data, options: opt) {
            self.init(object)
        } else {
            return nil
        }
    }

    public var jsonType: JSONType {
        var t = JSONType.unknown
        switch object {
        case is [String: Any]:
            t = .dictionary
        case is [Any]:
            t = .array
        case is String:
            t = .string
        case let n as NSNumber:
            if String(describing: type(of: n)) == "__NSCFBoolean" {
                t = .bool
            } else {
                t = .number
            }
        default:
            t = .unknown
        }
        return t
    }

    public var string: String? {
        get {
            return object as? String
        }
    }

    public var number: NSNumber? {
        get {
            return object as? NSNumber
        }
    }

    public var bool: Bool? {
        get {
            if let bool = number, String(describing: type(of: bool)) == "__NSCFBoolean" {
                return bool.boolValue
            }
            return nil
        }
    }

    public var array: [JSON]? {
        get {
            return (object as? [ Any ])?.map{ JSON($0) }
        }
    }

    public var dictionary: [String: JSON]? {
        get {
            if let dict = object as? [String: Any] {
                var t = [String: JSON](minimumCapacity: dict.count)
                for (key, obj) in dict {
                    t[key] = JSON(obj)
                }
                return t
            }
            return nil
        }
    }

    public subscript(index: Int) -> JSON? {
        get {
            if let a = array {
                if index >= 0 && index < a.count {
                    return a[index]
                }
            }
            return nil
        }
    }

    public subscript(index: String) -> JSON? {
        get {
            if let h = dictionary {
                return h[index]
            }
            return nil
        }
    }

    public subscript(index: String...) -> Any {
        get {
            fatalError()
        }
        set {
            guard let dictionaryObj = object as? [String: Any] else { return }
            var me = dictionaryObj
            do {
                let a = try (index <- {_ = $0.popLast()}).reduce(into: [[String: Any]](), {r,x in
                    if let sub = me[x] {
                        if let dictionary = sub as? [String: Any] {
                            r.append(dictionary)
                            me = dictionary
                        } else {
                            throw NSError()
                        }
                    } else {
                        r.append([:])
                        me = [:]
                    }
                })
                var rr = Array(zip(["_"] + index, [dictionaryObj] + a + [newValue]))
                var last = rr.popLast()!

                rr.reversed().forEach{ x in
                    var t = x.1 as! [String: Any]
                    t[last.0] = last.1
                    last = (x.0, t)
                }
                object = last.1
            } catch {
                /// skipping reduce
            }
        }
    }

    public func jsonData(_ pretty: Bool = false) -> Data? {
        if JSONSerialization.isValidJSONObject(object) {
            return try? JSONSerialization.data(withJSONObject: object, options: pretty ? .prettyPrinted : [])
        }
        return nil
    }

    public func prettyPrinted() -> String? {
        if let d = jsonData(true) {
            return String(data: d, encoding: .utf8)
        }
        return nil
    }

    public override var description: String {
        return prettyPrinted() ?? describingBool()
    }

    public func describingBool() -> String {
        if let b = bool {
            return String(describing: b)
        }
        return String(describing: object)
    }


    public static func make<T: Codable>(fromAny payload: Any) throws -> T {
        try make(fromData: try JSONSerialization.data(withJSONObject: payload, options: []))
    }

    public static func make<T: Codable>(fromData data: Data) throws -> T {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return try decoder.decode(T.self, from: data)
    }

    public static func makeData<T: Codable>(from value: T) throws -> Data {
        try JSONEncoder().encode(value)
    }

    public static func makeJSONObject<T: Codable>(from value: T) throws -> Any {
        JSON(data: try JSONEncoder().encode(value))!.object
    }

    public static func prettyPrinted<T: Encodable>(_ value: T) throws -> String {
        String(data: try __je.encode(value), encoding: .utf8)!
    }

    public static func prettyFormatted(_ data: Data) -> String? {
        (try? JSONSerialization.jsonObject(with: data, options: .allowFragments))
            .flatMap{try? JSONSerialization.data(withJSONObject: $0, options: .prettyPrinted)}
            .flatMap{String(data: $0, encoding: .utf8)}
    }

    public var dictionaryObject: [String: Any]? {
        object as? [String: Any]
    }

}


public func JSONObjectOrNull(object: Any?, dataFormat: String = "yyyy-MM-dd") -> AnyObject {
    if let obj = object {
        switch obj {
        case let data as NSData:
            if let string = String(data: data as Data, encoding: .utf8) {
                return string as AnyObject
            } else {
                return data.base64EncodedString(options: NSData.Base64EncodingOptions()) as AnyObject
            }
        case let date as NSDate:
            return NSNumber(floatLiteral: date.timeIntervalSince1970)
        case let n as NSNumber:
            return n
        case let s as NSString:
            return s
        case let s as String:
            return s as AnyObject
        case let a as [AnyObject?]:
            var ta = [AnyObject]()
            for x in a {
                ta.append(JSONObjectOrNull(object: x))
            }
            return ta as AnyObject
        case let h as [String: Any?]:
            var td = [String: AnyObject]()
            for (k, v) in h {
                td[k] = JSONObjectOrNull(object: v)
            }
            return td as AnyObject
        default:
            //debugger.po("Invalid JSON object in JSONObjectOrNull(\(obj)), returning null")
            return NSNull()
        }
    }
    return NSNull()
}
