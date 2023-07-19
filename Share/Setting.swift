//
//  Setting.swift
//  Share
//
//  Created by 顾艳华 on 2023/7/5.
//

import SwiftUI

struct Setting: View {
    
    static let shared = Setting()
    
    @State private var showingIAP = false
//    @AppStorage(wrappedValue: false, "iap") var iap: Bool
    // @AppStorage(wrappedValue: NSLocale.preferredLanguages.first!, "lang", store: UserDefaults.shared) var lang: String
    
    @State var lang: String
    @AppStorage(wrappedValue: 10, "tryout", store: UserDefaults.shared) var tryout: Int
    
    init() {
        if UserDefaults.shared.string(forKey: "lang") == nil {
            UserDefaults.shared.set("en", forKey: "lang")
        }
        lang = UserDefaults.shared.string(forKey: "lang")!
//        print(lang)
    }
    var body: some View {
        Form {
            Section(header: Text("Summarize Language")) {
                Picker("Language", selection: $lang) {
                    //                Text("System")
                    //                    .tag(Locale.current.identifier)
                    Text("Chinese Simplified")
                        .tag("zh-Hans")
                    Text("Chinese Traditional")
                        .tag("zh-Hant")
                    Text("English")
                        .tag("en")
                    Text("French")
                        .tag("fr")//
                    Text("Japanese")
                        .tag("ja")
                    Text("Korean")
                        .tag("ko")
                    Text("Spanish")
                        .tag("es")
                    Text("Italian")
                        .tag("it")//
                    Text("German")
                        .tag("de")//
                }.onChange(of: lang) { newValue in
                    UserDefaults.shared.set(newValue, forKey: "lang")
                }
            }
            HStack{
                Text("Version")
                Spacer()
                Text(Bundle.main.releaseVersionNumber!)
            }
            HStack{
                Text("License")
                Spacer()
                Text("GPLv3")
            }
            HStack {
                Text("Tryout count")
                Spacer()
                Text("\(tryout)")
            }
            Section {
                Button{
                   showingIAP = true
                } label: {
                    
                    Text("Subscribe")
                    
                }
            }
        }
        .sheet(isPresented: $showingIAP){
            ProView(scheme: false){
                showingIAP = false
            }
        }
    }
}

