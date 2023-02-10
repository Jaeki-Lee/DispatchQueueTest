//: [Previous](@previous)

import Foundation

let workingQueue = DispatchQueue(label: "com.inflearn.concurrent", attributes: .concurrent)
let defaultQueue = DispatchQueue.global()

let numberArray = [(0,1), (2,3), (4,5), (6,7), (8,9), (10,11)]

//비동기 함수
func asyncAdd(_ input: (Int, Int), runQueue: DispatchQueue, competionQueue: DispatchQueue, completion: @escaping (Int, Error?) -> ()) {
    runQueue.async {
        var error: Error?
        error = .none
        
        let result = slowAdd(input)
        competionQueue.async {
            completion(result, error)
        }
    }
}


//비동기 디스패치 그룹함수
func asyncAdd_Group(_ input: (Int, Int), runQueue: DispatchQueue, completionQueue: DispatchQueue, group: DispatchGroup, completion: @escaping (Int, Error?) -> ()) {
    
}
//: [Next](@next)
