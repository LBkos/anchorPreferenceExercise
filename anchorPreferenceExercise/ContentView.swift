//
//  ContentView.swift
//  anchorPreferenceExercise
//
//  Created by Константин Лопаткин on 13.07.2023.
//

import SwiftUI

struct ContentView: View {
    var messages: [Message] = [
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!"),
        Message(text: "Hello, world!")
    ]
    @State var highlightMessage: Message?
    
    var body: some View {
        List(messages) { message in
            listItem(message)
        }
        .listStyle(.plain)
        .overlay {
            if highlightMessage != nil {
                Rectangle()
                    .background(.ultraThinMaterial)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            highlightMessage = nil
                        }
                        
                    }
            }
        }
        .overlayPreferenceValue(BoundsPreferenceKey.self) { values in
            if let highlightMessage = highlightMessage,
               let preference = values.first(where: { item in
                   item.key == highlightMessage.id
               }) {
                GeometryReader { proxy in
                    let rect = proxy[preference.value]
                    listItem(highlightMessage)
                        .id(highlightMessage.id)
                        .frame(width: rect.width, height: rect.height)
                        .offset(x: rect.minX, y: rect.minY)
                        .transition(.asymmetric(insertion: .identity, removal: .offset(x: 1)))
                }
            }
        }
        
    }
    func listItem(_ message: Message) -> some View {
        HStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.white)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .listRowSeparator(.hidden)
        .id(message.id)
        .anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { anchor in
            return [message.id : anchor]
        }
        .onTapGesture {}
        .onLongPressGesture(minimumDuration: 0.2) {
            withAnimation(.spring()) {
                highlightMessage = message
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
struct BoundsPreferenceKey: PreferenceKey {
    static var defaultValue: [UUID : Anchor<CGRect>] = [:]
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}

struct Message: Identifiable {
    let id: UUID = .init()
    var text: String
}
