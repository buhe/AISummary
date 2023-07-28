//
//  Sum.swift
//  Share
//
//  Created by 顾艳华 on 2023/7/5.
//

import SwiftUI

struct Sum: View {
    let fav: Fav
    let search: String
    let screenWidth = UIScreen.main.bounds.width
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
    @Environment(\.managedObjectContext) private var viewContext
    func fav(condition: Fav, isFav: Bool) -> Bool {
        switch condition {
        case .all:
            return true
        case .id(let f):
            return isFav == f
        }
    }
    var body: some View {
        List {
            ForEach(items.filter{(($0.title ?? "title").contains(search.lowercased()) || search == "") && fav(condition: self.fav, isFav: $0.fav)}) { item in
                NavigationLink {
                    VStack {
                        Text(item.title ?? "title")
                            .font(.title)
                            .bold()
                        HStack {
                            Text(item.url ?? "url")
                                .italic()
                                .foregroundStyle(.gray)
                                .font(.callout)
                            Spacer()
                        }
                        //                            .padding(.horizontal)
                        AsyncImage(url: URL(string: item.thumbnail ?? "thumbnail")) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(.gray)
                        }
                        .frame(width: screenWidth - 22 , height: screenWidth * 2 / 3)
                        ScrollView {
                            Text(item.summary ?? "summary")
                        }
                        Spacer()
                    }
                    .padding()
                    .toolbar {
                        ToolbarItem {
                            ShareLink(item: URL(string: item.url!)!, message: Text(item.summary!))
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button{
                                if let url = URL(string: item.url!) {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Image(systemName: "safari")
                            }
                        }
                    }
                } label: {
                    VStack{
                        HStack{
                            VStack(alignment: .leading){
                                Text(item.title ?? "title")
                                    .bold()
                                    .lineLimit(3)
                                Text(item.url ?? "url")
                                    .italic()
                                    .foregroundStyle(.gray)
                                    .font(Font.system(size: 10))
//                                Text("\(i)")
                                
                            }
                            
                            Spacer()
                            AsyncImage(url: URL(string: item.thumbnail ?? "thumbnail")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 150, height: 100)
                            
                        }
                        HStack {
                            Spacer()
                            Image(systemName: item.fav ? "bookmark.fill" : "bookmark")
                                .onTapGesture {
                                    item.fav.toggle()
                                    updateItem(item: item)
                                }
                                .padding(.horizontal)
                            Image(systemName: "trash")
                                .onTapGesture {
                                    deleteItems(item: item)
                                }
                                .padding(.horizontal)
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
//        .refreshable {
//            i += 1
//        }
    }
    
    private func deleteItems(item: Item) {
        withAnimation {
            viewContext.delete(item)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func updateItem(item: Item) {
        withAnimation {

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

enum Fav {
    case all
    case id(Bool)
}

