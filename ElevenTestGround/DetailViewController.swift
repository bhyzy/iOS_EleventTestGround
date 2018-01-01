//
//  DetailViewController.swift
//  ElevenTestGround
//
//  Created by Bartlomiej Hyzy on 26/12/2017.
//  Copyright © 2017 Bartlomiej Hyzy. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    @IBOutlet weak var commentsActionLabel: UILabel!
    @IBOutlet weak var commentsHeaderLabel: UILabel!
    
    @IBOutlet var expandedConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    
    var detailItem: AnyObject? = nil
    
    let transitionDuration: TimeInterval = 0.7
    let dampingRatio: CGFloat = 1
    let swipeVelocityThreshold: CGFloat = 200
    let releaseProgressThreshold: CGFloat = 0.3
    
    var progressWhenInterrupted: CGFloat = 0

    var runningAnimators = [UIViewPropertyAnimator]()
    
    enum State {
        case Collaped
        case Expanded
        
        @discardableResult mutating func toggle() -> State {
            switch self {
            case .Collaped:
                self = .Expanded
            case .Expanded:
                self = .Collaped
            }
            return self
        }
    }
    
    var currentState: State = .Collaped
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.blurView.effect = nil
        self.blurView.alpha = 1
    }
    
    @IBAction func tappedCommentsSection(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == UIGestureRecognizerState.recognized else { return }
        guard currentState == .Collaped || !runningAnimators.isEmpty else { return }
        
        currentState.toggle()
        animateOrReverseRunningTransition(state: currentState, duration: transitionDuration)
    }

    @IBAction func pannedCommentsSection(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            if runningAnimators.isEmpty {
                currentState.toggle()
            }
            startInteractiveTransition(state: currentState, duration: transitionDuration)
        case .changed:
            let translation = recognizer.translation(in: photoImageView)
            let verticalDelta = translation.y * (currentState == .Collaped ? 1 : -1)
            let deltaFraction = verticalDelta / photoImageView.frame.height
            updateInteractiveTransition(fractionDelta: deltaFraction)
        case .ended:
            var cancel: Bool
            let velocity = recognizer.velocity(in: photoImageView)
            if abs(velocity.y) >= swipeVelocityThreshold {
                cancel = (currentState == .Expanded && velocity.y > 0) || (currentState == .Collaped && velocity.y < 0)
            } else {
                let fractionCompleted = runningAnimators[0].fractionComplete
                cancel = fractionCompleted < releaseProgressThreshold
            }
            continueInteractiveTransition(cancel: cancel)
            if cancel {
                currentState.toggle()
            }
        default:
            break
        }
    }

    func animateTransitionIfNeeded(state: State, duration: TimeInterval) {
        guard runningAnimators.isEmpty else { return }
        
        let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dampingRatio) {
            self.expandedConstraint.isActive = (state == .Expanded)
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        appendAnimator(frameAnimator)
        
        let labelAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: dampingRatio) {
            self.commentsActionLabel.alpha = state == .Collaped ? 1 : 0
            self.commentsHeaderLabel.alpha = state == .Expanded ? 1 : 0
        }
        appendAnimator(labelAnimator)
        
        let controlPoints = state == .Expanded ?
            [CGPoint(x: 0.75, y: 0.1), CGPoint(x: 0.9, y: 0.25)] :
            [CGPoint(x: 0.1, y: 0.75), CGPoint(x: 0.25, y: 0.9)];
        let blurTiming = UICubicTimingParameters(controlPoint1: controlPoints[0], controlPoint2: controlPoints[1])
        let blurAnimator = UIViewPropertyAnimator(duration: duration, timingParameters: blurTiming)
        blurAnimator.addAnimations {
            self.blurView.effect = state == .Expanded ? UIBlurEffect(style: .dark) : nil
        }
        blurAnimator.scrubsLinearly = false
        appendAnimator(blurAnimator)
    }
    
    func animateOrReverseRunningTransition(state: State, duration: TimeInterval) {
        if runningAnimators.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        } else {
            reverseRunningAnimators()
        }
    }
    
    func startInteractiveTransition(state: State, duration: TimeInterval) {
        animateTransitionIfNeeded(state: state, duration: duration)
        for animator in runningAnimators {
            animator.pauseAnimation()
        }
        progressWhenInterrupted = runningAnimators[0].fractionComplete
    }
    
    func updateInteractiveTransition(fractionDelta: CGFloat) {
        let fractionComplete = progressWhenInterrupted + fractionDelta
        for animator in runningAnimators {
            animator.fractionComplete = fractionComplete
        }
    }
    
    func continueInteractiveTransition(cancel: Bool) {
        if cancel {
            reverseRunningAnimators()
        }
        let timing = UISpringTimingParameters(dampingRatio: dampingRatio)
        for animator in runningAnimators {
            animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
        }
    }
    
    func appendAnimator(_ animator: UIViewPropertyAnimator) {
        animator.addCompletion { _ in
            if let index = self.runningAnimators.index(of: animator) {
                self.runningAnimators.remove(at: index)
            }
        }
        animator.startAnimation()
        runningAnimators.append(animator)
    }
    
    func reverseRunningAnimators() {
        for animator in runningAnimators {
            animator.isReversed = !animator.isReversed
        }
    }
}

