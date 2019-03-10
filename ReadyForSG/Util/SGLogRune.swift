//
// Created by Elliot Li on 2019-03-08.
// Copyright (c) 2019 Alanli7991. All rights reserved.
//

import Foundation

class SGLogRune: NSObject, UITextViewDelegate {

    @objc static let instance = SGLogRune()
    static var redirect = false
    
    let toHook = Pipe()
    let fromHook = Pipe()
    var text: UITextView?

    private override init() {
        super.init()
    }
    
    public var active = false {
        didSet {
           text?.isHidden = !active
        }
    }
    public func clearText() {
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
        
        objc_sync_enter(self)
        if !SGLogRune.redirect {
            openConsolePipe()
        }
        objc_sync_exit(self)
        
        let textView = UITextView()
        view.addSubview(textView)
        view.bringSubviewToFront(textView)

        textView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        textView.isEditable = false
        textView.isSelectable = false
        textView.font = UIFont.systemFont(ofSize: 10)
        textView.textColor = UIColor.black
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        let guide = view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            textView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            textView.rightAnchor.constraint(equalTo: guide.rightAnchor),
            textView.widthAnchor.constraint(equalTo: guide.widthAnchor),
//            textView.heightAnchor.constraint(equalToConstant: 200),
            textView.heightAnchor.constraint(equalTo: guide.heightAnchor, constant: 100),
        ])
        text = textView
        active = true
        
    }
}
