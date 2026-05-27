//
//  JSONLoader.swift
//  DynamicFormDemo
//
//  Created by Himanshu Lahoti on 26/05/26.
//

import Foundation

enum JSONLoader {
    enum LoadError: Error, LocalizedError {
        case fileNotFound(String)
        case decodingFailed(Error)
        case invalidData
        
        var errorDescription: String? {
            switch self {
            case .fileNotFound(let filename):
                return "Could not find file '\(filename)' in app bundle."
            case .decodingFailed(let error):
                return "Failed to decode JSON: \(error.localizedDescription)"
            case .invalidData:
                return "The JSON file contains invalid data."
            }
        }
    }
    
    /// Load and decode a JSON file from the app bundle
    static func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) throws -> T {
        // Remove .json extension if provided
        let name = filename.replacingOccurrences(of: ".json", with: "")
        
        guard let url = Bundle.main.url(forResource: name, withExtension: "json") else {
            throw LoadError.fileNotFound(filename)
        }
        
        guard let data = try? Data(contentsOf: url) else {
            throw LoadError.invalidData
        }
        
        let decoder = JSONDecoder()
        
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw LoadError.decodingFailed(error)
        }
    }
}
