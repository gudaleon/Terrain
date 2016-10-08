//
//  TerrainNode.swift
//  Terrain
//
//  Created by Vivek Nagar on 10/7/16.
//  Copyright © 2016 Vivek Nagar. All rights reserved.
//

import SceneKit
import SpriteKit

enum TerrainType: Int {
    case heightmap = 0
    case perlinnoise = 1
}
typealias TerrainFormula = ((Int32, Int32) -> (Double))

class TerrainNode: SCNNode, SCNProgramDelegate {
    private let rangeOne:float2
    private let rangeTwo:float2
    private let textureRepeatCount = float2(8, 8)

    let width:Int
    let depth:Int
    let type:TerrainType
    var pixels = [[Pixel]]()
    var formula: TerrainFormula?
    
    init(width: Int, depth: Int) {
        type = .perlinnoise
        self.width = width
        self.depth = depth
        rangeOne = float2(-Float(width)/Float(2.0), Float(width)/Float(2.0))
        rangeTwo = float2(-Float(depth)/Float(2.0), Float(depth)/Float(2.0))
        let generator = PerlinNoiseGenerator(seed: nil)
        self.formula = {(x: Int32, y: Int32) in
            return generator.valueFor(x: x, y: y)
        }
        super.init()
    }
    
    init(imageName: String, imageType: String, inDirectory: String) {
        type = .heightmap
        
        if let imagePath = Bundle.main.path(forResource: imageName, ofType: imageType, inDirectory: inDirectory)
        {
            guard let image = GameImage(contentsOfFile: imagePath) else {
                fatalError("Cannot read heightmap data")
            }
            self.width = Int(image.size.width)
            self.depth = Int(image.size.height)
            pixels = image.pixelData()
            //print(pixels)
        } else {
            fatalError("Cannot read heightmap")
        }
        rangeOne = float2(-Float(width)/Float(2.0), Float(width)/Float(2.0))
        rangeTwo = float2(-Float(depth)/Float(2.0), Float(depth)/Float(2.0))
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func create(withColor color: SKColor) {
        let terrainNode = SCNNode(geometry: createGeometry())
        self.addChildNode(terrainNode)
        
        terrainNode.geometry!.firstMaterial!.diffuse.contents = color
        terrainNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: nil)
        terrainNode.name = "terrain"
    }
    
    func create(withTexture image: GameImage) {
        let terrainNode = SCNNode(geometry: createGeometry())
        self.addChildNode(terrainNode)
        
        terrainNode.geometry!.firstMaterial!.diffuse.contents = image
        terrainNode.physicsBody = SCNPhysicsBody(type: SCNPhysicsBodyType.static, shape: nil)
        terrainNode.name = "terrain"
    }
    
    
    func create(withMultipleTextures image:GameImage) {
        let terrainNode = SCNNode(geometry: createGeometry())
        self.addChildNode(terrainNode)

        terrainNode.geometry!.firstMaterial!.diffuse.contents = image
        
        let alpha_texture = SCNMaterialProperty(contents: "art.scnassets/textures/alphamap.png")
        let dirt_texture = SCNMaterialProperty(contents: "art.scnassets/textures/dirt.jpg")
        let grass_texture = SCNMaterialProperty(contents:image)
        
        terrainNode.geometry!.firstMaterial!.setValue(alpha_texture, forKeyPath: "alphaTexture")
        terrainNode.geometry!.firstMaterial!.setValue(dirt_texture, forKeyPath: "dirtTexture")

        
        let res = Bundle.main.path(forResource: "terrain", ofType: "shader", inDirectory:"art.scnassets/shaders")
        let surfaceModifier = try? String(contentsOfFile: res!)
        terrainNode.geometry!.firstMaterial?.shaderModifiers = [SCNShaderModifierEntryPoint.surface: surfaceModifier!]
    }
    

    private func createGeometry() -> SCNGeometry {
        
        let pointCount = width * depth
        var vertices = [SCNVector3](repeating:SCNVector3Make(0,0,0), count:pointCount)
        var normals = [SCNVector3](repeating:SCNVector3Make(0,0,0), count:pointCount)
        var textures = [CGPoint](repeating:CGPoint(x:0, y:0), count:pointCount)
        
        var numberOfIndices = (2*width)*(depth)
        if (depth%4==0) {
            numberOfIndices = numberOfIndices + 2
        }
        
        var indices = [UInt32](repeating:0, count:numberOfIndices)
        
        //    The indices for a mesh
        //
        //    (1)━━━(2)━━━(3)━━━(4)
        //     ┃   ◥ ┃   ◥ ┃   ◥ ┃
        //     ┃  ╱  ┃  ╱  ┃  ╱  ┃
        //     ▼ ╱   ▼ ╱   ▼ ╱   ▼
        //    (4)━━━(5)━━━(6)━━━(7)⟳  nr 7 twice
        //     ┃ ◤   ┃ ◤   ┃ ◤   ┃
        //     ┃  ╲  ┃  ╲  ┃  ╲  ┃
        //     ┃   ╲ ┃   ╲ ┃   ╲ ┃
        //  ⟳(8)━━━(9)━━━(10)━━(11)   nr 8 twice
        //     ┃   ◥ ┃   ◥ ┃   ◥ ┃
        //     ┃  ╱  ┃  ╱  ┃  ╱  ┃
        //     ▼ ╱   ▼ ╱   ▼ ╱   ▼
        //    (12)━━(13)━━(14)━━(15)
        
        var lastIndex = 0
        for row in stride(from:0, to:width-1, by:1) {
            let isEven = row%2 == 0
            for col in stride(from:0, to:depth, by:1) {
                if (isEven) {
                    indices[lastIndex] = UInt32(row*width + col)
                    lastIndex = lastIndex + 1
                    indices[lastIndex] = UInt32((row+1)*width + col)
                    if (col == depth-1) {
                        lastIndex = lastIndex + 1
                        indices[lastIndex] = UInt32((row+1)*width + col)
                    }
                } else {
                    indices[lastIndex] = UInt32(row*width + (depth-1-col))
                    lastIndex = lastIndex + 1
                    indices[lastIndex] = UInt32((row+1)*width + (depth-1-col))
                    if (col == depth-1) {
                        lastIndex = lastIndex + 1
                        indices[lastIndex] = UInt32((row+1)*width + (depth-1-col))
                    }
                }
                lastIndex = lastIndex + 1
            }
        }
        
        // Generate the mesh by calculating the vector, normal
        // and texture coordinate for each x,z pair.
        for row in stride(from:0, to:width, by:1) {
            for col in stride(from:0, to:depth, by:1) {
                let one:SCNFloat = SCNFloat(col)/SCNFloat(width-1) * SCNFloat(self.rangeOne.y - self.rangeOne.x) + SCNFloat(self.rangeOne.x)
                let two:SCNFloat = SCNFloat(row)/SCNFloat(depth-1) * SCNFloat(self.rangeTwo.y - self.rangeTwo.x) + SCNFloat(self.rangeTwo.x)
                
                let value = self.vectorForFunction(one:one, two:two)
                
                vertices[col + row*depth] = value
                
                let delta:SCNFloat = 0.001
                let dx = Utils.vectorSubtract(a: value, b: self.vectorForFunction(one:one+delta, two:two))
                let dz = Utils.vectorSubtract(a: value, b: self.vectorForFunction(one:one, two:two+delta))
                
                let v = Utils.crossProduct(a: dz, b: dx)
                normals[col + row*depth] = v.normalize()
                
                textures[col + row*depth] = CGPoint(x:CGFloat(col)/CGFloat(width)*CGFloat(self.textureRepeatCount.x), y:CGFloat(row)/CGFloat(depth)*CGFloat(self.textureRepeatCount.y))
                //print("Texcoord is \(textures[col + row*depth])")
            }
        }
        
        // Create geometry sources for the generated data
        let vertexSource = SCNGeometrySource(vertices: vertices, count: pointCount)
        let normalSource = SCNGeometrySource(normals:normals, count: pointCount)
        let textureSource = SCNGeometrySource(textureCoordinates: textures, count: pointCount)
        
        // Configure the indices that was to be interpreted as a
        // triangle strip using
        
        let data = NSData(bytes: indices, length: MemoryLayout<UInt32>.size*(numberOfIndices))
        let element = SCNGeometryElement(data: data as Data, primitiveType: .triangleStrip, primitiveCount: numberOfIndices, bytesPerIndex: MemoryLayout<UInt32>.size)
        
        // Create geometry from these sources
        //print("Vertices are \(vertices)")
        let geometry = SCNGeometry(sources: [vertexSource, normalSource, textureSource], elements: [element])
        
        // Since the builder exposes a geometry with repeating texture
        // coordinates it is configured with a repeating material
        
        let repeatingTextureMaterial = SCNMaterial()
        repeatingTextureMaterial.isDoubleSided = true
        
        repeatingTextureMaterial.diffuse.wrapS = SCNWrapMode.repeat
        repeatingTextureMaterial.diffuse.wrapT = SCNWrapMode.repeat
        
        repeatingTextureMaterial.ambient.wrapS = SCNWrapMode.repeat
        repeatingTextureMaterial.ambient.wrapT = SCNWrapMode.repeat
        
        repeatingTextureMaterial.specular.contents = SKColor(white: 0.3, alpha: 1.0)
        repeatingTextureMaterial.shininess = 0.1250
        
        geometry.materials = [repeatingTextureMaterial]
        return geometry
    }

    func getHeight(x:SCNFloat, y:SCNFloat) -> SCNFloat {
        if(x <= SCNFloat(self.rangeOne.x) || x >= SCNFloat(self.rangeOne.y) || y <= SCNFloat(self.rangeTwo.x) || y >= SCNFloat(self.rangeTwo.y)) {
            return 0.0
        }
        
        let x1 = Int(x - SCNFloat(self.rangeOne.x))
        let y1 = Int(y - SCNFloat(self.rangeTwo.x))
        
        return SCNFloat(heightFromMap(x:x1, y:y1))
    }
    
    private func heightFromMap(x:Int, y:Int) -> CGFloat {
        if(type == .heightmap) {
            //print("Getting height of pixel:\(x),\(y)")
            if(x==width || y==depth) {
                return 0.0
            }
            return pixels[x][y].intensity * 20.0
        } else {
            // Perlin Noise
            if (formula == nil) {
                return 0.0
            }
            
            let val = formula!(Int32(x), Int32(y))
            return CGFloat(val/48.0)
        }
    }
    
    
    private func vectorForFunction(one:SCNFloat, two:SCNFloat) -> SCNVector3 {
        return SCNVector3Make(SCNFloat(one), SCNFloat(heightFromMap(x:Int(one-SCNFloat(self.rangeOne.x)), y:Int(two-SCNFloat(self.rangeTwo.x)))), SCNFloat(two))
    }
    
}
