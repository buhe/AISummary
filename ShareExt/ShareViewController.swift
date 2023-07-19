//
//  ShareViewController.swift
//  ShareExt
//
//  Created by 顾艳华 on 2023/7/3.
//

import UIKit
import Social
import SwiftUI
import LangChain
import AsyncHTTPClient
import Foundation
import NIOPosix
import StoreKit
import CoreData

enum Cause {
    case NoSubtitle
    case Expired
    case Success
}
struct VideoInfo {
    let title: String
    let summarize: String
    let description: String
    let thumbnail: String
    let url: String
    let successed: Bool
    let cause: Cause
    let id: String
}
@available(iOSApplicationExtension, unavailable)
class ShareViewController: UIViewController {
    var requested = false
    let persistenceController = PersistenceController.shared
    @AppStorage(wrappedValue: NSLocale.preferredLanguages.first!, "lang", store: UserDefaults.shared) var lang: String
    
    @AppStorage(wrappedValue: 10, "tryout", store: UserDefaults.shared) var tryout: Int
//    let userDefaults = UserDefaults(suiteName: suiteName)
//    let semaphore = DispatchSemaphore(value: 0)
    var hasTry = false

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        print("lang: \(userDefaults?.object(forKey: "lang") ?? "")")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sui = SwiftUIView(close: {
            self.extensionContext!.completeRequest(returningItems: nil, completionHandler: nil)
        })
        // Do any additional setup after loading the view.
        let vc  = UIHostingController(rootView: sui)
        self.addChild(vc)
        self.view.addSubview(vc.view)
        vc.didMove(toParent: self)

        vc.view.translatesAutoresizingMaskIntoConstraints = false
        vc.view.heightAnchor.constraint(equalTo: self.view.heightAnchor).isActive = true
        vc.view.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        vc.view.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        vc.view.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        vc.view.backgroundColor = UIColor.clear
    
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if checkSubscriptionStatus() {
            for item in extensionContext!.inputItems as! [NSExtensionItem] {
                if let attachments = item.attachments {
                    for itemProvider in attachments {
                        // brower
                        if itemProvider.hasItemConformingToTypeIdentifier("public.url") {
                            itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (item, error) in
                                let url = item as! NSURL
                                // parse https://www.youtube.com/watch?v=c6SSUhsU0A0
                                if url.absoluteString!.contains("watch") {
                                    if !self.requested {
                                        self.requested = true
                                        Task {
                                            await self.parseURL2(url:url.absoluteString!, callback: {
                                                await self.sum(video_id: $0)
                                            })
                                        }
                                    }
                                }
                                // parse https://youtu.be/r25tAO1HaAI
                                if url.absoluteString!.contains("youtu.be") {
                                    if !self.requested {
                                        self.requested = true
                                        Task {
                                            await self.parseURL(url:url.absoluteString!, callback: {
                                                await self.sum(video_id: $0)
                                            })
                                        }
                                    }
                                }
                            })
                        }
                        // youtube app
                        if itemProvider.hasItemConformingToTypeIdentifier("public.text") {
                            itemProvider.loadItem(forTypeIdentifier: "public.text", options: nil, completionHandler: { (item, error) in
                                let url = item as! String
                                // https://www.youtube.com/watch?v=c6SSUhsU0A0
                                if url.contains("watch") {
                                    if !self.requested {
                                        self.requested = true
                                        Task {
                                            await self.parseURL2(url: url, callback: {
                                                await self.sum(video_id: $0)
                                            })
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
        }
        else {
            let payload = VideoInfo(title: "", summarize: "", description: "", thumbnail: "", url: "", successed: false, cause: .Expired, id: "")
            NotificationCenter.default.post(name: Notification.Name("Summarize"), object: payload)
        }
    }
    func parseURL(url: String, callback: (_ id: String) async -> Void) async {
        let c = URLComponents(string: url)
        if let id = c?.path.replacingOccurrences(of: "/", with: "") {
            await callback(id)
        }
    }
    func parseURL2(url: String, callback: (_ id: String) async -> Void) async {
        let c = URLComponents(string: url)
        if let queryItems = c?.queryItems {
            for item in queryItems {
                if item.name ==  "v" {
                    let video_id = item.value!
                    await callback(video_id)
                }
            }
        }
    }
    func sum(video_id: String) async {
        var p = ""
        switch lang {
        case let x where x.hasPrefix("zh-Hans"):
            p = """
以下是 youtube 一个视频的字幕 : %@ , 请总结主要内容, 要求在100个字以内.
"""
        case let x where x.hasPrefix("zh-Hant"):
            p = """
以下是 youtube 一個視頻的字幕 ： %@ ， 請總結主要內容， 要求在100個字以內.
"""
        case let x where x.hasPrefix("en"):
            p = """
Here are the subtitles of a YouTube video : %@ , please summarize the main content, within 100 words.
"""
        case let x where x.hasPrefix("fr"):
            p = """
Voici les sous-titres d’une vidéo YouTube : %@ , veuillez résumer le contenu principal, en 100 mots.
"""
        case let x where x.hasPrefix("ja"):
            p = """
YouTubeビデオの字幕は次のとおりです:%@、メインコンテンツを100語以内に要約してください。
"""
        case let x where x.hasPrefix("ko"):
            p = """
YouTube 동영상의 자막은 다음과 같습니다 : %@ , 주요 내용을 100단어 이내로 요약해 주세요.
"""
        case let x where x.hasPrefix("es"):
            p = """
Aquí están los subtítulos de un video de YouTube: %@ , resuma el contenido principal, dentro de 100 palabras.
"""
        case let x where x.hasPrefix("it"):
            p = """
Ecco i sottotitoli di un video di YouTube: %@ , si prega di riassumere il contenuto principale, entro 100 parole.
"""
        case let x where x.hasPrefix("de"):
            p = """
Hier sind die Untertitel eines YouTube-Videos: %@ , bitte fassen Sie den Hauptinhalt innerhalb von 100 Wörtern zusammen.
"""
        default:
            p = ""
        }
        print(lang)
        let loader = YoutubeLoader(video_id: video_id, language: lang)
        let doc = await loader.load()
        if doc.isEmpty {
            let payload = VideoInfo(title: "", summarize: "", description: "", thumbnail: "", url: "", successed: false, cause: .NoSubtitle, id: "")
            NotificationCenter.default.post(name: Notification.Name("Summarize"), object: payload)
        } else {
            let prompt = PromptTemplate(input_variables: ["youtube"], template: p)
            let request = prompt.format(args: [String(doc.first!.page_content.prefix(2000))])
            let llm = OpenAI()
            let reply = await llm.send(text: request)
            print(reply)
            let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)
            
            let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
            defer {
                // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
                try? httpClient.syncShutdown()
            }
            
            let info = await YoutubeHackClient.info(video_id: video_id, httpClient: httpClient)
            let uuid = UUID()
            let uuidString = uuid.uuidString
            let payload = VideoInfo(title: info!.title, summarize: reply, description: info!.description, thumbnail: info!.thumbnail, url: "https://www.youtube.com/watch?v=" + video_id, successed: true, cause: .Success,id: uuidString)
            if hasTry {
                tryout -= 1
                hasTry = false
            }
            NotificationCenter.default.post(name: Notification.Name("Summarize"), object: payload)
        }
    }

    func checkSubscriptionStatus() -> Bool {
        
        let semaphore = DispatchSemaphore(value: 0)
        let request = SKReceiptRefreshRequest()
//        request.delegate = self
        request.start()
        var vaild = true
        #if DEBUG
            print("Debug mode")
            let storeURL = URL(string: "https://sandbox.itunes.apple.com/verifyReceipt")
        #else
            print("Release mode")
            let storeURL = URL(string: "https://buy.itunes.apple.com/verifyReceipt")
        #endif
        print("store url: \(storeURL!.absoluteString)")
        
        if let receiptUrl = Bundle.main.appStoreReceiptURL {
            do {
                let receiptData = try Data(contentsOf: receiptUrl)
                let receiptString = receiptData.base64EncodedString(options: [])
                let requestContents = ["receipt-data": receiptString,
                                       "password": "3efc6609314c47c69aba82b471f65d4c"]

                let requestData = try JSONSerialization.data(withJSONObject: requestContents,
                                                              options: [])
                
                var request = URLRequest(url: storeURL!)
                request.httpMethod = "POST"
                request.httpBody = requestData

                let session = URLSession.shared
                let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
                    if let data = data {
                        do {
                            if let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                let receiptInfo = jsonResponse["latest_receipt_info"] as? [[String: Any]] {
                                let last = receiptInfo.first!
                                let expires = Int(last["expires_date_ms"] as! String)!
                                let now = Date()
                                
                                let utcMilliseconds = Int(now.timeIntervalSince1970 * 1000)
                                if utcMilliseconds > expires {
                                    // timeout
                                    vaild = false
                                }
                            }
                        } catch {
                            print("Pasre server error: \(error)")
                        }
                    }
                    
                    semaphore.signal()
                })
                task.resume()
            } catch {
                print("Can not load receipt：\(error), user not subscriptio.")
                vaild = false
                semaphore.signal()
            }
            
        } else {
            vaild = false
            semaphore.signal()
        }
        semaphore.wait()
        if !vaild {
            if tryout > 0 {
                hasTry = true
                return true
            } else {
                //
                
                UIApplication.shared.open(URL(string:"sum://")!)
                return false
            }
        } else {
            return true
        }
    }

}
struct SwiftUIView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @State var text = "Summarizing..."
    init(close: @escaping () -> Void) {
        self.close = close
        NotificationCenter.default.addObserver(forName: NSNotification.Name("Summarize"), object: nil, queue: .main) { msg in
            
        }
    }
    let close: () -> Void
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 25, style: .continuous)
                .fill(colorScheme == .light ? .white : .gray)
                .shadow(radius: 10)
            VStack {
                HStack {
                    Spacer()
                    Button {
                        close()
                    } label: {
                        Image(systemName: "xmark.circle")
                    }
                    .font(.title)
                    .padding()
                }
                Text("AI Summarize")
                    .bold()
                    .font(.title)
                ScrollView {
                    Text(text)
                        .font(.title2)
                }
                .padding([.bottom,.horizontal])
                Spacer()
            
            }
        }
        .padding()
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("Summarize"))) { msg in
            let payload = msg.object as! VideoInfo
            if payload.successed {
                text = payload.summarize
                addItem(payload: payload)
            } else {
                switch payload.cause {
                    case .NoSubtitle:
                        text = "The video has no subtitles, and the summary fails."
                    case .Expired:
                        text = "You have exceeded the number of trials and are not subscribed."
                    default:
                    // not reachered
                        text = ""
                }
            }
        }
    }
    
    private func addItem(payload: VideoInfo) {
        let viewContext = PersistenceController.shared.container.viewContext
        // 创建一个NSFetchRequest对象来指定查询的实体
        let fetchRequest: NSFetchRequest<Item> = Item.fetchRequest()

        // 创建一个NSPredicate对象来定义查询条件
        let predicate = NSPredicate(format: "uuid == %@", payload.id)

        // 将NSPredicate对象赋值给fetchRequest的predicate属性
        fetchRequest.predicate = predicate

        // 指定任何其他所需的排序、限制或排序规则
        // fetchRequest.sortDescriptors = ...

        // 获取需要的ManagedObjectContext对象
//        let context = persistentContainer.viewContext

        do {
            // 执行查询并获取结果
            let results = try viewContext.fetch(fetchRequest)
            
//            // 处理查询结果
//            for result in results {
//                // 打印或对结果进行其他处理
//                print(result)
//            }
            
            if results.isEmpty {
                
                let newItem = Item(context: viewContext)
                newItem.timestamp = Date()
                newItem.summary = payload.summarize
                newItem.title = payload.title
                newItem.url = payload.url
                newItem.desc = payload.description
                newItem.thumbnail = payload.thumbnail
                newItem.fav = false
                newItem.uuid = payload.id
                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        } catch {
            // 处理错误
            print("Error fetching data: \(error)")
        }
        
        
    }
}
