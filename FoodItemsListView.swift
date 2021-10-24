//
//  FoodItemsListView.swift
//  FoodItemTracker
//

import SwiftUI

struct FoodItemsListView: View {
    var foodItem: FoodItem
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Food Item: \(foodItem.name)")
            
            Text("Quantity: \(foodItem.quantity)")
            
            Text("Shelf Life (days): \(foodItem.shelfLife)")
        }
    }
}

struct FoodItemsListView_Previews: PreviewProvider {
    static var previews: some View {
        FoodItemsListView(foodItem: FoodItem(name: "Banana", quantity: 10, shelfLife: 7))
    }
}
