//
//  FoodItemsView.swift
//  FoodItemTracker
//
 
import SwiftUI

struct FoodItemsView: View {
    @ObservedObject var myFoodItems: MyFoodItems
    @State var goToAddFoodItemView = false
    var body: some View {
        NavigationView {
            VStack {
                if myFoodItems.foodItems.count > 0 {
                    List {
                        ForEach(myFoodItems.foodItems) { foodItem in
                            FoodItemsListView(foodItem: foodItem)
                        }
                    }
                } else {
                    Text("Click on the plus button to log your first pantry item.")
                }
                
                NavigationLink(destination: AddFoodItemView(myFoodItems: self.myFoodItems), isActive: self.$goToAddFoodItemView) {
                    EmptyView()
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        self.goToAddFoodItemView = true
                    }, label: {
                        Image(systemName: "plus")
                    })
                }
            }
            .navigationTitle(Text("My Pantry"))
        }
    }
}

struct FoodItemsView_Previews: PreviewProvider {
    static var previews: some View {
        FoodItemsView(myFoodItems: MyFoodItems())
    }
}
