//
//  JSONCodable.swift
//  DAData
//
//  Created by Z on 1/6/18.
//  Copyright © 2018 dczign. All rights reserved.
//

import Foundation
import FoundationPlus


public func ClassFromString(_ className: String) -> AnyClass? {
    let namespace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
    return NSClassFromString("\(namespace).\(className)")
}

public func JSONClassFromString(_ className: String) -> JSONCodable.Type? {
    return NSClassFromString(className) as? JSONCodable.Type
}

open class JSONCodable: NSObject {
    open func jsonKeyMap() -> [String: String]? {
        return nil
    }
    
    public override init() {
        super.init()
    }
    
    public required init(json: JSON) {
        super.init()
        
        sequence(first: (Mirror(reflecting: self), Swift.type(of: self))) { (m, t) -> (Mirror, AnyClass)? in
            if let mm = m.superclassMirror,
                let tt = t.superclass() {
                return (mm, tt)
            }
            return nil
            }.forEach { (mirror, klass) in
                for property in mirror.children {
                    guard let name = property.label else {
                        continue
                    }
                    
                    var jname = name
                    if let mapped = jsonKeyMap()?[name] {
                        jname = mapped
                    }
                    var type = String(describing: Swift.type(of: property.value))
                    type = String(type.suffix(type.count - 9).prefix(type.count - 10))
                    
                    if type.hasPrefix("Array<") {
                        let subtype = String(type.suffix(type.count - 6).prefix(type.count - 7))
                        if let a = json[jname]?.array {
                            
                            switch subtype {
                            case "String":
                                setValue(a.compactMap{$0.string}, forKey: name)
                            default:
                                let ta = a.compactMap({ json -> JSONCodable? in
                                    if let klass = JSONClassFromString(subtype)  {
                                        return klass.init(json: json)
                                    }
                                    return nil
                                })
                                setValue(ta, forKey: name)
                                
                            }
                        }
                        continue
                    }
                    
                    let pointer = Unmanaged.passUnretained(self).toOpaque()
                    switch type {
                    case "String":
                        setValue(json[jname]?.string, forKey: name)
                    case "NSNumber":
                        setValue(json[jname]?.number, forKey: name)
                    case "Bool":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<Bool>.self)
                            vp.pointee = json[jname]?.bool
                        }
                    case "Int":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<Int>.self)
                            vp.pointee = json[jname]?.number?.intValue
                        }
                    case "Int8":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<Int8>.self)
                            vp.pointee = json[jname]?.number?.int8Value
                        }
                    case "Int16":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<Int16>.self)
                            vp.pointee = json[jname]?.number?.int16Value
                        }
                    case "Int32":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<Int32>.self)
                            vp.pointee = json[jname]?.number?.int32Value
                        }
                    case "Int64":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<Int64>.self)
                            vp.pointee = json[jname]?.number?.int64Value
                        }
                    case "UInt8":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<UInt8>.self)
                            vp.pointee = json[jname]?.number?.uint8Value
                        }
                    case "UInt16":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<UInt16>.self)
                            vp.pointee = json[jname]?.number?.uint16Value
                        }
                    case "UInt32":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<UInt32>.self)
                            vp.pointee = json[jname]?.number?.uint32Value
                        }
                    case "UInt64":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<UInt64>.self)
                            vp.pointee = json[jname]?.number?.uint64Value
                        }
                    case "Float":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<Float>.self)
                            vp.pointee = json[jname]?.number?.floatValue
                        }
                    case "Double":
                        if let x = class_getInstanceVariable(klass, name) {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<Double>.self)
                            vp.pointee = json[jname]?.number?.doubleValue
                        }
                    case "CGFloat":
                        if let x = class_getInstanceVariable(klass, name),
                            let dbl = json[jname]?.number?.doubleValue {
                            let offset = ivar_getOffset(x)
                            let vp = (pointer + offset).assumingMemoryBound(to: Optional<CGFloat>.self)
                            vp.pointee =  CGFloat(dbl)
                        }
                    case "Date":
                        if let t = json[jname]?.number?.doubleValue {
                            setValue(Date(timeIntervalSince1970: t), forKey: name)
                        }
                    default:
                        if let klass = JSONClassFromString(type),
                            let j = json[jname] {
                            setValue(klass.init(json: j), forKey: name)
                        }
                    }
                }
        }
        
    }
    
    public func toJSON() -> JSON {
        return JSON(toStringAny())
    }
    
//    public func toJSON_ObjC() -> JSON {
//        return JSON(serializing2(Mirror(reflecting: self))
//    }
    
    func toStringAny() -> [String: Any] {
        return jsonSerializing(Mirror(reflecting: self))
    }
    
    // these likes NOT included: "key": nil
    func jsonSerializing(_ m: Mirror) -> [String: Any] {
        var h = [String: Any]()
        let r = m.children.makeIterator()
        while let child = r.next() {
            guard let name = child.label else {
                continue
            }
            var jname = name
            if let mapped = jsonKeyMap()?[name] {
                jname = mapped
            }

            var type = String(describing: Swift.type(of: child.value))
            type = String(type.suffix(type.count - 9).prefix(type.count - 10))
            
            if type.hasPrefix("Array<") {
                if let t = child.1 as? [JSONCodable] {
                    h[jname] = t.map({jsonSerializing(Mirror(reflecting: $0))})
                } else if let t = child.1 as? [String] {
                    h[jname] = t
                } else if let t = child.1 as? [NSNumber] {
                    h[jname] = t
                } else if let t = child.1 as? [Bool] {
                    h[jname] = t
                } else if let t = child.1 as? [Int] {
                    h[jname] = t
                } else if let t = child.1 as? [Int8] {
                    h[jname] = t
                } else if let t = child.1 as? [Int16] {
                    h[jname] = t
                } else if let t = child.1 as? [Int32] {
                    h[jname] = t
                } else if let t = child.1 as? [Int64] {
                    h[jname] = t
                } else if let t = child.1 as? [UInt] {
                    h[jname] = t
                } else if let t = child.1 as? [UInt8] {
                    h[jname] = t
                } else if let t = child.1 as? [UInt16] {
                    h[jname] = t
                } else if let t = child.1 as? [UInt32] {
                    h[jname] = t
                } else if let t = child.1 as? [UInt64] {
                    h[jname] = t
                } else if let t = child.1 as? [Float] {
                    h[jname] = t
                } else if let t = child.1 as? [Double] {
                    h[jname] = t
                } else if let t = child.1 as? [CGFloat] {
                    h[jname] = t
                } 
            } else {
                switch type {
                case "String", "NSNumber", "Bool",
                     "Int", "Int8", "Int16", "Int32", "Int64",
                     "UInt", "UInt8", "UInt16", "UInt32", "UInt64",
                     "Float", "Double", "CGFloat":
                    h[jname] = child.1
                case "Date":
                    if let t = child.1 as? Date {
                        h[jname] = t.timeIntervalSince1970
                    }
                default:
                    if let t = child.1 as? JSONCodable {
                        h[jname] = jsonSerializing(Mirror(reflecting: t))
                    }
                }
            }
        }
        if let mm = m.superclassMirror {
            h += jsonSerializing(mm)
        }
        return h
    }
    
    open override var description: String {
        if let data =  toJSON().jsonData(),
            let s = String(data: data, encoding: .utf8) {
            return s
        }
        return "Invalid JSON!"
    }
    
}

