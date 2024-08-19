//
//  WeatherStruct.swift
//  TheWeather
//
//  Created by Victoria Isaeva on 19.08.2024.
//

import Foundation

struct WeatherData {
    let hourly: Hourly
    let daily: Daily
    
    struct Hourly {
        let time: [Date]
        let temperature2m: [Float]
        let pressureMSL: [Float]
    }
    
    struct Daily {
        let time: [Date]
        let temperature2mMax: [Float]
        let temperature2mMin: [Float]
        let windSpeed10mMax: [Float]
        let weatherCode: [Float]
    }
}
