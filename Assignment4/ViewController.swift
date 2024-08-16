//
//  ViewController.swift
//  Assignment4
//
//  Created by Kishan Jayswal on 2024-08-12.
//

import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ProductDetailViewControllerDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = productList[indexPath.row]
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "productCell", for: indexPath) as? ProductTableViewCell else {
                fatalError("Failed to dequeue a ProductTableViewCell.")
            }
            cell.productTitle.text = product.title
            cell.productPrice.text = String(format: "%.2f", product.price)
            cell.productImage.downloaded(from: product.image)
            // Load image asynchronously
            if let imageUrl = URL(string: product.image) {
                URLSession.shared.dataTask(with: imageUrl) { data, _, _ in
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            cell.productImage.image = image
                            cell.setNeedsLayout()
                        }
                    }
                }.resume()
            }
            return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var favProductsBtn: UIBarButtonItem!
    @IBAction func favProductsBtnTapped(_ sender: Any) {
    }
    @IBOutlet weak var buyBtn: UIButton!
    @IBAction func buyBtn(_ sender: Any) {
        if totalPrice > 0 {
                let alert = UIAlertController(title: "Success", message: "Items ordered successfully", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    // Change the title of the buyBtn after the alert is dismissed
                    self?.buyBtn.setTitle("Buy", for: .normal)
                }
                
                alert.addAction(okAction)
                present(alert, animated: true, completion: nil)
            }
        
    }
    
    var productList:[Product]=[]
    private var totalPrice: Double = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Product Catalog"
        tableView.delegate = self
        tableView.dataSource = self
        fetchData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showProductDetail",
           let destinationVC = segue.destination as? ProductDetailViewController {
            // Set the delegate
            destinationVC.delegate = self
            
            // Pass the product ID if available
            if let indexPath = tableView.indexPathForSelectedRow {
                let product = productList[indexPath.row]
                destinationVC.productID = product.id
            }
        }
    }
    
    func fetchData(){
        DataManager.shared.fetchProducts { [weak self] products in
            guard let self = self, let products = products else { return }
            self.productList = products
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func didUpdateTotalPrice(_ newTotalPrice: Double) {
        totalPrice += newTotalPrice  // Add new total price to the existing total
           DispatchQueue.main.async { [weak self] in
               self?.buyBtn.setTitle(String(format: "Buy ($%.2f)", self?.totalPrice ?? 0.0), for: .normal)
           }
        }
    




}

