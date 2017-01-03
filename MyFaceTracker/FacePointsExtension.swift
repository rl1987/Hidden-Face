//
//  FacePointsExtension.swift
//  MyFaceTracker
//
//  Created by rl1987 on 02/01/17.
//  Copyright © 2017 camtasia. All rights reserved.
//

import Foundation
import FaceTracker

extension FacePoints {
    func rectangleEnclosingCGPoints(_ cgPoints : [CGPoint]) -> CGRect {
        var minX : CGFloat = .infinity
        var maxX : CGFloat = 0.0
        var minY : CGFloat = .infinity
        var maxY : CGFloat = 0.0
        
        for point in cgPoints {
            if point.x < minX {
                minX = point.x
            }
            
            if point.x > maxX {
                maxX = point.x
            }
            
            if point.y < minY {
                minY = point.y
            }
            
            if point.y > maxY {
                maxY = point.y
            }
        }
        
        return CGRect.init(x: minX, y: minY, width: maxX-minX, height: maxY-minY)
    }
    
    func enclosingRect(_ eyesOnly : Bool) -> CGRect {
        var cgPoints = self.leftEye + self.rightEye
        
        if (eyesOnly == false) {
            cgPoints += self.leftBrow
            cgPoints += self.rightBrow
            cgPoints += self.outerMouth
        }
        
        return rectangleEnclosingCGPoints(cgPoints)
    }
    
    func leftEyeCenter() -> CGPoint {
        let enclosingRect = rectangleEnclosingCGPoints(self.leftEye)
        
        return CGPoint.init(x: enclosingRect.midX, y: enclosingRect.midY)
    }
    
    func rightEyeCenter() -> CGPoint {
        let enclosingRect = rectangleEnclosingCGPoints(self.rightEye)
        
        return CGPoint.init(x: enclosingRect.midX, y: enclosingRect.midY)
    }
    
    func interPupillaryDistance() -> CGFloat {
        let deltaX = self.rightEyeCenter().x - self.leftEyeCenter().x
        let deltaY = self.rightEyeCenter().y - self.rightEyeCenter().y
        
        return sqrt(deltaX*deltaX + deltaY*deltaY)
    }
}
