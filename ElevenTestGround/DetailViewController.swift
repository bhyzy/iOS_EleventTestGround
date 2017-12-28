//
//  DetailViewController.swift
//  ElevenTestGround
//
//  Created by Bartlomiej Hyzy on 26/12/2017.
//  Copyright © 2017 Bartlomiej Hyzy. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var commentsView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var commentsActionLabel: UILabel!
    @IBOutlet weak var commentsHeaderLabel: UILabel!
    
    @IBOutlet var expandedConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    
    var detailItem: AnyObject? = nil
    
    var progressWhenInterrupted: CGFloat = 0
    var animator: UIViewPropertyAnimator! = nil
    let transitionDuration: TimeInterval = 0.3
    
    var commentsScrollRange: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentsScrollRange = photoImageView.convert(commentsView.bounds.origin, from: commentsView).y
    }
    
    @IBAction func tappedCommentsSection(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == UIGestureRecognizerState.recognized else { return }
        animateTransitionIfNeeded(duration: transitionDuration)
    }

    @IBAction func pannedCommentsSection(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            animateTransitionIfNeeded(duration: transitionDuration)
            animator.pauseAnimation()
            progressWhenInterrupted = animator.fractionComplete
        case .changed:
            let translation = recognizer.translation(in: photoImageView)
            animator.fractionComplete = progressWhenInterrupted + translation.y / commentsScrollRange
        case .ended:
            let timing = UICubicTimingParameters(animationCurve: .easeOut)
            animator.continueAnimation(withTimingParameters: timing, durationFactor: 0)
        default:
            break
        }
    }
    
    func animateTransitionIfNeeded(duration: TimeInterval) {
        guard animator == nil || animator.isRunning == false else { return }
        
        expandedConstraint.isActive = !expandedConstraint.isActive
        
        animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut, animations: {
            self.view.layoutIfNeeded()
            self.commentsActionLabel.alpha = self.expandedConstraint.isActive ? 0 : 1
            self.commentsHeaderLabel.alpha = self.expandedConstraint.isActive ? 1 : 0
            })
        animator.startAnimation()
    }
}

