//
//  ViewController.swift
//  Demo
//
//  Created by Joky on 2019/10/26.
//  Copyright © 2019 eyee. All rights reserved.
//

import UIKit
import FacebookLogin
import FacebookCore
import RxSwift
import RxCocoa

class ViewController: UIViewController {
    fileprivate var resultText = "" // empty
    let dispose = DisposeBag()
    var payPalConfig = PayPalConfiguration() // default
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PayPalMobile.preconnect(withEnvironment: PayPalEnvironmentSandbox)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
     
        // Set up payPalConfig
        payPalConfig.acceptCreditCards = false
        payPalConfig.merchantName = "Awesome Shirts, Inc."
        payPalConfig.merchantPrivacyPolicyURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/privacy-full")
        payPalConfig.merchantUserAgreementURL = URL(string: "https://www.paypal.com/webapps/mpp/ua/useragreement-full")
        payPalConfig.languageOrLocale = Locale.preferredLanguages[0]
        payPalConfig.payPalShippingAddressOption = .payPal;
        print("PayPal iOS SDK Version: \(PayPalMobile.libraryVersion())")
        
        let loginButton = FBLoginButton(permissions: [ .publicProfile ])
        loginButton.frame = CGRect(x: 120, y: 100, width: 100, height: 50)
        loginButton.delegate = self
        view.addSubview(loginButton)
        
        let btn = UIButton.init(type: .system)
        btn.frame = CGRect(x: 100, y: 200, width: 200, height: 50)
        btn.setTitle("custom fbLogin", for: .normal)
        view.addSubview(btn)
        btn.backgroundColor = UIColor.yellow
        btn.rx.tap.subscribe(onNext: { [weak self] in
            
            self?.facebookBtnClick()
            
        }).disposed(by: dispose)
        
        let shareProfileBtn = UIButton.init(type: .system)
        shareProfileBtn.frame = CGRect(x: 100, y: 300, width: 200, height: 50)
        shareProfileBtn.setTitle("shareProfile", for: .normal)
        shareProfileBtn.backgroundColor = UIColor.green
        view.addSubview(shareProfileBtn)
        shareProfileBtn.rx.tap.subscribe(onNext: { [weak self] in
            
            self?.shareProfileBtnClick()
            
        }).disposed(by: dispose)
        
        var payBtn = UIButton()
        if #available(iOS 13.0, *) {
            payBtn = UIButton.systemButton(with: UIImage(), target: self, action: #selector(payBtnClick))
        } else {
            // Fallback on earlier versions
            payBtn = UIButton(type: .system)
        }
        payBtn.backgroundColor = UIColor.orange
        payBtn.frame = CGRect(x: 100, y: 400, width: 200, height: 50)
        payBtn.setTitle("payPal", for: .normal)
        view.addSubview(payBtn)
        
    }
    
    /// 按钮监听方法
    @objc func facebookBtnClick() {
        
        // 打开 FBSDKProfile 自动追踪 FBSDKAccessToken
        Profile.enableUpdatesOnAccessTokenChange(true)
        // 清空FBSDKAccessToken
        AccessToken.current = nil
        
        // 登录
        let loginManager: LoginManager = LoginManager()
        loginManager.logOut() // 先退出登录
        
//        loginManager.loginBehavior = .browser // 优先客户端方式
        
        loginManager.logIn(permissions:  ["public_profile"], viewController: self, completion: { (result: LoginResult?) in
            
            print("00000----\(String(describing: result))")
        })
    }
    
    @objc func  payBtnClick() {
        self.startPay()
    }
    
    // 资料共享
    @objc func  shareProfileBtnClick() {
        
        let scopes = [kPayPalOAuth2ScopeOpenId]
        let profileSharingViewController = PayPalProfileSharingViewController(scopeValues: NSSet(array: scopes) as Set<NSObject>, configuration: payPalConfig, delegate: self)
        present(profileSharingViewController!, animated: true, completion: nil)
    }
    
}
// Mark facebook
extension ViewController: LoginButtonDelegate {
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
      print("Did complete login via LoginButton with result \(String(describing: result)) " +
        "error\(String(describing: error))")
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
      print("Did logout via LoginButton")
    }
}

// Mark paypal
extension ViewController: PayPalPaymentDelegate,PayPalProfileSharingDelegate {
    
    func startPay() {
        // Optional: include multiple items
        let item1 = PayPalItem(name: "Old jeans with holes", withQuantity: 2, withPrice: NSDecimalNumber(string: "84.99"), withCurrency: "USD", withSku: "Hip-0037")
        let item2 = PayPalItem(name: "Free rainbow patch", withQuantity: 1, withPrice: NSDecimalNumber(string: "0.00"), withCurrency: "USD", withSku: "Hip-00066")
        let items = [item1, item2]
        let subtotal = PayPalItem.totalPrice(forItems: items)
        
        // Optional: include payment details
        let shipping = NSDecimalNumber(string: "5.99")
        let tax = NSDecimalNumber(string: "2.50")
        let paymentDetails = PayPalPaymentDetails(subtotal: subtotal, withShipping: shipping, withTax: tax)
        
        let total = subtotal.adding(shipping).adding(tax)
        
        let payment = PayPalPayment(amount: total, currencyCode: "USD", shortDescription: "Hipster Clothing", intent: .sale)
        
        payment.items = items
        payment.paymentDetails = paymentDetails
        
        if (payment.processable) {
          let paymentViewController = PayPalPaymentViewController(payment: payment, configuration: payPalConfig, delegate: self)
          present(paymentViewController!, animated: true, completion: nil)
        }
        else {
          // This particular payment will always be processable. If, for
          // example, the amount was negative or the shortDescription was
          // empty, this payment wouldn't be processable, and you'd want
          // to handle that here.
          print("Payment not processalbe: \(payment)")
        }
        
    }
    
    func payPalPaymentDidCancel(_ paymentViewController: PayPalPaymentViewController) {
        self.resultText = ""
        paymentViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalPaymentViewController(_ paymentViewController: PayPalPaymentViewController, didComplete completedPayment: PayPalPayment) {
        print("PayPal Payment Success !")
        paymentViewController.dismiss(animated: true, completion: { () -> Void in
          // send completed confirmaion to your server
          print("Here is your proof of payment:\n\n\(completedPayment.confirmation)\n\nSend this to your server for confirmation and fulfillment.")
          self.resultText = completedPayment.description
        })
    }
    
//    profile
    func userDidCancel(_ profileSharingViewController: PayPalProfileSharingViewController) {
        profileSharingViewController.dismiss(animated: true, completion: nil)
    }
    
    func payPalProfileSharingViewController(_ profileSharingViewController: PayPalProfileSharingViewController, userDidLogInWithAuthorization profileSharingAuthorization: [AnyHashable : Any]) {
        print("PayPal Profile Sharing Authorization Success!")
        // send authorization to your server
        profileSharingViewController.dismiss(animated: true, completion: { () -> Void in
            self.resultText = profileSharingAuthorization.description
        })
    }
    
    
}

