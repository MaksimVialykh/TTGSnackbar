//
//  TTGSnackbar.swift
//  TTGSnackbar
//
//  Created by zekunyan on 15/10/4.
//  Copyright © 2015年 tutuge. All rights reserved.
//

import UIKit
import Darwin

// MARK: -
// MARK: Enum

/**
 Snackbar display duration types.
 
 - Short:   1 second
 - Middle:  3 seconds
 - Long:    5 seconds
 - Forever: Not dismiss automatically. Must be dismissed manually.
 */

@objc public enum TTGSnackbarDuration: Int {
    case short = 1
    case middle = 3
    case long = 5
    case forever = 2147483647 // Must dismiss manually.
}

/**
 Snackbar animation types.
 
 - FadeInFadeOut:               Fade in to show and fade out to dismiss.
 - SlideFromBottomToTop:        Slide from the bottom of screen to show and slide up to dismiss.
 - SlideFromBottomBackToBottom: Slide from the bottom of screen to show and slide back to bottom to dismiss.
 - SlideFromLeftToRight:        Slide from the left to show and slide to rigth to dismiss.
 - SlideFromRightToLeft:        Slide from the right to show and slide to left to dismiss.
 - Flip:                        Flip to show and dismiss.
 */

@objc public enum TTGSnackbarAnimationType: Int {
    case fadeInFadeOut
    case slideFromBottomToTop
    case slideFromBottomBackToBottom
    case slideFromLeftToRight
    case slideFromRightToLeft
    case slideFromTopToBottom
    case slideFromTopBackToTop
}

class TTGSnackbar: UIView {
    // MARK: -
    // MARK: Class property.

    /// Snackbar default frame
    static let snackbarDefaultFrame: CGRect = CGRect(x: 0, y: 0, width: 320, height: 44)
    
    /// Snackbar min height
    static let snackbarMinHeight: CGFloat = 44
    
    /// Snackbar icon imageView default width
    static let snackbarIconImageViewWidth: CGFloat = 32

    // MARK: -
    // MARK: Typealias

    /// Action callback closure definition.
    internal typealias TTGActionBlock = (snackbar:TTGSnackbar) -> Void

    /// Dismiss callback closure definition.
    internal typealias TTGDismissBlock = (snackbar:TTGSnackbar) -> Void

    // MARK: -
    // MARK: Public property.

    /// Action callback.
    internal dynamic var actionBlock: TTGActionBlock? = nil

    /// Second action block
    internal dynamic var secondActionBlock: TTGActionBlock? = nil

    /// Dismiss callback.
    internal dynamic var dismissBlock: TTGDismissBlock? = nil

    /// Snackbar display duration. Default is Short - 1 second.
    internal dynamic var duration: TTGSnackbarDuration = TTGSnackbarDuration.short

    /// Snackbar animation type. Default is SlideFromBottomBackToBottom.
    internal dynamic var animationType: TTGSnackbarAnimationType = TTGSnackbarAnimationType.slideFromBottomBackToBottom

    /// Show and hide animation duration. Default is 0.3
    internal dynamic var animationDuration: NSTimeInterval = 0.3

    /// Corner radius: [0, height / 2]. Default is 4
    internal dynamic var cornerRadius: CGFloat = 4 {
        didSet {
            if cornerRadius < 0 {
                cornerRadius = 0
            }

            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }

    /// Left margin. Default is 4
    internal dynamic var leftMargin: CGFloat = 4 {
        didSet {
            leftMarginConstraint?.constant = leftMargin
            superview?.layoutIfNeeded()
        }
    }

    /// Right margin. Default is 4
    internal dynamic var rightMargin: CGFloat = 4 {
        didSet {
            rightMarginConstraint?.constant = -rightMargin
            superview?.layoutIfNeeded()
        }
    }

    /// Bottom margin. Default is 4, only work when snackbar is at bottom
    internal dynamic var bottomMargin: CGFloat = 4 {
        didSet {
            bottomMarginConstraint?.constant = -bottomMargin
            superview?.layoutIfNeeded()
        }
    }
    
    /// Top margin. Default is 4, only work when snackbar is at top
    internal dynamic var topMargin: CGFloat = 4 {
        didSet {
            topMarginConstraint?.constant = topMargin
            superview?.layoutIfNeeded()
        }
    }
    
    /// Content inset. Default is (0, 4, 0, 4)
    internal dynamic var contentInset: UIEdgeInsets = UIEdgeInsets.init(top: 0, left: 4, bottom: 0, right: 4) {
        didSet {
            contentViewTopConstraint?.constant = contentInset.top
            contentViewBottomConstraint?.constant = -contentInset.bottom
            contentViewLeftConstraint?.constant = contentInset.left
            contentViewRightConstraint?.constant = -contentInset.right
            layoutIfNeeded()
            superview?.layoutIfNeeded()
        }
    }

    /// Main text shown on the snackbar.
    internal dynamic var message: String = "" {
        didSet {
            messageLabel.text = message
        }
    }

    /// Message text color. Default is white.
    internal dynamic var messageTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            messageLabel.textColor = messageTextColor
        }
    }

    /// Message text font. Default is Bold system font (14).
    internal dynamic var messageTextFont: UIFont = UIFont.boldSystemFontOfSize(14) {
        didSet {
            messageLabel.font = messageTextFont
        }
    }

    /// Message text alignment. Default is left
    internal dynamic var messageTextAlign: NSTextAlignment = .Left {
        didSet {
            messageLabel.textAlignment = messageTextAlign
        }
    }

    /// Action button title.
    internal dynamic var actionText: String = "" {
        didSet {
            actionButton.setTitle(actionText, forState: UIControlState())
        }
    }

    /// Second action button title.
    internal dynamic var secondActionText: String = "" {
        didSet {
            secondActionButton.setTitle(secondActionText, forState: UIControlState())
        }
    }

    /// Action button title color. Default is white.
    internal dynamic var actionTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            actionButton.setTitleColor(actionTextColor, forState: UIControlState())
        }
    }

    /// Second action button title color. Default is white.
    internal dynamic var secondActionTextColor: UIColor = UIColor.whiteColor() {
        didSet {
            secondActionButton.setTitleColor(secondActionTextColor, forState: UIControlState())
        }
    }

    /// Action text font. Default is Bold system font (14).
    internal dynamic var actionTextFont: UIFont = UIFont.boldSystemFontOfSize(14) {
        didSet {
            actionButton.titleLabel?.font = actionTextFont
        }
    }

    /// Second action text font. Default is Bold system font (14).
    internal dynamic var secondActionTextFont: UIFont = UIFont.boldSystemFontOfSize(14) {
        didSet {
            secondActionButton.titleLabel?.font = secondActionTextFont
        }
    }
    
    /// Action button max width, min = 44
    internal dynamic var actionMaxWidth: CGFloat = 64 {
        didSet {
            actionMaxWidth = actionMaxWidth < 44 ? 44 : actionMaxWidth
            actionButtonMaxWidthConstraint?.constant = actionButton.hidden ? 0 : actionMaxWidth
            secondActionButtonMaxWidthConstraint?.constant = secondActionButton.hidden ? 0 : actionMaxWidth
            layoutIfNeeded()
        }
    }
    
    /// Action button text number of lines. Default is 1
    internal dynamic var actionTextNumberOfLines: Int = 1 {
        didSet {
            actionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
            secondActionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
            layoutIfNeeded()
        }
    }

    /// Icon image
    internal dynamic var icon: UIImage? = nil {
        didSet {
            iconImageView.image = icon
        }
    }

    /// Icon image content 
    internal dynamic var iconContentMode: UIViewContentMode = .Center {
        didSet {
            iconImageView.contentMode = iconContentMode
        }
    }
    
    /// Custom container view
    internal dynamic var containerView: UIView?
    
    /// Custom content view
    internal dynamic var customContentView: UIView?

    /// SeparateView background color
    internal dynamic var separateViewBackgroundColor: UIColor = UIColor.grayColor() {
        didSet {
            separateView.backgroundColor = separateViewBackgroundColor
        }
    }
    
    /// ActivityIndicatorViewStyle
    internal dynamic var activityIndicatorViewStyle: UIActivityIndicatorViewStyle {
        get {
            return activityIndicatorView.activityIndicatorViewStyle
        }
        set {
            activityIndicatorView.activityIndicatorViewStyle = newValue
        }
    }
    
    /// ActivityIndicatorView color
    internal dynamic var activityIndicatorViewColor: UIColor {
        get {
            return activityIndicatorView.color ?? .whiteColor()
        }
        set {
            activityIndicatorView.color = newValue
        }
    }
    
    /// Animation SpringWithDamping. Default is 0.7
    internal dynamic var animationSpringWithDamping: CGFloat = 0.7
    
    /// Animation initialSpringVelocity
    internal dynamic var animationInitialSpringVelocity: CGFloat = 5

    // MARK: -
    // MARK: Private property.

    var contentView: UIView!
    var iconImageView: UIImageView!
    var messageLabel: UILabel!
    var separateView: UIView!
    var actionButton: UIButton!
    var secondActionButton: UIButton!
    var activityIndicatorView: UIActivityIndicatorView!

    /// Timer to dismiss the snackbar.
    var dismissTimer: NSTimer? = nil

    // Constraints.
    var leftMarginConstraint: NSLayoutConstraint? = nil
    var rightMarginConstraint: NSLayoutConstraint? = nil
    var bottomMarginConstraint: NSLayoutConstraint? = nil
    var topMarginConstraint: NSLayoutConstraint? = nil // Only work when top animation type
    var centerXConstraint: NSLayoutConstraint? = nil
    
    // Content constraints.
    var iconImageViewWidthConstraint: NSLayoutConstraint? = nil
    var actionButtonMaxWidthConstraint: NSLayoutConstraint? = nil
    var secondActionButtonMaxWidthConstraint: NSLayoutConstraint? = nil
    
    var contentViewLeftConstraint: NSLayoutConstraint? = nil
    var contentViewRightConstraint: NSLayoutConstraint? = nil
    var contentViewTopConstraint: NSLayoutConstraint? = nil
    var contentViewBottomConstraint: NSLayoutConstraint? = nil
    
    // MARK: -
    // MARK: Deinit
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: -
    // MARK: Default init

    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    internal override init(frame: CGRect) {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
        configure()
    }

    /**
     Default init
     
     - returns: TTGSnackbar instance
     */
    internal init() {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
        configure()
    }

    /**
     Show a single message like a Toast.
     
     - parameter message:  Message text.
     - parameter duration: Duration type.
     
     - returns: TTGSnackbar instance
     */
    internal init(message: String, duration: TTGSnackbarDuration) {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
        self.duration = duration
        self.message = message
        configure()
    }

    /**
     Show a message with action button.
     
     - parameter message:     Message text.
     - parameter duration:    Duration type.
     - parameter actionText:  Action button title.
     - parameter actionBlock: Action callback closure.
     
     - returns: TTGSnackbar instance
     */
    internal init(message: String, duration: TTGSnackbarDuration, actionText: String, actionBlock: TTGActionBlock) {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
        self.duration = duration
        self.message = message
        self.actionText = actionText
        self.actionBlock = actionBlock
        configure()
    }

    /**
     Show a custom message with action button.
     
     - parameter message:          Message text.
     - parameter duration:         Duration type.
     - parameter actionText:       Action button title.
     - parameter messageFont:      Message label font.
     - parameter actionButtonFont: Action button font.
     - parameter actionBlock:      Action callback closure.
     
     - returns: TTGSnackbar instance
     */
    internal init(message: String, duration: TTGSnackbarDuration, actionText: String, messageFont: UIFont, actionTextFont: UIFont, actionBlock: TTGActionBlock) {
        super.init(frame: TTGSnackbar.snackbarDefaultFrame)
        self.duration = duration
        self.message = message
        self.actionText = actionText
        self.actionBlock = actionBlock
        self.messageTextFont = messageFont
        self.actionTextFont = actionTextFont
        configure()
    }

    // Override
    internal override func layoutSubviews() {
        super.layoutSubviews()
        if messageLabel.preferredMaxLayoutWidth != messageLabel.frame.size.width {
            messageLabel.preferredMaxLayoutWidth = messageLabel.frame.size.width
            setNeedsLayout()
        }
        super.layoutSubviews()
    }
}

// MARK: -
// MARK: Show methods.

extension TTGSnackbar {

    /**
     Show the snackbar.
     */
    internal func show() {
        // Only show once
        if superview != nil {
            return
        }

        // Create dismiss timer
        dismissTimer = NSTimer.scheduledTimerWithTimeInterval((NSTimeInterval)(duration.rawValue),
                                            target: self, selector: #selector(dismiss), userInfo: nil, repeats: false)

        // Show or hide action button
        iconImageView.hidden = icon == nil
        
        actionButton.hidden = actionText.isEmpty || actionBlock == nil
        secondActionButton.hidden = secondActionText.isEmpty || secondActionBlock == nil
        
        separateView.hidden = actionButton.hidden
        
        iconImageViewWidthConstraint?.constant = iconImageView.hidden ? 0 : TTGSnackbar.snackbarIconImageViewWidth
        actionButtonMaxWidthConstraint?.constant = actionButton.hidden ? 0 : actionMaxWidth
        secondActionButtonMaxWidthConstraint?.constant = secondActionButton.hidden ? 0 : actionMaxWidth
        
        // Content View
        let finalContentView = customContentView ?? contentView
        finalContentView?.translatesAutoresizingMaskIntoConstraints = false
        addSubview(finalContentView!)
        
        contentViewTopConstraint = NSLayoutConstraint.init(item: finalContentView!, attribute: .Top, relatedBy: .Equal,
                                                           toItem: self, attribute: .Top, multiplier: 1, constant: contentInset.top)
        contentViewBottomConstraint = NSLayoutConstraint.init(item: finalContentView!, attribute: .Bottom, relatedBy: .Equal,
                                                              toItem: self, attribute: .Bottom, multiplier: 1, constant: -contentInset.bottom)
        contentViewLeftConstraint = NSLayoutConstraint.init(item: finalContentView!, attribute: .Left, relatedBy: .Equal,
                                                            toItem: self, attribute: .Left, multiplier: 1, constant: contentInset.left)
        contentViewRightConstraint = NSLayoutConstraint.init(item: finalContentView!, attribute: .Right, relatedBy: .Equal,
                                                             toItem: self, attribute: .Right, multiplier: 1, constant: -contentInset.right)
        
        addConstraints([contentViewTopConstraint!, contentViewBottomConstraint!, contentViewLeftConstraint!, contentViewRightConstraint!])

        // Get super view to show
        if let superView = containerView ?? UIApplication.sharedApplication().keyWindow {
            superView.addSubview(self)
            
            // Left margin constraint
            leftMarginConstraint = NSLayoutConstraint.init(
                item: self, attribute: .Left, relatedBy: .Equal,
                toItem: superView, attribute: .Left, multiplier: 1, constant: leftMargin)

            // Right margin constraint
            rightMarginConstraint = NSLayoutConstraint.init(
                item: self, attribute: .Right, relatedBy: .Equal,
                toItem: superView, attribute: .Right, multiplier: 1, constant: -rightMargin)

            // Bottom margin constraint
            bottomMarginConstraint = NSLayoutConstraint.init(
                item: self, attribute: .Bottom, relatedBy: .Equal,
                toItem: superView, attribute: .Bottom, multiplier: 1, constant: -bottomMargin)
            
            // Top margin constraint
            topMarginConstraint = NSLayoutConstraint.init(
                item: self, attribute: .Top, relatedBy: .Equal,
                toItem: superView, attribute: .Top, multiplier: 1, constant: topMargin)
            
            // Center X constraint
            centerXConstraint = NSLayoutConstraint.init(
                item: self, attribute: .CenterX, relatedBy: .Equal,
                toItem: superView, attribute: .CenterX, multiplier: 1, constant: 0)
            
            // Min height constraint
            let minHeightConstraint = NSLayoutConstraint.init(
                item: self, attribute: .Height, relatedBy: .GreaterThanOrEqual,
                toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarMinHeight)

            // Avoid the "UIView-Encapsulated-Layout-Height" constraint conflicts
            // http://stackoverflow.com/questions/25059443/what-is-nslayoutconstraint-uiview-encapsulated-layout-height-and-how-should-i
            leftMarginConstraint?.priority = 999
            rightMarginConstraint?.priority = 999
            topMarginConstraint?.priority = 999
            bottomMarginConstraint?.priority = 999
            centerXConstraint?.priority = 999
            
            // Add constraints
            superView.addConstraint(leftMarginConstraint!)
            superView.addConstraint(rightMarginConstraint!)
            superView.addConstraint(bottomMarginConstraint!)
            superView.addConstraint(topMarginConstraint!)
            superView.addConstraint(centerXConstraint!)
            superView.addConstraint(minHeightConstraint)

            // Active or deactive
            topMarginConstraint?.active = false // For top animation
            leftMarginConstraint?.active = customContentView == nil
            rightMarginConstraint?.active = customContentView == nil
            centerXConstraint?.active = customContentView != nil
            
            // Show
            showWithAnimation()
        } else {
            fatalError("TTGSnackbar needs a keyWindows to display.")
        }
    }

    /**
     Show.
     */
    func showWithAnimation() {
        var animationBlock: (() -> Void)? = nil
        let superViewWidth = (superview?.frame)!.width
        let snackbarHeight = systemLayoutSizeFittingSize(CGSizeMake(superViewWidth - leftMargin - rightMargin, TTGSnackbar.snackbarMinHeight)).height

        switch animationType {
            
        case .fadeInFadeOut:
            alpha = 0.0
            // Animation
            animationBlock = {
                self.alpha = 1.0
            }
            
        case .slideFromBottomBackToBottom, .slideFromBottomToTop:
            bottomMarginConstraint?.constant = snackbarHeight
            
        case .slideFromLeftToRight:
            leftMarginConstraint?.constant = leftMargin - superViewWidth
            rightMarginConstraint?.constant = -rightMargin - superViewWidth
            bottomMarginConstraint?.constant = -bottomMargin
            centerXConstraint?.constant = -superViewWidth
            
        case .slideFromRightToLeft:
            leftMarginConstraint?.constant = leftMargin + superViewWidth
            rightMarginConstraint?.constant = -rightMargin + superViewWidth
            bottomMarginConstraint?.constant = -bottomMargin
            centerXConstraint?.constant = superViewWidth
            
        case .slideFromTopBackToTop, .slideFromTopToBottom:
            bottomMarginConstraint?.active = false
            topMarginConstraint?.active = true
            topMarginConstraint?.constant = -snackbarHeight
        }
        
        // Update init state
        superview?.layoutIfNeeded()

        // Final state
        bottomMarginConstraint?.constant = -bottomMargin
        topMarginConstraint?.constant = topMargin
        leftMarginConstraint?.constant = leftMargin
        rightMarginConstraint?.constant = -rightMargin
        centerXConstraint?.constant = 0

        UIView.animateWithDuration(animationDuration, delay: 0,
                       usingSpringWithDamping: animationSpringWithDamping,
                       initialSpringVelocity: animationInitialSpringVelocity, options: .AllowUserInteraction,
                animations: {
                    () -> Void in
                    animationBlock?()
                    self.superview?.layoutIfNeeded()
                }, completion: nil)
    }
}

// MARK: -
// MARK: Dismiss methods.

extension TTGSnackbar {
    
    /**
     Dismiss the snackbar manually.
     */
    internal func dismiss() {
        // On main thread
        dispatch_async(dispatch_get_main_queue()) { 
            self.dismissAnimated(true)
        }
    }

    /**
     Dismiss.
     
     - parameter animated: If dismiss with animation.
     */
    func dismissAnimated(animated: Bool) {
        // If the dismiss timer is nil, snackbar is dismissing or not ready to dismiss.
        if dismissTimer == nil {
            return
        }
        
        invalidDismissTimer()
        activityIndicatorView.stopAnimating()

        let superViewWidth = (superview?.frame)!.width
        let snackbarHeight = frame.size.height

        if !animated {
            dismissBlock?(snackbar: self)
            removeFromSuperview()
            return
        }

        var animationBlock: (() -> Void)? = nil

        switch animationType {
            
        case .fadeInFadeOut:
            animationBlock = {
                self.alpha = 0.0
            }
            
        case .slideFromBottomBackToBottom:
            bottomMarginConstraint?.constant = snackbarHeight
            
        case .slideFromBottomToTop:
            animationBlock = {
                self.alpha = 0.0
            }
            bottomMarginConstraint?.constant = -snackbarHeight - bottomMargin
            
        case .slideFromLeftToRight:
            leftMarginConstraint?.constant = leftMargin + superViewWidth
            rightMarginConstraint?.constant = -rightMargin + superViewWidth
            centerXConstraint?.constant = superViewWidth
            
        case .slideFromRightToLeft:
            leftMarginConstraint?.constant = leftMargin - superViewWidth
            rightMarginConstraint?.constant = -rightMargin - superViewWidth
            centerXConstraint?.constant = -superViewWidth
            
        case .slideFromTopToBottom:
            topMarginConstraint?.active = false
            bottomMarginConstraint?.active = true
            bottomMarginConstraint?.constant = snackbarHeight
            
        case .slideFromTopBackToTop:
            topMarginConstraint?.constant = -snackbarHeight
        }

        setNeedsLayout()
        
        UIView.animateWithDuration(animationDuration, delay: 0,
                       usingSpringWithDamping: animationSpringWithDamping,
                       initialSpringVelocity: animationInitialSpringVelocity, options: .CurveEaseIn,
                animations: {
                    () -> Void in
                    animationBlock?()
                    self.superview?.layoutIfNeeded()
                }) {
            (finished) -> Void in
                    self.dismissBlock?(snackbar: self)
                    self.removeFromSuperview()
        }
    }

    /**
     Invalid the dismiss timer.
     */
    func invalidDismissTimer() {
        dismissTimer?.invalidate()
        dismissTimer = nil
    }
}

// MARK: -
// MARK: Init configuration.

private extension TTGSnackbar {
    
    func configure() {
        // Clear subViews
        for subView in subviews {
            subView.removeFromSuperview()
        }

        // Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(onScreenRotateNotification),
                                               name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = UIColor.init(white: 0, alpha: 0.8)
        layer.cornerRadius = cornerRadius
        layer.shouldRasterize = true
        layer.rasterizationScale = UIScreen.mainScreen().scale
        
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 2
        layer.shadowColor = UIColor.blackColor().CGColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.frame = TTGSnackbar.snackbarDefaultFrame
        contentView.backgroundColor = UIColor.clearColor()

        iconImageView = UIImageView()
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.backgroundColor = UIColor.clearColor()
        iconImageView.contentMode = iconContentMode
        contentView.addSubview(iconImageView)

        messageLabel = UILabel()
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.textColor = UIColor.whiteColor()
        messageLabel.font = messageTextFont
        messageLabel.backgroundColor = UIColor.clearColor()
        messageLabel.lineBreakMode = .ByTruncatingTail
        messageLabel.numberOfLines = 0;
        messageLabel.textAlignment = .Left
        messageLabel.text = message
        contentView.addSubview(messageLabel)

        actionButton = UIButton()
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        actionButton.backgroundColor = UIColor.clearColor()
        actionButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4)
        actionButton.titleLabel?.font = actionTextFont
        actionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        actionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
        actionButton.setTitle(actionText, forState: UIControlState())
        actionButton.setTitleColor(actionTextColor, forState: UIControlState())
        actionButton.addTarget(self, action: #selector(doAction(_:)), forControlEvents: .TouchUpInside)
        contentView.addSubview(actionButton)

        secondActionButton = UIButton()
        secondActionButton.translatesAutoresizingMaskIntoConstraints = false
        secondActionButton.backgroundColor = UIColor.clearColor()
        secondActionButton.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4)
        secondActionButton.titleLabel?.font = secondActionTextFont
        secondActionButton.titleLabel?.adjustsFontSizeToFitWidth = true
        secondActionButton.titleLabel?.numberOfLines = actionTextNumberOfLines
        secondActionButton.setTitle(secondActionText, forState: UIControlState())
        secondActionButton.setTitleColor(secondActionTextColor, forState: UIControlState())
        secondActionButton.addTarget(self, action: #selector(doAction(_:)), forControlEvents: .TouchUpInside)
        contentView.addSubview(secondActionButton)

        separateView = UIView()
        separateView.translatesAutoresizingMaskIntoConstraints = false
        separateView.backgroundColor = separateViewBackgroundColor
        contentView.addSubview(separateView)

        activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .White)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.stopAnimating()
        contentView.addSubview(activityIndicatorView)

        // Add constraints
        let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
            "H:|-0-[iconImageView]-2-[messageLabel]-2-[seperateView(0.5)]-2-[actionButton(>=44@999)]-0-[secondActionButton(>=44@999)]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["iconImageView": iconImageView, "messageLabel": messageLabel, "seperateView": separateView, "actionButton": actionButton, "secondActionButton": secondActionButton])
        
        let vConstraintsForIconImageView = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-2-[iconImageView]-2-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["iconImageView": iconImageView])

        let vConstraintsForMessageLabel = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-0-[messageLabel]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["messageLabel": messageLabel])

        let vConstraintsForSeperateView = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-4-[seperateView]-4-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["seperateView": separateView])

        let vConstraintsForActionButton = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-0-[actionButton]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["actionButton": actionButton])

        let vConstraintsForSecondActionButton = NSLayoutConstraint.constraintsWithVisualFormat(
            "V:|-0-[secondActionButton]-0-|",
            options: NSLayoutFormatOptions(rawValue: 0),
            metrics: nil,
            views: ["secondActionButton": secondActionButton])

        iconImageViewWidthConstraint = NSLayoutConstraint.init(
            item: iconImageView, attribute: .Width, relatedBy: .Equal,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: TTGSnackbar.snackbarIconImageViewWidth)
        
        actionButtonMaxWidthConstraint = NSLayoutConstraint.init(
            item: actionButton, attribute: .Width, relatedBy: .LessThanOrEqual,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: actionMaxWidth)

        secondActionButtonMaxWidthConstraint = NSLayoutConstraint.init(
            item: secondActionButton, attribute: .Width, relatedBy: .LessThanOrEqual,
            toItem: nil, attribute: .NotAnAttribute, multiplier: 1, constant: actionMaxWidth)

        let vConstraintForActivityIndicatorView = NSLayoutConstraint.init(
            item: activityIndicatorView, attribute: .CenterY, relatedBy: .Equal,
            toItem: contentView, attribute: .CenterY, multiplier: 1, constant: 0)

        let hConstraintsForActivityIndicatorView = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:[activityIndicatorView]-2-|",
                options: NSLayoutFormatOptions(rawValue: 0),
                metrics: nil,
                views: ["activityIndicatorView": activityIndicatorView])

        iconImageView.addConstraint(iconImageViewWidthConstraint!)
        actionButton.addConstraint(actionButtonMaxWidthConstraint!)
        secondActionButton.addConstraint(secondActionButtonMaxWidthConstraint!)

        contentView.addConstraints(hConstraints)
        contentView.addConstraints(vConstraintsForIconImageView)
        contentView.addConstraints(vConstraintsForMessageLabel)
        contentView.addConstraints(vConstraintsForSeperateView)
        contentView.addConstraints(vConstraintsForActionButton)
        contentView.addConstraints(vConstraintsForSecondActionButton)
        contentView.addConstraint(vConstraintForActivityIndicatorView)
        contentView.addConstraints(hConstraintsForActivityIndicatorView)
        
        messageLabel.setContentHuggingPriority(1000, forAxis: .Vertical)
        messageLabel.setContentCompressionResistancePriority(1000, forAxis: .Vertical)
        
        actionButton.setContentHuggingPriority(998, forAxis: .Horizontal)
        actionButton.setContentCompressionResistancePriority(999, forAxis: .Horizontal)
        secondActionButton.setContentHuggingPriority(998, forAxis: .Horizontal)
        secondActionButton.setContentCompressionResistancePriority(999, forAxis: .Horizontal)
    }
}

// MARK: -
// MARK: Actions

private extension TTGSnackbar {
    
    /**
     Action button callback
     
     - parameter button: action button
     */
    @objc func doAction(button: UIButton) {
        // Call action block first
        button == actionButton ? actionBlock?(snackbar: self) : secondActionBlock?(snackbar: self)

        // Show activity indicator
        if duration == .forever && actionButton.hidden == false {
            actionButton.hidden = true
            secondActionButton.hidden = true
            separateView.hidden = true
            activityIndicatorView.hidden = false
            activityIndicatorView.startAnimating()
        } else {
            dismissAnimated(true)
        }
    }
}

// MARK: -
// MARK: Rotation notification

private extension TTGSnackbar {
    @objc func onScreenRotateNotification() {
        messageLabel.preferredMaxLayoutWidth = messageLabel.frame.size.width
        layoutIfNeeded()
    }
}
