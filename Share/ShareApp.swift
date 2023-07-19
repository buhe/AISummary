//
//  ShareApp.swift
//  Share
//
//  Created by 顾艳华 on 2023/7/3.
//

import SwiftUI
import StoreKit

@main
struct ShareApp: App {
    let persistenceController = PersistenceController.shared
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage(wrappedValue: true, "first") var first: Bool
    @State var showNav = false
   
    fileprivate func workaroundChinaSpecialBug() {
        let url = URL(string: "https://www.baidu.com")!
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            guard let _ = data else { return }
//            print(String(data: data, encoding: .utf8)!)
        }
        
        task.resume()
    }
    
    var body: some Scene {
        SKPaymentQueue.default().add(IAPManager.shared)
        IAPManager.shared.getProducts()
        if first {
            workaroundChinaSpecialBug()
        }
        
        return WindowGroup {
            if first {
                NavContainer {
                    first = false
                }
            } else {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
//        .onChange(of: scenePhase) { phase in
//            if phase == .active {
//                print("View appeared on the screen")
//                self.refresh()
//            }
//        }
    }
    
    func refresh() {
//        persistenceController.container.viewContext.reset()
//        deleteItems(item: addItem())
//        addItem()
//        do {
//            try persistenceController.container.viewContext.save()
//        } catch {
//            print(error)
//        }
    }
    
    private func deleteItems(item: Item) {
        withAnimation {
            persistenceController.container.viewContext.delete(item)

            do {
                try persistenceController.container.viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func addItem() -> Item {
//        let viewContext = PersistenceController.shared.container.viewContext
        
        let newItem = Item(context: persistenceController.container.viewContext)
        newItem.timestamp = Date()
        newItem.fav = false
    
        do {
            try persistenceController.container.viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return newItem
    }
}
