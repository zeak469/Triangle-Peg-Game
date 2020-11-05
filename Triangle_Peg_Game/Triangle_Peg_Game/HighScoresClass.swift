//
//  HighScoresClass.swift
//  Triangle_Peg_Game
//
//  Created by Zeak on 5/5/20.
//  Copyright © 2020 Zeak. All rights reserved.
//

import Foundation

class HighScoresClass {
    var score: Int64 = 0
    var initials: String = ""
    
    init(score: Int64, initials: String) {
        self.score = score
        self.initials = initials
    }
}
