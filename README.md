# <img src="https://user-images.githubusercontent.com/71283039/131775478-4a85acc9-d0c8-488c-a79d-d368fd173de0.png" alt="logoAppPoint" width="40"/>  App Point

<img src="https://user-images.githubusercontent.com/71283039/131775478-4a85acc9-d0c8-488c-a79d-d368fd173de0.png" alt="logoAppPoint" width="200"/> You can ***Add*** your favorite places to a list to find them easily later. ***Manage*** your saved places 

## Skills
* UITableView
* Realm
* RatingControl
* CosmosStar
* MapVC
* User Location 

## Сreate
![addText](https://user-images.githubusercontent.com/71283039/131778300-effbd723-24d1-4f75-a2b4-022e35535a07.gif) 

## Location
Find out your ***location address***

![location](https://user-images.githubusercontent.com/71283039/131780549-14e0e110-7f5d-4c04-bd5e-a0a6e31de244.gif)

## Photo ***of the*** Place
***Take pictures*** of places

![takePhoto](https://user-images.githubusercontent.com/71283039/131781188-4e07e2a0-0923-44e7-a0df-a1c2c8985a94.gif)

## Search ***and*** Sorting
***Sort*** by date added and by name

![search](https://user-images.githubusercontent.com/71283039/131781651-ce9b0cfc-0115-482d-97b3-7571099fd381.gif)

## Get Direction ***&*** Show Route

`let locationManager = CLLocationManager()`

`func getDirections(for mapView: MKMapView, previousLocation: (CLLocation) -> ()) {`

> User Location Coordinates

```        
        guard let location = locationManager.location?.coordinate else {
            showAlert(title: "Error", message: "Current location is not found")
            return
        }
```
> The mode used to track the user location
        
``` 
        locationManager.startUpdatingLocation()
        previousLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)) 
```
> Route request

```
        guard let request = createDirectionRequest(from: location) else { 
            showAlert(title: "Error", message: "Destination is not found")
            return
        }
```
> Draw a route

```
        let directions = MKDirections(request: request) 
        resetMapView(withNew: directions, mapView: mapView)
```   
> Route calculation

``` 
        directions.calculate { (response, error) in 
            
            if let error = error {
                print(error)
                return
            }
```           
>> Fetch route         
  
```
            guard let response = response else { 
                self.showAlert(title: "Error", message: "Destinations are not available")
                return
            }
```
>>> Route selection. Overlay routes
  
```
            for route in response.routes { 
                mapView.addOverlay(route.polyline)
```
 
>>> Focusing the map
   
```
                mapView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)   
```
>>> Travel Time and Distance. %.1f - round up to 0,1
   
```                  
                let distance = String(format: "%.1f", route.distance / 1000) 
                let timeInterval = route.expectedTravelTime
            }
        }
    }
``` 
    

![route](https://user-images.githubusercontent.com/71283039/132023936-86fa4728-712f-4312-84d7-b13b636887a6.gif)

## Follow ***me***

[<img src="https://user-images.githubusercontent.com/71283039/132022115-2858493b-14de-4b86-8b95-b0bac4f1cb18.png" alt="linkedin" width="30"/>][linkedin]
[<img src="https://user-images.githubusercontent.com/71283039/132022727-fe1359e1-1446-46a0-baac-a62753330116.png" alt="instagram" width="30"/>][instagram]
[<img src="https://user-images.githubusercontent.com/71283039/132022883-f4235aed-1234-4a5e-af6b-6f123a6aa6b2.png" alt="facebook" width="30"/>][facebook]
[<img src="https://user-images.githubusercontent.com/71283039/132022909-9fcbb71e-4540-47eb-b9b3-a226a4eafbf0.png" alt="twitter" width="30"/>][twitter]
[<img src="https://user-images.githubusercontent.com/71283039/132022922-69e960f7-5481-495a-92c9-01ee30e7a515.png" alt="behance" width="30"/>][behance]

[linkedin]: https://www.linkedin.com/in/tsolovart/
[instagram]: https://www.instagram.com/tsolovartem/
[facebook]: https://www.facebook.com/tsolovart/
[twitter]: https://twitter.com/tsolovart
[behance]: https://www.behance.net/tsolovart
