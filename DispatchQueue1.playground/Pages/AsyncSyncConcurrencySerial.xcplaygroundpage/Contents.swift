import UIKit
import Foundation

/*
 Async, Sync
 : 클로저 내에서 실행할 단일 작업에 대한 특성을 정의
 Async - 큐에 작업이 있어도 기다리지 않고 다음 작업을 실행함
 Sync - 큐에 작업이 있으면 기다리고 해당 작업이 끝나면 다음 작업을 실행함
 
 Serial Queue 직렬, Concurrency Queue 동시
 Serial Queue 직렬큐
 : 한 스레드에 연속적으로 테스크를 할당하는 큐
 
 Concurrency Queue 동시큐
 : 여러 스레드에 테스크를 분산 처리 시키는 큐
*/

func task1() {
    print("task1 시작")
    sleep(2)
    print("task1 완료*")
}

func task2() {
    print("task2 시작")
    sleep(2)
    print("task2 완료*")
}

func task3() {
    print("task3 시작")
    sleep(2)
    print("task3 완료*")
}

let concurrencyQueue = DispatchQueue.global()
let serialQueue = DispatchQueue(label: "serial queue")

//Concurrecny 큐로 여러 스레드로 분산 처리 하지만 task1 을 분산 처리시킨후 끝난 후에 task2 ..task3 실행
//concurrencyQueue.sync {
//    task1()
//}
//
//concurrencyQueue.sync {
//    task2()
//}
//
//concurrencyQueue.sync {
//    task3()
//}

/*
 concurrencyQueue 로 여러 스레드에 분산 처리 하지만 queue 의 sync 처리로 분산 후 작업 처리를 기다린후 다음 작업 처리
 task1 시작
 task1 완료*
 task2 시작
 task2 완료*
 task3 시작
 task3 완료*
 */

//concurrencyQueue.async {
//    print("task 1 작업 할당")
//    task1()
//}
//
//concurrencyQueue.async {
//    print("task 2 작업 할당")
//    task2()
//}
//
//concurrencyQueue.async {
//    print("task 3 작업 할당")
//    task3()
//}

/*
 concurrencyQueue 로 분산처리 하고 다음 작업을 기다리지 않고 처리
 task1 시작
 task2 시작
 task3 시작
 task3 완료*
 task1 완료*
 task2 완료*
 */

serialQueue.async {
    task1()
}

serialQueue.async {
    task2()
}

serialQueue.async {
    task3()
}

/*
 serialQueue 로 한 스레드에 모든 task 를 할당 async 처리 하더라도 다른 스레드에 작업을 할당 하지 않는다
 task1 시작
 task1 완료*
 task2 시작
 task2 완료*
 task3 시작
 task3 완료*
 */


