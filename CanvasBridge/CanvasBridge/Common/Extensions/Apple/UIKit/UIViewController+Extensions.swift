//
//  UIViewController+Extensions.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import UIKit

public extension UIViewController {
    
    var presentedViewControllers: [UIViewController] {
        presentedViewController.map({ $0.presentedViewControllers.prepending($0) }).orEmpty
    }
    
    var presenter: UIViewController {
        presentedViewControllers.last ?? self
    }
}
