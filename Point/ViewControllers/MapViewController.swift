//
//  MapViewController.swift
//  Point
//
//  Created by Zaoksky on 07.05.2021.
//

import UIKit
import MapKit // [27]
import CoreLocation // [31] Для определения местоположения пользователя

	
protocol MapViewControllerDelegate {    /*  [35] Можно передавать данные от одного ViewController другому.
                                            Передаем данные из MapViewController в NewPlaceViewController
                                            @objc optional если нужно реализовать опциональные методы
                                         */
    
    func getAddress(_ address: String?)
}

class MapViewController: UIViewController {
    
    let mapManager = MapManager()
    var mapViewControllerDelegate: MapViewControllerDelegate?
    var place = Place()
    
    let annotationIdentifier = "annotationIdentifier"
    var incomeSegueIdentifier = ""
    var previousLocation: CLLocation? { /*  [37]
                                             Cв-во для хранение предыдущего местоположения пользователя.
                                             Мы построили маршрут. Нам нужно постоянно фокусировать карту на пользователе.
                                             Каждый раз, когда место будет меняться, мы должны будем обновлять св-ва previousLocation.
                                         */
        didSet {
            mapManager.startTrackingUserLocation(for: mapView, and: previousLocation) { (currentLocation) in
                
                self.previousLocation = currentLocation
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.mapManager.showUserLocation(mapView: self.mapView)
                }
            }
        }
    }
    
    @IBOutlet weak var userLocation: UIButton!
    @IBOutlet weak var mapView: MKMapView! //[27]
    @IBOutlet weak var mapPinImage: UIImageView! //[33]
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var goButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        userLocation.layer.cornerRadius = userLocation.frame.size.height / 3
        userLocation.clipsToBounds = true
        
        addressLabel.text = ""
        mapView.delegate = self // [29]
        setupMapView()

    }
    
    @IBAction func centerViewInUserLocation() {
        mapManager.showUserLocation(mapView: mapView) // [33] для перехода "gerAdress"
    }
    
    @IBAction func doneButtonPressed() {
        mapViewControllerDelegate?.getAddress(addressLabel.text)
        dismiss(animated: true, completion: nil) // [35] закрываем ViewController
    }
    
    @IBAction func goButtonPressed() {
        mapManager.getDirections(for: mapView) { (location) in
            self.previousLocation = location
        }
    }
    
    @IBAction func closeMapVC() {
        dismiss(animated: true, completion: nil) // [27] закрытие VC
    }
        
    private func setupMapView() { // [33]
        
        goButton.isHidden = true
        
        mapManager.checkLocationServices(mapView: mapView, segueIdentifier: incomeSegueIdentifier) {
            mapManager.locationManager.delegate = self
        }
        
        if incomeSegueIdentifier == "showPlace" {
            mapManager.setupPlacemark(place: place, mapView: mapView)
            mapPinImage.isHidden = true
            addressLabel.isHidden = true
            doneButton.isHidden = true
            goButton.isHidden = false
        }
    }
    
    deinit {
        print("deinit", MapViewController.self)
    }
    
}


extension MapViewController: MKMapViewDelegate { // [29]
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        guard !(annotation is MKUserLocation) else { return nil } // [29] если маркером на карте явлется текущее местоположение пользователя, то мы не должны создавать никакой аннотации
        
        /*  [29] объект класса MKAnnotationView, который и представляет View с аннотацией на карте
            Чтобы не создавать новое представление при каждом вызове этого метода
             withIdentifier: необходимо поставить идентификатор
            MKPinAnnotationView - булавка
        */
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MKPinAnnotationView 
        
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation,
                                                 reuseIdentifier: annotationIdentifier)
            
            annotationView?.canShowCallout = true // [29] Отобразить аннотация ввиде баннер
        }
        
        if let imageData = place.imageData {
            
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50)) // [29] Отобразим на баннере изображение нашего заведения, размещая на нем ImageView
            imageView.layer.cornerRadius = 10
            imageView.clipsToBounds = true
            imageView.image = UIImage(data: imageData) // [29]  Помещаем изображение в ImageView
            annotationView?.rightCalloutAccessoryView = imageView // [29]  Отобразить ImageView на баннере справа
        }
            
        return annotationView
    }
        
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) { // [34] получаем адрес по координатам
         
        let center = mapManager.getCenterLocation(for: mapView) // [34] текущие координаты
        let geocoder = CLGeocoder()
        
        // [37] При смещении и масштабировании карты через время мы будем возвращать меположение пользователя в центр
        if incomeSegueIdentifier == "showPlace" && previousLocation == nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.mapManager.showUserLocation(mapView: self.mapView)
            }
        }
            
        geocoder.cancelGeocode() // [37] Освобождаем ресурсы, связанные с геокодированием, делаем отмену отложенного запроса
         
        geocoder.reverseGeocodeLocation(center) { (placemarks, error) in // [34] преобразуем координаты в адрес
            
            if let error = error {
                print(error)
                return
            }
            
            guard let placemarks = placemarks else { return } // [34] извекаем [] меток
            
            let placemark = placemarks.first // [34] данный [] должен содержать одну метку, извлекаем ее
            let streetName = placemark?.thoroughfare // извлекаем название улицы
            let buildNumber = placemark?.subThoroughfare // номер дома
            
            DispatchQueue.main.async { // [34] Обновлять interface мы должны в основном потоке асинхронно. И передаем значение в Label
                
                if streetName != nil && buildNumber != nil {
                    self.addressLabel.text = "\(streetName!), \(buildNumber!)"
                } else if streetName != nil {
                    self.addressLabel.text = "\(streetName!)"
                } else {
                    self.addressLabel.text = ""
                }
            }
        }
    }
        
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer { // [36] подсветить маршрут цветом
            
        // [36] пока что маршрут был невидимый, чтобы его отобразить, создадим линию по этому наложению.
        let renderer = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderer.strokeColor = .blue
        
        return renderer
    }
    
}


extension MapViewController: CLLocationManagerDelegate { // [29] Отслеживаем в реальном времени изменение статуса разрешения на геопозицию
    	
    // [29] Вызывается при каждом изменении статуса авторизации приложения для использования геолокации
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        mapManager.checkLocationAuthoriation(mapView: mapView,
                                             segueIdentifier: incomeSegueIdentifier)
    }
    
}

