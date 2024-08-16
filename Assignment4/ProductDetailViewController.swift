//
//  ProductDetailViewController.swift
//  Assignment4
//
//  Created by Kishan Jayswal on 2024-08-12.
//

import UIKit
import CoreData

protocol ProductDetailViewControllerDelegate: AnyObject {
    func didUpdateTotalPrice(_ newTotalPrice: Double)
}


class ProductDetailViewController: UIViewController {

    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productTitle: UILabel!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productCategory: UILabel!
    @IBOutlet weak var productRating: UILabel!
    @IBOutlet weak var productRatingCount: UILabel!
    @IBOutlet weak var productDescription: UILabel!
    
    @IBOutlet weak var addToCartBtn: UIButton!
    @IBOutlet weak var addToFavBtn: UIButton!
    
    weak var delegate: ProductDetailViewControllerDelegate?
        var productID: Int?
        var product: Product?
        
        override func viewDidLoad() {
            super.viewDidLoad()
            if let productID = productID {
                fetchData(for: productID)
            }
            addToFavBtn.addTarget(self, action: #selector(addToFavorites), for: .touchUpInside)
            addToCartBtn.addTarget(self, action: #selector(addToCart), for: .touchUpInside)
        }
        
        func fetchData(for productID: Int) {
            DataManager.shared.fetchProductDetails(for: productID) { [weak self] product in
                guard let self = self, let product = product else { return }
                self.product = product
                DispatchQueue.main.async {
                    self.updateUI(with: product)
                    self.updateFavoritesButton()
                }
            }
        }
        
        func updateUI(with product: Product) {
            productTitle.text = product.title
            productPrice.text = "Price: $"+String(format: "%.2f", product.price)
            productCategory.text = "Category: "+product.category
            productRating.text = "Ratings: "+String(format: "%.1f", product.rating.rate)+"/5"
            productRatingCount.text = "Number of Ratings: "+"(\(product.rating.count))"
            productDescription.text = "Description: \n"+product.description
            
            if let imageUrl = URL(string: product.image) {
                productImage.downloaded(from: imageUrl)
            }
        }
        
        func updateFavoritesButton() {
            if let product = product {
                DataManager.shared.fetchFavoriteProducts { favorites in
                    let isFavorite = favorites?.contains(where: { $0.id == product.id }) ?? false
                    DispatchQueue.main.async {
                        self.addToFavBtn.setTitle(isFavorite ? "Remove from Favorites" : "Add to Favorites", for: .normal)
                    }
                }
            }
        }

        
    @objc func addToCart() {
        guard let product = product else { return }
        
        // Create an alert with a text field for quantity input
        let alertController = UIAlertController(title: "Add to Cart", message: "Enter the quantity for \(product.title):", preferredStyle: .alert)
        
        // Add a text field to the alert
        alertController.addTextField { textField in
            textField.placeholder = "Quantity (1-10)"
            textField.keyboardType = .numberPad
        }
        
        // Add an "Add" action
        let addAction = UIAlertAction(title: "Add", style: .default) { [weak self, weak alertController] _ in
            guard let self = self, let textField = alertController?.textFields?.first, let quantityText = textField.text, !quantityText.isEmpty else {
                self?.showErrorAlert(message: "Please enter a quantity.")
                return
            }
            
            // Validate the input
            if let quantity = Int(quantityText), quantity > 0 && quantity <= 10 {
                let totalPrice = Double(quantity) * product.price
                self.delegate?.didUpdateTotalPrice(totalPrice)
                
                // Show confirmation alert
                let confirmationAlert = UIAlertController(title: "Added to Cart", message: "\(quantity) x \(product.title) has been added to your cart.", preferredStyle: .alert)
                confirmationAlert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(confirmationAlert, animated: true)
            } else {
                self.showErrorAlert(message: "Please enter a valid quantity between 1 and 10.")
            }
        }
        
        // Add a "Cancel" action
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        // Add actions to the alert
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        // Present the alert
        present(alertController, animated: true)
    }


        private func showErrorAlert(message: String) {
            let errorAlert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            errorAlert.addAction(okAction)
            present(errorAlert, animated: true, completion: nil)
        }

    @objc func addToFavorites() {
        if let product = product {
            DataManager.shared.toggleFavorite(product: product) { [weak self] success in
                guard let self = self else { return }
                let message = success ? "Added to Favorites" : "Removed from Favorites"
                DispatchQueue.main.async {
                    self.addToFavBtn.setTitle(success ? "Remove from Favorites" : "Add to Favorites", for: .normal)
                }
                let alert = UIAlertController(title: "Favorites", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
}
