//
//  WeatherTableViewCell.swift
//  TheWeather
//
//  Created by Victoria Isaeva on 19.08.2024.
//

import UIKit

class WeatherCollectionViewCell: UICollectionViewCell {
    
    private lazy var backgroundImage: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "backgroundCell1"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        label.textColor = .black
        label.text = "Москва"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .black
        label.text = "28°C"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var temperatureLabelView: UILabel = {
        let label = UILabel()
        label.text = "High/Low"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(backgroundImage)
        contentView.addSubview(cityLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(temperatureLabelView)
        setupConstraints()
        setupCellAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    func configure(with image: UIImage, cityName: String, temperature: String, highLowTemperature: String) {
        backgroundImage.image = image
        cityLabel.text = cityName
        temperatureLabel.text = temperature
        temperatureLabelView.text = highLowTemperature
    }
    
    // MARK: - Private Methods
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            backgroundImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            cityLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cityLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            temperatureLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            temperatureLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            
            temperatureLabelView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            temperatureLabelView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
        ])
    }
    
    private func setupCellAppearance() {
        layer.cornerRadius = 15
        layer.masksToBounds = false
        
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.35
        layer.shadowOffset = CGSize(width: 4, height: 0)
        layer.shadowRadius = 10
        
        contentView.layer.cornerRadius = 15
        contentView.layer.masksToBounds = true
    }
}
