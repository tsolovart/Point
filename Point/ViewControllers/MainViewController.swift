//
//  MainViewController.swift
//  Point
//
//  Created by Zaoksky on 06.04.2021.
//

import UIKit
import RealmSwift

class MainViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
        
    @IBOutlet weak var segmentedControl: UISegmentedControl! // [22]
    @IBOutlet weak var reversedSortingButton: UIBarButtonItem! // [22]
    @IBOutlet weak var tableView: UITableView! // [20]
    
        // [17]  Позволяет работать с данными в реальном времени
    private var places: Results<Place>!
    
        // [22] Помещаем в [] отсортированные данные
    private var filteredPlaces: Results<Place>!
    
        // [21] Сортировка по возрастанию
    private var ascendingSorting = true
    
        // [22] nil - для результатов поиска хотим использовать тот же View, в котором отображается основной контент
    private let searchController = UISearchController(searchResultsController: nil)
    
        // [22]
    private var searchBarIsEnpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    
        // [22] отслеживание поискового запроса
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEnpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // [17]  Отображение данных. Запрос объектов из REALM
        places = realm.objects(Place.self)
        
            // [22] Setup the search controller
        searchController.searchResultsUpdater = self // получателем информации о изменении текста в поиске должен быть наш класс
        searchController.obscuresBackgroundDuringPresentation = false // позволяет взаимодействовать с отображаемым контентом
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true // отпускаем поиск при переходе на другой экран
    }

    // MARK: - Table view data source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! CustomTableViewCell
        
        let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
        
        cell.nameLabel.text = place.name
        cell.locationLabel.text = place.location
        cell.typeLabel.text = place.type
        cell.imageOfPlace.image = UIImage(data: place.imageData!)
        cell.cosmosView.rating = place.rating
    
        return cell
    }
    
    // MARK: - Table view delegate
    
        // [24] Отмена выделения ячейки при возращении обратно от редактирования
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let place = places[indexPath.row]
        
        	// [18] действие при swipe
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.deleteObject(place)
                
                // [18] удалить строки
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    // MARK: - Navigation

        // [19] Переход для редактирования
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            
                // [19] Определить индекс выбранной ячейки
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            
                // [22] чтобы переходить на редактирование прямо из поиска
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            
                // [19] Экземпляр VC
            let newPlaceVC = segue.destination as! NewPlaceViewController
            newPlaceVC.currentPlace = place
        }
    }
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        
            /*  [14]
                Экземпляр класса (NewPlaceViewController)
                .destination - мы используем для VC-плучателя, когда мы хотим передать данные от VC с которого переходим на VC на который переходим
                .source - мы выполняем возврат на VC, который мы использовали ранее
            */
        guard let newPlaceVC = segue.source as? NewPlaceViewController else { return }

        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
    @IBAction func sortSelection(_ sender: UISegmentedControl) {
        
        sorting()
    }
    
    @IBAction func reversedSorting(_ sender: Any) {
        
            // [21] меняем значение на противоположное
        ascendingSorting.toggle()
        
        if ascendingSorting {
            reversedSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reversedSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        
        sorting()
    }
        
        // [21] Чтобы выполнить сортировку, нужно прописать такую же логику, что и при выборе segment. ЧТобы не повторятся, пропишем это в методе
    private func sorting() {
        
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: ascendingSorting)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: ascendingSorting)
        }
        
            // [21] После выбора segment нам нужно обновить таблицу
        tableView.reloadData()
    }
    
    deinit {
        print("deinit", MainViewController.self)
    }
        
}

    // [22] Чтобы отображать данные в контроллере MainView, подписываемся под протакол UISearchResultsUpdating
extension MainViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
    
        /*  [22] фильтрация контента
            Поиск по полю Name или Location. Данные фильтруем по значению из параметра searchText, все зависимости от регистра символов
        */
    private func filterContentForSearchText(_ searchText: String) {
        
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS %@", searchText, searchText)
        tableView.reloadData() // [22] обновляем
    }
    
}
