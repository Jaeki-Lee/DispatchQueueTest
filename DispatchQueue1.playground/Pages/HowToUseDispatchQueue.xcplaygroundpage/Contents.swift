//: [Previous](@previous)

import UIKit
import Foundation

/*
 반드시 메인큐에서 처리해야하는 작업
 */

//DispatchQueue.global().async {
//    //파일 다운로드 등 시간이 걸리는 작업
//
//    DispatchQueue.main.async {
//        //파일을 다운 받은 후 파일을 넣어서 처리할 UI 작업
//    }
//}

/*
 sync 메서드 주의사항
 */
//1. main thread 에서 작업할때 다른 작업은 sync 로 작업 하면 안된다.; 다른 작업이 sync 처리 되면서 해당 작업이 끝날때 까지 main thread 는 멈추게 되는데 UI 를 업데이트 하는 main thread 는 멈추면 안되기 때문이다.

//DispatchQueue.main.async {
////    DispatchQueue.global().sync {
////      "(X)"
////    }
//
//    DispatchQueue.global().async {
//        "(O)"
//    }
//}

//2.현재 큐에서 현재의 큐로 "동기적으로" 보내면 안된다, sync 처리로 인해 큐를 블락하는 동시에 다시 현재의 큐에 접근하기 때문에 교착상황(DeadLock) 이 발생한다.

//async 작업으로 큐에서 다른 작업을 실행 하려고 하는데
//DispatchQueue.global().async {
//    //sync 작업으로 인해 큐가 블락 되어 async 작업과 교착상황 발생
//    DispatchQueue.global().sync {
//
//    }
//}

//3. DispathcQueue 내 에서 어떤 클래스를 참조해서 사용한다면 weak self 를 사용하는게 좋다. 그렇지 않는다면. 해당 클래스가 dismiss 된 후에도. Dispatch 클로저 안에서 해당 클래스를 참조하게 되어 메모리 누수가 발생하게 된다.

//DispatchQueue.global(qos: .utility).async { [weak self] in
//    guard let self = self else { return }
//
//    DispatchQueue.main.async {
//        self.textLabel.text = "New posts update!"
//    }
//
//}


/*
동기적 함수를 비동기적 함수로 바꿔서 지속적으로 사용할 수 있도록 만들기 결국 (기존 함수의 내용 +)
1) 직접적으로 작업을 실행할 큐와
2) 작업을 마치고나서의 큐
3) 컴플리션핸들러 필요
4) 에러처리에 대한 내용
 */

func thiltShift(image: UIImage) -> UIImage {
    return UIImage
}

func asyncTiltShift(_ inputImage: UIImage?, runQueue: DispatchQueue, completionQueue: DispatchQueue, completion: @escaping (UIImage?, Error?) -> ()) {
    
    //serial 큐로 한 스레드에 작업 연속적으로 할당
    runQueue.async {
        var error: Error?
        error = .none
        
        let outputImage = thiltShift(image: inputImage)
        
        //outputImage task 가 끝났을때
        completionQueue.async {
            //completion 으로 리턴
            completion(outputImage, error)
        }
    }
        
}

let workingQueue = DispatchQueue(label: "com.inflearn.serial")
// 플레이그라운드에서는 메인큐가 아닌 디폴트글로벌큐에서 동작
let resultQueue = DispatchQueue.global()

asyncTiltShift(image, runQueue: workingQueue, completionQueue: resultQueue) { image, error in
    image
    print("★★★비동기작업의 실제 종료시점★★★")
    //    PlaygroundPage.current.finishExecution()     //실제 모든 작업이 끝나고 플레이그라운드 종료하기 위함
}





