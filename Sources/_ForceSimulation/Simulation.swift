//
//  File.swift
//
//
//  Created by li3zhen1 on 10/1/23.
//

import Foundation
import NDTree


enum SimulationError: Error {
    case subscriptionToNonexistentNode
}


public final class Simulation<NodeID, V> where NodeID: Hashable, V: VectorLike, V.Scalar == Double {
    public typealias Scalar = V.Scalar
    public struct NodeStatus {
        var position: V
        var velocity: V
        var fixation: V?
        
        static var zero: NodeStatus { .init(position: .zero, velocity: .zero) }
    }
    
    public let initializedAlpha: Double

    public var alpha: Double
    public var alphaMin: Double
    public var alphaDecay: Double
    public var alphaTarget: Double
    public var velocityDecay: Double
    
    public internal(set) var forces: [any Force] = []  //Dictionary<String, any Force> = [:]

    public private(set) var nodes: [NodeStatus]
    public private(set) var nodeIds: [NodeID]
    
    public init(
        nodeIds: [NodeID],
        alpha: Double = 1,
        alphaMin: Double = 1e-3,
        alphaDecay: Double? = nil,
        alphaTarget: Double = 0.0,
        velocityDecay: Double = 0.6,

        setInitialStatus getInitialStatus: (
            (NodeID) -> NodeStatus
        )? = nil
        
    ) {
        
        self.alpha = alpha
        self.initializedAlpha = alpha  // record and reload this when restarted

        self.alphaMin = alphaMin
        self.alphaDecay = alphaDecay ?? 1 - pow(alphaMin, 1.0 / 300.0)
        self.alphaTarget = alphaTarget

        self.velocityDecay = velocityDecay
        self.nodeIds = nodeIds
        
        
        if let getInitialStatus {
            self.nodes = nodeIds.map(getInitialStatus)
        }
        else {
            self.nodes = Array(repeating: .zero, count: nodeIds.count)
            for i in nodes.indices {
                nodes[i].jiggle()
            }
        }
        
    }
    
    
    
    public func tick(iterationCount: UInt = 1) {
        for _ in 0..<iterationCount {
            alpha += (alphaTarget - alpha) * alphaDecay

            for f in forces {
                //                #if DEBUG
                //                print("Applying force: \(n)")
                //                #endif
                f.apply(alpha: alpha)
            }

            for i in nodes.indices {
                if let fixation = nodes[i].fixation {
                    nodes[i].position = fixation
                } else {
                    nodes[i].velocity *= velocityDecay
                    nodes[i].position += simulationNodes[i].velocity
                }
            }

        }
    }
}


extension Simulation.NodeStatus {
    mutating func jiggle() {
        self.position = position.jiggled()
    }
}



public class _Simulation<N> where N: Identifiable /*, E: EdgeLike, E.VertexID == V*/ {

    public typealias NodeID = N.ID

    public let initializedAlpha: Double

    public var alpha: Double
    public var alphaMin: Double
    public var alphaDecay: Double
    public var alphaTarget: Double
    public var velocityDecay: Double

    public internal(set) var forces: [any Force] = []  //Dictionary<String, any Force> = [:]

    public var nodeIndexLookup: [NodeID: Int] = [:]
    public var simulationNodes: [SimulationNode<NodeID>]

    public init(
        nodes: [N] = [],
        alpha: Double = 1,
        alphaMin: Double = 1e-3,
        alphaDecay: Double? = nil,
        alphaTarget: Double = 0.0,
        velocityDecay: Double = 0.6,

        setInitialStatus: (
            (inout SimulationNode<NodeID>, [SimulationNode<NodeID>].Index) -> Void
        )? = nil
    ) {
        self.alpha = alpha
        self.initializedAlpha = alpha  // record and reload this when restarted

        self.alphaMin = alphaMin
        self.alphaDecay = alphaDecay ?? 1 - pow(alphaMin, 1.0 / 300.0)
        self.alphaTarget = alphaTarget

        self.velocityDecay = velocityDecay

        self.simulationNodes = nodes.map { n in
            SimulationNode(id: n.id, position: .zero, velocity: .zero)
        }
        self.nodeIndexLookup = Dictionary(
            uniqueKeysWithValues: simulationNodes.enumerated().map { ($0.1.id, $0.0) })

        if let setInitialStatus {
            for i in self.simulationNodes.indices {
                setInitialStatus(&simulationNodes[i], i)
            }
        }

    }

    private var timer: Timer?

    public func start(
        intervalPerTick: TimeInterval,
        startWithAlpha: Double? = nil,
        onTicked: @escaping ([SimulationNode<NodeID>]) -> Void
    ) {
        self.alpha = startWithAlpha ?? initializedAlpha

        self.timer = Timer.scheduledTimer(withTimeInterval: intervalPerTick, repeats: true) {
            [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            if self.alpha < self.alphaMin {
                timer.invalidate()
                self.timer = nil
                return
            }
            self.tick()
            onTicked(self.simulationNodes)
        }

    }

    public var isTicking: Bool { return self.timer != nil }

    internal func tick(_ iterations: Int = 1) {
        for _ in 0..<iterations {
            alpha += (alphaTarget - alpha) * alphaDecay

            for f in forces {
                f.apply(alpha: alpha)
            }

            for i in simulationNodes.indices {
                if let fixation = simulationNodes[i].fixation {
                    simulationNodes[i].position = fixation
                } else {
                    simulationNodes[i].velocity *= velocityDecay
                    simulationNodes[i].position += simulationNodes[i].velocity
                }
            }

        }
    }

    @inlinable public func getNode(_ nodeId: NodeID) -> SimulationNode<NodeID>? {
        guard let index = nodeIndexLookup[nodeId] else { return nil }
        return simulationNodes[index]
    }

    @inlinable public func updateNode(
        nodeId: NodeID, update: (inout SimulationNode<NodeID>) -> Void
    ) {
        guard let index = nodeIndexLookup[nodeId] else { return }
        update(&simulationNodes[index])
    }

    @inlinable public func updateNode(
        index: [SimulationNode<NodeID>].Index, update: (inout SimulationNode<NodeID>) -> Void
    ) {
        update(&simulationNodes[index])
    }

}