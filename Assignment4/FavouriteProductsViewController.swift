//
//  FavouriteProductsViewController.swift
//  Assignment4
//
//  Created by Kishan Jayswal on 2024-08-14.
//

import UIKit
import CoreData

class FavouriteProductsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ProductDetailViewControllerDelegate {
    func didUpdateTotalPrice(_ newTotalPrice: Double) {
        totalPrice += newTotalPrice  // Add new total price to the existing total
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    var favoriteProducts: [FavoriteProduct] = []
    private var totalPrice: Double = 0.0
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favoriteProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as! ProductTableViewCell
        let product = favoriteProducts[indexPath.row]

        cell.productTitle.text = product.title
        cell.productPrice.text = String(format: "$%.2f", product.price)

        if let imageUrl = URL(string: product.image!), let imageData = try? Data(contentsOf: imageUrl) {
            cell.productImage.image = UIImage(data: imageData)
        } else {
            cell.productImage.image = UIImage(named: "placeholder") // Placeholder image if URL is invalid
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getData()
        tableView.reloadData()
    }
    
    func getData() {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteProduct")
                request.returnsObjectsAsFaults = false

                do {
                    let result = try context.fetch(request) as! [FavoriteProduct]
                    favoriteProducts = result
                } catch {
                    print("Failed to fetch favorite products: \(error)")
                }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductDetail",
           let destinationVC = segue.destination as? ProductDetailViewController {
            // Set the delegate
            destinationVC.delegate = self
            
            // Pass the product ID if available
            if let indexPath = tableView.indexPathForSelectedRow {
                let product = favoriteProducts[indexPath.row]
                destinationVC.productID = Int(product.id)
            }
        }
    }

}
