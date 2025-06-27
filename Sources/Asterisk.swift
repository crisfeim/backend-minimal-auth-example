// © 2025  Cristian Felipe Patiño Rojas. Created on 27/6/25.


infix operator .*: AdditionPrecedence
func .*<T>(lhs: T, rhs: (inout T) -> Void) -> T {
    var copy = lhs
    rhs(&copy)
    return copy
}