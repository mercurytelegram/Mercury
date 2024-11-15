//
//  FlowLayout.swift
//  Mercury Watch App
//
//  Created by Alessandro Alberti on 11/15/24.
//

import SwiftUI

struct FlowLayout: Layout {
    var spacing: (x: CGFloat, y: CGFloat)
    
    init(horizontalSpacing: CGFloat = 5, verticalSpacing: CGFloat = 5) {
        self.spacing = (horizontalSpacing, verticalSpacing)
    }

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let arranger = Arranger(
            containerSize: proposal.replacingUnspecifiedDimensions(),
            subviews: subviews,
            spacing: spacing
        )
        let result = arranger.arrange()
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let arranger = Arranger(
            containerSize: proposal.replacingUnspecifiedDimensions(),
            subviews: subviews,
            spacing: spacing
        )
        let result = arranger.arrange()

        for (index, cell) in result.cells.enumerated() {
            let point = CGPoint(
                x: bounds.minX + cell.frame.origin.x,
                y: bounds.minY + cell.frame.origin.y
            )

            subviews[index].place(
                at: point,
                anchor: .topLeading,
                proposal: ProposedViewSize(cell.frame.size)
            )
        }
    }
}

struct Arranger {
    var containerSize: CGSize
    var subviews: LayoutSubviews
    var spacing: (x: CGFloat, y: CGFloat)

    func arrange() -> Result {
        var cells: [Cell] = []

        var maxY: CGFloat = 0
        var previousFrame: CGRect = .zero

        for (index, subview) in subviews.enumerated() {
            let size = subview.sizeThatFits(ProposedViewSize(containerSize))

            var origin: CGPoint
            if index == 0 {
                origin = .zero
            } else if previousFrame.maxX + spacing.x + size.width > containerSize.width {
                origin = CGPoint(x: 0, y: maxY + spacing.y)
            } else {
                origin = CGPoint(x: previousFrame.maxX + spacing.x, y: previousFrame.minY)
            }

            let frame = CGRect(origin: origin, size: size)
            let cell = Cell(frame: frame)
            cells.append(cell)

            previousFrame = frame
            maxY = max(maxY, frame.maxY)
        }

        let maxWidth = cells.reduce(0, { max($0, $1.frame.maxX) })
        return Result(
            size: CGSize(width: maxWidth, height: previousFrame.maxY),
            cells: cells
        )
    }
    
    struct Result {
        var size: CGSize
        var cells: [Cell]
    }

    struct Cell {
        var frame: CGRect
    }
}
