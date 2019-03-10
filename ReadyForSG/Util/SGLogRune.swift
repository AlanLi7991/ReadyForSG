//
// Created by Elliot Li on 2019-03-08.
// Copyright (c) 2019 Alanli7991. All rights reserved.
//

import Foundation

class SGLogRune: NSObject, UITextViewDelegate {

    @objc static public let instance = SGLogRune()
    
    let toHook = Pipe()
    let fromHook = Pipe()
    var text: UITextView?

    private override init() {
        super.init()
        openConsolePipe()
    }
    
    public var active = false {
        didSet {
           text?.isHidden = !active
        }
    }
    @objc public func clearText() {
        text?.text = ""
    }

    func openConsolePipe() {

        //From fromHook >> stdout
        dup2(STDOUT_FILENO, fromHook.fileHandleForWriting.fileDescriptor)
        
        //From stdout >> toHook
        dup2(toHook.fileHandleForWriting.fileDescriptor, STDOUT_FILENO)
        //From stderr >> toHook
        dup2(toHook.fileHandleForWriting.fileDescriptor, STDERR_FILENO)
  
        //Add Listen
        NotificationCenter.default.addObserver(self, selector: #selector(toHookCompleteRead(notification:)), name: FileHandle.readCompletionNotification, object: toHook.fileHandleForReading)
        //Read and Notify
        toHook.fileHandleForReading.readInBackgroundAndNotify()
    }

    @objc func toHookCompleteRead(notification: Notification) {
        //Loop Read
        toHook.fileHandleForReading.readInBackgroundAndNotify()
        //Get Data
        guard let data = notification.userInfo?[NSFileHandleNotificationDataItem] as? Data else { return }
        guard let str = String(data: data, encoding: String.Encoding.ascii) else { return }
        //Print to fromHook and Redirect >> stdout
        fromHook.fileHandleForWriting.write(data)
        //Add to TextView
        text?.insertText(str)
    }

    @objc func attach(view: UIView) {

        let textView = UITextView()
        view.addSubview(textView)
        view.bringSubviewToFront(textView)

        textView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = UIFont.systemFont(ofSize: 13)
        textView.textColor = UIColor.black
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            textView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            textView.rightAnchor.constraint(equalTo: guide.rightAnchor),
            textView.widthAnchor.constraint(equalTo: view.widthAnchor),
            textView.heightAnchor.constraint(equalToConstant: 200),
        ])
        text = textView
        active = true
        
    }
}
