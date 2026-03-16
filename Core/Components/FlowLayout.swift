import SwiftUI

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (_, line) in result.lines.enumerated() {
            let lineY = bounds.minY + line.yOffset
            var xOffset = bounds.minX
            
            for itemIndex in line.itemIndices {
                let subview = subviews[itemIndex]
                let size = subview.sizeThatFits(.unspecified)
                subview.place(
                    at: CGPoint(x: xOffset, y: lineY),
                    proposal: ProposedViewSize(size)
                )
                xOffset += size.width + spacing
            }
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var lines: [Line] = []
        
        struct Line {
            var itemIndices: [Int] = []
            var yOffset: CGFloat = 0
            var height: CGFloat = 0
        }
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentLine = Line()
            var currentX: CGFloat = 0
            var maxY: CGFloat = 0
            var lineHeight: CGFloat = 0
            var itemsInLine: [Int] = []
            
            for (index, subview) in subviews.enumerated() {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth, !itemsInLine.isEmpty {
                    // Complete current line
                    currentLine.itemIndices = itemsInLine
                    currentLine.height = lineHeight
                    currentLine.yOffset = maxY
                    lines.append(currentLine)
                    
                    // Start new line
                    itemsInLine = [index]
                    currentX = size.width + spacing
                    maxY += lineHeight + spacing
                    lineHeight = size.height
                } else {
                    itemsInLine.append(index)
                    currentX += size.width + spacing
                    lineHeight = max(lineHeight, size.height)
                }
            }
            
            // Add last line
            if !itemsInLine.isEmpty {
                currentLine.itemIndices = itemsInLine
                currentLine.height = lineHeight
                currentLine.yOffset = maxY
                lines.append(currentLine)
                maxY += lineHeight
            }
            
            size = CGSize(width: maxWidth, height: maxY)
        }
    }
}
