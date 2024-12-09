//
//  ContentView.swift
//  Amidi
//
//  Created by Евгений on 09/12/2024.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "cloud.sun.rain")
                .imageScale(.large)
                .foregroundStyle(.gray)
            Text("Погода в Кутаиси")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
