//
//  AnimatedLogoOrbit.swift
//  AppleLoginAnimation
//
//  Created by George on 14/10/2025.
//

import SwiftUI
import SpriteKit

struct AnimatedLogoOrbit: View {
    let images: [String]
    
    @State private var scene: AnimatedLogoOrbitScene?
    
    var body: some View {
        ZStack {
            if let scene {
                SpriteView(
                    scene: scene,
                    options: [.allowsTransparency],
                    debugOptions: [.showsFPS, .showsDrawCount, .showsNodeCount]
                )
            }
        }
        .onAppear {
            setupScene()
        }
    }
    
    private func setupScene() {
        let newScene = AnimatedLogoOrbitScene()
        newScene.images = images
        newScene.scaleMode = .resizeFill
        scene = newScene
    }
}

class AnimatedLogoOrbitScene: SKScene {
    var images: [String] = []
    
    let dotsPerCircle = 23
    let numCircles = 4
    
    var outerCircleDots: [SKShapeNode] = []
    var nextIconIndex = 0
    var originalPositions: [CGPoint] = []
    
    let container = SKNode()
    
    private let gradient: [(angle: CGFloat, color: SKColor)] = [
        (0, SKColor(red: 185/255, green: 88/255, blue: 217/255, alpha: 1)), // right = purple
        (.pi / 2, SKColor(red: 236/255, green: 103/255, blue: 124/255, alpha: 1)), // top = pink
        (.pi, SKColor(red: 233/255, green: 188/255, blue: 158/255, alpha: 1)), // left = orange
        (3 * .pi / 2, SKColor(red: 116/255, green: 190/255, blue: 246/255, alpha: 1)), // bottom = blue
        (2 * .pi, SKColor(red: 185/255, green: 88/255, blue: 217/255, alpha: 1))  // right = purple
    ]
    
    override func didMove(to view: SKView) {
        self.backgroundColor = .clear
        physicsWorld.gravity = .zero
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        addChild(container)
        buildCircles()
        startRotation()
        animateNextIcon()
    }
    
    private func buildCircles() {
        let circles = generateCircles()
        var angleOffset: CGFloat = 0
        
        for (circleIndex, circle) in circles.enumerated() {
            for dotIndex in 0..<dotsPerCircle {
                var angle = (2 * .pi / CGFloat(dotsPerCircle) * CGFloat(dotIndex)) + angleOffset
                if angle > 2 * .pi { angle -= 2 * .pi }
                
                let position = CGPoint(x: circle.radius * cos(angle), y: circle.radius * sin(angle))
                
                let dot = SKShapeNode(circleOfRadius: circle.size)
                dot.position = position
                dot.fillColor = getColor(for: angle)
                dot.strokeColor = .clear
                dot.name = "dot-\(circleIndex)"
                dot.physicsBody = SKPhysicsBody(circleOfRadius: circle.size + 3)
                dot.physicsBody?.isDynamic = true
                dot.physicsBody?.affectedByGravity = false
                
                if circleIndex == 0 {
                    let step = Int(round(Double(dotsPerCircle) / Double(images.count)))
                    
                    if dotIndex % step == 0 {
                        placeIconOnOuterCircle(for: dot)
                        outerCircleDots.append(dot)
                    }
                }
                
                container.addChild(dot)
                originalPositions.append(position)
            }
            
            angleOffset += 0.4
        }
        
        // icons should animate clockwise
        outerCircleDots.reverse()
    }
    
    private func placeIconOnOuterCircle(for dot: SKShapeNode) {
        let sprite = SKSpriteNode(imageNamed: images[outerCircleDots.count])
        sprite.size = CGSize(width: 20, height: 20)
        sprite.alpha = 0
        sprite.name = "sprite"
        dot.addChild(sprite)
    }
    
    private func startRotation() {
        let rotate = SKAction.rotate(byAngle: .pi * -2, duration: 10)
        container.run(.repeatForever(rotate))
    }
    
    private func animateNextIcon() {
        let dot = outerCircleDots[nextIconIndex]
        
        dot.physicsBody? = SKPhysicsBody(circleOfRadius: 10)
        dot.physicsBody?.density = 110
        dot.physicsBody?.isDynamic = false
        
        let scaleIcon = SKAction.run {
            let a1 = SKAction.scale(to: 4.0 * 1.1, duration: 0.1)
            let a2 = SKAction.scale(to: 4.0, duration: 0.1)
            
            dot.run(.sequence([a1, a2]))
            
            dot.childNode(withName: "sprite")?.alpha = 1
        }
        
        let wait = SKAction.wait(forDuration: 1)
        
        let shrinkIcon = SKAction.run {
            let scale = SKAction.scale(to: 1.0, duration: 0.6)
            scale.timingFunction = SpriteKitTimingFunctions.easeInQuad
            dot.run(scale)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                let sprite = dot.childNode(withName: "sprite")
                let fade = SKAction.fadeAlpha(to: 0, duration: 0.1)
                sprite?.run(fade)
            }
        }
        
        // move dots back to their original position
        let moveDots = SKAction.run {
            for (i, surroundingDot) in self.container.children.enumerated()
            where !surroundingDot.position.isApproximatelyEqual(to: self.originalPositions[i])
            {
                let moveAction = SKAction.move(to: self.originalPositions[i], duration: 0.6)
                moveAction.timingFunction = SpriteKitTimingFunctions.easeInQuad
                surroundingDot.run(moveAction)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.nextIconIndex = (self.nextIconIndex + 1) % self.outerCircleDots.count
                self.animateNextIcon()
            }
        }

        dot.run(.sequence([scaleIcon, wait, moveDots, shrinkIcon])) {
            dot.physicsBody?.isDynamic = true
        }
    }
    
    private func generateCircles() -> [(radius: CGFloat, size: CGFloat)] {
        let radiusStep = 15
        let initialRadius = 75
        var dotSize = 4
        
        var circles: [(CGFloat, CGFloat)] = []
        
        for circleIndex in 0..<numCircles {
            let radius = CGFloat(initialRadius + (circleIndex * radiusStep))
            circles.append((CGFloat(radius), CGFloat(dotSize)))
            
            if circleIndex == 0 {
                dotSize += 2
            } else if circleIndex % 2 == 0 {
                dotSize += 3
            } else {
                dotSize -= 1
            }
        }
        
        return Array(circles.reversed())
    }
    
    override func update(_ currentTime: TimeInterval) {
        for case let dot as SKShapeNode in container.children {
            let worldPos = container.convert(dot.position, to: self)
            var angle = atan2(worldPos.y, worldPos.x)
            
            // normalise from -pi...pi to 0...2pi
            if angle < 0 {
                angle += 2 * .pi
            }
            
            dot.fillColor = getColor(for: angle)
        }
        
        let dot = outerCircleDots[nextIconIndex]
        dot.zRotation = -container.zRotation
    }
    
    private func getColor(for angle: CGFloat) -> SKColor {
        guard let startIndex = gradient.lastIndex(where: { $0.angle <= angle }) else {
            return .white
        }
        
        let endIndex = startIndex + 1
        
        let start = gradient[startIndex]
        let end = gradient[endIndex]
        
        let percent = (angle - start.angle) / (end.angle - start.angle)
        
        let r = start.color.rgba.red + (end.color.rgba.red - start.color.rgba.red) * percent
        let g = start.color.rgba.green + (end.color.rgba.green - start.color.rgba.green) * percent
        let b = start.color.rgba.blue + (end.color.rgba.blue - start.color.rgba.blue) * percent
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
    
}

#Preview {
    AnimatedLogoOrbit(
        images: ["messages", "app-store", "find-my", "music", "cloud", "files", "wallet", "photos"]
    )
}
