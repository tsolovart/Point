//
//  RatingControl.swift
//  Point
//
//  Created by Zaoksky on 02.05.2021.
//

    // [23]
import UIKit
    // [23] @IBDesignable позволяет в реальном времени просмотривать изменения
@IBDesignable class RatingControl: UIStackView {
    
    
    // MARK: Properties
    
        // [23] данные о рейтинге
    var rating = 0 {
        didSet {
            updateButtonSelectionState()
        }
    }
        
    private var ratingButtons = [UIButton]()
    
    @IBInspectable var starSize: CGSize = CGSize(width: 30.0, height: 30.0) {
        
            /*  [23] Для того, чтобы обновлять данные через interface builder, значение св-в нужно обновлять в реальном времени.
                Observer за св-вом did set, который вызывается каждый раз, после того как значение св-ва было изменино.
            */
        didSet {
            setupButtons() // [23] Добавляет новые кнопки.
        }
    }
    @IBInspectable var starCount: Int = 5 {
        
        didSet {
            setupButtons()
        }
    }
    
        /*  [23]
            View создается либо кодом, либо в storyboard
            init(frame: - для програмной инициализации View
            init(coder: - для работы через starybord
            Все это методы, которые подготавливают экземпляр класса к пользованию. Которые вкл. установки начальних значений для каждого св-ва.
            Нам прийдется разместить StackView в storyboard
        */
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame) // инициализатор родительского класса
        setupButtons()
    }
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
        setupButtons()
    }
    
    // MARK: Button Action
    
    @objc func ratingButtonTapped(button: UIButton) {
        
            /*  [24]
                Все Button хранятся в []
                Нужно определить индекс Button, которой касается пользователь
                .firstIndex(of:) - возвращает интекс первого элемента
            */
        guard let index = ratingButtons.firstIndex(of: button) else { return }
        
            // [24] Calculate the rating of the selected button
        let selectedRating = index + 1
        
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    
    // MARK: Private Methods
    
    private func setupButtons() {
        
            // [23] Сначала очищаем все кнопки, а после уже создаем
        for button in ratingButtons {
            removeArrangedSubview(button)
            button.removeFromSuperview() // удаляем из StackView
        }
            
            // [23] Очищаем массив button
        ratingButtons.removeAll()
        
            // Load button image
            /*  [24]
                Для отображения образов Button in the Interface Builder необходимо явно указать, откуда брать изображения.
                Мы берем их из каталога Assets
                Bundle() определяем местоположение ресурсов
                in: где файлы
                compatibleWith: убидиться, что загружен правильный вариант
            */
        let bundle = Bundle(for: type(of: self))
        
        let filledStar = UIImage(named: "filledStar",
                                 in: bundle,
                                 compatibleWith: self.traitCollection)
        
        let emptyStar = UIImage(named: "emptyStar",
                                in: bundle,
                                compatibleWith: self.traitCollection)
        
        let highlightedStar = UIImage(named: "highlightedStar",
                                      in: bundle,
                                      compatibleWith: self.traitCollection)
        
            // [23] Нам нужно 5 кнопок, поэтому добавляем его в цикл с 5 итерациями
        for _ in 0..<starCount {
            
                // Create the button [23]
            let button = UIButton()
            
                // Set the button image
            button.setImage(emptyStar, for: .normal)
            button.setImage(filledStar, for: .selected)
            button.setImage(highlightedStar, for: .highlighted)
            button.setImage(highlightedStar, for: [.highlighted, .selected])
            
                // Add constraints [23]
            button.translatesAutoresizingMaskIntoConstraints = false // отключает автоматические constraints for the button
            button.heightAnchor.constraint(equalToConstant: starSize.height).isActive = true // высота кнопки
            button.widthAnchor.constraint(equalToConstant: starSize.width).isActive = true
            
                // Setup the button action
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            
                // Add the button to the stack
            addArrangedSubview(button)
            
                // Add the new button on the rating button array
            ratingButtons.append(button)
        }
        
        updateButtonSelectionState()
        
    }
    
        // [24] Обновление внешнего вида звезд относительно выбора
    private func updateButtonSelectionState() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
        
    }
    
    deinit {
        print("deinit", RatingControl.self)
    }

}
