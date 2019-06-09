//  Copyright © 2019. Adevinta CMH Kft. All rights reserved.

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var wallper: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        wallper.image = UIImage(named: "wallper.jpg")
        wallper.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView))
        wallper.addGestureRecognizer(gestureRecognizer)
    }

    @objc func didTapView() {
        let vc = PresentedViewController()
        vc.modalPresentationStyle = .overFullScreen
        present(vc, animated: true, completion: nil)
    }
    
}

