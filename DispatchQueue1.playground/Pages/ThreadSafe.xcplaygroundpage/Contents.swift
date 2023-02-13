//: [Previous](@previous)

import Foundation

/*
 1.경쟁상황(Race Condition)
 : 2개 이상의 쓰레드 에서 동시다발적 으로 데이터를 수정할때 작업이 겹쳐 엉뚱한 결과 값이 나오게 됨.
   * 읽는건 동시에 해도 괜찮으나 쓰는걸 동시에 한다면 엉뚱한 데이터 출력
   
   메모리에 여러 스레드가 동시다발적으로 접근하지 못하게 한다 -> 시리얼큐 + Sync / 디스패치베리어 처리해 한 스레드에서 메모리에 접근해 데이터를 수정한 후 다음 작업을 하도록 함
 */

var value = 777

func changeValue() {
    sleep(2)
    value = 555
}

func changeValue1() {
    sleep(1)
    value = 888
}

func changeValue2() {
    sleep(1)
    value = 0
}

//changeValue()
//changeValue1()
//changeValue2()
//
//print("(동기)함수 실행값:", value) // (동기)함수 실행값: 0

//print("\n=== 경쟁 상황 만들어서 실험해보기 ===")

// 프라이빗 시리얼 큐
let queue = DispatchQueue(label: "serial")

//value = 777
//
//queue.async {
//    changeValue()
//}
//
//queue.async {
//    changeValue1()
//}
//
//queue.async {
//    changeValue2()
//}
//
//
//print("(비동기)함수 실행값:", value) //엉뚱한 값 (비동기)함수 실행값: 777
//
//print("\n=== 이 경우에서의 간단한  해결책 ===")


value = 777

// 동기적으로 보냄(현재의 쓰레드를 block하고 기다림) ===> 경쟁상황을 제거
// (그렇지만 실제로는 이런 코드를 쓰면 안됨. 메인쓰레드를 block하고 기다리기 때문에, UI반응이 느려질 수 있음)
queue.sync {
    changeValue()
}

queue.sync {
    changeValue1()
}

queue.sync {
    changeValue2()
}


print("동기적으로 실행값:", value)

/*
 2.교착상태(DeadLock)
 : 한정된 자원을 여러 쓰레드에서 사용하려고 할때, 자원을 얻지 못해 다음 처리를 위한 진행을 못하고 있는 상태.
   예를 들어 두개의 스레드 에서 서로 필요한 자원을 들고 있어 두 스레드 모두 무한정 기다리게 되는 현상이 있다.
 
   메모리에 여러 스레드가 동시다발적으로 접근하지 못하게 한다 -> 시리얼큐, 세마포어를 이용한 제한된 리소스 사용
 */
