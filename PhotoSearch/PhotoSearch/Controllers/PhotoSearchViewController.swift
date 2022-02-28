//
//  ViewController.swift
//  PhotoSearch
//
//  Created by Shivang on 28/02/22.
//

import UIKit

class PhotoSearchViewController: UIViewController {
    
    private var collectionView: UICollectionView?
    
    var results: [Result] = []
    
    private let searchbar = UISearchBar()

    override func viewDidLoad() {
        super.viewDidLoad()
        searchbar.delegate = self
        view.addSubview(searchbar)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width/2,
                                 height: view.frame.size.width/2)
        let collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self,
                                forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        self.collectionView = collectionView
    }
    
    override func viewDidLayoutSubviews() {
        searchbar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
        collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.frame.size.width, height: view.frame.size.height-55)
    }

    func fetchPhotos(query: String) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=4000&query=\(query)&client_id=vKgewsMkPr2FAEzTPbyuv_6npFhyUkSjGnXq8_ltrf8"
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            print("Got Data!")
            do {
                let jsonResults = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.results = jsonResults.results
                    self?.collectionView?.reloadData()
                }
            }
            catch {
                print("error")
            }
        }
        task.resume()
    }
}


// Mark:- SearchBar Implementation

extension PhotoSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchbar.text {
            results = []
            collectionView?.reloadData()
            fetchPhotos(query: text)
        }
    }

}

// Mark:- CollectionView Datasource

extension PhotoSearchViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return results.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imageUrlString = results[indexPath.row].urls.regular
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ImageCollectionViewCell.identifier,
            for: indexPath
        ) as? ImageCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(with: imageUrlString)
        return cell
    }
    
}

