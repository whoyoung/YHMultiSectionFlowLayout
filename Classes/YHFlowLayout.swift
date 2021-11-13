//
//  YHFlowLayout.swift
//  流式布局
//

import UIKit

/// 流式布局代理
public protocol YHFlowLayoutDataSource: AnyObject {
    /// ITEM 高度
    func flowLayoutHeight(_ collectionView: UICollectionView, layout: YHFlowLayout, indexPath: IndexPath) -> CGFloat
    
    /// 流式布局列数，默认2列
    /// - Parameter layout: 布局
    /// - Returns: 列数
    func numberOfColumnsInFlowLayout(_ collectionView: UICollectionView, layout: YHFlowLayout, section: Int) -> Int
    
    func insetForSection(_ collectionView: UICollectionView, layout: YHFlowLayout, section: Int) -> UIEdgeInsets?
}

public extension YHFlowLayoutDataSource {
    func flowLayoutHeight(_ collectionView: UICollectionView, layout: YHFlowLayout, indexPath: IndexPath) -> CGFloat {
        return 0.1
    }
    
    func numberOfColumnsInFlowLayout(_ collectionView: UICollectionView, layout: YHFlowLayout, section: Int) -> Int {
        return 2
    }
    
    func insetForSection(_ collectionView: UICollectionView, layout: YHFlowLayout, section: Int) -> UIEdgeInsets? {
        return nil
    }
}

public class YHFlowLayout: UICollectionViewFlowLayout {
    
    /// 布局属性数组
    private lazy var attrsArray: [UICollectionViewLayoutAttributes] = []
    
    /// 每一个 section 每一列的高度累计
    private var columnHeights: [Int: [CGFloat]] = [:]
    
    /// 每一个 section 最高的高度
    private var maxH: [Int: CGFloat] = [:]
    
    /// 智能排序: item 拼接在高度最小的列。默认为 true。 false: 按顺序左右逐个排列
    public var smartSort = true
    
    /// 每一个 section 中 item 的数目
    private var existedNum: [Int: Int] = [:]
    
    public weak var flowLayoutDataSource: YHFlowLayoutDataSource?
}

extension YHFlowLayout {
    
    public override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        let sectionCount = collectionView.numberOfSections
        var columns = 2
        guard let lay = flowLayoutDataSource else {
            fatalError("请设置 flowLayoutDataSource, 并实现 YHFlowLayoutDataSource 协议")
        }
        if columnHeights.isEmpty {
            var top = self.sectionInset.top
            for i in 0..<sectionCount {
                if let inset = lay.insetForSection(collectionView, layout: self, section: i) {
                    top = inset.top
                }
                columns = lay.numberOfColumnsInFlowLayout(collectionView, layout: self, section: i)
                
                columnHeights[i] = Array(repeating: top, count: columns)
                existedNum[i] = 0
                maxH[i] = top
            }
        }
        
        var previousSectionH = CGFloat(0)
        var inset = self.sectionInset
        for index in 0..<sectionCount {
            let itemCount = collectionView.numberOfItems(inSection: index)
            if let aInset = lay.insetForSection(collectionView, layout: self, section: index) {
                inset = aInset
            }
            columns = lay.numberOfColumnsInFlowLayout(collectionView, layout: self, section: index)
            
            let drawW = collectionView.bounds.width - inset.left - inset.right
            // Item宽度
            let itemW = (drawW - self.minimumInteritemSpacing * CGFloat(columns - 1)) / CGFloat(columns)
            
            if index > 0 {
                previousSectionH = maxH[index - 1] ?? CGFloat(0.0)
            }
            let existed = existedNum[index] ?? 0
            var heights = columnHeights[index] ?? []

            // 计算所有的item的属性
            for i in existed..<itemCount {
                let indexPath = IndexPath(item: i, section: index)
                let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)

                let height = lay.flowLayoutHeight(collectionView, layout: self, indexPath: indexPath)
                var destColumn = i % columns
                var minHeight = heights[destColumn]
                if smartSort {
                    // swiftlint:disable for_where
                    for idx in 0..<heights.count {
                        if minHeight > heights[idx] {
                            minHeight = heights[idx]
                            destColumn = idx
                        }
                    }
                    // swiftlint:enable for_where
                }
                
                let x = inset.left + (self.minimumInteritemSpacing + itemW) * CGFloat(destColumn)
     
                // 设置item的属性
                attrs.frame = CGRect(x: x, y: minHeight + previousSectionH, width: itemW, height: height)
                // 将当前列的高度在加载当前ITEM的高度
                minHeight += height + minimumLineSpacing
                // 重新设置当前列的高度
                heights[destColumn] = minHeight
                
                attrsArray.append(attrs)
            }
            columnHeights[index] = heights
            existedNum[index] = itemCount
            if index == 0 {
                maxH[index] = columnHeights[index]?.max() ?? 0
            } else {
                let previousH = maxH[index - 1] ?? CGFloat(0)
                maxH[index] = previousH + (columnHeights[index]?.max() ?? CGFloat(0))
            }
        }
        
    }
    
    public override func invalidateLayout() {
        super.invalidateLayout()
        columnHeights.removeAll()
        existedNum.removeAll()
        attrsArray.removeAll()
        maxH.removeAll()
    }
}

extension YHFlowLayout {
    public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return attrsArray
    }
    
    public override var collectionViewContentSize: CGSize {
        guard let collectionView = collectionView else { return CGSize.zero
        }
        let sectionCount = collectionView.numberOfSections
        if sectionCount < 1 {
            return CGSize.zero
        }
        let h = maxH[sectionCount - 1] ?? CGFloat(0)
        var bottom = sectionInset.bottom
        if let inset = flowLayoutDataSource?.insetForSection(collectionView, layout: self, section: sectionCount - 1) {
            bottom = inset.bottom
        }
        return CGSize(width: 0, height: h + bottom - minimumLineSpacing)
    }
}
