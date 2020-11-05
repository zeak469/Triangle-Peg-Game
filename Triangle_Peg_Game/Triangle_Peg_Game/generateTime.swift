//
//  generateTime.swift
//  Triangle_Peg_Game
//
//  Created by Zeak on 5/4/20.
//  Copyright © 2020 Zeak. All rights reserved.
//

import Foundation


func generateTime(time: Int) -> String {
    var minutesString: String = "00"
    var hoursString: String = "00"
    var minutesInt: Int
    var hoursInt: Int
    
    // Exists hours
    if (time >= 3600){
        hoursInt = ( time / 60 ) / 60
        if hoursInt < 10 {
            hoursString = "0\(hoursInt)"
        }
        else{
            hoursString = "\(hoursInt)"
        }
        
        minutesInt = (time / 60) % 60
        if minutesInt < 10 {
            minutesString = "0\(minutesInt)"
        }
        else{
            minutesString = "\(minutesInt)"
        }
        
    }
        
    // Exists only minutes
    else if (time >= 60){
        minutesInt = time / 60
        if minutesInt < 10 {
           minutesString = "0\(minutesInt)"
        }
        else{
           minutesString = "\(minutesInt)"
        }
    }
    
    return ("\(hoursString):\(minutesString)")
}
