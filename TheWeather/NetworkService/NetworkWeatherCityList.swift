//
//  NetworkWeatherCityList.swift
//  TheWeather
//
//  Created by Victoria Isaeva on 23.08.2024.
//

import Foundation
import OpenMeteoSdk

protocol NetworkServiceWeatherCityListDelegate: AnyObject {
    func didFetchWeatherData(_ weatherData: [CityWeatherStruct])
}

class NetworkServiceWeatherCityList {
    weak var delegate: NetworkServiceWeatherCityListDelegate?
    private var allWeatherData = [CityWeatherStruct]()
    
    private func fetchWeatherData(cityName: String, latitude: Double, longitude: Double) async throws {
        let url = URL(string: "https://api.open-meteo.com/v1/forecast?latitude=\(latitude)&longitude=\(longitude)&daily=temperature_2m_max,temperature_2m_min,wind_speed_10m_max,weathercode,&hourly=temperature_2m,pressure_msl&timezone=auto&format=flatbuffers")!
        
        let responses = try await WeatherApiResponse.fetch(url: url)
        
        guard let response = responses.first else {
            print("Нет данных для обработки.")
            return
        }
        
        let utcOffsetSeconds = response.utcOffsetSeconds
        let hourly = response.hourly!
        let daily = response.daily!
        let timezone = response.timezone ?? "Неизвестный город"
        
        guard let temperature2m = hourly.variables(at: 0)?.values,
              let pressureMSL = hourly.variables(at: 1)?.values,
              let temperature2mMax = daily.variables(at: 0)?.values,
              let temperature2mMin = daily.variables(at: 1)?.values,
              let windSpeed10mMax = daily.variables(at: 2)?.values,
              let weatherCode = daily.variables(at: 3)?.values else {
            print("Ошибка при получении данных")
            return
        }
        
        let data = WeatherData(
            hourly: .init(
                time: hourly.getDateTime(offset: utcOffsetSeconds),
                temperature2m: temperature2m,
                pressureMSL: pressureMSL
            ),
            daily: .init(
                time: daily.getDateTime(offset: utcOffsetSeconds),
                temperature2mMax: temperature2mMax,
                temperature2mMin: temperature2mMin,
                windSpeed10mMax: windSpeed10mMax,
                weatherCode: weatherCode
            )
        )
        
        let currentDate = Date()
        let calendar = Calendar.current
        let currentHour = calendar.component(.hour, from: currentDate)
        
        guard let closestIndex = data.hourly.time.firstIndex(where: { calendar.component(.hour, from: $0) == currentHour }) else {
            print("Не удалось найти данные для этого часа.")
            return
        }
        
        let currentTemperature = Float(round((data.hourly.temperature2m[closestIndex]) * 10) / 10.0)
        let maxTemperature = Float(round((data.daily.temperature2mMax.first ?? 0.0) * 10) / 10.0)
        let minTemperature = Float(round((data.daily.temperature2mMin.first ?? 0.0) * 10) / 10.0)
        let windSpeedInMetersPerSecond = (data.daily.windSpeed10mMax.first ?? 0.0) / 3.6
        let windSpeed = Float(round(windSpeedInMetersPerSecond * 10) / 10.0)
        let currentPressureHPA = Float(round((data.hourly.pressureMSL[closestIndex]) * 10) / 10.0)
        let pressureMMHg = round(currentPressureHPA * 0.750062)
        
        let currentWeatherCodeIndex = data.daily.time.firstIndex(where: { calendar.isDate($0, inSameDayAs: currentDate) })
        let currentWeatherCode = currentWeatherCodeIndex != nil ? data.daily.weatherCode[currentWeatherCodeIndex!] : 0
        let weatherDescription = weatherCodes[Int(currentWeatherCode)] ?? "Неизвестное описание погоды"
        let formattedDate = DateFormatter.dateFormatter.string(from: data.daily.time.first ?? Date())
        
        print("Дата: \(formattedDate)")
        print("Текущая температура: \(currentTemperature)°C")
        print("Максимальная температура за сегодня: \(maxTemperature)°C")
        print("Минимальная температура за сегодня: \(minTemperature)°C")
        print("Максимальная скорость ветра за сегодня: \(windSpeed) м/с")
        print("Временная зона: \(timezone)")
        print("Текущее атмосферное давление: \(Int(pressureMMHg)) мм рт.ст.")
        print("Код погоды: \(currentWeatherCode), Описание: \(weatherDescription)")
        
        DispatchQueue.main.async {
            let cityWeather = CityWeatherStruct(cityName: cityName, temperature: "\(currentTemperature)°C", highLowTemperature: "Max: \(maxTemperature)°C, Min: \(minTemperature)°C")
            self.allWeatherData.append(cityWeather)
            
            if self.allWeatherData.count == 7 {
                self.delegate?.didFetchWeatherData(self.allWeatherData)
            }
        }
    }
    
    
    func startFetchingData(cityName: String, latitude: Double, longitude: Double) {
        Task {
            do {
                try await fetchWeatherData(cityName: cityName, latitude: latitude, longitude: longitude)
            } catch {
                print("Ошибка: \(error)")
            }
        }
    }
    
    func startFetchingWeatherForPredefinedCities() {
        allWeatherData.removeAll()
        
        let citiesCoordinates: [String: (latitude: Double, longitude: Double)] = [
            "New York": (40.7128, -74.0060),
            "London": (51.5074, -0.1278),
            "Tokyo": (35.6762, 139.6503),
            "Moscow": (55.7558, 37.6176),
            "Sydney": (-33.8688, 151.2093),
            "Istanbul": (41.0082, 28.9784),
            "Budapest": (47.4979, 19.0402)
        ]
        
        for (city, coordinates) in citiesCoordinates {
            print("Fetching weather for \(city) at latitude \(coordinates.latitude), longitude \(coordinates.longitude)")
            startFetchingData(cityName: city, latitude: coordinates.latitude, longitude: coordinates.longitude)
        }
    }
    
}


