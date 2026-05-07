//
//  BaseViewController.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import UIKit

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigation()
        setupUI()
    }
    
    func setupNavigation() {
        navigationController?.navigationBar.tintColor = UIColor.label
    }
    
    func setupUI() {
        view.backgroundColor = .systemBackground
    }
}
