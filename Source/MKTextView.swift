//
//  MKTextField.swift
//  MaterialKit
//
//  Created by LeVan Nghia on 11/14/14.
//  Copyright (c) 2014 Le Van Nghia. All rights reserved.
//

import UIKit
import QuartzCore

@IBDesignable
public class MKTextView : UITextView {
    // MARK: - Inspectable
    @IBInspectable public var showCounter: Bool = false {
        didSet{
            addCounter()
        }
    }
    @IBInspectable public var counterLimit: Int = 0

    @IBInspectable public var bottomBorderEnabled: Bool = true {
        didSet {
            bottomBorderLayer?.removeFromSuperlayer()
            bottomBorderLayer = nil
            if bottomBorderEnabled {
                var bX = self.frame.origin.x
                var bY = self.frame.height + self.frame.origin.y + 1
                bottomBorderLayer = CALayer()
                bottomBorderLayer?.frame = CGRect(x: bX, y: bY, width: self.frame.width, height: 1)
                bottomBorderLayer?.backgroundColor = bottomBorderColor.CGColor
                self.superview?.layer.addSublayer(bottomBorderLayer)
            }
        }
    }

    @IBInspectable public var bottomBorderWidth: CGFloat = 1.0
    @IBInspectable public var bottomBorderColor: UIColor = UIColor.lightGrayColor() {
        didSet{
            bottomBorderLayer?.backgroundColor = bottomBorderColor.CGColor
        }
    }
    @IBInspectable public var bottomBorderHighlightWidth: CGFloat = 1.75

    @IBInspectable public var placeholder: String? {
        didSet {
            updateFloatingLabelText()
            updatePlaceholderLabelText()
        }
    }

    @IBInspectable public var padding: CGSize = CGSize(width: 2.0, height: 5.0)
    @IBInspectable public var floatingLabelBottomMargin: CGFloat = 2.0
    @IBInspectable public var floatingPlaceholderEnabled: Bool = false

    // floating label
    @IBInspectable public var placeholderLabelFont: UIFont = UIFont.boldSystemFontOfSize(10.0) {
        didSet {
            placeholderLabel.font = placeholderLabelFont
        }
    }

    @IBInspectable public var placeholderLabelTextColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            placeholderLabel.textColor = placeholderLabelTextColor
        }
    }

    @IBInspectable public var floatingLabelTextColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            floatingLabel.textColor = floatingLabelTextColor
        }
    }

    @IBInspectable public var floatingLabelFont: UIFont = UIFont.boldSystemFontOfSize(10.0) {
        didSet {
            floatingLabel.font = floatingLabelFont
        }
    }

    @IBInspectable public var counterLabelTextColor: UIColor = UIColor.lightGrayColor() {
        didSet {
            counterLabel.textColor = counterLabelTextColor
        }
    }

    @IBInspectable public var counterLabelFont: UIFont = UIFont.boldSystemFontOfSize(10.0) {
        didSet {
            counterLabel.font = counterLabelFont
        }
    }


    // MARK: - Properties
    private var bottomBorderLayer: CALayer?
    private var floatingLabel: UILabel!
    private var placeholderLabel: UILabel!
    private var counterLabel: UILabel!

    // MARK: - Methods
    func hidePlaceholderLabel(){
        self.placeholderLabel.alpha = 0
    }

    func showPlaceholderLabel(){
        self.placeholderLabel.alpha = 1.0
    }

    func addCounter(){
        counterLabel = UILabel()
        counterLabel.font = self.font
        counterLabel.alpha = 0.0
        updateCounterCount()
        self.superview?.addSubview(counterLabel)
    }

    private func hideCounterLabel(){
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.counterLabel?.alpha = 0.0
        })
    }

    private func showCounterLabel(){
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.counterLabel?.alpha = 1.0
        })
    }

    func updateCounterCount(){
        var textLength = 0
        if !text.isEmpty{
            textLength = count(text)
        }
        if counterLimit > 0 {
            self.counterLabel.text = "\(textLength) / \(counterLimit)"
        }else{
            self.counterLabel.text = "\(textLength)"
        }
        updateCounterLabel()
    }

    func updateCounterLabel(){
        self.counterLabel.sizeToFit()
        var x = bounds.size.width + frame.origin.x - self.counterLabel.frame.width
        var y = bounds.size.height + frame.origin.y + 2.0
        self.counterLabel.frame = CGRectMake(x, y, self.counterLabel.frame.width, self.counterLabel.frame.height)
    }

    public func clear(){
        self.text = ""
        self.textViewDidChange(self)
    }


    private func setupLayer() {
        self.delegate = self

        // floating label
        floatingLabel = UILabel()
        floatingLabel.font = floatingLabelFont
        floatingLabel.alpha = 1.0
        updateFloatingLabelText()
//        self.textContainerInset.top = 30.0

        // placeholder label
        placeholderLabel = UILabel(frame: CGRect(x: self.textContainerInset.left + 3, y: self.textContainerInset.top, width: 0, height: 0))
        placeholderLabel.font = self.font

        insertSubview(placeholderLabel, atIndex: 0)
//        insertSubview(floatingLabel, atIndex: 0)
    }


    public func textRectForBounds(bounds: CGRect) -> CGRect {
        let rect = self.bounds
        var newRect = CGRect(x: rect.origin.x + padding.width, y: rect.origin.y,
            width: rect.size.width - 2*padding.width, height: rect.size.height)

        if !floatingPlaceholderEnabled {
            return newRect
        }

        if !text.isEmpty {
            let dTop = floatingLabel.font.lineHeight + floatingLabelBottomMargin
            newRect = UIEdgeInsetsInsetRect(newRect, UIEdgeInsets(top: dTop, left: 0.0, bottom: 0.0, right: 0.0))
        }
        return newRect
    }
    
    func getBorderBottomFrame() -> CGRect {
        bottomBorderLayer?.backgroundColor = isFirstResponder() ? tintColor.CGColor : bottomBorderColor.CGColor
        let borderWidth = isFirstResponder() ? bottomBorderHighlightWidth : bottomBorderWidth
        var bX = self.frame.origin.x
        var bY = self.frame.height + self.frame.origin.y + 1
        return CGRect(x: bX, y: bY, width: self.frame.width, height: borderWidth)
    }

    // MARK: - Overrides

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupLayer()
    }

    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayer()
    }
}

// MARK - private methods
private extension MKTextView {
    private func setFloatingLabelOverlapTextField() {
        let textRect = textRectForBounds(bounds)
        var originX = textRect.origin.x
        switch textAlignment {
        case .Center:
            originX += textRect.size.width/2 - floatingLabel.bounds.width/2
        case .Right:
            originX += textRect.size.width - floatingLabel.bounds.width
        default:
            break
        }
        let positionFrame = CGRect(x: self.frame.origin.x + originX + padding.width, y: self.frame.origin.y - self.floatingLabel.frame.height, width: floatingLabel.frame.size.width, height: floatingLabel.frame.size.height)

//        floatingLabel.frame = CGRect(x: originX, y: padding.height,
//            width: floatingLabel.frame.size.width, height: floatingLabel.frame.size.height)
        floatingLabel.frame = positionFrame
    }

    private func showFloatingLabel() {
        floatingLabel.removeFromSuperview()
        self.superview?.insertSubview(floatingLabel, aboveSubview: self)
        let curFrame = floatingLabel.frame
        let superCurFrame = self.frame
        floatingLabel.frame = CGRect(x: curFrame.origin.x, y: curFrame.origin.y + bounds.height/2, width: curFrame.width, height: curFrame.height)
        UIView.animateWithDuration(0.45, delay: 0.0, options: .CurveEaseOut,
            animations: {
                self.floatingLabel.alpha = 1.0
                self.floatingLabel.frame = curFrame
            }, completion: nil)
    }

    private func hideFloatingLabel() {
        floatingLabel.alpha = 0.0
    }

    private func updateFloatingLabelText() {
        floatingLabel.text = placeholder
        floatingLabel.sizeToFit()
        setFloatingLabelOverlapTextField()
    }

    private func updatePlaceholderLabelText() {
        placeholderLabel.text = placeholder
        placeholderLabel.sizeToFit()
        setFloatingLabelOverlapTextField()
    }
}

extension MKTextView: UITextViewDelegate{
    public func textViewDidChange(textView: UITextView) {
        if showCounter {
            updateCounterCount()
        }
        if !textView.text.isEmpty{
            hidePlaceholderLabel()
            showCounterLabel()
            floatingLabel.textColor = isFirstResponder() ? tintColor : floatingLabelTextColor
            if floatingLabel.alpha == 0 {
                showFloatingLabel()
            }
            return ()
        }
        showPlaceholderLabel()
        hideCounterLabel()
        hideFloatingLabel()
    }

    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        var actualCount = count(textView.text)
        var replaceCount = count(text)

        if counterLimit > 0 {
            if actualCount < counterLimit {
                if replaceCount > 1 {
                    textView.text = textView.text + text.truncate(counterLimit - actualCount, trailing: nil)
                    self.textViewDidChange(textView)
                    return false
                }
            }
            if actualCount + replaceCount > counterLimit{
                return false
            }
        }
        if actualCount + replaceCount > 0 {
            self.textViewDidChange(textView)
        }
        return true
    }

    public func textViewDidBeginEditing(textView: UITextView) {
        bottomBorderLayer?.frame = self.getBorderBottomFrame()
    }

    public func textViewDidEndEditing(textView: UITextView) {
        bottomBorderLayer?.frame = self.getBorderBottomFrame()
    }
}

extension String {
    /// Truncates the string to length number of characters and
    /// appends optional trailing string if longer
    func truncate(length: Int, trailing: String? = nil) -> String {
        if count(self) > length {
            return self.substringToIndex(advance(self.startIndex, length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}
