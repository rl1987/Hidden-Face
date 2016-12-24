//
//  ViewController.swift
//  MyFaceTracker
//
//  Created by camtasia on 2016-03-11.
//  Copyright © 2016 camtasia. All rights reserved.
//

import UIKit
import FaceTracker

class ViewController: UIViewController, FaceTrackerViewControllerDelegate {

    weak var faceTrackerViewController: FaceTrackerViewController?
    
    var overlayViews = [String: [UIView]]()
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "faceTrackerEmbed") {
            faceTrackerViewController = segue.destination as? FaceTrackerViewController
            faceTrackerViewController!.delegate = self
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        faceTrackerViewController!.startTracking { () -> Void in
            
        }
    }
    
    func updateViewForFeature(_ feature: String, index: Int, point: CGPoint, bgColor: UIColor) {
        
        let frame = CGRect(x: point.x-2, y: point.y-2, width: 4.0, height: 4.0)
        
        if self.overlayViews[feature] == nil {
            self.overlayViews[feature] = [UIView]()
        }
        
        if index < self.overlayViews[feature]!.count {
            self.overlayViews[feature]![index].frame = frame
            self.overlayViews[feature]![index].isHidden = false
            self.overlayViews[feature]![index].backgroundColor = bgColor
        } else {
            let newView = UIView(frame: frame)
            newView.backgroundColor = bgColor
            newView.isHidden = false
            self.view.addSubview(newView)
            self.overlayViews[feature]! += [newView]
        }
    }
    
    func hideAllOverlayViews() {
        for (_, views) in self.overlayViews {
            for view in views {
                view.isHidden = true
            }
        }
    }
    
    func faceTrackerDidUpdate(_ points: FacePoints?) {
        if let points = points {
            
            
            for (index, point) in points.leftEye.enumerated() {
                self.updateViewForFeature("leftEye", index: index, point: point, bgColor: UIColor.blue)
            }
            
            for (index, point) in points.rightEye.enumerated() {
                self.updateViewForFeature("rightEye", index: index, point: point, bgColor: UIColor.blue)
            }
            
            for (index, point) in points.leftBrow.enumerated() {
                self.updateViewForFeature("leftBrow", index: index, point: point, bgColor: UIColor.white)
            }
            
            for (index, point) in points.rightBrow.enumerated()
            {
                self.updateViewForFeature("rightBrow", index: index, point: point, bgColor: UIColor.white)
            }
            
            for (index, point) in points.nose.enumerated() {
                self.updateViewForFeature("nose", index: index, point: point, bgColor: UIColor.purple)
            }
            
            for (index, point) in points.innerMouth.enumerated() {
                self.updateViewForFeature("innerMouth", index: index, point: point, bgColor: UIColor.red)
            }
            
            for (index, point) in points.outerMouth.enumerated(){
                self.updateViewForFeature("outerMouth", index: index, point: point, bgColor: UIColor.yellow)
            }
            
        }
        else {
            self.hideAllOverlayViews()
        }
    }

}

