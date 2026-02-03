import SwiftUI
import SceneKit

/// 3D-Wetter-Szene mit SceneKit
struct WeatherScene3DView: UIViewRepresentable {
    let condition: WeatherCondition
    let isDay: Bool
    
    func makeUIView(context: Context) -> SCNView {
        let scnView = SCNView()
        scnView.backgroundColor = .clear
        scnView.allowsCameraControl = false
        scnView.autoenablesDefaultLighting = false
        scnView.antialiasingMode = .multisampling4X
        
        let scene = createScene(for: condition, isDay: isDay)
        scnView.scene = scene
        
        return scnView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        uiView.scene = createScene(for: condition, isDay: isDay)
    }
    
    // MARK: - Scene Creation
    
    private func createScene(for condition: WeatherCondition, isDay: Bool) -> SCNScene {
        let scene = SCNScene()
        
        // Kamera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(x: 0, y: 5, z: 15)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(cameraNode)
        
        // Basis-Licht
        addLighting(to: scene, for: condition, isDay: isDay)
        
        // Wetter-spezifische Elemente
        switch condition {
        case .sunny, .clear:
            if isDay {
                addSun(to: scene)
                addFloatingClouds(to: scene, count: 3, opacity: 0.3)
            } else {
                addMoon(to: scene)
                addStars(to: scene)
            }
            
        case .partlyCloudy:
            if isDay {
                addSun(to: scene)
            }
            addFloatingClouds(to: scene, count: 5, opacity: 0.7)
            
        case .cloudy, .overcast:
            addFloatingClouds(to: scene, count: 8, opacity: 0.9)
            
        case .rain, .heavyRain:
            addFloatingClouds(to: scene, count: 6, opacity: 0.95)
            addRain(to: scene, intensity: condition == .heavyRain ? 1.0 : 0.5)
            
        case .thunderstorm:
            addFloatingClouds(to: scene, count: 8, opacity: 1.0)
            addRain(to: scene, intensity: 0.8)
            addLightning(to: scene)
            
        case .snow, .sleet:
            addFloatingClouds(to: scene, count: 5, opacity: 0.8)
            addSnow(to: scene)
            
        case .fog, .mist:
            addFog(to: scene)
            
        default:
            addFloatingClouds(to: scene, count: 4, opacity: 0.5)
        }
        
        return scene
    }
    
    // MARK: - Lighting
    
    private func addLighting(to scene: SCNScene, for condition: WeatherCondition, isDay: Bool) {
        // Ambient Light
        let ambientLight = SCNNode()
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        
        switch condition {
        case .sunny, .clear:
            ambientLight.light?.color = isDay ? UIColor(white: 0.8, alpha: 1) : UIColor(white: 0.2, alpha: 1)
        case .rain, .heavyRain, .thunderstorm:
            ambientLight.light?.color = UIColor(white: 0.3, alpha: 1)
        case .snow:
            ambientLight.light?.color = UIColor(white: 0.7, alpha: 1)
        default:
            ambientLight.light?.color = UIColor(white: 0.5, alpha: 1)
        }
        
        scene.rootNode.addChildNode(ambientLight)
        
        // Directional Light (Sonne/Mond)
        if isDay && [.sunny, .partlyCloudy].contains(condition) {
            let directionalLight = SCNNode()
            directionalLight.light = SCNLight()
            directionalLight.light?.type = .directional
            directionalLight.light?.color = UIColor(red: 1, green: 0.95, blue: 0.8, alpha: 1)
            directionalLight.light?.intensity = 1000
            directionalLight.position = SCNVector3(10, 10, 10)
            directionalLight.look(at: SCNVector3(0, 0, 0))
            scene.rootNode.addChildNode(directionalLight)
        }
    }
    
    // MARK: - Sun
    
    private func addSun(to scene: SCNScene) {
        let sunGeometry = SCNSphere(radius: 2)
        let sunMaterial = SCNMaterial()
        sunMaterial.diffuse.contents = UIColor.yellow
        sunMaterial.emission.contents = UIColor.orange
        sunGeometry.materials = [sunMaterial]
        
        let sunNode = SCNNode(geometry: sunGeometry)
        sunNode.position = SCNVector3(x: 8, y: 8, z: -10)
        
        // Glow-Effekt
        let glowGeometry = SCNSphere(radius: 3)
        let glowMaterial = SCNMaterial()
        glowMaterial.diffuse.contents = UIColor.orange.withAlphaComponent(0.3)
        glowMaterial.emission.contents = UIColor.yellow.withAlphaComponent(0.5)
        glowGeometry.materials = [glowMaterial]
        
        let glowNode = SCNNode(geometry: glowGeometry)
        sunNode.addChildNode(glowNode)
        
        // Pulsier-Animation
        let pulseAction = SCNAction.sequence([
            SCNAction.scale(to: 1.1, duration: 2),
            SCNAction.scale(to: 1.0, duration: 2)
        ])
        glowNode.runAction(SCNAction.repeatForever(pulseAction))
        
        scene.rootNode.addChildNode(sunNode)
    }
    
    // MARK: - Moon
    
    private func addMoon(to scene: SCNScene) {
        let moonGeometry = SCNSphere(radius: 1.5)
        let moonMaterial = SCNMaterial()
        moonMaterial.diffuse.contents = UIColor(white: 0.9, alpha: 1)
        moonMaterial.emission.contents = UIColor(white: 0.3, alpha: 1)
        moonGeometry.materials = [moonMaterial]
        
        let moonNode = SCNNode(geometry: moonGeometry)
        moonNode.position = SCNVector3(x: 6, y: 7, z: -10)
        
        scene.rootNode.addChildNode(moonNode)
    }
    
    // MARK: - Stars
    
    private func addStars(to scene: SCNScene) {
        for _ in 0..<50 {
            let starGeometry = SCNSphere(radius: 0.05)
            let starMaterial = SCNMaterial()
            starMaterial.emission.contents = UIColor.white
            starGeometry.materials = [starMaterial]
            
            let starNode = SCNNode(geometry: starGeometry)
            starNode.position = SCNVector3(
                x: Float.random(in: -20...20),
                y: Float.random(in: 5...15),
                z: Float.random(in: -20...-5)
            )
            
            // Twinkle Animation
            let twinkle = SCNAction.sequence([
                SCNAction.fadeOpacity(to: 0.3, duration: Double.random(in: 0.5...1.5)),
                SCNAction.fadeOpacity(to: 1.0, duration: Double.random(in: 0.5...1.5))
            ])
            starNode.runAction(SCNAction.repeatForever(twinkle))
            
            scene.rootNode.addChildNode(starNode)
        }
    }
    
    // MARK: - Clouds
    
    private func addFloatingClouds(to scene: SCNScene, count: Int, opacity: CGFloat) {
        for i in 0..<count {
            let cloudNode = createCloud(opacity: opacity)
            cloudNode.position = SCNVector3(
                x: Float.random(in: -10...10),
                y: Float.random(in: 3...8),
                z: Float.random(in: -8...2)
            )
            cloudNode.scale = SCNVector3(
                x: Float.random(in: 0.5...1.5),
                y: Float.random(in: 0.5...1.0),
                z: Float.random(in: 0.5...1.5)
            )
            
            // Floating Animation
            let floatAction = SCNAction.sequence([
                SCNAction.moveBy(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: -0.5...0.5), z: 0, duration: Double.random(in: 4...8)),
                SCNAction.moveBy(x: CGFloat.random(in: -2...2), y: CGFloat.random(in: -0.5...0.5), z: 0, duration: Double.random(in: 4...8))
            ])
            cloudNode.runAction(SCNAction.repeatForever(floatAction))
            
            scene.rootNode.addChildNode(cloudNode)
        }
    }
    
    private func createCloud(opacity: CGFloat) -> SCNNode {
        let cloudNode = SCNNode()
        
        // Mehrere Kugeln für fluffigen Wolken-Look
        let positions: [(Float, Float, Float)] = [
            (0, 0, 0), (-1, 0.2, 0), (1, 0.1, 0),
            (-0.5, 0.5, 0), (0.5, 0.4, 0), (0, 0.3, 0.5)
        ]
        
        for pos in positions {
            let sphereGeometry = SCNSphere(radius: CGFloat.random(in: 0.8...1.2))
            let material = SCNMaterial()
            material.diffuse.contents = UIColor.white.withAlphaComponent(opacity)
            material.transparency = opacity
            sphereGeometry.materials = [material]
            
            let sphereNode = SCNNode(geometry: sphereGeometry)
            sphereNode.position = SCNVector3(x: pos.0, y: pos.1, z: pos.2)
            cloudNode.addChildNode(sphereNode)
        }
        
        return cloudNode
    }
    
    // MARK: - Rain
    
    private func addRain(to scene: SCNScene, intensity: Float) {
        let particleSystem = SCNParticleSystem()
        particleSystem.particleColor = UIColor(white: 0.8, alpha: 0.6)
        particleSystem.particleSize = 0.02
        particleSystem.birthRate = CGFloat(500 * intensity)
        particleSystem.emissionDuration = 0
        particleSystem.particleLifeSpan = 2
        particleSystem.spreadingAngle = 5
        particleSystem.particleVelocity = 15
        particleSystem.particleVelocityVariation = 3
        particleSystem.acceleration = SCNVector3(0, -10, 0)
        particleSystem.stretchFactor = 0.5
        
        let particleNode = SCNNode()
        particleNode.position = SCNVector3(0, 15, 0)
        particleNode.addParticleSystem(particleSystem)
        
        scene.rootNode.addChildNode(particleNode)
    }
    
    // MARK: - Snow
    
    private func addSnow(to scene: SCNScene) {
        let particleSystem = SCNParticleSystem()
        particleSystem.particleColor = .white
        particleSystem.particleSize = 0.1
        particleSystem.birthRate = 100
        particleSystem.emissionDuration = 0
        particleSystem.particleLifeSpan = 8
        particleSystem.spreadingAngle = 30
        particleSystem.particleVelocity = 2
        particleSystem.particleVelocityVariation = 1
        particleSystem.acceleration = SCNVector3(0, -1, 0)
        
        let particleNode = SCNNode()
        particleNode.position = SCNVector3(0, 15, 0)
        particleNode.addParticleSystem(particleSystem)
        
        scene.rootNode.addChildNode(particleNode)
    }
    
    // MARK: - Lightning
    
    private func addLightning(to scene: SCNScene) {
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .omni
        lightNode.light?.color = UIColor.white
        lightNode.light?.intensity = 0
        lightNode.position = SCNVector3(0, 10, 0)
        
        // Lightning flash animation
        let flashSequence = SCNAction.sequence([
            SCNAction.wait(duration: Double.random(in: 3...8)),
            SCNAction.run { node in
                node.light?.intensity = 5000
            },
            SCNAction.wait(duration: 0.1),
            SCNAction.run { node in
                node.light?.intensity = 0
            },
            SCNAction.wait(duration: 0.1),
            SCNAction.run { node in
                node.light?.intensity = 3000
            },
            SCNAction.wait(duration: 0.05),
            SCNAction.run { node in
                node.light?.intensity = 0
            }
        ])
        
        lightNode.runAction(SCNAction.repeatForever(flashSequence))
        scene.rootNode.addChildNode(lightNode)
    }
    
    // MARK: - Fog
    
    private func addFog(to scene: SCNScene) {
        scene.fogStartDistance = 5
        scene.fogEndDistance = 25
        scene.fogColor = UIColor(white: 0.8, alpha: 1)
        scene.fogDensityExponent = 1
        
        // Nebel-Partikel
        for i in 0..<10 {
            let fogGeometry = SCNSphere(radius: 3)
            let fogMaterial = SCNMaterial()
            fogMaterial.diffuse.contents = UIColor.white.withAlphaComponent(0.2)
            fogMaterial.transparency = 0.3
            fogGeometry.materials = [fogMaterial]
            
            let fogNode = SCNNode(geometry: fogGeometry)
            fogNode.position = SCNVector3(
                x: Float.random(in: -10...10),
                y: Float.random(in: 0...5),
                z: Float.random(in: -5...5)
            )
            
            // Drift Animation
            let driftAction = SCNAction.sequence([
                SCNAction.moveBy(x: CGFloat.random(in: -3...3), y: 0, z: CGFloat.random(in: -2...2), duration: Double.random(in: 6...12)),
                SCNAction.moveBy(x: CGFloat.random(in: -3...3), y: 0, z: CGFloat.random(in: -2...2), duration: Double.random(in: 6...12))
            ])
            fogNode.runAction(SCNAction.repeatForever(driftAction))
            
            scene.rootNode.addChildNode(fogNode)
        }
    }
}

// MARK: - Preview Container

struct WeatherScene3DContainer: View {
    let condition: WeatherCondition
    let isDay: Bool
    
    var body: some View {
        ZStack {
            // Gradient Background
            LinearGradient(
                colors: condition.gradientColors,
                startPoint: .top,
                endPoint: .bottom
            )
            
            // 3D Scene
            WeatherScene3DView(condition: condition, isDay: isDay)
                .opacity(0.8)
        }
    }
}

#Preview {
    WeatherScene3DContainer(condition: .thunderstorm, isDay: true)
        .ignoresSafeArea()
}
