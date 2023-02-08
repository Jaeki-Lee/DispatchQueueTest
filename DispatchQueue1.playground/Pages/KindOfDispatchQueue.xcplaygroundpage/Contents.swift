//: [Previous](@previous)

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
