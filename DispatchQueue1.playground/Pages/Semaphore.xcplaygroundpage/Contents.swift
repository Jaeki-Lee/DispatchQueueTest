//: [Previous](@previous)

import UIKit
import Foundation

let base = "https://images.unsplash.com/photo-"

let imageNames = [
    "1579962413362-65c6d6ba55de?ixlib=rb-1.2.1&auto=format&fit=crop&w=934&q=80",
    "1580394693981-254c3aeded6a?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=3326&q=80",
 "1579202673506-ca3ce28943ef?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80",
 "1535745049887-3cd1c8aef237?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80",
 "1568389494699-9076492b22e7?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=937&q=80",
  "1566624790190-511a09f6ddbd?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=crop&w=934&q=80"
]

let group = DispatchGroup()

// 접근가능한 작업수를 5개로 제한(0부터 시작)
let semaphore = DispatchSemaphore(value: 4)

let downloadSemaphore = DispatchSemaphore(value: 4)

var downloadImages: [UIImage] = []

for name in imageNames {
    guard let url = URL(string: "\(base)\(name)") else { continue }
    
    group.enter()
    
    //semaphore 1개 사용 //4 개가 다 사용되면 다시 사용될때까지 대기 하는 듯
    downloadSemaphore.wait()
    
    let task = URLSession.shared.dataTask(with: url) { data, _, error in
        //마지막에 실행
        defer {
            //semaphore 1개 다시 채움
            downloadSemaphore.signal()
            group.leave()
        }
        
        if error == nil, let data = data, let image = UIImage(data: data) {
            downloadImages.append(image)
        }
    }
    
    task.resume()
}

let userQueue = DispatchQueue.global(qos: .userInitiated)

group.notify(queue: userQueue) {
    print("=====모든 다운로드 완료=====")
    downloadImages
}
//: [Next](@next)
