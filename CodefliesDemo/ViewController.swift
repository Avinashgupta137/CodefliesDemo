//
//  ViewController.swift
//  CodefliesDemo
//
//  Created by Avinash Gupta on 31/03/25.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var searchitem: UISearchBar!
    @IBOutlet weak var mainCollectionView: UICollectionView!
    var categories: [(name: String, imageUrl: String, price: String)] = []
    var filteredCategories: [(name: String, imageUrl: String, price: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchitem.delegate = self
        setupCollectionViewLayout()
        fetchMessages()
        
    }
    func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        mainCollectionView.collectionViewLayout = layout
    }
    func fetchMessages() {
        ApiClient.shared.callHttpMethod(
            apiendpoint: Constant.productsCategories,
            method: .get,
            param: [:],
            model: [ProductsCategorieElement].self
        ) { [weak self] result in
            switch result {
            case .success(let response):
                self?.categories = response.compactMap { category in
                    
                    guard let imageUrl = category.image?.src else {
                        return nil
                    }
                    
                    let name = category.name
                    let price = category.slug
                    
                    return (name, imageUrl, price)
                }
                self?.filteredCategories = self?.categories ?? []
                DispatchQueue.main.async {
                    self?.view.layoutIfNeeded()
                    self?.mainCollectionView.reloadData()
                }
            case .failure(let error):
                print("API Error: \(error.localizedDescription)")
            }
        }
    }
    
}

extension ViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProductCollectionViewCell", for: indexPath) as! ProductCollectionViewCell
        let category = filteredCategories[indexPath.row]
        cell.configure(with: category)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfColumns: CGFloat = 2
        let spacing: CGFloat = 10
        let totalSpacing = (numberOfColumns - 1) * spacing + 20
        let itemWidth = (collectionView.frame.width - totalSpacing) / numberOfColumns
        let itemHeight = itemWidth + 120
        return CGSize(width: itemWidth, height: itemHeight)
    }
}
extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            filteredCategories = categories
        } else {
            filteredCategories = categories.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        mainCollectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}
