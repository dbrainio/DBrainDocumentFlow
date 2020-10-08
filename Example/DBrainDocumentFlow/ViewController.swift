//
//  ViewController.swift
//  DBrainDocumentFlow
//
//  Created by DeadHipo on 10/07/2020.
//  Copyright (c) 2020 DeadHipo. All rights reserved.
//

import UIKit
import DBrainDocumentFlow

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    @IBAction func startButtonClicked(_ sender: UIButton) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let autoDetectAction = UIAlertAction(title: "Auto detect", style: .default) { [weak self] _ in
            self?.runAutoDetectFlow()
        }
        
        let passportAction = UIAlertAction(title: "Passport", style: .default) { [weak self] _ in
            self?.runPassportFlow()
        }
        
        let driverLicenceAction = UIAlertAction(title: "Driver Licence", style: .default) { [weak self] _ in
            self?.runDriverLicenceFlow()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alertController.addAction(autoDetectAction)
        alertController.addAction(passportAction)
        alertController.addAction(driverLicenceAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func runAutoDetectFlow() {
        guard let token = textField.text, !token.isEmpty else {
            let alert = UIAlertController(title: nil, message: "Enter token", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let onEndFlow: ([RecognitionItem]) -> Void = { [weak self] data in
            print(data)
            self?.dismiss(animated: true)
        }

        let keyTitles: [String: String] = [
            "some_key": "Some key"
        ]

        let onReciveResult: ((_ key: String) -> String?) = { key in
            return keyTitles[key] ?? key
        }

        let onReciveDocumentType: ((_ type: String) -> (title: String, isEnabled: Bool)) = { type in
            return (type.replacingOccurrences(of: "_", with: " ").capitalized, type != "not_document")
        }
        
        let side = UIScreen.main.bounds.width - 50.0 * 2.0
        let size = CGSize(width: side, height: side)
        let origin = CGPoint(x: 50.0, y: 88.0)
        
        let flow = DocumentFlow.configure(type: .selectable, authorizationToken: token)
            .with(onEndFlow: onEndFlow)
            .with(onReciveResult: onReciveResult)
            .with(onReciveDocumentType: onReciveDocumentType)
            .with(lumaDiffCoefficient: 0.70)
            .with(expectedSizeKb: 1000)
            .with(trackingRect: CGRect(origin: origin, size: size))
            .withDebugViews()
            .withResult()
            .build()

        let viewController = flow.start()
        viewController.modalPresentationStyle = .fullScreen
        
        present(viewController, animated: true)
        
    }
    
    private func runPassportFlow() {
        guard let token = textField.text, !token.isEmpty else {
            let alert = UIAlertController(title: nil, message: "Enter token", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let onEndFlow: ([RecognitionItem]) -> Void = { [weak self] data in
            print(data)
            self?.dismiss(animated: true)
        }
        
        let flow = PassportFlow.configure(authorizationToken: token)
            .with(onEndFlow: onEndFlow)
            .build()
        
        let viewController = flow.start()
        viewController.modalPresentationStyle = .fullScreen
        
        present(viewController, animated: true)
    }
    
    private func runDriverLicenceFlow() {
        guard let token = textField.text, !token.isEmpty else {
            let alert = UIAlertController(title: nil, message: "Enter token", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        
        let onEndFlow: ([RecognitionItem]) -> Void = { [weak self] data in
            print(data)
            self?.dismiss(animated: true)
        }
        
        let flow = DriverLicenceFlow.configure(authorizationToken: token)
            .with(onEndFlow: onEndFlow)
            .build()
        
        let viewController = flow.start()
        viewController.modalPresentationStyle = .fullScreen
        
        present(viewController, animated: true)
    }
    
}

