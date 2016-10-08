//
//  Utils.swift
//  Terrain
//
//  Created by Vivek Nagar on 10/7/16.
//  Copyright © 2016 Vivek Nagar. All rights reserved.
//

import SceneKit

#if os(iOS)
    typealias TerrainColor=UIColor
    typealias GameImage=UIImage
#elseif os(OSX)
    typealias TerrainColor=NSColor
    typealias GameImage=NSImage
#endif
    
enum KeyboardDirection : UInt16 {
    case left   = 123
    case right  = 124
    case down   = 125
    case up     = 126
    
    var vector : float2 {
        switch self {
        case .up:    return float2( 0, 1)
        case .down:  return float2( 0, -1)
        case .left:  return float2(1,  0)
        case .right: return float2(-1,  0)
        }
    }
}

struct Pixel {
    var r: Float
    var g: Float
    var b: Float
    var a: Float
    var row: Int
    var col: Int
    
    init(r: UInt8, g: UInt8, b: UInt8, a: UInt8, row: Int, col: Int) {
        self.r = Float(r)
        self.g = Float(g)
        self.b = Float(b)
        self.a = Float(a)
        self.row = row
        self.col = col
    }
    
    var color: TerrainColor {
        return TerrainColor(red: CGFloat(r/255.0), green: CGFloat(g/255.0), blue: CGFloat(b/255.0), alpha: CGFloat(a/255.0))
    }
    
    var description: String {
        return "RGBA(\(r), \(g), \(b), \(a))"
    }
    
    var intensity:CGFloat {
        return CGFloat(r)/255.0
    }
}

#if os(OSX)
    extension NSImage {
        func pixelData() -> [[Pixel]] {
            let bmp = self.representations[0] as! NSBitmapImageRep
            var data: UnsafeMutablePointer<UInt8> = bmp.bitmapData!
            var r, g, b, a: UInt8
            var pixels: [[Pixel]] = Array(repeating: Array(repeating: Pixel(r:0, g:0, b:0, a:0, row:0, col:0), count: bmp.pixelsHigh+1), count: bmp.pixelsWide+1)
            
            for row in 0..<bmp.pixelsHigh {
                for col in 0..<bmp.pixelsWide {
                    r = data.pointee
                    data = data.advanced(by:1)
                    g = data.pointee
                    data = data.advanced(by:1)
                    b = data.pointee
                    data = data.advanced(by:1)
                    a = data.pointee
                    data = data.advanced(by:1)
                    pixels[row][col] = Pixel(r: r, g: g, b: b, a: a, row:row, col:col)
                }
            }
            return pixels
        }
    }

#else
    extension UIImage {
        func pixelData() -> [[Pixel]] {
            guard let pixelData = self.cgImage!.dataProvider!.data else {
                print("ERROR reading pixel data")
                return [[Pixel]]()
            }
            let data = CFDataGetBytePtr(pixelData)!
            var pixels: [[Pixel]] = Array(repeating: Array(repeating: Pixel(r:0, g:0, b:0, a:0, row:0, col:0), count: Int(self.size.height)), count: Int(self.size.width))
            
            for row in 0..<Int(self.size.height) {
                for col in 0..<Int(self.size.width) {
                    let index = Int(self.size.width) * row + col
                    let expectedLengthA = Int(self.size.width * self.size.height)
                    let expectedLengthRGB = 3 * expectedLengthA
                    let expectedLengthRGBA = 4 * expectedLengthA
                    let numBytes = CFDataGetLength(pixelData)
                    switch numBytes {
                    case expectedLengthA:
                        pixels[row][col] = Pixel(r: 0, g: 0, b: 0, a:UInt8(data[index]), row:row, col:col)
                    case expectedLengthRGB:
                        pixels[row][col] = Pixel(r:UInt8(data[3*index]), g: UInt8(data[3*index+1]), b: UInt8(data[3*index+2]), a: 255, row:row, col:col)
                    case expectedLengthRGBA:
                        //This should be the right one
                        pixels[row][col] = Pixel(r: UInt8(data[4*index]), g: UInt8(data[4*index+1]), b:UInt8(data[4*index+2]) , a: UInt8(data[4*index+3]), row:row, col:col)
                        
                    default:
                        pixels[row][col] = Pixel(r: 0, g: 0, b: 0, a: 0, row:row, col:col)
                    }
                }
            }
            return pixels
        }
    }
#endif

extension SCNVector3 {
    func normalize() -> SCNVector3 {
        let len = sqrt(pow(self.x, 2) + pow(self.y, 2) + pow(self.z, 2))
        
        return SCNVector3Make(self.x/len, self.y/len, self.z/len)
    }

}

class Utils {
    static func crossProduct(a:SCNVector3, b:SCNVector3) -> SCNVector3 {
        return SCNVector3Make(a.y*b.z - a.z*b.y, a.z*b.x - a.x*b.z, a.x*b.y - a.y*b.x);
    }
    
    static func vectorSubtract(a:SCNVector3, b:SCNVector3) -> SCNVector3 {
        return SCNVector3Make(a.x-b.x, a.y-b.y, a.z-b.z);
    }

}

