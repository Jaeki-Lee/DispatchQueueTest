import Foundation

open class Person {
    private var firstName: String
    private var lastName: String
    
    public init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
    
    open func changeName(firstName: String, lastName: String) {
        randomDelay(maxDuration: 0.2)
        self.firstName = firstName
        randomDelay(maxDuration: 1)
        self.lastName = lastName
    }
    
    open var name: String {
        return "\(firstName) \(lastName)"
    }
}
