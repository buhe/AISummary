//
//  IAP.swift
//  FinanceDashboard
//
//  Created by 顾艳华 on 2023/1/17.
//

import Foundation

import SwiftUI

import StoreKit

class IAPManager: NSObject, ObservableObject {

    static let shared = IAPManager()
    @Published var products = [SKProduct]()
    fileprivate var productRequest: SKProductsRequest!
    func getProductID() -> [String] {
        ["dev.buhe.sum.monthly"]
    }
    
    func getProducts() {
        let productIds = getProductID()
        let productIdsSet = Set(productIds)
        productRequest = SKProductsRequest(productIdentifiers: productIdsSet)
        productRequest.delegate = self
        productRequest.start()
    }
    
    func buy(product: SKProduct) {
            if SKPaymentQueue.canMakePayments() {
                let payment = SKPayment(product: product)
                SKPaymentQueue.default().add(payment)
            } else {
                // show error
            }
    }
    
    func restore() {
            SKPaymentQueue.default().restoreCompletedTransactions()
        }

}
extension IAPManager: SKProductsRequestDelegate {
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        response.products.forEach {
            print($0.localizedTitle, $0.price, $0.localizedDescription)
        }
        DispatchQueue.main.async {
           self.products = response.products
       }
    }
    
}

extension IAPManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        
        transactions.forEach {
            print($0.payment.productIdentifier, $0.transactionState.rawValue)
            switch $0.transactionState {
            case .purchased:
                IAPViewModel.shared.loading = false
              SKPaymentQueue.default().finishTransaction($0)
            case .failed:
                print($0.error ?? "")
                if ($0.error as? SKError)?.code != .paymentCancelled {
                    // show error
                }
              SKPaymentQueue.default().finishTransaction($0)
                IAPViewModel.shared.loading = false
            case .restored:
                //
//                Setting.shared.iap = true
                IAPViewModel.shared.loading = false
              SKPaymentQueue.default().finishTransaction($0)
            case .purchasing, .deferred:
                break
            @unknown default:
                break
            }
            
        }
    }
    
}

extension SKProduct {
    var regularPrice: String? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = self.priceLocale
        return formatter.string(from: self.price)
    }
}


//struct ProductList: View {
//
//    @ObservedObject var iapManager = IAPManager.shared
//
//    var body: some View {
//
//        List(iapManager.products, id: \.productIdentifier) { (product)  in
//            Button(action: {
//                self.iapManager.buy(product: product)
//}) {
//                HStack {
//                    Text(product.productIdentifier)
//                    Spacer()
//                    Text(product.regularPrice ?? "")
//                }
//            }
//        }
//        .onAppear {
//            self.iapManager.getProducts()
//        }
//    }
//}
