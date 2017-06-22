//
//  SwiftExtension.swift
//  PikeWay
//
//  Created by YHIOS003 on 2016/11/24.
//  Copyright © 2016年 YHSoft. All rights reserved.
//

import UIKit

public func YHPrint(_ item: Any...) {
    #if DEBUG
        print(item)
    #endif
}

public struct NilError: Error, CustomStringConvertible {
    private let _description: String
    public var description: String { return _description }
    public init(file: String, line: Int) {
        _description = "Nil returned at " + (file as NSString).lastPathComponent + ":\(line)"
    }
}

extension Optional {
    public func unwrap(file: String = #file, line: Int = #line) throws -> Wrapped {
        guard let unwrapped = self else { throw NilError(file: file, line: line) }
        return unwrapped
    }
}

extension UIView {
    
//    var height: CGFloat {
//        get {
//            return frame.size.height
//        }
//        set {
//            frame.size.height = newValue
//        }
//    }
//    
//    var width: CGFloat {
//        get {
//            return frame.size.width
//        }
//        set {
//            frame.size.width = newValue
//        }
//    }
    
    var x: CGFloat {
        get {
            return frame.origin.x
        }
        set {
            frame.origin.x = newValue
        }
    }
    
    var y: CGFloat {
        get {
            return frame.origin.y
        }
        set {
            frame.origin.y = newValue
        }
    }
    
    var maxX: CGFloat {
        get {
            return frame.origin.x + frame.size.width
        }
    }
    
    var maxY: CGFloat {
        get {
            return frame.origin.y + frame.size.height
        }
    }

}

extension UIView {
    func addSubviews(_ views: UIView...) {
        for view in views {
            addSubview(view)
        }
    }
}

extension UIView {
    func addConstrainsWithFormat(_ format: String, views: UIView...) {
        var viewDic = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewDic[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewDic))
    }
}

extension UIColor {
    //用数值初始化颜色，便于生成设计图上标明的十六进制颜色
    convenience init(valueRGB: UInt) {
        self.init(
            red: CGFloat((valueRGB & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((valueRGB & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(valueRGB & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}

extension UIColor {
    class func colorWithHexString(hex:String) ->UIColor {
        return colorWithHexString(hex: hex, alpha: 1)
    }
}

extension UIColor {
    class func colorWithHexString(hex:String,alpha:CGFloat) ->UIColor {
        
        var cString = hex.trimmingCharacters(in:CharacterSet.whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            let index = cString.index(cString.startIndex, offsetBy:1)
            cString = cString.substring(from: index)
        }
        
        if (cString.characters.count != 6) {
            return UIColor.red
        }
        
        let rIndex = cString.index(cString.startIndex, offsetBy: 2)
        let rString = cString.substring(to: rIndex)
        let otherString = cString.substring(from: rIndex)
        let gIndex = otherString.index(otherString.startIndex, offsetBy: 2)
        let gString = otherString.substring(to: gIndex)
        let bIndex = cString.index(cString.endIndex, offsetBy: -2)
        let bString = cString.substring(from: bIndex)
        
        var r:CUnsignedInt = 0, g:CUnsignedInt = 0, b:CUnsignedInt = 0;
        Scanner(string: rString).scanHexInt32(&r)
        Scanner(string: gString).scanHexInt32(&g)
        Scanner(string: bString).scanHexInt32(&b)
        
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(alpha))
    }
}



extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var result: Set<Iterator.Element> = []
        
        return filter {
            if result.contains($0) {
                return false
            }
            else {
                result.insert($0)
                return true
            }
        }
    }
}


protocol Reusable: class {
    static var reuseIdentifier: String { get }
}

extension Reusable {
    static var reuseIdentifier: String {
        // 我喜欢使用类名来作为标识符
        // 所以这里可以用类名返回一个默认值
        return String(describing: self)
    }
}

func delay(_ i: CGFloat, _ closure: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + TimeInterval(i), execute: closure)
}

func doInMainThread(_ closure: @escaping () -> Void ){
    DispatchQueue.main.async {
        closure()
    }
}

func doInGlobalThread(_ closure: @escaping () -> Void ){
    DispatchQueue.global().async {
        closure()
    }
}

enum WebViewRequestState {
    case initial
    case loading
    case success
    case fail
}

//struct KeyPath {
//    var segments: [String]
//    
//    var isEmpty: Bool { return segments.isEmpty }
//    var path: String {
//        return segments.joined(separator: ".")
//    }
//    
//    /// Strips off the first segment and returns a pair
//    /// consisting of the first segment and the remaining key path.
//    /// Returns nil if the key path has no segments.
//    func headAndTail() -> (head: String, tail: KeyPath)? {
//        guard !isEmpty else { return nil }
//        var tail = segments
//        let head = tail.removeFirst()
//        return (head, KeyPath(segments: tail))
//    }
//}
//
///// Initializes a KeyPath with a string of the form "this.is.a.keypath"
//extension KeyPath {
//    init(_ string: String) {
//        segments = string.components(separatedBy: ".")
//    }
//}
//
//extension KeyPath: ExpressibleByStringLiteral {
//    init(stringLiteral value: String) {
//        self.init(value)
//    }
//    init(unicodeScalarLiteral value: String) {
//        self.init(value)
//    }
//    init(extendedGraphemeClusterLiteral value: String) {
//        self.init(value)
//    }
//}
//
//// Needed because Swift 3.0 doesn't support extensions with concrete
//// same-type requirements (extension Dictionary where Key == String).
//protocol StringProtocol {
//    init(string s: String)
//}
//
//extension String: StringProtocol {
//    init(string s: String) {
//        self = s
//    }
//}
//
//extension Dictionary where Key: StringProtocol {
//    subscript(keyPath keyPath: KeyPath) -> Any? {
//        get {
//            switch keyPath.headAndTail() {
//            case nil:
//                // key path is empty.
//                return nil
//            case let (head, remainingKeyPath)? where remainingKeyPath.isEmpty:
//                // Reached the end of the key path.
//                let key = Key(string: head)
//                return self[key]
//            case let (head, remainingKeyPath)?:
//                // Key path has a tail we need to traverse.
//                let key = Key(string: head)
//                switch self[key] {
//                case let nestedDict as [Key: Any]:
//                    // Next nest level is a dictionary.
//                    // Start over with remaining key path.
//                    return nestedDict[keyPath: remainingKeyPath]
//                default:
//                    // Next nest level isn't a dictionary.
//                    // Invalid key path, abort.
//                    return nil
//                }
//            }
//        }
//        set {
//            switch keyPath.headAndTail() {
//            case nil:
//                // key path is empty.
//                return
//            case let (head, remainingKeyPath)? where remainingKeyPath.isEmpty:
//                // Reached the end of the key path.
//                let key = Key(string: head)
//                self[key] = newValue as? Value
//            case let (head, remainingKeyPath)?:
//                let key = Key(string: head)
//                let value = self[key]
//                switch value {
//                case var nestedDict as [Key: Any]:
//                    // Key path has a tail we need to traverse
//                    nestedDict[keyPath: remainingKeyPath] = newValue
//                    self[key] = nestedDict as? Value
//                default:
//                    // Invalid keyPath
//                    return
//                }
//            }
//        }
//    }
//}
//
//extension Dictionary where Key: StringProtocol {
//    subscript(string keyPath: KeyPath) -> String? {
//        get { return self[keyPath: keyPath] as? String }
//        set { self[keyPath: keyPath] = newValue }
//    }
//    
//    subscript(dict keyPath: KeyPath) -> [Key: Any]? {
//        get { return self[keyPath: keyPath] as? [Key: Any] }
//        set { self[keyPath: keyPath] = newValue }
//    }
//}
