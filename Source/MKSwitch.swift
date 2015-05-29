
//
//  MKSwitch.swift
//  MaterialKit
//
//  Created by Daniel Mendez on 5/29/15.
//  Copyright (c) 2015 Le Van Nghia. All rights reserved.
//

import UIKit
import QuartzCore

typealias MKSwitch_Trigger = (currentPoint: Int!) -> (Void)

@IBDesignable
public class MKSwitch : UIView {
    // MARK: - @IBInspectable
    @IBInspectable public var maskEnabled: Bool = true {
        didSet {
            mkLayer.enableMask(enable: maskEnabled)
        }
    }
    @IBInspectable public var rippleLocation: MKRippleLocation = .TapLocation {
        didSet {
            mkLayer.rippleLocation = rippleLocation
        }
    }
    @IBInspectable public var ripplePercent: Float = 0.9 {
        didSet {
            mkLayer.ripplePercent = ripplePercent
        }
    }
    @IBInspectable public var backgroundLayerCornerRadius: CGFloat = 0.0 {
        didSet {
            mkLayer.setBackgroundLayerCornerRadius(backgroundLayerCornerRadius)
        }
    }
    // animations
    @IBInspectable public var shadowAniEnabled: Bool = true
    @IBInspectable public var backgroundAniEnabled: Bool = true {
        didSet {
            if !backgroundAniEnabled {
                mkLayer.enableOnlyCircleLayer()
            }
        }
    }
    @IBInspectable public var rippleAniDuration: Float = 0.75
    @IBInspectable public var backgroundAniDuration: Float = 1.0
    @IBInspectable public var shadowAniDuration: Float = 0.65
    
    @IBInspectable public var rippleAniTimingFunction: MKTimingFunction = .Linear
    @IBInspectable public var backgroundAniTimingFunction: MKTimingFunction = .Linear
    @IBInspectable public var shadowAniTimingFunction: MKTimingFunction = .EaseOut
    
    @IBInspectable public var cornerRadius: CGFloat = 2.5 {
        didSet {
            layer.cornerRadius = cornerRadius
            mkLayer.setMaskLayerCornerRadius(cornerRadius)
        }
    }
    // color
    @IBInspectable public var rippleLayerColor: UIColor = UIColor(white: 0.45, alpha: 0.5) {
        didSet {
            mkLayer.setCircleLayerColor(rippleLayerColor)
        }
    }
    @IBInspectable public var backgroundLayerColor: UIColor = UIColor(white: 0.75, alpha: 0.25) {
        didSet {
            mkLayer.setBackgroundLayerColor(backgroundLayerColor)
        }
    }
    @IBInspectable public var state1Color: UIColor = UIColor.yellowColor()
    @IBInspectable public var state2Color: UIColor = UIColor.blueColor()
    @IBInspectable public var state3Color: UIColor = UIColor.redColor()
    @IBInspectable public var buttonColor: UIColor = UIColor.redColor()
    @IBInspectable public var midLaneColor: UIColor = UIColor.greenColor()
    
    // MARK: - Properties
    var circleCenter: CGPoint = CGPointZero
    var circleWidth: CGFloat = 0.0
    var context: CGContext!
    var circleButton: MKButton!
    var circleFrame: CGRect!
    
    var points = [CGPoint]()
    var currentPoint = 0
    
    var leftSwipe: UISwipeGestureRecognizer!
    var rightSwipe: UISwipeGestureRecognizer!
    
    var trigger: MKSwitch_Trigger!
    private var midLayer: CALayer?
    private lazy var mkLayer: MKLayer = MKLayer(superLayer: self.layer)
    
    // MARK: - Methods
    func changeGestureState(enable: Bool){
        self.leftSwipe.enabled = enable
        self.rightSwipe.enabled = enable
    }
    
    // MARK - setup methods
    private func setupLayer() {
        cornerRadius = 2.5
        mkLayer.setBackgroundLayerColor(backgroundLayerColor)
        mkLayer.setCircleLayerColor(rippleLayerColor)
    }
    
    // MARK: - Delegates
    
    // MARK: - Actions
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            if self.currentPoint - 1 >= 0 {
                self.currentPoint--
                self.changePoint(self.currentPoint)
            }
        }
        
        if (sender.direction == .Right) {
            if self.currentPoint + 1 < self.points.count {
                self.currentPoint++
                self.changePoint(self.currentPoint)
            }
        }
    }
    
    func changePoint(pos: Int){
        self.changeGestureState(false)
        self.currentPoint == pos
        var point = self.points[self.currentPoint]
        self.changeRippleColor()
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.circleButton.frame = CGRectMake(point.x, point.y, self.circleFrame.width, self.circleFrame.height)
            }, completion: { (end: Bool) -> Void in
                self.trigger?(currentPoint: self.currentPoint)
                self.rippleAnimation()
                self.changeGestureState(true)
        })
    }
    
    func changeRippleColor(){
        switch self.currentPoint {
        case 0:
            circleButton.rippleLayerColor = self.state1Color
            break
        case 1:
            circleButton.rippleLayerColor = self.state2Color
            break
        case 2:
            circleButton.rippleLayerColor = self.state3Color
            break
        default: break
        }
    }
    
    func rippleAnimation(){
        self.circleButton.beginTrackingWithTouch(UITouch(), withEvent: UIEvent())
    }
    
    func handlePan(sender: UIPanGestureRecognizer){
        var circleOrigin = self.circleButton.frame.origin
        var limit = self.circleButton.frame.width / 2
        var movePoint = sender.translationInView(self)
        if movePoint.x < limit && circleOrigin.x > limit {
            movePoint.x = movePoint.x + self.frame.width
        }
        var newX = max(min(movePoint.x, self.frame.width - limit), limit)
        println("Panning \(movePoint.x), \(newX), \(circleOrigin.x)")
        if circleOrigin.x >= 0 && circleOrigin.x <= self.frame.width - 5 {
            self.circleButton.frame.origin = CGPoint(x: newX, y: self.circleButton.frame.origin.y)
        }
    }
    
    func set3Points(){
        let midX = (self.frame.width / 2) - (self.circleButton.frame.width / 2)
        let lastX = (self.frame.width) - ((self.circleButton.frame.width))
        let circleOrigin = self.circleButton.frame.origin
        let circleFrame = self.circleButton.frame
        self.points.append(CGPoint(x: circleOrigin.x, y: circleOrigin.y))
        self.points.append(CGPoint(x: midX, y: circleOrigin.y))
        self.points.append(CGPoint(x: lastX, y: circleOrigin.y))
    }
    
    func addCenterLine(){
        let midWidth = (self.frame.width) - ((self.circleButton.frame.width))
        let circleOrigin = self.circleButton.frame.origin
        let circleFrame = self.circleButton.frame
        let circleRadius = circleFrame.width/2
        midLayer = CALayer()
        midLayer?.cornerRadius = circleFrame.height / 4
        midLayer?.frame = CGRect(x: circleOrigin.x + circleRadius, y: circleOrigin.y + (circleRadius / 2), width: midWidth, height: circleFrame.height/2)
        midLayer?.backgroundColor = self.midLaneColor.CGColor
        
        var subView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        subView.layer.addSublayer(midLayer)
        
        self.insertSubview(subView, belowSubview: self.circleButton)
    }
    
    func configButton(){
        circleButton.enabled = false
        circleButton.cornerRadius = self.circleButton.frame.height / 2
        circleButton.backgroundLayerCornerRadius = self.circleButton.frame.height / 2
        circleButton.maskEnabled = false
        circleButton.ripplePercent = 20.0
        circleButton.rippleLocation = .Center
        
        circleButton.layer.shadowOpacity = 0.75
        circleButton.layer.shadowRadius = 1.5
        circleButton.layer.shadowColor = self.buttonColor.CGColor
        circleButton.layer.shadowOffset = CGSize(width: 1.0, height: 1.5)
    }
    
    // MARK: - Overrides
    public override func drawRect(rect: CGRect) {
        self.circleCenter = CGPoint(x: 0, y: self.frame.height / 4)

        self.circleWidth = self.frame.height / 2
        var circleHeight = self.circleWidth
        
        self.circleFrame = CGRectMake(self.circleCenter.x, self.circleCenter.y, self.circleWidth, circleHeight)
        
        self.circleButton = MKButton(frame: self.circleFrame)
        self.circleButton.backgroundColor = self.buttonColor
        self.circleButton.layer.cornerRadius = self.circleWidth / 2
        self.circleButton.cornerRadius = self.circleWidth / 2
        self.addSubview(self.circleButton)
        
//        var panGesture = UIPanGestureRecognizer(target: self, action: Selector("handlePan:"))
        self.leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        self.rightSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        
        leftSwipe.direction = .Left
        rightSwipe.direction = .Right
        
//        self.circleButton.addGestureRecognizer(leftSwipe)
//        self.circleButton.addGestureRecognizer(rightSwipe)
        
        self.addGestureRecognizer(leftSwipe)
        self.addGestureRecognizer(rightSwipe)
        
        self.set3Points()
        self.addCenterLine()
//        self.configStyle()
        self.configButton()
//        self.circleButton.addGestureRecognizer(panGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
//        fatalError("init(coder:) has not been implemented")
    }
}


