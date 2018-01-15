//
//  APIClient.swift
//  CoreDataCountryList
//
//  Created by Mark on 1/14/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import Foundation

// good practice!!
enum Result<T> {
	case Success(T)
	case Error(String)
}

struct APIClient {
	typealias CountryDictionary = [[String: Any]]
	typealias CountryResultHandler = (Result<CountryDictionary>) -> ()
	
	static let shareInstance = APIClient()
	private init() {}
	
	func fechCountryList(completion: @escaping CountryResultHandler) {
		guard let url = URL(string: APIs.countryUrl) else {
			completion(.Error("Invalid URL"))
			return
		}
		
		URLSession.shared.dataTask(with: url) { (data, response, error) in
			guard error == nil else {
				completion(.Error(error!.localizedDescription))
				return
			}
			
			guard let data = data else {
				completion(.Error(error?.localizedDescription ?? "There is no country data to show"))
				return
			}
			
			do {
				if let jsonArray = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] {
					
					DispatchQueue.main.async {
						completion(.Success(jsonArray))
					}
				}
			} catch let error {
				completion(.Error(error.localizedDescription))
				return
			}
			
			
		}.resume()
	}
}

