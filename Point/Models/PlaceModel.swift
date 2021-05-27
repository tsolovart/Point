//
//  PlaceModel.swift
//  Point
//
//  Created by Zaoksky on 11.04.2021.
//

import RealmSwift

class Place: Object {
    
    @objc dynamic var name = ""
    @objc dynamic var location: String?
    @objc dynamic var type: String?
    @objc dynamic var imageData: Data?
    @objc dynamic var date = Date() // [22] так как мы делаем сортировку по дате
    @objc dynamic var rating = 0.0 // [25] расширяем модель, так как добавился рейтинг
 
        // [17] назначенный инициализатор, чтобы инициализировать все св-ва представленные классом
        // [25] добавляем параметр rating
    convenience init(name: String, location: String?, type: String?, imageData: Data?, rating: Double) {
        self.init()
        self.name = name
        self.location = location
        self.type = type
        self.imageData = imageData
        self.rating = rating
    }
}
