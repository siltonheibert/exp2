//
//  jsView.swift
//  vexController
//
//  Created by Levi Pope on 4/30/21.
//

import Foundation
import UIKit

class StickView: UIView {
    
    var nameLabel: UILabel!
    var valueLabel: UILabel!
    var controlView: UIView!
    var touchesView: UIView!
    var boundsView: UIView!
    var startPoint: CGPoint!
    
    var maxX:CGFloat = 0.0
    var maxY:CGFloat = 0.0
    
    var pressedVal:Bool = false
    
    var sensitive:Float = 0.75
    
    private var valX:Float = 0.0
    private var valY:Float = 0.0
    
    public typealias StickMovedHandler = ((Float, Float) -> Void)
    public var stickMovedHandler: StickMovedHandler?
    
    public typealias PressedHandler = ((Bool) -> Void)
    public var pressedHandler: PressedHandler?
    
    
//    var value: Float {
//        get {
//            return self.value
//        }
//        set {
//            self.value = newValue
//        }
//    }
    
    var X: Float {
        get {
            return self.valX
        }
    }
    
    var Y: Float {
        get {
            return self.valY
        }
    }
    
    var Pressed: Bool {
        get {
            return self.pressedVal
        }
    }
    
    var Sensitivity: Float {
        get {
            return self.sensitive
        }
        set {
            if(self.sensitive != newValue)
            {
                if(newValue > 0.0 && newValue <= 1.0)
                {
                    self.sensitive = 1.0 - newValue
                    maxX = frame.width * CGFloat(self.sensitive)
                    maxY = frame.height * CGFloat(self.sensitive)
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        
        nameLabel = UILabel(frame: CGRect(x: 0, y: frame.size.height - 20, width: frame.size.width, height: 15))
        nameLabel.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        nameLabel.textAlignment = .center
        nameLabel.font = UIFont(name: nameLabel.font.fontName, size: 10)
        addSubview(nameLabel)
        
        valueLabel = UILabel(frame: CGRect(x: 10, y: 10, width: frame.size.width - 20, height: 15))
        valueLabel.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleTopMargin]
        valueLabel.text = "0.0/0.0"
        valueLabel.font = UIFont(name: valueLabel.font.fontName, size: 10)
        valueLabel.textAlignment = .center
        addSubview(valueLabel)
        
        let controlViewSide = frame.width * 0.1
        controlView = UIView(frame: CGRect(x: (frame.width/2.0)-(controlViewSide/2), y: (frame.height/2.0)-(controlViewSide/2), width: controlViewSide, height: controlViewSide))
        //controlView.layer.cornerRadius = controlView.bounds.size.width / 2
        controlView.backgroundColor = UIColor.darkGray
        addSubview(controlView)
        
        backgroundColor = UIColor.lightGray
        //layer.cornerRadius = (frame.width / 2) - 50
        
        centerController(0.0)
        
        maxX = frame.width * CGFloat(self.sensitive)
        maxY = frame.height * CGFloat(self.sensitive)
        
        touchesView = self //controlView
//        controlView.isUserInteractionEnabled = true
        controlView.isHidden = true
    }
    
    func percentageForce(_ touch: UITouch) -> Float {
        let force = Float(touch.force)
        let maxForce = Float(touch.maximumPossibleForce)
        let percentageForce: Float
        if force == 0 { percentageForce = 0 } else { percentageForce = force / maxForce }
        return percentageForce
    }
    
    // Manage the frequency of updates
    var lastMotionRefresh: Date = Date()
    
    func processTouch(_ touch: UITouch!) {
        if touch!.view == touchesView {
            // Avoid updating too often
            if lastMotionRefresh.timeIntervalSinceNow > -(1 / 60) { return } else { lastMotionRefresh = Date() }
            
            // Prevent the stick from leaving the view center area
            let newX = touch!.location(in: self).x
            let newY = touch!.location(in: self).y
            print("Super raw: \(newX) \(newY)")
            
            controlView.center = CGPoint(x: newX, y: newY)
            

            
            self.valX = Float((newX - startPoint.x) / maxX)
            self.valY = Float(((newY - startPoint.y) / maxY) * -1.0)

            
            if(self.valX > 1.0){
                self.valX = 1.0
            }
            else if(self.valX < -1.0){
                self.valX = -1.0
            }
            
            if(self.valY > 1.0){
                self.valY = 1.0
            }
            else if(self.valY < -1.0){
                self.valY = -1.0
            }
            
            print("X: \(self.valX), Y: \(self.valY)")

            if let handler = self.stickMovedHandler {
                handler(self.valX, self.valY)
            }
            
            valueLabel.text = "\(round(self.valX * 100.0) / 100)/\(round(self.valY * 100.0) / 100)"
        }
    }

    func rawToDegrees(raw: CGFloat) -> CGFloat {
        switch raw {
        case _ where raw > 0:
            return 90 + (raw * 100)
        case _ where raw < 0:
            return 90 - (-raw * 100)
        default:
            return 90
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        startPoint = touch!.location(in: self)
        processTouch(touch)
        controlView.isHidden = false
        self.backgroundColor = UIColor.green
        self.pressedVal = true
        if let handler = self.pressedHandler {
            handler(self.pressedVal)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        processTouch(touch)
        self.pressedVal = true
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        //let touch = touches.first
        //processTouch(touch)
        //if touch!.view == touchesView {
            centerController(0.0)
        //}
        controlView.isHidden = true
        self.backgroundColor = UIColor.lightGray
        self.pressedVal = false

        if let handler = self.pressedHandler {
            handler(self.pressedVal)
        }
    }
    
    // Re-center the control element
    func centerController(_ duration: Double) {
        
        self.valX = 0.0
        self.valY = 0.0
        
        valueLabel.text = "\(round(self.valX * 100.0) / 100)/\(round(self.valY * 100.0) / 100)"
        
        if let handler = self.stickMovedHandler {
            handler(self.valX, self.valY)
        }

    }
}
