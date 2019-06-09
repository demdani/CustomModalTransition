//  Copyright © 2019. Adevinta CMH Kft. All rights reserved.

import UIKit

class PresentedViewController: UIViewController {

    @IBOutlet private weak var cardView: UIView!
    private var transitionType: ModalTransitionType?
    //private let backgroundColor = UIColor.black.withAlphaComponent(0.4)
    private let visualEffectView = UIVisualEffectView()

    init() {
        super.init(nibName: nil, bundle: nil)
        transitioningDelegate = self
        modalPresentationStyle = .custom
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        let effect = UIBlurEffect(style: .dark)
        visualEffectView.effect = effect
        view.insertSubview(visualEffectView, at: 0)

        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissViewController))
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(gestureRecognizer)
    }

    @objc private func dismissViewController() {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

// MARK: Transiton

extension PresentedViewController {

    private var duration: TimeInterval {
        guard let transitionType = transitionType else { return 0.5 }
        switch transitionType {
        case .presentation:
            return 0.44
        case .dismissal:
            return 0.32
        }
    }
}

extension PresentedViewController: UIViewControllerTransitioningDelegate {

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let result = presented == self ? self : nil
        result?.transitionType = .presentation
        return result
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let result = dismissed == self ? self : nil
        result?.transitionType = .dismissal
        return result
    }
}

extension PresentedViewController: UIViewControllerAnimatedTransitioning {

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let transitionType = transitionType else { return }

        let cardOffscreenState = { [weak self] in
            guard let self = self else { return }
            let offscreenY = self.view.frame.height
            self.cardView.transform = CGAffineTransform.identity.translatedBy(x: 0, y: offscreenY)
            self.visualEffectView.alpha = 0
        }

        let presentedState = { [weak self] in
            guard let self = self else { return }
            self.cardView.transform = CGAffineTransform.identity
            self.visualEffectView.alpha = 1
        }

        let animator: UIViewPropertyAnimator = transitionType == .presentation ?
            UIViewPropertyAnimator(duration: duration, dampingRatio: 0.8) :
            UIViewPropertyAnimator(duration: duration, curve: .easeIn)

        switch transitionType {
        case .presentation:
            let toView = transitionContext.view(forKey: .to)!
            toView.frame = CGRect(x: 0,
                                  y: 0,
                                  width: UIScreen.main.bounds.width,
                                  height: UIScreen.main.bounds.height)
            visualEffectView.frame = toView.bounds
            UIView.performWithoutAnimation(cardOffscreenState)
            transitionContext.containerView.addSubview(toView)
            animator.addAnimations(presentedState)
        case .dismissal:
            animator.addAnimations(cardOffscreenState)
        }

        animator.addCompletion { [weak self] _ in
            transitionContext.completeTransition(true)
            self?.transitionType = nil
        }

        animator.startAnimation()
    }
}

private enum ModalTransitionType {
    case presentation
    case dismissal
}
