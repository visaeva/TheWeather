//
//  NetworkService.swift
//  TheWeather
//
//  Created by Victoria Isaeva on 15.08.2024.
//
import Foundation
import OpenMeteoSdk

protocol NetworkServiceDelegate: AnyObject {
    func didFinishedCurrentTemperature(_ temperature: Float)
    func didFinishedMaxMinTemperature(maxTemperature: Float, minTemperature: Float)
    func didFinishedTimeZome(_ timezone: String)
    func didFinishedWind(_ wind: Float)
    func didFinishedPressure(_ pressure: Int)
    func didFinishedCurrentWeatherDescription(_ description: String)
}

class NetworkService {
    weak var delegate: NetworkServiceDelegate?
    
    private func fetchWeatherData(latitude: Double, longitude: Double) async throws {
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
            self.delegate?.didFinishedCurrentTemperature(currentTemperature)
            self.delegate?.didFinishedMaxMinTemperature(maxTemperature: maxTemperature, minTemperature: minTemperature)
            self.delegate?.didFinishedTimeZome(timezone)
            self.delegate?.didFinishedWind(windSpeed)
            self.delegate?.didFinishedPressure(Int(pressureMMHg))
            self.delegate?.didFinishedCurrentWeatherDescription(weatherDescription)
        }
    }
    
    func startFetchingData(latitude: Double, longitude: Double) {
        Task {
            do {
                try await fetchWeatherData(latitude: latitude, longitude: longitude)
            } catch {
                print("Ошибка: \(error)")
            }
        }
    }
}

extension DateFormatter {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}
