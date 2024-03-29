public struct KDTreeNode<Vector, Delegate>
where
    Vector: SimulatableVector & L2NormCalculatable,
    Delegate: KDTreeDelegate<Int, Vector>
{
    public var box: KDBox<Vector>
    public var nodePosition: Vector
    public var childrenBufferPointer: UnsafeMutablePointer<KDTreeNode>?

    @usableFromInline
    internal var nodeIndices: NodeIndex?
    public var delegate: Delegate

    @inlinable
    init(
        nodeIndices: NodeIndex?,
        childrenBufferPointer: UnsafeMutablePointer<KDTreeNode>?,
        delegate: Delegate,
        box: KDBox<Vector>,
        nodePosition: Vector = .zero
    ) {
        self.childrenBufferPointer = childrenBufferPointer
        self.nodeIndices = nodeIndices
        self.delegate = delegate
        self.box = box
        self.nodePosition = nodePosition
    }

    @inlinable
    mutating public func disposeNodeIndices() {
        nodeIndices?.dispose()
        nodeIndices = nil
    }
}

extension KDTreeNode {


    @usableFromInline
    struct NodeIndex: Disposable {

        @usableFromInline
        var index: Int

        @usableFromInline
        var next: UnsafeMutablePointer<NodeIndex>?

    }
}

extension KDTreeNode.NodeIndex {

    @inlinable
    internal init(
        nodeIndex: Int
    ) {
        self.index = nodeIndex
        self.next = nil
    }

    @inlinable
    internal init(
        _ nodeIndex: Int
    ) {
        self.index = nodeIndex
        self.next = nil
    }


    @inlinable
    internal mutating func append(nodeIndex: Int) {
        if let next {
            next.pointee.append(nodeIndex: nodeIndex)
        } else {
            next = .allocate(capacity: 1)
            next!.initialize(to: .init(nodeIndex: nodeIndex))
            // next!.pointee = .init(nodeIndex: nodeIndex)
        }
    }

    @inlinable
    internal func dispose() {
        if let next {
            next.pointee.dispose()
            next.deallocate()
        }
    }

    @inlinable
    internal func contains(_ nodeIndex: Int) -> Bool {
        if index == nodeIndex { return true }
        if let next {
            return next.pointee.contains(nodeIndex)
        } else {
            return false
        }
    }

    @inlinable
    internal func forEach(_ body: (Int) -> Void) {
        body(index)
        if let next {
            next.pointee.forEach(body)
        }
    }
}

extension KDTreeNode {
    /// Returns true is the current tree node is leaf.
    ///
    /// Does not guarantee that the tree node has point in it.
    @inlinable public var isLeaf: Bool { childrenBufferPointer == nil }

    /// Returns true is the current tree node is internal.
    ///
    /// Internal tree node are always empty and do not contain any points.
    @inlinable public var isInternalNode: Bool { childrenBufferPointer != nil }

    /// Returns true is the current tree node is leaf and has point in it.
    @inlinable public var isFilledLeaf: Bool { nodeIndices != nil }

    /// Returns true is the current tree node is leaf and does not have point in it.
    @inlinable public var isEmptyLeaf: Bool { nodeIndices == nil }

    /// Visit the tree in pre-order.
    ///
    /// - Parameter shouldVisitChildren: a closure that returns a boolean value indicating whether should continue to visit children.
    @inlinable public mutating func visit(
        shouldVisitChildren: (inout KDTreeNode<Vector, Delegate>) -> Bool
    ) {
        if shouldVisitChildren(&self) && childrenBufferPointer != nil {
            // this is an internal node
            for i in 0..<BufferedKDTree<Vector, Delegate>.directionCount {
                childrenBufferPointer![i].visit(shouldVisitChildren: shouldVisitChildren)
            }
        }
    }

    /// Returns an array of point indices in the tree node.
    @inlinable
    public var containedIndices: [Int] {
        guard isFilledLeaf else { return [] }
        var result: [Int] = []
        nodeIndices!.forEach { result.append($0) }
        return result
    }

    @inlinable
    static func zeroWithDelegate(_ delegate: Delegate) -> Self {
        return Self(
            nodeIndices: nil,
            childrenBufferPointer: nil,
            delegate: delegate,
            box: .zero,
            nodePosition: .zero
        )
    }

}
