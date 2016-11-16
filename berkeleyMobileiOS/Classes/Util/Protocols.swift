
/**
 * Specifies that conforming class requires data of DataType,
 * otherwise object may error or not behave properly.
 */
protocol RequiresData
{
    associatedtype DataType
    
    mutating func setData(_ data: DataType)
}
