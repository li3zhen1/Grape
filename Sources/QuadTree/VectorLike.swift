//
//  VectorLike.swift
//
//
//  Created by li3zhen1 on 10/13/23.
//


public protocol VectorLike: CustomStringConvertible, Decodable, Encodable, ExpressibleByArrayLiteral, Hashable, AdditiveArithmetic {
    
    associatedtype Scalar: FloatingPoint, Decodable, Encodable, Hashable
    
    
    @inlinable func lengthSquared() -> Scalar
    @inlinable func length() -> Scalar
    @inlinable func distanceSquared(to: Self) -> Scalar
    @inlinable func distance(to: Self) -> Scalar
    
    static func * (a: Self, b: Scalar) -> Self
    static func / (a: Self, b: Scalar) -> Self
    
    /// the same members as simd
    static var scalarCount: Int { get }

    init()

    subscript(index: Int) -> Self.Scalar { get set }
    
    var indices: Range<Int> { get }
    
    
//    mutating func replace<M>(with other: Self, where mask: M) where M:MaskLike, M.Storage.Scalar==Scalar.SIMDMaskScalar
    
    
    
//    public static func .< (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>
//
//    /// Returns a vector mask with the result of a pointwise less than or equal
//    /// comparison.
//    public static func .<= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>
//
//    /// The least element in the vector.
//    public func min() -> Scalar
//
//    /// The greatest element in the vector.
//    public func max() -> Scalar
//
//    /// Returns a vector mask with the result of a pointwise greater than or
//    /// equal comparison.
//    public static func .>= (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>
//
//    /// Returns a vector mask with the result of a pointwise greater than
//    /// comparison.
//    public static func .> (a: SIMD32<Scalar>, b: SIMD32<Scalar>) -> SIMDMask<SIMD32<Scalar.SIMDMaskScalar>>
    

}