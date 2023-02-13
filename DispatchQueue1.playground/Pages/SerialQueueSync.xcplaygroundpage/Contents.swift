//: [Previous](@previous)

import Foundation

let person = Person(firstName: "길동", lastName: "홍")

person.changeName(firstName: "꺽정", lastName: "임")
person.name

let nameList = [("재석", "유"), ("구라", "김"), ("나래", "박"), ("동엽", "신"), ("세형", "양")]

let concurrentQueue = DispatchQueue(label: "com.inflearn.concurrent", attributes: .concurrent)

let nameChangeGroup = DispatchGroup()


//for (idx, name) in nameList.enumerated() {
//    concurrentQueue.async(group: nameChangeGroup) {
//        usleep(UInt32(10_000 * idx))
//        print("\(name.0) \(name.1)")
//        person.changeName(firstName: name.0, lastName: name.1)
//        print("현재의 이름: \(person.name)")
//    }
//}
//
//nameChangeGroup.notify(queue: DispatchQueue.global()) {
//    print("마지막 이름은?: \(person.name)") // thread-safe 되어 있지 않아 엉뚱한 값이 나옴
//}

class ThreadSafeSyncPerson: Person {
    let serialQueue = DispatchQueue(label: "serial")
    
    //쓰기 - 시리얼 + 동기(sync) 작업으로 설정
    override func changeName(firstName: String, lastName: String) {
        //serailQueue 로 보내는데 sync 까지 하는 이유는 한 스레드에서 접근 하고 해당 스레드의 작업이 끝났을때 다른 스레드에서 작업을 진행할수 있도록
        serialQueue.sync {
            super.changeName(firstName: firstName, lastName: lastName)
        }
    }
    
    //읽기 - 시리얼 + 동기(sync) 작업으로 설정, 사실상 읽기는 문제 없이 읽힘 그래도 thread safe 하게 만들자면
    override var name: String {
        serialQueue.sync {
            var result = ""
            result = super.name
            return result
        }
    }
}

let threadSafeNameGroup = DispatchGroup()

let threadSafeSyncPerson = ThreadSafeSyncPerson(firstName: "길동", lastName: "홍")

for (idx, name) in nameList.enumerated() {
    concurrentQueue.async(group: threadSafeNameGroup) {
        usleep(UInt32(10_000 * idx))
        threadSafeSyncPerson.changeName(firstName: name.0, lastName: name.1)
        print("현재의 이름: \(threadSafeSyncPerson.name)")
    }
}

threadSafeNameGroup.notify(queue: DispatchQueue.global()) {
    print("마지막 이름은?: \(threadSafeSyncPerson.name)")
}
