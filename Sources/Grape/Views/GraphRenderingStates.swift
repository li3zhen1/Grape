import SwiftUI

@usableFromInline
internal struct GraphRenderingStates<NodeID: Hashable> {

    @usableFromInline
    enum StateID: Hashable {
        case node(NodeID)
        case link(NodeID, NodeID)
    }

    @usableFromInline
    var currentID: StateID? = nil

    @usableFromInline
    var shading: [GraphicsContext.Shading] = []

    @inlinable
    var currentShading: GraphicsContext.Shading { shading.last ?? defaultShading }

    @usableFromInline
    var stroke: [GraphContentEffect.Stroke] = []

    @inlinable
    var currentStroke: GraphContentEffect.Stroke { stroke.last ?? defaultStroke }

    @usableFromInline
    var opacity: [Double] = []

    @inlinable
    var currentOpacity: Double { opacity.last ?? defaultOpacity }

    @usableFromInline
    let defaultShading: GraphicsContext.Shading

    @usableFromInline
    let defaultStroke: GraphContentEffect.Stroke

    @usableFromInline
    let defaultOpacity: Double

    @inlinable
    init(
        defaultShading: GraphicsContext.Shading = .color(.blue),
        defaultStroke: GraphContentEffect.Stroke = .init(.color(.black)),
        defaultOpacity: Double = 1,
        reservingCapacity capacity: Int = 128
    ) {
        shading.reserveCapacity(capacity)
        stroke.reserveCapacity(capacity)
        opacity.reserveCapacity(capacity)

        self.defaultShading = defaultShading
        self.defaultStroke = defaultStroke
        self.defaultOpacity = defaultOpacity
    }
}