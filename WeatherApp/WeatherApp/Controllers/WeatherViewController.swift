//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Лилия on 8/24/19.
//  Copyright © 2019 Liliia. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pressureLabel: UILabel!
    @IBOutlet weak var humidityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var appearentLabel: UILabel!
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let locationManager = CLLocationManager()
    
    lazy var weatherManager = APIWeatherManager(apiKey: "b3f10d4d762dd77763c266f809fb7c44")
    let coordinates = Coordinates(latitude: 54.741704, longitude: 55.984471)
    
    func toggleActivityIndicatoe(on: Bool) {
        refreshButton.isHidden = on
        
        if on {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
        getCurrentWeatherData()
//        let icon = WeatherIcon.Rain.image
//        let currentWeather = CurrentWeather(temperature: 10, appearentTemperature: 25, humidity: 30, pressure: 250, icon: icon)

        //updateUIWith(currentWeather: currentWeather)
        
//        //let urlString = "https://api.darksky.net/forecast/b3f10d4d762dd77763c266f809fb7c44/37.8267,-122.4233"
//        let baseUrl = URL(string: "https://api.darksky.net/forecast/b3f10d4d762dd77763c266f809fb7c44")
//        let fullUrl = URL(string: "37.8267,-122.4233", relativeTo: baseUrl)
//
//        let sessionConfiguration = URLSessionConfiguration.default
//        let session = URLSession(configuration: sessionConfiguration)
//        
//        let request = URLRequest(url: fullUrl!)
//        let dataTask = session.dataTask(with: fullUrl!) { (data, response, error) in
//
//        }
//        dataTask.resume()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last! as CLLocation
        
        print("my location latitude: \(userLocation.coordinate.latitude), longitude: \(userLocation.coordinate.longitude)")
    }
    
    func getCurrentWeatherData() {
        weatherManager.fetchCurrentWeather(coordinates: coordinates) { (result) in
            self.toggleActivityIndicatoe(on: false)
            
            switch result {
            case.Success(let currentWeather):
                self.updateUIWith(currentWeather: currentWeather)
            case .Failure(let error as NSError):
                
                let alertController = UIAlertController(title: "Unable to get data", message: "\(error.localizedDescription)", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func didTapRefresh(_ sender: Any) {
        getCurrentWeatherData()
        toggleActivityIndicatoe(on: true)
    }
    
    func updateUIWith(currentWeather: CurrentWeather) {
        self.imageView.image = currentWeather.icon
        self.pressureLabel.text = currentWeather.pressureString
        self.temperatureLabel.text = currentWeather.temperatureString
        self.appearentLabel.text = currentWeather.appearentTemperatureString
        self.humidityLabel.text = currentWeather.humidityString
    }

}



