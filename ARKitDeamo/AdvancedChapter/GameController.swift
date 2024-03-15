//
//  GameController.swift
//  ARKitDeamo
//
//  Created by zhaoquan du on 2024/3/14.
//

import SwiftUI
import Foundation
import RealityKit
import Combine

class GameController{
    var gameAnchor: Ball.BallGame!
    var motherBall: (Entity & HasPhysics)? {
        gameAnchor.motherBall as? Entity & HasPhysics
    }
    var Ball13: (Entity & HasPhysics)? {
        gameAnchor.ball13 as? Entity & HasPhysics
    }
    var Ball6: (Entity & HasPhysics)? {
        gameAnchor.ball6 as? Entity & HasPhysics
    }
    var Ball4: (Entity & HasPhysics)? {
        gameAnchor.ball4 as? Entity & HasPhysics
    }
    let settings = GameSettings()
    var gestureRecognizer: EntityTranslationGestureRecognizer?
    var gestureStartLocation: SIMD3<Float>?
    
    var collisionEventStreams = [Cancellable]()

    deinit {
        collisionEventStreams.removeAll()
    }
}

struct GameSettings {
    let ballPlayDistanceThreshold: Float = 0.5
    let ballVelocityMinX: Float = -4.0
    let ballVelocityMaxX: Float = 4.0
    let ballVelocityMinZ: Float = -4.0
    let ballVelocityMaxZ: Float = 4.0
}


