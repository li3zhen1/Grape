public enum AttributeDescriptor<T> {
    case varied((Int) -> T)
    case constant(T)
}

extension AttributeDescriptor: Equatable where T: Equatable {
    
    @inlinable
    public static func == (lhs: AttributeDescriptor<T>, rhs: AttributeDescriptor<T>) -> Bool {
        switch (lhs, rhs) {
        case (.constant(let l), .constant(let r)):
            return l == r
        default:
            return false
        }
    }
}

extension AttributeDescriptor {
    @inlinable
    func calculate(for count: Int) -> [T] {
        switch self {
        case .constant(let m):
            return [T](repeating: m, count: count)
        case .varied(let radiusProvider):
            return (0..<count).map(radiusProvider)
        }
    }

    @inlinable
    func calculateUnsafe(for count: Int) -> UnsafeArray<T> where T: Numeric {
        switch self {
        case .constant(let m):
            return UnsafeArray<T>.createBuffer(
                withHeader: count,
                count: count,
                initialValue: m
            )
        case .varied(let valueProvider):
            let array = UnsafeArray<T>.createBuffer(withHeader: count, count: count) {
                valueProvider($0)
            }
            return array
        }
    }
}
