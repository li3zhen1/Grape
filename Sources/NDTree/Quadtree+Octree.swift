//
//  File 2.swift
//
//
//  Created by li3zhen1 on 10/13/23.
//

#if canImport(simd)

    import simd


    extension simd_double2: VectorLike {
        @inlinable public func lengthSquared() -> Scalar {
            return simd_length_squared(self)
        }

        @inlinable public func length() -> Scalar {
            return simd_length(self)
        }

        @inlinable public func distanceSquared(to: SIMD2<Scalar>) -> Scalar {
            return simd_length_squared(self - to)
        }

        @inlinable public func distance(to: SIMD2<Scalar>) -> Scalar {
            return simd_length(self - to)
        }

    }

    extension simd_float3: VectorLike {

        @inlinable public func lengthSquared() -> Scalar {
            return simd_length_squared(self)
        }

        @inlinable public func length() -> Scalar {
            return simd_length(self)
        }

        @inlinable public func distanceSquared(to: SIMD3<Scalar>) -> Scalar {
            return simd_length_squared(self - to)
        }

        @inlinable public func distance(to: SIMD3<Scalar>) -> Scalar {
            return simd_length(self - to)
        }
        
    }
    
    public typealias QuadBox = NDBox<simd_double2>
    public typealias OctBox = NDBox<simd_float3>



/// Uncomment the region below to unlock 4d tree
//    extension simd_double4: VectorLike {
//
//        @inlinable public func lengthSquared() -> Double {
//            return x * x + y * y + z * z + w * w
//        }
//
//        @inlinable public func length() -> Double {
//            return (x * x + y * y + z * z + w * w).squareRoot()
//        }
//
//        @inlinable public func distanceSquared(to: SIMD4<Scalar>) -> Scalar {
//            return (self - to).lengthSquared()
//        }
//
//        @inlinable public func distance(to: SIMD4<Scalar>) -> Scalar {
//            return (self - to).length()
//        }
//        public static let directionCount = 16
//    }
//    public typealias Vector4d = simd_double4
//    public protocol HyperoctreeDelegate: NDTreeDelegate where V == Vector4d {}
//    public typealias HyperoctBox = NDBox<Vector4d>
//    public typealias Hyperoctree<TD: HyperoctreeDelegate> = NDTree<Vector4d, TD>





#endif
