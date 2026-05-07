//
//  Flow.swift
//  CanvasBridge
//
//  Created by Dumitru Paraschiv on 07.05.2026.
//

import Swinject
import UIKit

protocol Flow: AnyObject, Presentable {
    
    var childFlows: [Flow] { get set }
    var parentFlow: Flow? { get set }
    var firstViewController: UIViewController? { get }
    var lastViewController: UIViewController? { get }
    
    func start()
    func addChild(_ flow: Flow)
    func removeChild(_ flow: Flow)
    func removeAllChildren()
    func finish()
}

class BaseFlow<Controller: UIViewController>: Flow, AnyFactory {
    
    var childFlows = [Flow]()
    weak var parentFlow: Flow?
    let r: Resolver
    
    private(set) var controller: Controller
    
    private var presentationDelegates = [ObjectIdentifier: PresentationControllerDelegate]()
    private var dismissCompletions = [ObjectIdentifier: EmptyCallback]()
    
    init(r: Resolver, controller: Controller) {
        self.r = r
        self.controller = controller
    }
    
    // MARK: - Presentable
    
    func toPresent() -> UIViewController {
        controller
    }
    
    // MARK: - Flow
    
    var firstViewController: UIViewController? {
        nil
    }
    
    var lastViewController: UIViewController? {
        nil
    }
    
    func start() {
        // Default implementation does nothing
        // Subclasses should override to provide custom behavior
    }
    
    func addChild(_ flow: Flow) {
        childFlows.append(flow)
        flow.parentFlow = self
        flow.start()
    }
    
    func removeChild(_ flow: Flow) {
        childFlows.removeAll { $0 === flow }
    }
    
    func removeAllChildren() {
        childFlows.forEach { $0.finish() }
        childFlows.removeAll()
    }
    
    func finish() {
        removeAllChildren()
        parentFlow?.removeChild(self)
    }
    
    func present(_ presentable: Presentable,
                 embeddingNavigationFlow: NavigationFlow? = nil,
                 animated: Bool = true,
                 completion: EmptyCallback? = nil,
                 dismissCompletion: EmptyCallback? = nil) {
        embeddingNavigationFlow?.setRoot(presentable)
        
        let resolvedPresentable = embeddingNavigationFlow ?? presentable
        let viewController = resolvedPresentable.toPresent()
        
        if let flow = resolvedPresentable as? Flow {
            let dismissCompletion = { [weak self, weak flow] in
                flow.flatMap { self?.removeChild($0) }
                dismissCompletion?()
            }
            addChild(flow)
            saveDismissCompletion(viewController, dismissCompletion)
        } else {
            saveDismissCompletion(viewController, dismissCompletion)
        }
        
        // Setup delegate BEFORE presenting to ensure it's ready
        setupPresentationDelegate(for: viewController)
        
        controller.presenter.present(viewController, animated: animated) { [weak self] in
            // Ensure delegate is still set after presentation completes
            // (needed when animated: false, as the timing can be unpredictable)
            self?.setupPresentationDelegate(for: viewController)
            completion?()
        }
    }
    
    func dismiss(_ presentable: Presentable,
                 animated: Bool = true,
                 completion: EmptyCallback? = nil) {
        let presented = presentable.toPresent()
        
        guard presented.presentingViewController.isSome else {
            if let flow = presentable as? Flow {
                removeChild(flow)
            }
            runDismissCompletion(presented)
            completion?()
            return
        }
        
        guard presented.isBeingDismissed.isFalse else {
            completion?()
            return
        }
        
        if let flow = presentable as? Flow {
            removeChild(flow)
        }
        
        presented.dismiss(animated: animated) { [weak self] in
            self?.runDismissCompletion(presented)
            completion?()
        }
    }
    
    // MARK: - Lifecycle
    
#if DEBUG
    deinit {
        // Help catch memory leaks during development
        trace("ℹ \(type(of: self)) deallocated")
    }
#endif
}

// MARK: - Presentation Tracking

private extension BaseFlow {
    
    func setupPresentationDelegate(for viewController: UIViewController) {
        guard let presentationController = viewController.presentationController else { return }
        
        let identifier = ObjectIdentifier(viewController)
        
        // Reuse existing delegate if already set
        if let existingDelegate = presentationDelegates[identifier] {
            presentationController.delegate = existingDelegate
            return
        }
        
        // Create new delegate
        let delegate = DefaultPresentationControllerDelegate()
        delegate.didDismiss = { [weak self, weak viewController] in
            guard let viewController else { return }
            
            self?.runDismissCompletion(viewController)
        }
        
        presentationDelegates[identifier] = delegate
        presentationController.delegate = delegate
    }
    
    func runDismissCompletion(_ viewController: UIViewController) {
        let identifier = ObjectIdentifier(viewController)
        dismissCompletions.removeValue(forKey: identifier)?()
        presentationDelegates.removeValue(forKey: identifier)
    }
    
    func saveDismissCompletion(_ viewController: UIViewController, _ completion: EmptyCallback?) {
        guard let completion else { return }
        
        dismissCompletions[ObjectIdentifier(viewController)] = completion
    }
}
