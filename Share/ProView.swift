//
//  ProView.swift
//  FinanceDashboard
//
//  Created by 顾艳华 on 2023/1/22.
//

import SwiftUI
import SwiftUIX
import StoreKit

struct ProView: View {
    let title: String = "Youtube Summarize"
  
    @ObservedObject var viewModel: IAPViewModel = IAPViewModel.shared
    
    @ObservedObject var iap: IAPManager = IAPManager.shared
    
    @State var text = ""
    
    let close: () -> Void
    
    init(scheme: Bool,  close: @escaping () -> Void){
        if scheme {
            SKPaymentQueue.default().add(IAPManager.shared)
            IAPManager.shared.getProducts()
            text = "You've run out of trials."
        }
        self.close = close
    }
    var body: some View {
        if viewModel.loading {
            ActivityIndicator()
        } else {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title)
                    .bold()
                    .padding()
                
                HStack{
                    Image(systemName: "infinity")
                    VStack(alignment: .leading){
                        Text("Unlimited Summaries")
                            .bold()
                        Text("Summarize any video without time or word limits.")
                    }
                }
                .padding()
                HStack{
                    Image(systemName: "square.and.arrow.up.fill").padding(.trailing, 8)
                    VStack(alignment: .leading){
                        Text("Share Summaries")
                            .bold()
                        Text("Share a summary and a link to the original video.")
                    }
                }
                .padding()
                Text("""
Includes unlimited summaries, unlimited characters, custom settings and exporting.
Plan auto-renews for $2.99/month until canceled.
""")
                .padding()
                Text(text)
                    .padding()
                    .bold()
                    .italic()
//                    .font(.title)
                Text("EULA: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")
                    .padding(.horizontal)
                Text("Privacy: https://github.com/buhe/AISummary/blob/main/PrivacyPolicy.md")
                    .padding(.horizontal)
                HStack{
                    Button{
                        IAPViewModel.shared.loading = true
                        IAPManager.shared.buy(product: IAPManager.shared.products.first!)
                        
                    }label: {
                        Text("Subscribe")
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(iap.products.isEmpty)
                    .padding(.horizontal)
                    Button{
                        IAPViewModel.shared.loading = true
                        IAPManager.shared.restore()
                    }label: {
                        Text("Restore")
                    }
                }
                Spacer()
            }
            .padding(.top, 100)
        }
    }
}

struct ProView_Previews: PreviewProvider {
    static var previews: some View {
        ProView(scheme: true){}
    }
}
