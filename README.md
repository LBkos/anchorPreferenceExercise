# Задание 
Создать список с произвольными элементами. задать background для каждого элемента. (Возможно не используя menu) при долгом нажатии на выбранный элемент, заблюрить экран и выдвинуть элемент на передний план, в том же месте где он находится под блюром(с возможным небольшим смещением, при желании).

# Решение 

Создаем модель для элемента списка 

```swift

struct Message: Identifiable {
    let id: UUID = .init()
    var text: String
}

``` 

Инициализируем массив с элементами списка(20-30)

Создаем **список** 

```swift

List(messages) { message in
            listItem(message)
        }
        .listStyle(.plain)

```
Создаем **listItem** для нашего списка 

```swift

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

```

Создаем свой **PreferenceKey** для получения места нашего выбранного элемента

```swift

struct BoundsPreferenceKey: PreferenceKey {
    static var defaultValue: [UUID : Anchor<CGRect>] = [:]
    
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}

```
Добавляем модификатор для получения места выбранного элемента в **listItem** 

```swift
.anchorPreference(key: BoundsPreferenceKey.self, value: .bounds) { anchor in
            return [message.id : anchor]
        }
```

Добавляем модификатор долгого нажатия, и перед ним ставим модификатор обычного нажатия для того что бы скролл в списке работал при поподании на его элемент.

```swift

.onTapGesture {}
        .onLongPressGesture(minimumDuration: 0.2) {
            withAnimation(.spring()) {
                highlightMessage = message
            }
        }

```
Теперь добавляем блюр и отображение сообщения к нашему списку

```swift

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
```