    func show(_ inView: UIView) {
        inView.addSubview(self)
        snp.remakeConstraints { make in
            make.center.equalToSuperview()
        }
        inView.layoutIfNeeded()
        transform = CGAffineTransform(translationX: 0, y: 60)
        let animation = UIViewPropertyAnimator(duration: 0.3, dampingRatio: 0.5)
        animation.addAnimations {
            self.transform = .identity
            self.alpha = 1
        }
        animation.startAnimation()
    }
    func hide() {
        UIView.animate(withDuration: 0.2) {
            self.alpha = 0
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    modalPresentationStyle = .overFullScreen
    modalTransitionStyle = .crossDissolve
    definesPresentationContext = false
    #41505B-0.55
