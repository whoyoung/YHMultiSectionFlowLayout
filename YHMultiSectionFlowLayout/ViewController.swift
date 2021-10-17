//
//  ViewController.swift
//  YHMultiSectionFlowLayout
//
//  Created by young on 2021/10/16.
//

import UIKit

class ViewController: UIViewController {
    private let kContentCellID = "kContentCellID"

    private let layout = YHFlowLayout()
    
    private lazy var collectionView: UICollectionView = {
        
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        layout.dataSource = self
        
        let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.white
        return collectionView
    }()
    
    private lazy var datas: [[String]] = {
        var d: [String] = []
        for i in 0..<20 {
            d.append("\(i)")
        }
        var ds = [["0", "1"], d]
        return ds
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: kContentCellID)
    }
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return datas.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section < datas.count {
            return datas[section].count
        }
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kContentCellID, for: indexPath)
        
        cell.backgroundColor = UIColor.randomColor()
        if indexPath.section >= datas.count {
            return cell
        }
        let d = datas[indexPath.section]
        if let label = cell.viewWithTag(101) as? UILabel {
            label.text = d[indexPath.item]
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        } else {
            let label = UILabel()
            label.text = d[indexPath.item]
            label.textColor = UIColor.black
            label.tag = 101
            cell.contentView.addSubview(label)
            label.frame = CGRect(x: 0, y: 0, width: 100, height: 44)
        }
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionView.elementKindSectionHeader {
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath)
//            header.backgroundColor = UIColor.green
//            if let label = header.viewWithTag(101) as? UILabel {
//                label.text = " Section \(indexPath.section)"
//            } else {
//                let label = UILabel()
//                label.textColor = UIColor.black
//                label.tag = 101
//                header.addSubview(label)
//                label.frame = CGRect(x: 0, y: 0, width: collectionView.frame.width - collectionView.contentInset.left - collectionView.contentInset.right, height: 44)
//                label.text = " Section \(indexPath.section)"
//            }
//            return header
//        } else {
//            return UICollectionReusableView()
//        }
//    }
}

extension ViewController: YHFlowLayoutDataSource {
    public func flowLayoutHeight(_ layout: YHFlowLayout, indexPath: IndexPath) -> CGFloat {
        return CGFloat(arc4random_uniform(150) + 100)
    }
    
    internal func numberOfColumnsInFlowLayout(_ layout: YHFlowLayout, section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return 2
    }
}

extension ViewController: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == datas.count - 1 {
//            DispatchQueue.main.async {
//                let count = self.datas.count
//                for i in 0..<20 {
//                    self.datas.append("\(count+i)")
//                }
//                self.collectionView.reloadData()
//            }
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: 300, height: 44)
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return CGSize(width: 0, height: 0)
//    }
}

extension UIColor {
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, alpha: CGFloat = 1.0) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0, alpha: alpha)
    }
    
    class func randomColor() -> UIColor {
        return UIColor(r: CGFloat(arc4random_uniform(256)), g: CGFloat(arc4random_uniform(256)), b: CGFloat(arc4random_uniform(256)))
    }
}

