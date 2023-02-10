import Foundation

public func slowAdd(_ input: (Int, Int)) -> Int {
    sleep(1)
    return input.0 + input.1
}

public func slowAddArray(_ input: [(Int, Int)], progress: ((Double) -> (Bool))? = nil) -> [Int] {
    var results = [Int]()
    for pair in input {
        results.append(slowAdd(pair))
        if let progress = progress {
            if !progress(Double(results.count) / Double(input.count)) { return results }
        }
    }
    return results
}

private let workerQueue = DispatchQueue(label: "com.raywenderlich.slowsum", attributes: DispatchQueue.Attributes.concurrent)


public func asyncAdd_GCD(_ input: (Int, Int), completionQueue: DispatchQueue, completion: @escaping (Int) -> ()) {
    workerQueue.async {
        let result = slowAdd(input)
        completionQueue.async {
            completion(result)
        }
    }
}

private let additonQueue = OperationQueue()
public func asyncAdd_OpQ(lhs: Int, rhs: Int, callback: @escaping (Int) -> ()) {
    additonQueue.addBarrierBlock {
        sleep(1)
        callback(lhs + rhs)
    }
}
