//
//  YHFlowLayout.swift
//  瀑布流
//
//

import UIKit

/// 瀑布流代理
@objc public protocol YHFlowLayoutDataSource: AnyObject {
    /// ITEM 高度
    func flowLayoutHeight(_ layout: YHFlowLayout, indexPath: IndexPath) -> CGFloat
    
    /// 瀑布流列数，默认2列
    /// - Parameter layout: 布局
    /// - Returns: 列数
    @objc optional func numberOfColumnsInFlowLayout(_ layout: YHFlowLayout, section: Int) -> Int
    
}

public class YHFlowLayout: UICollectionViewFlowLayout {
    
    /// 瀑布流数据源代理
    public weak var dataSource: YHFlowLayoutDataSource?
    
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
}

extension YHFlowLayout {
    
    public override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }
        let sectionCount = collectionView.numberOfSections
        if columnHeights.isEmpty {
            var top = CGFloat(0.0)
            for i in 0..<sectionCount {
                top += self.sectionInset.top
                let columns = self.dataSource?.numberOfColumnsInFlowLayout?(self, section: i) ?? 2

                columnHeights[i] = Array(repeating: top, count: columns)
                existedNum[i] = 0
                maxH[i] = top
            }
        }
        
        var previousSectionH = CGFloat(0)
        for index in 0..<sectionCount {
            let itemCount = collectionView.numberOfItems(inSection: index)
            
            let cols = dataSource?.numberOfColumnsInFlowLayout?(self, section: index) ?? 2
            
            let drawW = collectionView.bounds.width - self.sectionInset.left - self.sectionInset.right
            // Item宽度
            let itemW = (drawW - self.minimumInteritemSpacing * CGFloat(cols - 1)) / CGFloat(cols)
            
            if index > 0 {
                previousSectionH = maxH[index - 1] ?? CGFloat(0.0)
            }
            let existed = existedNum[index] ?? 0
            var heights = columnHeights[index] ?? []

            // 计算所有的item的属性
            for i in existed..<itemCount {
                let indexPath = IndexPath(item: i, section: index)
                let attrs = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                
                // 获取CELL的高度
                guard let height = dataSource?.flowLayoutHeight(self, indexPath: indexPath) else {
                    fatalError("请设置数据源,并且实现对应的数据源方法")
                }
                
                var destColumn = i % cols
                var minHeight = heights[destColumn]
                if smartSort {
                    for idx in 0..<heights.count {
                        if minHeight > heights[idx] {
                            minHeight = heights[idx]
                            destColumn = idx
                        }
                    }
                }
                
                let x = self.sectionInset.left + (self.minimumInteritemSpacing + itemW) * CGFloat(destColumn)
     
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
        return CGSize(width: 0, height: h + sectionInset.bottom - minimumLineSpacing)
    }
}
