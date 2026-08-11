import UIKit

final class CenteredRowFlowLayout: UICollectionViewFlowLayout {
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let originalAttributes = super.layoutAttributesForElements(in: rect) else {
            return nil
        }

        let attributes = originalAttributes.map { $0.copy() as! UICollectionViewLayoutAttributes }
        var rows: [[UICollectionViewLayoutAttributes]] = []
        let rowTolerance: CGFloat = 1.0

        for attribute in attributes where attribute.representedElementCategory == .cell {
            if let rowIndex = rows.firstIndex(where: { abs($0[0].center.y - attribute.center.y) <= rowTolerance }) {
                rows[rowIndex].append(attribute)
            } else {
                rows.append([attribute])
            }
        }

        for var row in rows {
            row.sort { $0.frame.minX < $1.frame.minX }

            let contentWidth = row.reduce(0) { $0 + $1.frame.width }
            let totalSpacing = minimumInteritemSpacing * CGFloat(max(0, row.count - 1))
            let availableWidth = collectionView?.bounds.width ?? 0
            let sectionInsets = evaluatedSectionInset
            let startX = sectionInsets.left + max(0, (availableWidth - sectionInsets.left - sectionInsets.right - contentWidth - totalSpacing) / 2)

            var currentX = startX
            for attribute in row {
                attribute.frame.origin.x = currentX
                currentX += attribute.frame.width + minimumInteritemSpacing
            }
        }

        return attributes
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView else { return false }
        return abs(collectionView.bounds.width - newBounds.width) > .ulpOfOne
    }

    private var evaluatedSectionInset: UIEdgeInsets {
        if let collectionView, let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout,
           let insets = delegate.collectionView?(collectionView, layout: self, insetForSectionAt: 0) {
            return insets
        }
        return sectionInset
    }
}