import UIKit
import Foundation

/*
 디스패치큐 종류
 */

//UI 작업이 이루어지는 main 스레드 작업 할당, Serial
let mainSerial = DispatchQueue.main


//유저와 직접적인 인터렉티브, UI, 애니메이션 등 - 거의 즉시
let backgoundConcurrency = DispatchQueue.global(qos: .userInitiated)
//일반적인 작업 디폴트 - 몇초
let globalConcurrency = DispatchQueue.global()
//길게 실행되는 작업, IO, Networking.. - 몇초에서 몇분
let utilityConcurrency = DispatchQueue.global(qos: .utility)
//유저가 직접적으로 인지하지 않는 작업, 데이터 미리 가져오기.. - 속도보다는 에너지효율성, 몇분이상
let background = DispatchQueue.global(qos: .background)

//커스텀으로 만드는큐, 기본 Serial Queue, Qos 설정 Concurrent 로 설정 가능
let customSerial = DispatchQueue(label: "serial queue")
let customConcurrent = DispatchQueue(label: "concurrent", qos: .default, attributes: .concurrent)


/*
 반드시 메인큐에서 처리해야하는 작업
 */

DispatchQueue.global().async {
    //파일 다운로드 등 시간이 걸리는 작업
    
    DispatchQueue.main.async {
        //파일을 다운 받은 후 파일을 넣어서 처리할 UI 작업
    }
}

/*
 sync 메서드 주의사항
 */
//1. main thread 에서 작업할때 다른 작업은 sync 로 작업 하면 안된다.; 다른 작업이 sync 처리 되면서 해당 작업이 끝날때 까지 main thread 는 멈추게 되는데 UI 를 업데이트 하는 main thread 는 멈추면 안되기 때문이다.

DispatchQueue.main.async {
//    DispatchQueue.global().sync {
//      "(X)"
//    }
    
    DispatchQueue.global().async {
        "(O)"
    }
}

//2.현재 큐에서 현재의 큐로 "동기적으로" 보내면 안된다, sync 처리로 인해 큐를 블락하는 동시에 다시 현재의 큐에 접근하기 때문에 교착상황(DeadLock) 이 발생한다.

//async 작업으로 큐에서 다른 작업을 실행 하려고 하는데
DispatchQueue.global().async {
    //sync 작업으로 인해 큐가 블락 되어 async 작업과 교착상황 발생
    DispatchQueue.global().sync {
        <#code#>
    }
}

//3. DispathcQueue 내 에서 어떤 클래스를 참조해서 사용한다면 weak self 를 사용하는게 좋다. 그렇지 않는다면. 해당 클래스가 dismiss 된 후에도. Dispatch 클로저 안에서 해당 클래스를 참조하게 되어 메모리 누수가 발생하게 된다.

//DispatchQueue.global(qos: .utility).async { [weak self] in
//    guard let self = self else { return }
//
//    DispatchQueue.main.async {
//        self.textLabel.text = "New posts update!"
//    }
//
//}

