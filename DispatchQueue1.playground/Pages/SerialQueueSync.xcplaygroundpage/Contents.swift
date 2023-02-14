//: [Previous](@previous)

import Foundation

let person = Person(firstName: "길동", lastName: "홍")

person.changeName(firstName: "꺽정", lastName: "임")
person.name

let nameList = [("재석", "유"), ("구라", "김"), ("나래", "박"), ("동엽", "신"), ("세형", "양")]

let concurrentQueue = DispatchQueue(label: "com.inflearn.concurrent", attributes: .concurrent)

let nameChangeGroup = DispatchGroup()

//다른 쓰레드에서 이름을 바꾸고 있는 동안에, 해당 이름에 접근
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
        /*
         serialQueue 로 보내는데 sync 까지 하는 이유는 해당 메소드를 async 비동기 함수에서 다시 비동기로 보내면 제대로된 값을 못 얻은 다음 사용할수 있기 때문이다.
         DispatchQueue.global().async {
            //task 작업
            serialQueue.sync {
                task
            }
            //serialQueue 에서 작업이 끝난 task 를 사용
            task
         }
         */
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
        //현재의 이름: 세현 양 만 5번 출력 되는 이유는 threadSafeSyncPerson.name 을 호출해 가져올때 이름을 쓰는 것, 읽는 것 모두 같은 serialQueue 에서 sync 작업 하는데 선행작업인 쓰는 작업이 모두 완료 된 후에 읽는 작업이 들어가기 때문이다.
    }
}

//결론적으로 읽고, 쓰는 작업을 한개의 쓰레드가 메모리에 접근해서 하게 된다.
threadSafeNameGroup.notify(queue: DispatchQueue.global()) {
    print("마지막 이름은?: \(threadSafeSyncPerson.name)")
}
