//
//  LocationViewController.swift
//  IeiruForiOS
//
//  Created by KenzaburoTakagi on 2020/05/04.
//  Copyright © 2020 KenzaburoTakagi. All rights reserved.
//

import UIKit
import CoreLocation

class LocationViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var usersLabel: UILabel!
    
    var locationManager: CLLocationManager!
    var latitude: Double?
    var longitude: Double?
    var usersIeiru: String?
    var registeredName: String?
    
    let urlString = "http://18.176.193.22/users"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getLocationInfo(completion: { lines in
            DispatchQueue.main.async {
                // labelの出し方は要検討
                let LineHeightStyle = NSMutableParagraphStyle()
                let lineSpaceSize = CGFloat(10)
                LineHeightStyle.lineSpacing = lineSpaceSize
                let lineHeightAttr = [NSAttributedString.Key.paragraphStyle: LineHeightStyle]
                self.usersLabel.frame.size.height = (UIFont.systemFontSize + lineSpaceSize) * CGFloat(lines + 3)
                self.usersLabel.attributedText = NSMutableAttributedString(string: self.usersIeiru ?? "", attributes: lineHeightAttr)
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        usersLabel.text = usersIeiru
    }
    
    @IBAction func tapStartBtn(_ sender: Any) {
        setupLocationManager()
        postLocationInfo()
    }
    
    @IBAction func tapFinishBtn(_ sender: Any) {
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func setupLocationManager() {
        locationManager = CLLocationManager()
        guard let locationManager = locationManager else { return }
        locationManager.requestAlwaysAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedAlways {
            locationManager.delegate = self
            locationManager.requestLocation()
            locationManager.startMonitoringSignificantLocationChanges()
            locationManager.allowsBackgroundLocationUpdates = true
        } else {
            showAlert()
        }
    }

    func showAlert() {
        let alertTitle = "位置情報取得が許可されてないンゴ"
        let alertMessage = "設定アプリの「プライバシー > 位置情報サービス」から常に許可にしてね"
        let alert: UIAlertController = UIAlertController(
            title: alertTitle, message: alertMessage, preferredStyle: UIAlertController.Style.alert
        )

        let defaultAction: UIAlertAction = UIAlertAction(
            title: "OK", style: UIAlertAction.Style.default
        )

        alert.addAction(defaultAction)
        present(alert, animated: true)
    }
    
    func getLocationInfo(completion: @escaping (Int) -> Void) {
        guard let url = URLComponents(string: urlString) else { return }
        
        let task = URLSession.shared.dataTask(with: url.url!) {(data, response, error) in
            if (error != nil) {
                print(error!.localizedDescription)
            }
            guard let data = data else { return }

            let response = try! JSONDecoder().decode(Response.self, from: data)
            print(response)
            
            for user in response.data {
                let name = user.name
                let isHome = user.isHome ? "家いる" : "家いない"
                let txt = name + " : " + isHome + "\n"

                if ((self.usersIeiru) == nil) {
                    self.usersIeiru = txt
                } else {
                    self.usersIeiru = self.usersIeiru! + txt
                }
            }
            completion(response.data.count)
        }
        task.resume()
    }
    
    func postLocationInfo() {
        guard let url = URL(string: urlString) else { return }
        let userDefaults = UserDefaults.standard
//        userDefaults.removeObject(forKey: "name")
        let name = userDefaults.object(forKey: "name") as? String
        guard let nameText = nameTextField.text else { return }
        if let name = name {
            registeredName = name
        } else {
            UserDefaults.standard.set(self.nameTextField.text, forKey: "name")
            registeredName = nameText
        }
        
        let parameters: [String: Any] = [
            "user": [
                "name": registeredName,
                "latitude" : self.latitude,
                "longitude": self.longitude
            ]
        ]
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        request.timeoutInterval = 20
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    print(json)
                } catch {
                    print(error)
                }
            }
        }.resume()
    }
}

extension LocationViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        self.latitude = location?.coordinate.latitude
        self.longitude = location?.coordinate.longitude
        self.usersLabel.text = usersIeiru
        
        postLocationInfo()
        print(self.latitude)
        print(self.longitude)
        print(usersIeiru)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("うんこおおおおおおおおおおお")
    }
}
