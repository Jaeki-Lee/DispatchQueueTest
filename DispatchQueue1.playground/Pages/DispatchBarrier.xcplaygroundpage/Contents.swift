//: [Previous](@previous)

import Foundation

let person = Person(firstName: "길동", lastName: "홍")

person.changeName(firstName: "꺽정", lastName: "임")
person.name

let nameList = [("재석", "유"), ("구라", "김"), ("나래", "박"), ("동엽", "신"), ("세형", "양")]

//let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
//let nameChangeGroup = DispatchGroup()
//
////다른 쓰레드에서 이름을 바꾸고 있는 동안에, 해당 이름에 접근
//for (idx, name) in nameList.enumerated() {
//    concurrentQueue.async(group: nameChangeGroup) {
//        usleep(UInt32(10_000 * idx))
//        person.changeName(firstName: name.0, lastName: name.1)
//        print("현재의 이름: \(person.name)")
//    }
//}
//
//nameChangeGroup.notify(queue: DispatchQueue.global()) {
//    print("마지막 이름은?: \(person.name)")
//}
//
//nameChangeGroup.wait()

class BarrierThreadSafePerson: Person {
    let newConcurrentQueue = DispatchQueue(label: "concurrent2", attributes: .concurrent)

    override func changeName(firstName: String, lastName: String) {
        //barrier 로 현재 부터 진행중인 스레드를 막는다.
        newConcurrentQueue.async(flags: .barrier) {
            super.changeName(firstName: firstName, lastName: lastName)
        }
    }

    override var name: String {
        //sync 처리로 task 를 맡기 스레드가 끝나고 큐에서 다른 스레드로 일을 맡긴다.
        newConcurrentQueue.sync {
            return super.name
        }
    }
}

print("\n=== Thread-safe처리된 객체로 확인 ===")

let concurrentQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)

let threadSafeNameGroup = DispatchGroup()

let barrierThreadSafePerson = BarrierThreadSafePerson(firstName: "길동", lastName: "홍")

for (idx, name) in nameList.enumerated() {
    concurrentQueue.async(group: threadSafeNameGroup) {
        usleep(UInt32(10_000 * idx))
        //barrier 사용으로 큐로부터 작업을 할당받은 스레드 외의 스레드는 블락상태 -> 한개의 스레드에서만 메모리의 데이터 접근
        barrierThreadSafePerson.changeName(firstName: name.0, lastName: name.1)
        //큐에서 sync 할당으로 스레드에서 일처리가 끝난후 작업 -> 한개의 스레드에서만 메모리의 데이터 접근
        print("현재의 이름: \(barrierThreadSafePerson.name)")
    }
}

threadSafeNameGroup.notify(queue: DispatchQueue.global()) {
    print("마지막 이름은?: \(barrierThreadSafePerson.name)")
}

print("\n=== Threadsafe Operation 작업 ===")

let blockOperation = BlockOperation()

let barrierThreadSafePerson2 = BarrierThreadSafePerson(firstName: "길동", lastName: "홍")

for (idx, name) in nameList.enumerated() {
    blockOperation.addExecutionBlock {
        usleep(UInt32(10_000 * idx))
        barrierThreadSafePerson2.changeName(firstName: name.0, lastName: name.1)
        print("현재의 이름: \(barrierThreadSafePerson2.name)")
    }
}

blockOperation.completionBlock = {
    print("마지막 이름은?: \(barrierThreadSafePerson2.name)")
}

//blockOperation.start()
//
//let queue = OperationQueue()
//
//queue.addOperation(blockOperation)

/*
 설계할때 메인스레드 에서는 sync 처리 하면 안된다.
 설계할때 다른큐에서 접근한다면 thread-safe 처리를 해주어야 한다 -> 시리얼큐 + sync / 베리어처리 -> 한개의 스레드에 한개의 메모리의 데이터 접근
 */
