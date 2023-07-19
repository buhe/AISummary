//
//  IAPViewModel.swift
//  FinanceDashboard
//
//  Created by 顾艳华 on 2023/1/23.
//

import Foundation
import SwiftUI

class IAPViewModel :ObservableObject {
    @Published var loading = false
    
    static let shared: IAPViewModel = IAPViewModel()
}
