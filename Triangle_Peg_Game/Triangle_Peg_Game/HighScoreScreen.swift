//
//  scoreScreen.swift
//  Triangle_Peg_Game
//
//  Created by Zeak on 5/3/20.
//  Copyright © 2020 Zeak. All rights reserved.
//


import UIKit
import SpriteKit
import GameplayKit
import CoreData
class HighScoreScreen : SKScene {
    let highScoreLabel = SKLabelNode(text: "High Scores")
    var time: Int = 0
    let height: CGFloat = 355
    var initials: [String] = ["A", "A", "A"]
    var highScores: [NSManagedObject] = []
    var highScoresClassArray: [HighScoresClass] = []
    var sortedHighScoresClassArray: [HighScoresClass] = []
    var appDelegate: AppDelegate!
    var managedObjectContext: NSManagedObjectContext!
    
    func getScores() -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "HighScores")
        var scores: [NSManagedObject] = []
        do {
            scores = try self.managedObjectContext.fetch(fetchRequest)
        } catch{
            print("ERROR!")
        }
        return scores
    }
    
    func addScore(){
        let newInitials = "\(initials[0])\(initials[1])\(initials[2])"
        let newScore = NSEntityDescription.insertNewObject(forEntityName: "HighScores", into: self.managedObjectContext)
        newScore.setValue(newInitials, forKey: "initials")
        newScore.setValue(time, forKey: "score")
        highScores.append(newScore)
        appDelegate.saveContext()
    }
    
    func clearScores(){
        for _ in 0..<highScores.count {
            managedObjectContext.delete(highScores[0])
            highScores.remove(at: 0)
            appDelegate.saveContext()
        }
    }
    
    func addHighScoreLabel(){
        highScoreLabel.position = CGPoint(x: self.frame.midX, y: height - 10)
        highScoreLabel.fontSize = 30
        highScoreLabel.fontName = "Courier New"
        highScoreLabel.name = "Timer"
        self.addChild(highScoreLabel)
    }
    
    
    override func didMove(to view: SKView) {
        // Setup NSObjectContext
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        managedObjectContext = appDelegate.persistentContainer.viewContext
        
        
        // Add labels
        addHighScoreLabel()
        
        // Put the scores on the screen
        generateScores()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//        }
        moveToStart()
        
    }
    
    
    func moveToStart(){
        // Load 'GameScene.sks' as a GKScene. This provides gameplay related content
        // including entities and graphs.
        if let scene = GKScene(fileNamed: "GameScene") {
            
            // Get the SKScene from the loaded GKScene
            if let sceneNode = scene.rootNode as! GameScene? {
                
                // Set the scale mode to scale to fit the window
                sceneNode.scaleMode = .aspectFill
                
                // Present the scene
                if let view = self.view as! SKView? {
                    view.presentScene(sceneNode, transition: SKTransition.fade(withDuration: 0.5))
                    
                    view.ignoresSiblingOrder = true
                    
                    view.showsFPS = true
                    view.showsNodeCount = true
                }
            }
        }
    }
    
    func deleteBottom(){
        var initials: String
        var score: Int64
        var counter = 0
        for scoreToBeDeleted in highScores {
            initials = scoreToBeDeleted.value(forKey: "initials") as? String ?? "AAA"
            score = scoreToBeDeleted.value(forKey: "score") as? Int64 ?? 9223372036854775807
            if (initials == sortedHighScoresClassArray[5].initials && score == sortedHighScoresClassArray[5].score){
                managedObjectContext.delete(highScores[counter])
                highScores.remove(at: counter)
                appDelegate.saveContext()
                return
            }
            counter += 1
        }
    }
    
    func getHighScoresClass(){
        if (highScores.count > 0) {
            for i in 0...4 {
                let currentScore = highScores[i]
                let initials = currentScore.value(forKey: "initials") as? String ?? "AAA"
                let score = currentScore.value(forKey: "score") as? Int64 ?? 9223372036854775807
                highScoresClassArray.append(HighScoresClass(score: score, initials: initials))
            }
            let newInitials = "\(initials[0])\(initials[1])\(initials[2])"
            highScoresClassArray.append(HighScoresClass(score: Int64(self.time), initials: newInitials))
            sortedHighScoresClassArray = highScoresClassArray.sorted(by: {$0.score < $1.score})
            addScore()
            deleteBottom()
        }
        else{
            return
        }
    }
    
    func createDefaults(){
        for _ in highScores.count..<5{
            let newInitials = "AAA"
            let newScore = NSEntityDescription.insertNewObject(forEntityName: "HighScores", into: self.managedObjectContext)
            newScore.setValue(newInitials, forKey: "initials")
            newScore.setValue(7483647, forKey: "score")
            highScores.append(newScore)
            appDelegate.saveContext()
        }
    }
    
    func generateScores(){
        // Get old scores
        highScores = getScores()
        
        // Create defaults
        if highScores.count < 5 {
            createDefaults()
        }
        
        // Place scores inside highScoresClassArray
        getHighScoresClass()
        
        
        // Create all scores
        let height: CGFloat = 280
        var newScoreLabel: SKLabelNode
        var yPosition: Int
        for i in 0..<5 {
            yPosition = Int(height) - 60 * i
            newScoreLabel = SKLabelNode(text: "\(i + 1). \(sortedHighScoresClassArray[i].initials): \(generateTime(time: Int(sortedHighScoresClassArray[i].score)))")
            newScoreLabel.position = CGPoint(x: self.frame.midX, y: CGFloat(yPosition))
            newScoreLabel.name = "Score Label \(i)"
            self.addChild(newScoreLabel)
        }
         
    }
}
