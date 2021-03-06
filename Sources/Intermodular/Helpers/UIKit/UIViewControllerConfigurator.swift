//
// Copyright (c) Vatsal Manot
//

#if os(iOS) || os(tvOS) || targetEnvironment(macCatalyst)

import Swift
import SwiftUI
import UIKit

/// A modifier that can be applied to a view, exposing access to the parent `UIViewController`.
struct UIViewControllerConfigurator: UIViewControllerRepresentable {
    struct Configuration {
        var hidesBottomBarWhenPushed: Bool?
    }
    
    class UIViewControllerType: UIViewController {
        var configuration: Configuration {
            didSet {
                parent?.configure(with: configuration)
            }
        }
        
        init(configuration: Configuration) {
            self.configuration = configuration
            
            super.init(nibName: nil, bundle: nil)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func didMove(toParent parent: UIViewController?) {
            parent?.configure(with: configuration)
            
            super.didMove(toParent: parent)
        }
    }
    
    var configuration: Configuration
    
    init(configuration: Configuration = .init()) {
        self.configuration = configuration
    }
    
    func makeUIViewController(context: Context) -> UIViewControllerType {
        .init(configuration: configuration)
    }
    
    func updateUIViewController(_ viewController: UIViewControllerType, context: Context) {
        viewController.configuration = configuration
    }
    
    func configure(_ transform: (inout Configuration) -> Void) -> Self {
        then({ transform(&$0.configuration) })
    }
}

// MARK: - Auxiliary Implementation -

fileprivate extension UIViewController {
    /// Configures this view controller with a given configuration.
    func configure(with configuration: UIViewControllerConfigurator.Configuration) {
        #if os(iOS) || targetEnvironment(macCatalyst)
        if let newValue = configuration.hidesBottomBarWhenPushed {
            hidesBottomBarWhenPushed = newValue
        }
        #endif
    }
}

fileprivate extension View {
    /// Configures this view's parent `UIViewController`.
    private func configureUIViewController(
        _ transform: (inout UIViewControllerConfigurator.Configuration) -> Void
    ) -> some View {
        background(UIViewControllerConfigurator().configure(transform))
    }
}

// MARK: - API -

extension View {
    /// Sets whether the bottom bar is hidden when this view is pushed.
    @available(tvOS, unavailable)
    public func hidesBottomBarWhenPushed(_ newValue: Bool) -> some View {
        configureUIViewController {
            $0.hidesBottomBarWhenPushed = newValue
        }
    }
}

#endif
