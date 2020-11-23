//
//  ContentView.swift
//  demoo
//
//  Created by User17 on 2020/11/18.
//
 
import SwiftUI
 
struct Wish: Identifiable, Codable {
    let id = UUID()
    var name: String
    var quantity: Int
    var category: String
    var price: String
    var pricecategory: String
}
 
struct WishRow: View {
    var wish: Wish
    var body: some View {
        HStack{
            VStack(alignment: .leading) {
                Text(wish.name)
                Spacer()
                Text("\(wish.quantity) pcs")
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text(wish.category)
                Spacer()
                VStack{
                    Text("\(wish.price) NTD")
                    Text("\(wish.pricecategory)")
                }
                
            }
        }
    }
}
 
class WishesData: ObservableObject {
    @Published var wishes = [Wish](){
        didSet{
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(wishes){
                UserDefaults.standard.set(data, forKey: "Wishes")
            }
        }
    }
    init(){
        if let data = UserDefaults.standard.data(forKey: "Wishes"){
            let decoder = JSONDecoder()
            if let decodedData = try? decoder.decode([Wish].self, from: data){
                wishes = decodedData
            }
        }
    }
}
 
struct WishEditor: View {
    @State private var name = ""
    @State private var selectcategory = ["Electronic", "Fashion", "Foods & Drinks", "Others"]
    @State private var selectpricecategory = ["Cheap", "Normal", "Expensive"]
    @State private var quantity = 1
    @State private var category = "Electronic"
    @State private var pricecategory = "Cheap"
    @State private var price = ""
    var editWish: Wish?
    var wishesData: WishesData
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                Stepper("Quantity \(quantity)", value: $quantity, in: 1...100)
                VStack{
                    Text("Category")
                    Picker(selection: $category, label: Text("")) {
                        ForEach(selectcategory, id: \.self) { (role) in
                            Text(role)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                }
                TextField("Price", text: $price)
                Picker(selection: $pricecategory, label: Text("")) {
                    ForEach(selectpricecategory, id: \.self) { (role) in
                        Text(role)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            .onAppear(perform: {
                if let editWish = editWish {
                    name = editWish.name
                    quantity = editWish.quantity
                    category = editWish.category
                    price = editWish.price
                }
            })
            .navigationBarTitle(editWish == nil ? "Add new wishlist" : "Edit wishlist")
            .toolbar(content: {
                ToolbarItem {
                    Button("Save") {
                        let wish = Wish(name: name, quantity: quantity, category: category, price: price, pricecategory: pricecategory)
                        if let editWish = editWish {
                            let index = wishesData.wishes.firstIndex {
                                $0.id == editWish.id
                            }!
                            wishesData.wishes[index] = wish
                        } else {
                            wishesData.wishes.insert(wish, at: 0)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            })
        }
    }
}
 
struct WishList: View {
    @StateObject var wishesData = WishesData()
    @State private var showEditWish = false
    var body: some View {
        NavigationView {
            List {
                ForEach(wishesData.wishes) { (wish) in
                    NavigationLink(destination:
                                    WishEditor( editWish: wish, wishesData: wishesData)) {
                        WishRow(wish: wish)
                    }
                }
                .onDelete { (indexSet) in
                    wishesData.wishes.remove(atOffsets: indexSet)
                }
                .onMove { (indexSet, index) in
                              self.wishesData.wishes.move(fromOffsets: indexSet, toOffset: index)
                        }
            }
            .navigationBarTitle("My Wishlist")
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showEditWish = true
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                    })
                    .sheet(isPresented: $showEditWish) {
                        NavigationView{
                            WishEditor(wishesData: wishesData)
                        }
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    EditButton()
                }
            })
        }
    }
}

struct ContentView: View {
    @ObservedObject var wishesData = WishesData()
    var body: some View {
        WishList()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

