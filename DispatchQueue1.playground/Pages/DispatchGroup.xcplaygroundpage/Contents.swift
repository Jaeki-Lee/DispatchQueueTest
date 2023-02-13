import Foundation
import UIKit

/*
 디스패치 그룹
 : 그룹화된 여러작업들을 스레드에 분산처리 하지만 여러작업이 묶인 그룹의 끝난 부분을 알고 어떤 작업을 이어서 하고 싶을때 사용
 */

//let workingQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
//let numberArray = [(0, 1), (2, 3), (4, 5), (6, 7), (8, 9), (10, 11)]
//
//let group1 = DispatchGroup()
//
//for inValue in numberArray {
//    workingQueue.async(group: group1) {
//        print(inValue)
//        let result = slowAdd(inValue)
//        print("더한 결과값 출력하기 = \(result)")
//    }
//}


//1.그룹 지은 Queue 의 작업이 끝날때 호출되는 함수 notify

//let defaultQueue = DispatchQueue.global()
//
//group1.notify(queue: defaultQueue) {
//    print("====그룹1 안의 모든 작업이 완료====")
//}


//2.group 의 작업이 모두 끝날때 까지 기다리는 함수 wait(현재 스레드에서 sync 사용)

//group1.wait 를 호출할때 주의해서 사용해야 한다. 이건 사용하는 thread 에서 sync(동기적으로) 작업 하기 때문에 스레드가 블락되어 어딘가에서 해당 스레드를 사용하려고 할때 Deadlock 이 발생할수 있기 때문이다.(그래서 이 wait 함수는 main 스레드에서 호출되면 안된다 main thread 는 절대로 블락 되어서는 안되기 때문이다.)
//group1.wait(timeout: DispatchTime.distantFuture)
//print("group1 is finished")

//3.group 의 timeout 처리
//if group1.wait(timeout: .now() + 60) == .timedOut {
//    print("모든 작업이 60초 안에 끝나진 않았습니다.")
//}


/*
 디스패치 그룹의 사용:
 디스패치 그룹을 사용할때 동기적 함수를 사용한다면 문제 없다.
 하지만 비동기 함수를 사용한다면 문제가 발생할수 있다.
 디스패치 그룹의 사용이 끝난후 결과 값을 이용해 어떤 작업을 한다 가정 했을때, 디스패치 그룹에 A, B 라는 비동기 메서드가 들어가 작업하는데 A 는 끝났지만 B 가 끝나지 않은 상태에서 디스패치 그룹이 끝났을때는 잘못된 값을 사용할수 있는 문제가 생긴다.
 */

//func asyncMethod(input: String, completion: @escaping (String) -> Void) {
//
//    DispatchQueue.global().async {
//        sleep(2)
//        completion("result")
//    }
//
//}
//
//DispatchQueue.global().async(group: group1) {
//    print("async group task started")
//    group1.enter() //group1 의 시작
//    asyncMethod(input: "url") { result in
//        print(result)
//        group1.leave() //group1 의 종료
//    }
//}
//
//
//group1.notify(queue: DispatchQueue.global()) {
//    print("async group task finished")
//}



/*
 위와 같은 결과로 프린트 된다. 즉 ayncMethod 가 종료되지 않았는데 group1 이 종료된다. 이를 막기 위해서는 group 의 enter, leave 메서드가 필요하다.
 
 async group task started
 async group task finished
 result
 
 enter 와 leave 메서드를 호출 한 뒤 찍히는 프린트
 
 async group task started
 result
 async group task finished
 */

/*
 Dispatch 비동기 함수 작업 실재 사용
 */
//let workingQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
//let defaultQueue = DispatchQueue.global()
//
//let numberArray = [(0,1), (2,3), (4,5), (6,7), (8,9), (10,11)]
//
////두 큐 모두 concurrent 로 하더라도
//func asyncAdd(_ input: (Int, Int), runQueue: DispatchQueue, completionQueue: DispatchQueue,
//              completion: @escaping (Int, Error?) -> ()) {
//    runQueue.async {
//        var error: Error?
//        error = .none
//
//        let result = slowAdd(input)
//        completionQueue.async {
//            completion(result, error)
//        }
//    }
//}
//
////마지막 completionQueue 가 끝났을때 group.leave 함수를 호출해 정상적인 종료 시점을 지정할수 있어 올바른 값을 사용할수 있다.
//func asyncAdd_Group(_ input: (Int, Int), runQueue: DispatchQueue, completionQueue: DispatchQueue, group: DispatchGroup, completion: @escaping (Int, Error?) -> ()) {
//
//    group.enter()
//
//    asyncAdd(input, runQueue: runQueue, completionQueue: completionQueue) { result, error in
//        completion(result, error)
//        group.leave()     // 컴플리션 핸들러에서 "퇴장"시점 알기
//    }
//
//}
//
//// 디스패치 그룹 생성
//let wrappedGroup = DispatchGroup()
//
//
//// 반복문으로 비동기 그룹함수 활용하기
//for pair in numberArray {
//    asyncAdd_Group(pair, runQueue: workingQueue, completionQueue: defaultQueue, group: wrappedGroup) {
//        result, error in
//        print("결과값 출력 = \(result)")
//    }
//}
//
//// 모든 비동기 작업이 끝남을 알림받기
//wrappedGroup.notify(queue: defaultQueue) {
//    print("====모든 작업이 완료 되었습니다.====")
//}


/*
 DispatchGroup 다른 예제
 */

let group = DispatchGroup()

let base = "https://images.unsplash.com/photo-"

let imageNames = [
    "1579962413362-65c6d6ba55de?ixlib=rb-1.2.1&auto=format&fit=crop&w=934&q=80","1580394693981-254c3aeded6a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3326&q=80", "1579202673506-ca3ce28943ef?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80", "1535745049887-3cd1c8aef237?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80", "1568389494699-9076492b22e7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=937&q=80",  "1566624790190-511a09f6ddbd?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80"
]

let userQueue = DispatchQueue.global(qos: .userInitiated)

var downloadImages: [UIImage] = []

for name in imageNames {
    guard let url = URL(string: "\(base)\(name)") else { continue }
    
    group.enter()
    
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        defer { group.leave() }
        
        if error == nil, let data = data, let image = UIImage(data: data) {
            downloadImages.append(image)
        }
    }
    
    task.resume()
}

group.notify(queue: userQueue) {
    print("=====모든 다운로드 완료=====")
}

/*
 Dispatch workItem 실행할 디스패치작업 크로저를 아이템에 저장해서 사용
 */

//let item1 = DispatchWorkItem(qos: .utility) {
//    print("task1")
//    print("task2")
//}
//
//let item2 = DispatchWorkItem {
//    print("task3")
//    print("task4")
//}
//
//item1.notify(queue: DispatchQueue.global(), execute: item2)
//
//DispatchQueue.global().async(execute: item1)
