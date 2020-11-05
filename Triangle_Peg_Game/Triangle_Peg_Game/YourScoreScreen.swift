//
//  scoreScreen.swift
//  Triangle_Peg_Game
//
//  Created by Zeak on 5/3/20.
//  Copyright © 2020 Zeak. All rights reserved.
//

import SpriteKit

class YourScoreScreen : SKScene {
    let yourScoreLabel = SKLabelNode(text: "Your Score")
    var time: Int = 0
    let height: CGFloat = 355
    let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    var initials = ["A", "A", "A"]
    override func didMove(to view: SKView) {
        
        // Create score label
        yourScoreLabel.position = CGPoint(x: self.frame.midX, y: height - 10)
        yourScoreLabel.fontSize = 30
        yourScoreLabel.fontName = "Courier New"
        yourScoreLabel.name = "Timer"
        yourScoreLabel.text = "Your Score \(generateTime(time: time))"
        self.addChild(yourScoreLabel)
        
        
        // Create upright Triangles
        createTriangles(isUpRight: true)
        
        // Create Labels
        createLables()
        
        // Create upside down triangles
        createTriangles(isUpRight: false)
        
        
        // Create done label
        let doneLabel = SKLabelNode(text: "Done")
        doneLabel.position = CGPoint(x: self.frame.midX, y: 20)
        doneLabel.fontSize = 30
        doneLabel.fontName = "Courier New"
        doneLabel.name = "Done"
        doneLabel.text = "Done"
        self.addChild(doneLabel)
        
    }
    
    func getLabelNumber(node: SKNode) -> Int{
        let nodesName = node.name!
        if let range = nodesName.range(of: "Triangle ") {
            let number = nodesName[range.upperBound...]
            let nodeNumber = Int(number)!
            return nodeNumber
        }
        return -1
        
    }
    
    func getCharacterIndex(text: String) -> Int{
        /* Code from  https://stackoverflow.com/questions/24029163/finding-index-of-character-in-swift-string*/

        let range: Range<String.Index> = alphabet.range(of: "\(text)")!
        let index: Int = alphabet.distance(from: alphabet.startIndex, to: range.lowerBound)
        return index
    }
    
    
    func createLables(){
        var nameLablel: SKLabelNode
        var leftX  = 210
        for i in 0..<3 {
            leftX = 120 + 210 * i
            nameLablel = SKLabelNode(text: "A")
            nameLablel.position = CGPoint(x: leftX, y: 160)
            nameLablel.fontSize = 64
            nameLablel.fontName = "Courier New"
            nameLablel.name = "nameLabel \(i)"
            self.addChild(nameLablel)
        }
    }
    
    func createTriangles(isUpRight: Bool){
        var leftX = 210
        let width: CGFloat = 580 / 13
        let myHeight: CGFloat = 25
        var points: [CGPoint] = []
        var Triangle: SKShapeNode
        var direction: CGFloat = -1
        var name: String = "Upside Down Triangle"
        var y: Int = 100
        
        if isUpRight {
            direction = 1
            name = "Upright Triangle"
            y = 260
        }
        
        for i in 0..<3 {
            leftX = 120 + 210 * i
            points = [CGPoint(x:width, y:myHeight * direction * -1),
                          CGPoint(x:-width, y:myHeight * direction * -1),
                          CGPoint(x: 0.0, y: myHeight * direction)]
            Triangle = SKShapeNode(points: &points, count: points.count)
            Triangle.fillColor = UIColor.red
            Triangle.position = CGPoint(x: leftX, y: y)
            Triangle.name = "\(name) \(i)"
            self.addChild(Triangle)
        }
    }
    
    func updateLabel(number: Int, down: Bool, node: SKLabelNode){
        let labelText = node.text ?? "Broke"
        if down {
            let index = alphabet.index(alphabet.startIndex, offsetBy: getCharacterIndex(text: labelText) + 1)
            if index != alphabet.endIndex {
                node.text = "\(alphabet[index])"
            }
            else{
                node.text = "\(alphabet[alphabet.startIndex])"
            }
        }
        else {
            let characterIndexNumber = getCharacterIndex(text: labelText)
            if (characterIndexNumber == 0){
                node.text = "\(alphabet[alphabet.index(before: alphabet.endIndex)])"
            }
            else {
                let index = alphabet.index(alphabet.startIndex, offsetBy: getCharacterIndex(text: labelText) - 1)
                node.text = "\(alphabet[index])"
            }
        }
        initials[number] = node.text!
        
    }
    
    func moveToHighScoreScreen(){
        let scoreScreen = HighScoreScreen()
        scoreScreen.scaleMode = .resizeFill
        scoreScreen.time = time
        scoreScreen.initials = initials
        self.view?.presentScene(scoreScreen, transition: SKTransition.fade(withDuration: 0.5))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: self)
            let nodeArray = nodes(at: point)
            let allNodesArray = self.children
            var nodeNumber: Int = 0
            for node in nodeArray {
                
                let nodeNames: String  = node.name ?? "Broke"
  
                // See if finished
                if (nodeNames == "Done") {
                    moveToHighScoreScreen()
                }
                
                // Hadle updating the labels
                nodeNumber = getLabelNumber(node: node)
                if (nodeNames.contains("Triangle")){
                    // Get its corresponding node
                    for newNode in allNodesArray {
                        let nodeNames2: String = newNode.name ?? "Broke"
                        
                        if (nodeNames2 == "nameLabel \(nodeNumber)"){
                            // Is Upside Down
                            if nodeNames.contains("Down"){
                                updateLabel(number: nodeNumber, down: true, node: newNode as! SKLabelNode)
                            }
                            
                            // Is Upright
                            else{
                                updateLabel(number: nodeNumber, down: false, node: newNode as! SKLabelNode)
                            }
                        }
                    }
                    
                }
            }
        }
    }
    
    
    
}
