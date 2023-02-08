import UIKit
import Foundation

/*
 디스패치 그룹의 개념
 */

//var sumNum = 0

//func slowAdd(_ numbers: (Int, Int)) -> Int {
//    sumNum += numbers.0
//    sumNum += numbers.1
//    return sumNum
//}
//
//let workingQueue = DispatchQueue(label: "concurrent", attributes: .concurrent)
//let numberArray = [(0, 1), (2, 3), (4, 5), (6, 7), (8, 9), (10, 11)]
//
let group1 = DispatchGroup()

//for inValue in numberArray {
//    workingQueue.async(group: group1) {
//        print(inValue)
//        let result = slowAdd(inValue)
//        print("더한 결과값 출력하기 = \(result)")
//    }
//}
//
//let defaultQueue = DispatchQueue.global()

//1.그룹 지은 Queue 의 작업이 끝날때 호출되는 함수 notify

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
 디스패치 그룹의 사용
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
 Dispatch workItem 실행할 디스패치작업 크로저를 아이템에 저장해서 사용
 */

let item1 = DispatchWorkItem(qos: .utility) {
    print("task1")
    print("task2")
}

let item2 = DispatchWorkItem {
    print("task3")
    print("task4")
}

item1.notify(queue: DispatchQueue.global(), execute: item2)

DispatchQueue.global().async(execute: item1)
