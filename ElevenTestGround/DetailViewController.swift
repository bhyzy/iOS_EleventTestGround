//
//  DetailViewController.swift
//  ElevenTestGround
//
//  Created by Bartlomiej Hyzy on 26/12/2017.
//  Copyright © 2017 Bartlomiej Hyzy. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    var detailItem: AnyObject? = nil
    
    @IBOutlet var expandedConstraint: NSLayoutConstraint!
    @IBOutlet weak var tapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var commentsActionLabel: UILabel!
    @IBOutlet weak var commentsHeaderLabel: UILabel!
    
    @IBAction func tappedCommentsSection(_ recognizer: UITapGestureRecognizer) {
        guard recognizer.state == UIGestureRecognizerState.recognized else { return }

        expandedConstraint.isActive = !expandedConstraint.isActive
        UIView.animate(withDuration: 0.3,
                       delay: 0,
                       options: [UIViewAnimationOptions.curveEaseOut, UIViewAnimationOptions.beginFromCurrentState, UIViewAnimationOptions.allowUserInteraction],
                       animations: {
                        self.view.layoutIfNeeded()
                        self.commentsActionLabel.alpha = self.expandedConstraint.isActive ? 0 : 1
                        self.commentsHeaderLabel.alpha = self.expandedConstraint.isActive ? 1 : 0
            }
        )
    }
}

