import ForceSimulation


public struct KineticState {
    public let position: SIMD2<Double>
    public let velocity: SIMD2<Double>
    public let fixation: SIMD2<Double>?
    @inlinable
    public init(
        position: SIMD2<Double>,
        velocity: SIMD2<Double> = .zero,
        fixation: SIMD2<Double>? = nil
    ) {
        self.position = position
        self.velocity = velocity
        self.fixation = fixation
    }
}

@usableFromInline
internal struct SimulationContext<NodeID: Hashable> {

    public typealias Vector = ForceField.Vector
    public typealias ForceField = SealedForce2D

    @usableFromInline
    internal var storage: Simulation2D<ForceField>

    @usableFromInline
    internal var nodeIndexLookup: [NodeID: Int]

    @usableFromInline
    internal var nodeIndices: [NodeID]

    @inlinable
    package init(
        _ storage: Simulation2D<ForceField>,
        _ nodeIndexLookup: [NodeID: Int],
        _ nodeIndices: [NodeID]
    ) {
        self.storage = storage
        self.nodeIndexLookup = nodeIndexLookup
        self.nodeIndices = nodeIndices
    }

}

extension SimulationContext {

    @inlinable 
    public static func create(
        for graphRenderingContext: _GraphRenderingContext<NodeID>,
        makeForceField: (inout SealedForce2D, [NodeID]) -> Void,
        velocityDecay: Vector.Scalar
    ) -> Self {
        let nodes = graphRenderingContext.nodes

        let nodeIndexLookup = Dictionary(
            uniqueKeysWithValues: nodes.enumerated().map {
                ($0.element.id, $0.offset)
            }
        )

        let nodeIDs = nodes.map { $0.id }

        var forceField = SealedForce2D([])
        makeForceField(&forceField, nodeIDs)

        let links = graphRenderingContext.edges.map {
            EdgeID<Int>(
                source: nodeIndexLookup[$0.id.source]!,
                target: nodeIndexLookup[$0.id.target]!
            )
        }
        return .init(
            .init(
                nodeCount: nodes.count,
                links: links,
                forceField: forceField,
                velocityDecay: velocityDecay
            ),
            nodeIndexLookup,
            nodes.map(\.id)
        )
    }

    // @inlinable
    // public static func create(
    //     for graphRenderingContext: _GraphRenderingContext<NodeID>,
    //     with forceField: ForceField,
    //     velocityDecay: Vector.Scalar
    // ) -> Self {
    //     let nodes = graphRenderingContext.nodes

    //     let nodeIndexLookup = Dictionary(
    //         uniqueKeysWithValues: nodes.enumerated().map {
    //             ($0.element.id, $0.offset)
    //         }
    //     )

    //     let links = graphRenderingContext.edges.map {
    //         EdgeID<Int>(
    //             source: nodeIndexLookup[$0.id.source]!,
    //             target: nodeIndexLookup[$0.id.target]!
    //         )
    //     }
    //     return .init(
    //         .init(
    //             nodeCount: nodes.count,
    //             links: links,
    //             forceField: forceField,
    //             velocityDecay: velocityDecay
    //         ),
    //         nodeIndexLookup,
    //         nodes.map(\.id)
    //     )
    // }

    /// reuse the same simulation context for new graph
    @inlinable
    public mutating func revive(
        for newContext: _GraphRenderingContext<NodeID>,
        makeForceField: (inout SealedForce2D, [NodeID]) -> Void,
        velocityDecay: Vector.Scalar,
        emittingNewNodesWith states: (NodeID) -> KineticState = { _ in .init(position: .zero) }
    ) {
        let newNodes = newContext.nodes

        let newNodeIndexLookup = Dictionary(
            uniqueKeysWithValues: newNodes.enumerated().map {
                ($0.element.id, $0.offset)
            }
        )

        let nodeIDs = newNodes.map { $0.id }

        var newForceField = SealedForce2D([])
        makeForceField(&newForceField, nodeIDs)

        let newLinks = newContext.edges.map {
            EdgeID<Int>(
                source: newNodeIndexLookup[$0.id.source]!,
                target: newNodeIndexLookup[$0.id.target]!
            )
        }

        let newlyAddedNodes = newNodes.filter { newNode in
            !nodeIndexLookup.keys.contains(newNode.id)
        }

        let newlyAddedNodeStates = Dictionary(
            uniqueKeysWithValues: newlyAddedNodes.map {
                ($0.id, states($0.id))
            }
        )

        

        let newPosition = newNodes.map {
            if let index = self.nodeIndexLookup[$0.id] {
                return storage.kinetics.position[index]
            } else {
                if let newState = newlyAddedNodeStates[$0.id] {
                    return newState.position
                }
                return .zero
            }
        }

        let newVelocity = newNodes.map {
            if let index = self.nodeIndexLookup[$0.id] {
                return storage.kinetics.velocity[index]
            } else {
                if let newState = newlyAddedNodeStates[$0.id] {
                    return newState.velocity
                }
                return .zero
            }
        }

        let newFixation = newNodes.map {
            if let index = self.nodeIndexLookup[$0.id] {
                return storage.kinetics.fixation[index]
            } else {
                if let newState = newlyAddedNodeStates[$0.id] {
                    return newState.fixation
                }
                return nil
            }
        }

        let newStorage = Simulation2D<SealedForce2D>(
            nodeCount: newNodes.count,
            links: newLinks,
            forceField: newForceField,
            velocityDecay: velocityDecay,
            position: newPosition,
            velocity: newVelocity,
            fixation: newFixation
        )

        self = .init(
            newStorage,
            newNodeIndexLookup,
            newNodes.map(\.id)
        )
    }

    @inlinable
    public func getKineticState(nodeID: NodeID) -> KineticState? {
        if let index = nodeIndexLookup[nodeID] {
            return .init(
                position: storage.kinetics.position[index],
                velocity: storage.kinetics.velocity[index],
                fixation: storage.kinetics.fixation[index]
            )
        } else {
            return nil
        }
    }

    @inlinable
    public func updateKineticState(nodeID: NodeID, _ state: KineticState) {
        if let index = nodeIndexLookup[nodeID] {
            storage.kinetics.position[index] = state.position
            storage.kinetics.velocity[index] = state.velocity
            storage.kinetics.fixation[index] = state.fixation
        }
    }

    @inlinable
    public func updateAllKineticStates(_ states: (NodeID) -> KineticState) {
        for (nodeID, index) in nodeIndexLookup {
            let state = states(nodeID)
            storage.kinetics.position[index] = state.position
            storage.kinetics.velocity[index] = state.velocity
            storage.kinetics.fixation[index] = state.fixation
        }
    }
}
