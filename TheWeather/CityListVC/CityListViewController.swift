//
//  CityListViewController.swift
//  TheWeather
//
//  Created by Victoria Isaeva on 19.08.2024.
//

import UIKit

final class CityListViewController: UIViewController, UISearchBarDelegate, NetworkServiceWeatherCityListDelegate {
    private var citiesWeather = [CityWeatherStruct]()
    private var filteredCitiesWeather = [CityWeatherStruct]()
    private let networkService = NetworkServiceWeatherCityList()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.delegate = self
        searchBar.placeholder = "Search"
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        searchBar.backgroundImage = UIImage()
        return searchBar
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.bounds.width - 20, height: 150)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        return collectionView
    }()
    
    private lazy var backgroundImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "background1")
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupNavBar()
        setupUI()
        setupConstraints()
        collectionView.register(WeatherCollectionViewCell.self, forCellWithReuseIdentifier: "WeatherCell")
        networkService.delegate = self
        networkService.startFetchingWeatherForPredefinedCities()
    }
    
// MARK: - Public Methods
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCitiesWeather = citiesWeather
        } else {
            filteredCitiesWeather = citiesWeather.filter { $0.cityName.lowercased().contains(searchText.lowercased()) }
        }
        collectionView.reloadData()
    }
    
    func didFetchWeatherData(_ weatherData: [CityWeatherStruct]) {
        citiesWeather = weatherData
        filteredCitiesWeather = weatherData
        collectionView.reloadData()
    }
    
// MARK: - Private Methods
    private func setupUI() {
        view.addSubview(backgroundImage)
        view.addSubview(searchBar)
        
        let backgroundView = UIImageView(image: UIImage(named: "background1"))
        backgroundView.contentMode = .scaleAspectFill
        collectionView.backgroundView = backgroundView

        view.addSubview(collectionView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 5),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 5),
            
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 5),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupNavBar() {
        navigationController?.navigationBar.barTintColor = .white
        title = "Weather"
        
        let backButtonImage = UIImage(systemName: "chevron.left")
        let backButton = UIBarButtonItem(image: backButtonImage, style: .plain, target: self, action: #selector(backButtonTapped))
        backButton.tintColor = .black
        
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
}
// MARK: - UICollectionViewDelegate, UICollectionViewDataSource

extension CityListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCitiesWeather.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WeatherCell", for: indexPath) as! WeatherCollectionViewCell
        
        let cityWeather = filteredCitiesWeather[indexPath.item]
        let backgroundImage = UIImage(named: "backgroundCell1")!
        
        cell.configure(with: backgroundImage, cityName: cityWeather.cityName, temperature: cityWeather.temperature, highLowTemperature: cityWeather.highLowTemperature)
        
        return cell
    }
}
