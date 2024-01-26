//
//  RobotHead.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/1/25.
//

import RealityKit
import ARKit

class RobotHead: Entity, HasModel {
    
    // Default color values
    private let eyeColor: SimpleMaterial.Color = .blue
    private let eyebrowColor: SimpleMaterial.Color = .brown
    private let headColor: SimpleMaterial.Color = .green
    private let lipColor: SimpleMaterial.Color = .lightGray
    private let mouthColor: SimpleMaterial.Color = .gray
    private let tongueColor: SimpleMaterial.Color = .red
    private let clearColor: SimpleMaterial.Color = .clear
    
    private var originalJawY: Float = 0
    private var originalUpperLipY: Float = 0
    private var originalEyebrowY: Float = 0
    
    private lazy var eyeLeftEntity = findEntity(named: "eyeLeft")!
    private lazy var eyeRightEntity = findEntity(named: "eyeRight")!
    private lazy var eyebrowLeftEntity = findEntity(named: "eyebrowLeft")!
    private lazy var eyebrowRightEntity = findEntity(named: "eyebrowRight")!
    private lazy var jawEntity = findEntity(named: "jaw")!
    private lazy var upperLipEntity = findEntity(named: "upperLip")!
    private lazy var headEntity = findEntity(named: "head")!
    private lazy var tongueEntity = findEntity(named: "tongue")!
    private lazy var mouthEntity = findEntity(named: "mouth")!
    
    private lazy var jawHeight: Float = {
        let bounds = jawEntity.visualBounds(relativeTo: jawEntity)
        return (bounds.max.y - bounds.min.y)
    }()
    
    private lazy var height: Float = {
        let bounds = headEntity.visualBounds(relativeTo: nil)
        return (bounds.max.y - bounds.min.y)
    }()
    
    required init() {
        super.init()
        
        if let robotHead = try? Entity.load(named: "robotHead") {
            
            robotHead.position.y += 0.05
            addChild(robotHead)
        } else {
            fatalError("无法加载模型.")
        }
        originalJawY = jawEntity.position.y
        originalUpperLipY = upperLipEntity.position.y
        originalEyebrowY = eyebrowLeftEntity.position.y
        setColor()
    }
    
    
    func setColor(){
        
        headEntity.color = headColor
        eyeLeftEntity.color = eyeColor
        eyeRightEntity.color = eyeColor
        eyebrowLeftEntity.color = eyebrowColor
        eyebrowRightEntity.color = eyebrowColor
        upperLipEntity.color = lipColor
        jawEntity.color = lipColor
        mouthEntity.color = mouthColor
        tongueEntity.color = tongueColor
    }
    
    // MARK: - Animations
    
    /// - Tag: InterpretBlendShapes
    func update(with faceAnchor: ARFaceAnchor) {
        // Update eyes and jaw transforms based on blend shapes.
        let blendShapes = faceAnchor.blendShapes
        guard let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
            let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float,
            let eyeBrowLeft = blendShapes[.browOuterUpLeft] as? Float,
            let eyeBrowRight = blendShapes[.browOuterUpRight] as? Float,
            let jawOpen = blendShapes[.jawOpen] as? Float,
            let upperLip = blendShapes[.mouthUpperUpLeft] as? Float,
            let tongueOut = blendShapes[.tongueOut] as? Float
            else { return }
        
        eyebrowLeftEntity.position.y = originalEyebrowY + 0.03 * eyeBrowLeft
        eyebrowRightEntity.position.y = originalEyebrowY + 0.03 * eyeBrowRight
        tongueEntity.position.z = 0.1 * tongueOut
        jawEntity.position.y = originalJawY - jawHeight * jawOpen
        upperLipEntity.position.y = originalUpperLipY + 0.05 * upperLip
        eyeLeftEntity.scale.z = 1 - eyeBlinkLeft
        eyeRightEntity.scale.z = 1 - eyeBlinkRight
        
        let cameraTransform = self.parent?.transformMatrix(relativeTo: nil)
        let faceTransformFromCamera = simd_mul(simd_inverse(cameraTransform!), faceAnchor.transform)
        let rotationEulers = faceTransformFromCamera.eulerAngles
        let mirroredRotation = Transform(pitch: rotationEulers.x, yaw: -rotationEulers.y + .pi, roll: rotationEulers.z)
        self.orientation = mirroredRotation.rotation
    }
}


extension Entity {
    var color: SimpleMaterial.Color? {
        get {
            if let model = components[ModelComponent.self] as? ModelComponent,
               let color = (model.materials.first as? SimpleMaterial)?.color.tint {
                return color
            }
            return nil
        }
        set {
            if var model = components[ModelComponent.self] as? ModelComponent {
                if let color = newValue {
                    model.materials = [SimpleMaterial(color: color, isMetallic: false)]
                } else {
                    model.materials = []
                }
                components[ModelComponent.self] = model
            }
        }
    }
}

extension simd_float4x4 {
    // Note to ourselves: This is the implementation from AREulerAnglesFromMatrix.
    // Ideally, this would be RealityKit API when this sample gets published.
    var eulerAngles: SIMD3<Float> {
        var angles: SIMD3<Float> = .zero
        
        if columns.2.y >= 1.0 - .ulpOfOne * 10 {
            angles.x = -.pi / 2
            angles.y = 0
            angles.z = atan2(-columns.0.z, -columns.1.z)
        } else if columns.2.y <= -1.0 + .ulpOfOne * 10 {
            angles.x = -.pi / 2
            angles.y = 0
            angles.z = atan2(columns.0.z, columns.1.z)
        } else {
            angles.x = asin(-columns.2.y)
            angles.y = atan2(columns.2.x, columns.2.z)
            angles.z = atan2(columns.0.y, columns.1.y)
        }
        
        return angles
    }
}
