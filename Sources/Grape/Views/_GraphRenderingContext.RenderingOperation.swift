import SwiftUI

extension _GraphRenderingContext {
    @usableFromInline
    internal enum RenderingOperation {
        case node(NodeMark<NodeID>)
        case link(LinkMark<NodeID>)
        case label(Text, id: NodeID)

        case fillPush(GraphicsContext.Shading)
        case fillPop

        case strokePush(GraphicsContext.Shading)
        case strokePop

        case opacityPush(Double)
        case opacityPop

        case modifierBegin(AnyGraphContentModifier)
        case modifierEnd
    }
}

extension _GraphRenderingContext.RenderingOperation: Equatable {
    @inlinable
    internal static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.node(let l), .node(let r)):
            return l == r
        case (.link(let l), .link(let r)):
            return l == r
        case (.modifierEnd, .modifierEnd):
            return true
        case (.modifierBegin(let l), .modifierBegin(let r)):
            return l == r
        default:
            return false
        }
    }
}