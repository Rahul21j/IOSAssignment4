//
//  DataManager.swift
//  Assignment4
//
//  Created by Kishan Jayswal on 2024-08-14.
//

import Foundation
import CoreData
import UIKit

class DataManager {
    
    // Singleton instance
    static let shared = DataManager()
    private init() {}
    
    // Fetch products from API
    func fetchProducts(completion: @escaping ([Product]?) -> Void) {
        guard let url = URL(string: "https://fakestoreapi.com/products") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching products: \(error)")
                completion(nil)
                return
            }
            guard let data = data else {
                completion(nil)
                return
            }
            do {
                let products = try JSONDecoder().decode([Product].self, from: data)
                completion(products)
            } catch {
                print("Error decoding products: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    // Fetch product details from API
    func fetchProductDetails(for productID: Int, completion: @escaping (Product?) -> Void) {
        guard let url = URL(string: "https://fakestoreapi.com/products/\(productID)") else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching product details: \(error)")
                completion(nil)
                return
            }
            guard let data = data else {
                completion(nil)
                return
            }
            do {
                let product = try JSONDecoder().decode(Product.self, from: data)
                completion(product)
            } catch {
                print("Error decoding product details: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    // Fetch favorite products from Core Data
    func fetchFavoriteProducts(completion: @escaping ([FavoriteProduct]?) -> Void) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            completion(results)
        } catch {
            print("Failed to fetch favorite products: \(error)")
            completion(nil)
        }
    }
    
    // Add or remove product from favorites
    func toggleFavorite(product: Product, completion: @escaping (Bool) -> Void) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteProduct> = FavoriteProduct.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", Int32(product.id))
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.isEmpty {
                let favoriteProduct = FavoriteProduct(context: context)
                favoriteProduct.id = Int32(product.id)
                favoriteProduct.title = product.title
                favoriteProduct.price = product.price
                favoriteProduct.category = product.category
                favoriteProduct.productDescription = product.description
                favoriteProduct.image = product.image
                favoriteProduct.rating = product.rating.rate
                favoriteProduct.ratingCount = Int32(product.rating.count)
                
                try context.save()
                completion(true)
            } else {
                let favoriteProduct = results.first!
                context.delete(favoriteProduct)
                try context.save()
                completion(false)
            }
        } catch {
            print("Failed to fetch or save product: \(error)")
            completion(false)
        }
    }
}
