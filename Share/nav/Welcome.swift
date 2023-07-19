//
//  Welcome.swift
//  Share
//
//  Created by 顾艳华 on 2023/7/14.
//

import SwiftUI

struct Welcome: View {
    let next: () -> Void
    @AppStorage(wrappedValue: 10, "tryout", store: UserDefaults.shared) var tryout: Int
    var body: some View {
        VStack {
            Text("Welcome to AISummarize")
                .font(.title)
                .bold()
                .padding()
            VStack(alignment: .leading){
                Text("""
Summarify harnesses advanced Al technology to provide concise and accurate summaries of YouTube videos, helping you extract key insights with ease.

""")
                Text("You have \(tryout) trials!")
                    
            }.padding()
            Button{
                next()
            }label: {
                Text("Continue")
            }
            .buttonStyle(.borderedProminent)
            Spacer()
        }
        .padding(.top, 100)
    }
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Welcome{}
    }
}
