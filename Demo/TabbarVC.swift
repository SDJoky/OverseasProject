//
//  TabbarVC.swift
//  Demo
//
//  Created by Joky on 2019/10/29.
//  Copyright © 2019 eyee. All rights reserved.
//

import UIKit

class TabbarVC: UITabBarController {
    override func viewDidLoad() {
           super.viewDidLoad()
           tabBar.tintColor = UIColor.orange
           addChildViewControllers()
           let navigationBar = UINavigationBar.appearance()
           navigationBar.setBackgroundImage(UIImage(named: "navigation_background"), for: .default)
           navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.purple]
           navigationBar.tintColor = UIColor.yellow
       }
       
       private func addChildViewControllers() {
           setChildViewController(ViewController(), title: "LoginPay", imageName: "live_nor",selectName: "zhibo_hi")
       }
       
       private func setChildViewController(_ childVC:UIViewController ,title:String ,imageName:String ,selectName:String) {
           childVC.title = title;
           childVC.tabBarItem.image = UIImage (named: imageName)?.withRenderingMode(.alwaysOriginal)
           childVC.tabBarItem.selectedImage = UIImage (named: selectName)?.withRenderingMode(.alwaysOriginal)
           let navBar : UINavigationController = UINavigationController(rootViewController: childVC)
           addChild(navBar)
       }
}
