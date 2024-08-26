//
//  ViewController.swift
//  TheWeather
//
//  Created by Victoria Isaeva on 14.08.2024.
//

import UIKit
import CoreLocation

final class ViewController: UIViewController, NetworkServiceDelegate, CLLocationManagerDelegate {
    private let locationManager: CLLocationManager = CLLocationManager()
    private var loadedDataCount = 0
    private let totalDataToLoad = 6
    private var networkService = NetworkService()
    
    private lazy var backgroundImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "background")
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var weatherLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.textAlignment = .center
        label.text = "- / -"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var weatherImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "weather1")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var weatherDescription: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.text = ""
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 40)
        label.textAlignment = .center
        label.text = "-"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var pictureStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 90
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var temperatureView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "thermometer.medium")
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.tintColor = .black
        return imageView
    }()
    
    private lazy var windView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "wind")
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.tintColor = .black
        return imageView
    }()
    
    private lazy var atmView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "gauge")
        imageView.translatesAutoresizingMaskIntoConstraints = true
        imageView.tintColor = .black
        return imageView
    }()
    
    private lazy var temperatureLabelView: UILabel = {
        let label = UILabel()
        label.text = "High/Low"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var windLabelView: UILabel = {
        let label = UILabel()
        label.text = "Wind"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var atmLabelView: UILabel = {
        let label = UILabel()
        label.text = "ATM"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var temperatureResult: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var windResult: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var atmResult: UILabel = {
        let label = UILabel()
        label.text = "-"
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.style = .large
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .white
        activityIndicator.startAnimating()
        return activityIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupNavBar()
        setupUI()
        setupConstraints()
        
        networkService.delegate = self
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    // MARK: - Public Methods
    func didFinishedMaxMinTemperature(maxTemperature: Float, minTemperature: Float) {
        self.temperatureResult.text = "\(maxTemperature)° / \(minTemperature)°"
        self.loadedData()
    }
    
    func didFinishedCurrentTemperature(_ temperature: Float) {
        self.temperatureLabel.text = "\(temperature)°C"
        self.loadedData()
    }
    
    func didFinishedTimeZome(_ timezone: String) {
        self.weatherLabel.text = "\(timezone)"
        self.loadedData()
    }
    
    func didFinishedPressure(_ pressure: Int) {
        self.atmResult.text = "\(pressure) mm"
        self.loadedData()
    }
    
    func didFinishedWind(_ wind: Float) {
        self.windResult.text = "\(wind) m/s"
        self.loadedData()
    }
    
    func didFinishedCurrentWeatherDescription(_ description: String) {
        self.weatherDescription.text = "\(description)"
        if let imageName = weatherImages[description] {
            self.weatherImage.image = UIImage(named: imageName)
        } else {
            self.weatherImage.image = UIImage(named: "weather1")
        }
        self.loadedData()
    }
    
    // MARK: - Private Methods
    private func setupUI() {
        view.addSubview(backgroundImage)
        view.addSubview(weatherLabel)
        view.addSubview(weatherImage)
        view.addSubview(weatherDescription)
        view.addSubview(temperatureLabel)
        view.addSubview(pictureStackView)
        view.addSubview(activityIndicator)
        
        addIconAndLabel(to: pictureStackView, icon: temperatureView, label: temperatureLabelView, label1: temperatureResult)
        addIconAndLabel(to: pictureStackView, icon: windView, label: windLabelView, label1: windResult)
        addIconAndLabel(to: pictureStackView, icon: atmView, label: atmLabelView, label1: atmResult)
        
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.barTintColor = .white
        title = "Weather"
        
        let menuButton = UIBarButtonItem(
            image: UIImage(systemName: "line.horizontal.3"),
            style: .plain,
            target: self,
            action: #selector(menuButtonTapped)
        )
        menuButton.tintColor = .black
        navigationItem.leftBarButtonItem = menuButton
        
        let refreshButton = UIBarButtonItem(
            image: UIImage(systemName: "arrow.circlepath"),
            style: .plain,
            target: self,
            action: #selector(refreshButtonTapped)
        )
        refreshButton.tintColor = .black
        navigationItem.rightBarButtonItem = refreshButton
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            weatherImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherImage.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            
            weatherLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherLabel.topAnchor.constraint(equalTo: weatherImage.bottomAnchor, constant: 10),
            
            weatherDescription.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherDescription.topAnchor.constraint(equalTo: weatherLabel.bottomAnchor, constant: 10),
            
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: weatherDescription.bottomAnchor, constant: 40),
            
            pictureStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pictureStackView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 250),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)]
        )
    }
    
    private func addIconAndLabel(to stackView: UIStackView, icon: UIImageView, label: UILabel, label1: UILabel) {
        let container = UIStackView(arrangedSubviews: [icon, label, label1])
        container.axis = .vertical
        container.alignment = .center
        container.spacing = 5
        stackView.addArrangedSubview(container)
    }
    
    @objc private func menuButtonTapped() {
        let cityListVC = CityListViewController()
        navigationController?.pushViewController(cityListVC, animated: true)
    }
    
    @objc private func refreshButtonTapped() {
        activityIndicator.startAnimating()
        
        if let currentLocation = locationManager.location {
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            networkService.startFetchingData(latitude: latitude, longitude: longitude)
        } else {
            print("Не удалось получить текущее местоположение.")
        }
    }
    
    private func loadedData() {
        loadedDataCount += 1
        checkIfAllDataLoaded()
    }
    
    private func checkIfAllDataLoaded() {
        if loadedDataCount == totalDataToLoad {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    //MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let currentLocation = locations.last else { return }
        
        if currentLocation.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            let latitude = currentLocation.coordinate.latitude
            let longitude = currentLocation.coordinate.longitude
            networkService.startFetchingData(latitude: latitude, longitude: longitude)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Ошибка при получении местоположения: \(error.localizedDescription)")
    }
}

