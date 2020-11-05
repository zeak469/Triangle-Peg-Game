//
//  GameScene.swift 
//  Triangle_Peg_Game
//
//  Created by Zeak on 5/2/20.
//  Copyright © 2020 Zeak. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var TimerLabel = SKLabelNode(text: "Choose a peg to remove it from the game")
    var isStarted = false
    var gameTimer: Timer!
    var time = 0
    var finalTime = 0
    var pegStates: [[pegState]] = []
    
    func dropConfetii(name: Int){
        let x = Int.random(in: -370..<370)
        let y = Int.random(in: 0..<200)
        let width = Int.random(in: 50..<80)
        let height = Int.random(in: 50..<80)
        let red = Int.random(in: 0..<255)
        let green = Int.random(in: 0..<255)
        let blue = Int.random(in: 0..<255)
        let rectangle = SKShapeNode(rect: CGRect(x: x, y: y, width: width, height: height))
        rectangle.fillColor = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1.0)
        rectangle.name = "Rectangle \(name)"
        let bottomPoint = CGPoint(x: 0, y: -500)
        let randomDuration = Int.random(in: 5..<15)
        let mySKAction = SKAction.move(to: bottomPoint, duration: TimeInterval(randomDuration))
        rectangle.run(mySKAction)
        self.addChild(rectangle)
    }
    
    
    override func didMove(to view: SKView) {
        self.removeAllChildren()
        
        /* Code from https://codepad.co/snippet/spritekit-23-draw-a-triangle */
        let width: CGFloat = 370 / 1.10
        let height: CGFloat = 200 / 1.18
        
        var points = [CGPoint(x:width, y:height * -1),
                      CGPoint(x:-width, y:height * -1),
                      CGPoint(x: 0.0, y: height)]
        let Triangle = SKShapeNode(points: &points, count: points.count)
        Triangle.fillColor = UIColor.red
        Triangle.position = CGPoint(x: self.frame.midX, y: self.frame.midY - 35)
        Triangle.name = "Base Triangle"
        self.addChild(Triangle)
        
        
        let diameter = 20
        let y1 = CGFloat(80)
        let y2 = CGFloat(20)
        let y3 = CGFloat(-40)
        let y4 = CGFloat(-100)
        let y5 = CGFloat(-172.5)
        var Circle: SKShapeNode
        let xyPositions = [[-250, y5], [-140, y5], [self.frame.midX, y5], [140, y5], [250, y5], [-180, y4], [-70, y4], [70, y4], [180, y4], [-120, y3], [self.frame.midX, y3], [120, y3], [-60, y2], [60, y2], [self.frame.midX, y1] ]
        var pegStateArray: [pegState] = []
        var maxLayerCount = 4
        var currentLayerCount = 0
        for i in 0..<xyPositions.count{
            Circle = SKShapeNode(circleOfRadius: CGFloat(diameter) ) // Size of Circle
            Circle.position = CGPoint(x: xyPositions[i][0], y: xyPositions[i][1])  // Middle of Screen
            Circle.glowWidth = 1.0
            Circle.fillColor = UIColor.blue
            Circle.name = "Circle \(i + 1)"
            self.addChild(Circle)
            if (currentLayerCount < maxLayerCount){
                pegStateArray.append(pegState.active)
            }
            if currentLayerCount == maxLayerCount {
                pegStateArray.append(pegState.active)
                pegStates.append(pegStateArray)
                pegStateArray = []
                maxLayerCount -= 1
                currentLayerCount = 0
            }
            else{
                currentLayerCount += 1
            }
        }
        
        TimerLabel.position = CGPoint(x: self.frame.midX, y: height - 10)
        TimerLabel.fontSize = 30
        TimerLabel.fontName = "Courier New"
        TimerLabel.name = "Timer"
        self.addChild(TimerLabel)
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
    }
    
    func touchMoved(toPoint pos : CGPoint) {
    }
    
    func touchUp(atPoint pos : CGPoint) {
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let point = touch.location(in: self);
            let nodeArray = nodes(at: point)
            for node in nodeArray {
                let nodeNames: String  = node.name ?? "Broke"
                if node.name == "Timer"{
                    isStarted = false
                    gameTimer.invalidate()
                    resetGame()
                    TimerLabel.fontSize = 30
                    TimerLabel.text = "Choose a peg to remove it from the game"
                    time = 0
                    updateGame()
                }
                if nodeNames.contains("Circle") {
                    let tappedNode = node as! SKShapeNode
                    if (isStarted == false){
                        startGame()
                        deactiveNode(node: tappedNode)
                    }
                    else if (getNodeStatus(node: tappedNode) == .active){
                        selectNode(node: tappedNode)
                        highLightNodesNextToNode(node: tappedNode)
                    }
                    else if (getNodeStatus(node: tappedNode) == .jumpable){
                        if (deactiveJumpedNode(jumpToNode: tappedNode)){
                            activateNode(node: tappedNode)
                            deactiveSelectedNode()
                        }
                    }
                    updateGame()
                }
            }
        }
    }
    
    func clearJumpableNodes(){
        let nodeArray = self.children
        var layerNumber = 0
        var nodeNumber = 0
        for node in nodeArray {
            let nodeName = node.name ?? "Broke"
            if nodeName.contains("Circle"){
                if (pegStates[layerNumber][nodeNumber] == .jumpable){
                    pegStates[layerNumber][nodeNumber] = .deactive
                }
                
                // Iterate through layers
                if (nodeNumber >= pegStates[layerNumber].count - 1){
                    layerNumber += 1
                    nodeNumber = 0
                }
                else {
                    nodeNumber += 1
                }
            }
        }
    }
    
    func resetGame(){
        let nodeArray = self.children
        var layerNumber = 0
        var nodeNumber = 0
        for node in nodeArray {
            let nodeName = node.name ?? "Broke"
            if nodeName.contains("Circle"){
                pegStates[layerNumber][nodeNumber] = .active
                
                // Iterate through layers
                if (nodeNumber >= pegStates[layerNumber].count - 1){
                    layerNumber += 1
                    nodeNumber = 0
                }
                else {
                    nodeNumber += 1
                }
            }
        }
    }
    
    
    func deactiveJumpedNode(jumpToNode: SKShapeNode) -> Bool{
        let selectedNode = getSelectedNode()
        let jumpableNodes = getNodesNextToJumpable(nodeNumber: selectedNode[1], nodeLayer: selectedNode[0])
        let endingNodeJump = getNodeLayerAndNumber(nodeNumber: getNodeNumber(node: jumpToNode))
        var jumpableNodeLayer: Int = 0
        var jumpableNodeNumber: Int = 0
        var selectedNodeLayer: Int = 0
        var selectedNodeNumber: Int = 0
        var endingNodeNumber: Int = 0
        var endingNodeLayer: Int = 0
        var wasSeaching: Bool = false
        for jumpableNode in jumpableNodes {
            wasSeaching = true
            jumpableNodeLayer = jumpableNode[0]
            jumpableNodeNumber = jumpableNode[1]
            selectedNodeLayer = selectedNode[0]
            selectedNodeNumber = selectedNode[1]
            endingNodeLayer = endingNodeJump[0]
            endingNodeNumber = endingNodeJump[1]
            
            
            // LEFT OR RIGHT
            if (jumpableNodeLayer == selectedNodeLayer && endingNodeLayer == selectedNodeLayer){
                
                // RIGHT
                if (jumpableNodeNumber > selectedNodeNumber) {
                    if (endingNodeNumber > jumpableNodeNumber){
                        break
                    }
                }
                    
                // LEFT
                else{
                    if (endingNodeNumber < jumpableNodeNumber){
                        break
                    }
                }
            }
                
            // UP OR DOWN
            else if (endingNodeLayer != selectedNodeLayer){
                
                // DOWN
                if (jumpableNodeLayer < selectedNodeLayer){
                    
                    // DOWN AND TO THE LEFT
                    if (endingNodeNumber == jumpableNodeNumber){     break
                    }
                    
                    // DOWN AND TO THE RIGHT
                    else if (endingNodeNumber < jumpableNodeNumber){
                       break
                   }
                }
                
                    
                // UP
                else if (jumpableNodeLayer > selectedNodeLayer){
                    if (pegStates[selectedNodeLayer].count % 2 != 0 && pegStates[selectedNodeLayer].count / 2 == selectedNodeNumber){
                        if (endingNodeNumber < jumpableNodeNumber){
                            break
                        }
                    }
                    
                    
                    // UP AND TO THE RIGHT
                    else if (endingNodeNumber == jumpableNodeNumber){
                        break
                    }
                    
                    // UP AND TO THE LEFT
                     else if (endingNodeNumber < jumpableNodeNumber){
                        break
                    }
                    
                }
            }
            
        }
        if (pegStates[jumpableNodeLayer][jumpableNodeNumber] == .active && wasSeaching == true){
            pegStates[jumpableNodeLayer][jumpableNodeNumber] = .deactive
            return true
        }
        else{
            return false
        }
        
    }
    
    func getSelectedNode() -> [Int]{
        let nodeArray = self.children
        var layerNumber = 0
        var nodeNumber = 0
        for node in nodeArray {
            let nodeName = node.name ?? "Broke"
            if nodeName.contains("Circle"){
                if (pegStates[layerNumber][nodeNumber] == .selected){
                    return [layerNumber, nodeNumber]
                }
                
                // Iterate through layers
                if (nodeNumber >= pegStates[layerNumber].count - 1){
                    layerNumber += 1
                    nodeNumber = 0
                }
                else {
                    nodeNumber += 1
                }
            }
        }
        return [-1]
    }
    
    func selectNode(node: SKShapeNode){
        activateSelectedNode()
        let nodesName = node.name!
        if let range = nodesName.range(of: "Circle ") {
            let number = nodesName[range.upperBound...]
            let nodeLayerAndNumber = getNodeLayerAndNumber(nodeNumber: Int(number)! - 1)
            pegStates[nodeLayerAndNumber[0]][nodeLayerAndNumber[1]] = .selected
        }
    }
    
    func deactiveSelectedNode(){
        let nodeArray = self.children
        var layerNumber = 0
        var nodeNumber = 0
        for node in nodeArray {
            let nodeName = node.name ?? "Broke"
            if nodeName.contains("Circle"){
                if (pegStates[layerNumber][nodeNumber] == .selected){
                    pegStates[layerNumber][nodeNumber] = .deactive
                }
                else if (pegStates[layerNumber][nodeNumber] == .jumpable){
                    pegStates[layerNumber][nodeNumber] = .deactive
                }
                
                // Iterate through layers
                if (nodeNumber >= pegStates[layerNumber].count - 1){
                    layerNumber += 1
                    nodeNumber = 0
                }
                else {
                    nodeNumber += 1
                }
            }
        }
    }
    
    func activateSelectedNode(){
        let nodeArray = self.children
        var layerNumber = 0
        var nodeNumber = 0
        for node in nodeArray {
            let nodeName = node.name ?? "Broke"
            if nodeName.contains("Circle"){
                if (pegStates[layerNumber][nodeNumber] == .selected){
                    pegStates[layerNumber][nodeNumber] = .active
                    return
                }
                
                // Iterate through layers
                if (nodeNumber >= pegStates[layerNumber].count - 1){
                    layerNumber += 1
                    nodeNumber = 0
                }
                else {
                    nodeNumber += 1
                }
            }
        }
    }
    
    func getNodeStatus(node: SKShapeNode) -> pegState{
        let layerAndNumber = getNodeLayerAndNumber(nodeNumber: getNodeNumber(node: node))
        return pegStates[layerAndNumber[0]][layerAndNumber[1]]
    }
    
    func highLightNodesNextToNode(node: SKShapeNode){
        
        // Deselect all current layers
        var layerNumber = 0
        var nodeNumber  = 0
        for pegStateArray in pegStates{
            for pegState in pegStateArray{
                if pegState == .jumpable {
                    pegStates[layerNumber][nodeNumber] = .deactive
                }
                if (nodeNumber >= pegStates[layerNumber].count - 1){
                    layerNumber += 1
                    nodeNumber = 0
                }
                else {
                    nodeNumber += 1
                }
            }
        }
        
        // Select layers next to it
        let nodesNextToLayerNumberAndNodeNumber = getJumpToNodes(node: node)
        for nodeLayerAndNodeNumber in nodesNextToLayerNumberAndNodeNumber {
            if ( pegStates[nodeLayerAndNodeNumber[0]][nodeLayerAndNodeNumber[1]] == .deactive){
                pegStates[nodeLayerAndNodeNumber[0]][nodeLayerAndNodeNumber[1]] = .jumpable
            }
        }
    }
    
    func deactiveNode(node: SKShapeNode){
        let nodesName = node.name!
        if let range = nodesName.range(of: "Circle ") {
            let number = nodesName[range.upperBound...]
            let nodeLayerAndNumber = getNodeLayerAndNumber(nodeNumber: Int(number)! - 1)
            pegStates[nodeLayerAndNumber[0]][nodeLayerAndNumber[1]] = .deactive
        }
    }
    func activateNode(node: SKShapeNode){
        let nodesName = node.name!
        if let range = nodesName.range(of: "Circle ") {
            let number = nodesName[range.upperBound...]
            let nodeLayerAndNumber = getNodeLayerAndNumber(nodeNumber: Int(number)! - 1)
            pegStates[nodeLayerAndNumber[0]][nodeLayerAndNumber[1]] = .active
        }
    }
    
    func getNodeNumber(node: SKShapeNode) -> Int{
        let nodesName = node.name!
        if let range = nodesName.range(of: "Circle ") {
            let number = nodesName[range.upperBound...]
            let nodeNumber = Int(number)! - 1
            return nodeNumber
        }
        return -1
        
    }
    
    func getNodeLayerAndNumber(nodeNumber: Int) -> [Int]{
        var counter = 0
        var newNodeNumber = nodeNumber
        var layerNumber = 0
        var nodeNumberInLayer: Int = 0
        for pegStateArray in pegStates {
            nodeNumberInLayer = newNodeNumber
            newNodeNumber -= pegStateArray.count
            if (newNodeNumber < 0){
                layerNumber = counter
                break;
            }
            counter += 1
        }
        return [layerNumber, nodeNumberInLayer]
    }
    
    func getJumpToNodes(node: SKShapeNode) -> [[Int]]{
        let nodesName = node.name!
        var jumpableIntArrays: [[Int]] = []
        var endJumpIntArray: [[Int]] = []
        if let range = nodesName.range(of: "Circle ") {
            let number = nodesName[range.upperBound...]
            let nodeLayerAndNumber = getNodeLayerAndNumber(nodeNumber: Int(number)! - 1)
            let nodeLayer = nodeLayerAndNumber[0]
            let nodeNumber = nodeLayerAndNumber[1]
            jumpableIntArrays = getNodesNextToJumpable(nodeNumber: nodeNumber, nodeLayer: nodeLayer)
            
            
            var currentNodeLayer = 0
            var currentNodeNumber = 0
            for intArray in jumpableIntArrays {
                currentNodeLayer = intArray[0]
                currentNodeNumber = intArray[1]
                if (pegStates[currentNodeLayer][currentNodeNumber] == .active){
                    
                    // Get the node to the right and left
                    if (nodeLayer == currentNodeLayer && nodeNumber < currentNodeNumber){
                        endJumpIntArray.append([nodeLayer, nodeNumber + 2])
                    }
                    else if (nodeLayer == currentNodeLayer && nodeNumber > currentNodeNumber){
                        endJumpIntArray.append([nodeLayer, nodeNumber - 2])
                    }
                        
                    // DOWN
                    else if (nodeLayer > currentNodeLayer){
                        if (nodeNumber == currentNodeNumber){
                            endJumpIntArray.append([currentNodeLayer - 1, currentNodeNumber])
                        }
                        else{
                            endJumpIntArray.append([currentNodeLayer - 1, currentNodeNumber + 1])
                        }
                    }
                        
                    // UP
                    else if (nodeLayer < currentNodeLayer) {
                        if (nodeNumber == currentNodeNumber){
                           endJumpIntArray.append([currentNodeLayer + 1, currentNodeNumber])
                        }
                        else{
                           endJumpIntArray.append([currentNodeLayer + 1, currentNodeNumber - 1])
                        }
                    }
                }
                
            }
            
            
            return endJumpIntArray
        }
        return [[-1]]
    }
    
    func getNodesNextToJumpable(nodeNumber: Int, nodeLayer: Int) -> [[Int]]{
        var myIntArrays: [[Int]] = []
        // Get the nodes to the left and right
        if (nodeNumber >= 2 && nodeNumber < pegStates[nodeLayer].count - 1 && nodeNumber != pegStates[nodeLayer].count - 2){
            myIntArrays.append([nodeLayer, nodeNumber - 1])
            myIntArrays.append([nodeLayer, nodeNumber + 1])
        }
        else if (nodeNumber >= 2){
            myIntArrays.append([nodeLayer, nodeNumber - 1])
        }
        else if (nodeNumber < pegStates[nodeLayer].count - 1 && nodeNumber != pegStates[nodeLayer].count - 2){
            myIntArrays.append([nodeLayer, nodeNumber + 1])
        }
        
        // Get Diagonal nodes above
        let upNodeLayer = nodeLayer + 1
        if (upNodeLayer < pegStates.count){
            if (nodeNumber - 1 > 0 && nodeNumber <= pegStates[upNodeLayer].count - 1 && nodeNumber != pegStates[nodeLayer].count - 2 ){
                myIntArrays.append([upNodeLayer, nodeNumber - 1])
                myIntArrays.append([upNodeLayer, nodeNumber])
            }
            else if (nodeNumber - 1 > 0){
                myIntArrays.append([upNodeLayer, nodeNumber - 1])
            }
            else if (nodeNumber <= pegStates[upNodeLayer].count - 1 && nodeNumber != pegStates[nodeLayer].count - 2){
                myIntArrays.append([upNodeLayer, nodeNumber])
            }
        }
        
        let downNodeLayer = nodeLayer - 1
        if (downNodeLayer >= 1){
            myIntArrays.append([downNodeLayer, nodeNumber])
            myIntArrays.append([downNodeLayer, nodeNumber + 1])
        }
        return myIntArrays
    }
    
    func getCircleNumberFromLayerAndNumber(nodeLayer: Int, nodeNumber: Int) -> Int{
        var counter = 0
        var newNodeLayer = nodeLayer
        for pegStateArray in pegStates {
            if newNodeLayer == 0{
                break
            }
            counter += pegStateArray.count
            newNodeLayer -= 1
        }
        return counter + nodeNumber
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
    
    func startGame(){
        isStarted = true
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true, block: updateTimer)
    }
    
    func updateTimer(timer: Timer){
        time += 1
        TimerLabel.fontSize = 64
        TimerLabel.text = (generateTime(time: time))
    }
    
    func updateGame(){
        let nodeArray = self.children
        var layerNumber = 0
        var nodeNumber = 0
        for node in nodeArray {
            let nodeName = node.name ?? "Broke"
            if nodeName.contains("Circle"){
                let circleNode = node as! SKShapeNode
                // Get its status
                switch pegStates[layerNumber][nodeNumber] {
                    case .active:
                        circleNode.fillColor = UIColor.blue
                    case .deactive:
                        circleNode.fillColor = UIColor.white
                    case .jumpable:
                        circleNode.fillColor = UIColor.green
                    case .selected:
                        circleNode.fillColor = UIColor.purple
                }
                
                // Iterate through layers
                if (nodeNumber >= pegStates[layerNumber].count - 1){
                    layerNumber += 1
                    nodeNumber = 0
                }
                else {
                    nodeNumber += 1
                }
            }
        }
        goalTest()
    }
    
    func goalTest(){
        var counter = 0
        for pegStateArray in pegStates{
            for pegState in pegStateArray {
                if (pegState == .active || pegState == .jumpable){
                    counter += 1
                }
                if (counter >= 2){
                    return
                }
            }
        }
        if (counter == 1){
            isStarted = false
            gameTimer.invalidate()
            resetGame()
            TimerLabel.fontSize = 30
            TimerLabel.text = "Victory Screech!"
            finalTime = time
            time = 0
            for i in 0..<170{
                dropConfetii(name: i)
            }
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: moveToScoreScreen)
        }
        
    }
    
    func moveToScoreScreen(timer: Timer){
        let scoreScreen = YourScoreScreen()
        scoreScreen.scaleMode = .resizeFill
        scoreScreen.time = finalTime
        self.view?.presentScene(scoreScreen, transition: SKTransition.fade(withDuration: 0.5))
    }
}
