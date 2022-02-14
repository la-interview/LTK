//
//  SceneDelegate.swift
//  LTK
//
//  Created by Laura Artiles on 2/5/22.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

  var window: UIWindow?


  func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
    guard let windowScene = (scene as? UIWindowScene) else { return }
    
    let window = UIWindow(windowScene: windowScene)
    
    let service = LTKContentService()
    let factory = LTKViewControllerFactory(service: service)
    let feedViewController = factory.makeFeedViewController()
    window.rootViewController = UINavigationController(rootViewController: feedViewController)
    window.makeKeyAndVisible()
    self.window = window
  }
}

