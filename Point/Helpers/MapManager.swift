//
//  MapManager.swift
//  Point
//
//  Created by Zaoksky on 14.05.2021.
//

import UIKit
import MapKit

class MapManager { // [38] Выносим св-ва и методы, которые не влияют на работу MapViewController
    
    let locationManager = CLLocationManager() // [31] Отвечает за настройку и управление службами геолокации
    
    private var placeCoordinate: CLLocationCoordinate2D? // [36] Принимает координаты заведения
    private let regionInMeters = 1000.00
    private var directionsArray: [MKDirections] = [] /*  [37]
                                                         Так как при изменении местоложения маршруты будут накладываться друг на друга, мы должны отменить прошлые маршруты
                                                         Массив, в который помещаем текущие маршруты
                                                     */
    
    // Маркер места на карте. [38] Расширяем доп. параметрами place: Place
    func setupPlacemark(place: Place, mapView: MKMapView) {
        
        guard let location = place.location else { return } // [28] Извлекаем адрес заведения
        
            
        let geocoder = CLGeocoder() /*   [28]
                                         CLGeocoder() - преобразовывает географические координаты и названия
                                         Преобразовывает координаты долготы и широты в удобный для пользователя вид точка на карте
                                     */
        geocoder.geocodeAddressString(location) { (placemarks, error) in /*  [28] Место на карте по адресу
                                                                             CLPlacemark возвращает массив меток соответствующие переданному ардесу
                                                                          */
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return }
            
            let placemark = placemarks.first // [28] Метка на карте
            
            let annotation = MKPointAnnotation() // [28] Описание метки на карте
            annotation.title = place.name
            annotation.subtitle = place.type
            
            guard let placemarkLocation = placemark?.location else { return } // [28] Привязываем описание метки конкретной точке
            
            annotation.coordinate = placemarkLocation.coordinate // [28] Если получилось получить локацию, то привязываем к описанию
            self.placeCoordinate = placemarkLocation.coordinate // [36] Передаем координаты св-ва placemarkLocations новому св-ву
            
                
            mapView.showAnnotations([annotation], animated: true)  /*   [28] Область видимости карты, чтобы на ней были видны все созданные Annotation
                                                                        .annotations - все описания, которые должны быть в области видимости.
                                                                    */
            mapView.selectAnnotation(annotation, animated: true) // [28] Выделяем созданную аннотацию
            
        }
    }
    
    // Включены ли службы геолокации?
    func checkLocationServices(mapView: MKMapView, segueIdentifier: String, closure: () -> ()) {
        
        if CLLocationManager.locationServicesEnabled() { // [31] Если службы доступны, то
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            checkLocationAuthoriation(mapView: mapView, segueIdentifier: segueIdentifier)
            closure()
        } else {
                /*  [32] Отрабатывается до того, как View отобразится на экране
                    DispatchQueue.main.asyncAfter позволяет отложить вызов UIAlertController на определенное время (now + 1 секунда)
                */
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Location Services are Disabled",
                               message: "To enable it go: Setting -> Privacy -> Location Services and turn On")
            }
        }
    }
    
    // Проверка на разрешение использования геолокации от пользователя
    func checkLocationAuthoriation(mapView: MKMapView, segueIdentifier: String) {
        
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse: // когда приложения разрешино определять геолокацию в момент использования
            mapView.showsUserLocation = true
            if segueIdentifier == "getAddress" { showUserLocation(mapView: mapView) }
            break
        case .denied: // когда запрещено или отключено в настройках
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.showAlert(title: "Your Location is not Available",
                               message: "To enable your location tracking: Setting -> MyPlaces -> Location")
            }
            break
        case .notDetermined: // статус не определен, еще не сделан выбор
            locationManager.requestWhenInUseAuthorization()
        case .restricted: // если приложение не авторизовано для использования служб геолокации
            break
        case .authorizedAlways: // постоянно можно использовать службу геолокации
            break
        @unknown default:
            print("New case is available")
        }
    }
    
    // Фокус карты на местоположении пользователя
    func showUserLocation(mapView: MKMapView) {
        
        if let location = locationManager.location?.coordinate { // [33] Если определяем координаты пользоватетеля, то определяем регион для позиционирования карты
            let region = MKCoordinateRegion(center: location,
                                            latitudinalMeters: regionInMeters,
                                            longitudinalMeters: regionInMeters)
                
            mapView.setRegion(region, animated: true) // [33] Устанавливаем регион на экране
        }
    }
    
    // Логика для прокладки маршрута от местоположения пользователя до заведения
    func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {
        
        guard let location = locationManager.location?.coordinate else { // [36] Определим координаты местоположения пользователя
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
        
        locationManager.startUpdatingLocation() // [37] Включим режим отслеживания постоянного местоположения пользователя.
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)) // [37] Передаем текущие координаты местоположения пользователя
        
        guard let request = createDirectionRequest(from: location) else { // [36] Запрос на прокладку марштура
            showAlert(title: "Error", message: "Destination is not found")
            return
        }

        let directions = MKDirections(request: request) // [36] Если все успехно, то создаем маршрут
        
        resetMapView(withNew: directions, mapView: mapView) // [37] Перед тем как создать новый маршрут, издавляемся от текущин
        
        directions.calculate { (response, error) in // [36] Запуск расчета маршрута
            
            if let error = error {
                print(error)
                return
            }
            
            guard let response = response else { // [36] Пробуем извлечь обработанный маршрут
                self.showAlert(title: "Error", message: "Destinations are not available")
                return
            }
            
            for route in response.routes { // [36] Выбор маршрута
                mapView.addOverlay(route.polyline) // [36] Создаем дополнительное наложение со всеми возможными маршрутами. .polyline -  подробная геометрия маршрута
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true) // [36] Фокусируем карту, чтобы было видно весь маршрут
                    
                let distance = String(format: "%.1f", route.distance / 1000) // [36] Доп. инфо. по маршруту. Расстояние и время в пути. %.1f - округляем до 0,1
                let timeInterval = route.expectedTravelTime
                
                print("Расстояние до места: \(distance) км.")
                print("Время в пути: \(timeInterval) мин.")
            }
        }
    }
    
    // Настройка запроса для расчета маршрута
    func createDirectionRequest(from coordinate: CLLocationCoordinate2D) -> MKDirections.Request? {
        
        guard let destinationCoordinate = placeCoordinate else { return nil }
        
        let startingLocation = MKPlacemark(coordinate: coordinate) // [36] определяем местоположение точки для начала маршрута
        let destination = MKPlacemark(coordinate: destinationCoordinate) // [36] точка места назначения
              
        let request = MKDirections.Request() // [36] Имея две точки, создаем запрос на построение маршрута
        request.source = MKMapItem(placemark: startingLocation) // [36] Стартовая точка
        request.destination = MKMapItem(placemark: destination) // [36] Конечная точка
        request.transportType = .automobile // [36] Тип транспорта
        request.requestsAlternateRoutes = true // [36] Позволяет строить несколько маршрутов, если есть альтернативные варинты
        
        return request
    }
    
    // Меняем отображаемую зону области карты в соответствии с перемещением пользователя
    func startTrackingUserLocation(for mapView: MKMapView, and location: CLLocation?, closure: (_ currentLocation: CLLocation) -> ()) {
        
        guard let location = location else { return } // [37] если не nil
        
        let center = getCenterLocation(for: mapView) // [37] Определяем текущие координаты центра отображаемой области
            
        guard center.distance(from: location) > 50 else { return } /*  [37] Обновляем регион отображения карты в том случае, если расстояние между точками будет более 50 м
                                                                                 Мы будем обновлять центр карты на новом месположении пользователя
                                                                                 Определим расстояние до центра текущей области от предыдущей точки
                                                                             */
        closure(center)
    }
    
    // Cброс старых маршрутов перед построением новых
    func resetMapView(withNew directions: MKDirections, mapView: MKMapView) {
        
        mapView.removeOverlays(mapView.overlays) // [37] Удаляем старый маршрут
        directionsArray.append(directions) // [37] Добавляем в массив текущие маршруты
        let _ = directionsArray.map { $0.cancel() } // [37] Перебор всех значений массива. И отмена у каждого элемента маршрут. $0 - проход по каждому элементу массива
        directionsArray.removeAll()
        
    }
    
    // Определяем координаты в центре отображаемой области карты, где CLLocation - координаты
    func getCenterLocation(for mapView: MKMapView) -> CLLocation {
        
        let latitude = mapView.centerCoordinate.latitude // координаты широты
        let longitude = mapView.centerCoordinate.longitude // долгота
        
        return CLLocation(latitude: latitude, longitude: longitude)
    }
    
    private func showAlert(title: String, message: String) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        
        alert.addAction(okAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds) // [38] Чтобы вызвать present
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindow.Level.alert + 1 // [38] Позиционирование окна относительно других окн. Поверх остальных окн.
        alertWindow.makeKeyAndVisible() // [38] Сделаем окно ключивым и видимым
        alertWindow.rootViewController?.present(alert, animated: true, completion: nil)// [38] Вызовем окно в качестве AlertController
    }
    
    deinit {
        print("deinit", MapManager.self)
    }
    
}
