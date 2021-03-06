//
//  AddressQRCodeController.swift
//  BankexWallet
//
//  Created by Korovkina, Ekaterina on 3/13/2561 BE.
//  Copyright © 2561 Alexander Vlasov. All rights reserved.
//

import UIKit
import web3swift

class AddressQRCodeController: UIViewController {

    var addressToGenerateQR: String?
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var walletNameLabel: UILabel!
    @IBOutlet weak var copiedIcon: UIImageView!
    @IBOutlet weak var copiedLabel: UILabel!
    @IBOutlet weak var copyAddressButton: UIButton!
    
    let keysService: SingleKeyService  = SingleKeyServiceImplementation()
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        imageView.image = generateQRCode(from: addressToGenerateQR)
        addressLabel.text = addressToGenerateQR?.lowercased()
        walletNameLabel.text = keysService.selectedWallet()?.name
        copiedIcon.alpha = 0
        copiedLabel.alpha = 0
    }
    
    func setNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        let sendButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareAddress(_:)))
        self.navigationItem.rightBarButtonItem = sendButton
        self.title = "Receive"
    }
    
    @objc func shareAddress(_ sender : UIBarButtonItem) {
        
        let addressToShare: String = addressToGenerateQR ?? ""
        
        let itemsToShare = [ addressToShare ]
        let activityViewController = UIActivityViewController(activityItems: itemsToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.mail, UIActivityType.message, UIActivityType.postToTwitter ]
        
        self.present(activityViewController, animated: true, completion: nil)
    }
    
 
    @IBAction func copyAddress(_ sender: Any) {
        UIPasteboard.general.string = addressToGenerateQR
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1,
                           animations: {
                            self.copyAddressButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }, completion: { _ in
                UIView.animate(withDuration: 0.1) {
                    self.copyAddressButton.transform = CGAffineTransform.identity
                    
                }
            })
        }
        
        DispatchQueue.main.async {
            self.copiedIcon.alpha = 0.0
            self.copiedLabel.alpha = 0.0
            UIView.animate(withDuration: 1.0,
                           animations: {
                self.copiedIcon.alpha = 1.0
                self.copiedLabel.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 2.0, animations: {
                    self.copiedIcon.alpha = 0.0
                    self.copiedLabel.alpha = 0.0
                })
            })
        }
        
    }
    
    func generateQRCode(from string: String?) -> UIImage? {
        guard let string = string else {
            return nil
        }
        
        guard let code = Web3.EIP67Code(address: string)?.toString() else {
            return nil
        }
        
        let data = code.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        
        return nil
    }
}
