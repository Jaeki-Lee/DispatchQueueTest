//: [Previous](@previous)

import Foundation
import UIKit

let queue = DispatchQueue(label: "test", qos: .default, attributes:[.initiallyInactive, .concurrent])

let group1 = DispatchGroup()

/*
 Thread-safe 하지 않은 Lazy var 문제
 */

class SharedInstanceClass1 {
    lazy var testVar = {
        return Int.random(in: 0..<99)
    }()
}

let instance1 = SharedInstanceClass1()

// 여러 스레드에서 선언될때 메모리에 올라가는 lazy var 에 접근하면서 생기는 문제 -> thread-safe 하게 만들어주어서 문제 해결 -> 시리얼큐 + sync 작업 / Dispatch Barrier 작업 / 세마포어 이용, 작업의 실행 갯수 제한
for i in 0 ..< 10 {
    group1.enter()
    queue.async(group: group1) {
        print("id:\(i), lazy var 이슈:\(instance1.testVar)")
        group1.leave()
    }
}

group1.notify(queue: DispatchQueue.global()) {
    print("lazy var 이슈가 생기는 모든 작업의 완료.")
}

queue.activate()
group1.wait()

//sync + serial 로 해결
class SharedInstanceClass2 {
    let serialQueue = DispatchQueue(label: "serial")
    
    lazy var testVar = {
        return Int.random(in: 0...100)
    }()
    
    var readVar: Int {
        serialQueue.sync {
            return testVar
        }
    }
}

let group2 = DispatchGroup()

let instance2 = SharedInstanceClass2()

for i in 0 ..< 10 {
    group2.enter()
    queue.async(group: group2) {
        print("id:\(i), lazy var 이슈:\(instance2.readVar)")
        group2.leave()
    }
}

group2.notify(queue: DispatchQueue.global()) {
    print("시리얼큐로 해결한 모든 작업의 완료.")
}

queue.activate()
group2.wait()


//Dispatch Barrier 해결

class SharedInstanceClass3 {
    lazy var testVar = {
        return Int.random(in: 0...100)
    }()
}

let group3 = DispatchGroup()

let instance3 = SharedInstanceClass3()

for i in 0 ..< 10 {
    group3.enter()
    queue.async(flags: .barrier) {
        print("id:\(i), lazy var 이슈:\(instance3.testVar)")
        group3.leave()
    }
}

group3.notify(queue: DispatchQueue.global()) {
    print("디스패치 배리어로 해결한 모든 작업의 완료.")
}


//세마포어 해결

class SharedInstanceClass4 {
    lazy var testVar = {
        return Int.random(in: 0...100)
    }()
}


// 디스패치그룹 생성
let group4 = DispatchGroup()

// 객체 생성
let instance4 = SharedInstanceClass4()

let semaphore = DispatchSemaphore(value: 1)

for i in 0 ..< 10 {
    group4.enter()
    semaphore.wait()
    queue.async(group: group4) {
        print("id:\(i), lazy var 이슈:\(instance4.testVar)")
        group4.leave()
        semaphore.signal()
    }
}

group4.notify(queue: DispatchQueue.global()){
    print("디스패치 세마포어로 해결한 모든 작업의 완료.")
}
