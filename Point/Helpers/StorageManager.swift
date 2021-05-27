//
//  StorageManager.swift
//  Point
//
//  Created by Zaoksky on 25.04.2021.
//


import RealmSwift

    /*  [16]
        Для работы с базой нам нужно создать объект Realm, который будет предоставлять доступ к базе данных.
        Данный объект должен быть объявлен как глобальная переменная
        Поэтому до того, как мы имплементируем новый класс, создадим объект realm
    */
let realm = try! Realm()
    
    /*  [16]
        Имплементируем класс и реализуем в нем метод сохранения объектов с типом place
        realm - это и есть база данных, точка входа в базу данных
    */
class StorageManager {
    static func saveObject(_ place: Place) {
        
        try! realm.write {
            realm.add(place)
        }
    }
    
        // [18] удаление из базы данных
    static func deleteObject(_ place: Place) {
        
        try! realm.write {
            realm.delete(place)
        }
    }
}
    
