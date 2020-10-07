## Contents

- [Требования](#требования)
- [Установка](#установка)
- [Применение](#применение)
- [Засвет](#засвет)
- [Credits](#credits)
- [License](#license)

## Требования

- iOS 9.0+
- Xcode 10.0+
- Swift 4.0+

## Установка

### CocoaPods

[CocoaPods](http://cocoapods.org) - диспетчер зависимостей для проектов Cocoa. Вы можете установить его с помощью следующей команды::

```bash
$ gem install cocoapods
```

Чтобы интегрировать DBrainDocumentFlow в ваш проект Xcode с помощью CocoaPods, укажите его в своем `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
    pod 'DBrainDocumentFlow', '~> 5.0.0'
end
```

Затем выполните следующую команду:

```bash
$ pod install
```
---
## Применение

### Flow

`DocumentFlow` -  Когда вы сделаете фото, вы сможете выбрать тип документа, прежде чем отправить его для распознавания;
`PassportFlow` - унаследованный от DocumentFlow. По умолчанию распознает тип passport_main;
`DriverLicenceFlow` - унаследованный от DocumentFlow. По умолчанию распознает тип driver_license_2011_front.

### Методы

- Хендлер завершения (вызов при успешной загрузке фото), по умолчанию `nil`
#### Swift
```swift
let onEndFlow: () -> Void = { [weak self] in
    self?.dismiss(animated: true)
}

flow.with(onEndFlow: onEndFlow)
```

- Максимальный размер фотографии в килобайтах, по умолчанию `400`
#### Swift
```swift
flow.with(expectedSizeKb: 400)
```

- Задавая зону отслеживания, по умолчанию площадь рассчитывается так же, как в примере
#### Swift
```swift
let width = UIScreen.main.bounds.width - 50.0 * 2.0
let height = width * 1.3

let size = CGSize(width: width, height: height)
let origin = CGPoint(x: 50.0, y: 88.0)

let zoneRect = CGRect(origin: origin, size: size)

flow.with(trackingRect: zoneRect)
```

- Максимальный уровень засвета, по умолчанию `1` (засвет не учитывается), подробнее [Засвет](#засвет)
#### Swift
```swift
let lumaDiffCoefficient: CGFloat = 0.35

faceFlow.with(lumaDiffCoefficient: lumaDiffCoefficient)
```

- Dотображение гистограммы и максимального уровня освещенности, по умолчанию `отключено`
#### Swift
```swift
faceFlow.withDebugViews()
```

- Хендлер результата, полученного в результате анализа, позволяет вам возвращать строки для отображения заголовков, по умолчанию `nil` (Также, если вы вернете` nil`, информация отображаться не будет)
#### Swift
```swift
let keyTitles: [String: String] = [
    "date_of_birth": "Date of birth: ",
    "date_of_issue": "Date of issue: ",
    "first_name": "First name: ",
    "issuing_authority": "Issuing authority: ",
    "other_names": "Other names: ",
    "place_of_birth": "Place of birth: ",
    "series_and_number": "Series and number: ",
    "sex": "Sex: ",
    "subdivision_code": "Subdivision code: ",
    "surname": "Surname: "
]

let onReciveResult: ((_ key: String) -> String?) = { key in
    return keyTitles[key]
}

documentFlow.with(onReciveResult: onReciveResult)
```

- Хендлер результата, полученного в результате классификации, по умолчанию позволяет возвращать строки и делать доступным / недоступным распознавание `nil`
#### Swift
```swift
let onReciveDocumentType: ((_ type: String) -> (title: String, isEnabled: Bool)) = { type in
    return (type.replacingOccurrences(of: "_", with: " ").capitalized, type != "not_document")
}

documentFlow.with(onReciveDocumentType: onReciveDocumentType)
```

- Создание модуля и отображение модуля. Перед созданием необходимо вызвать метод `build ()`, после чего, используя метод `start ()`, вы можете получить настроенный `UIViewController`
#### Swift
```swift
// Some configration
flow = flow.build()
let viewController = flow.start()
present(viewController, animated: true)
```

### Пример

- Создание DocumentFlow
#### Swift
```swift
let onEndFlow: () -> Void = { [weak self] in
    self?.dismiss(animated: true)
}

let keyTitles: [String: String] = [
    "some_key": "Some key"
]

let onReciveResult: ((_ key: String) -> String?) = { key in
    return keyTitles[key] ?? key
}

let onReciveDocumentType: ((_ type: String) -> (title: String, isEnabled: Bool)) = { type in
    return (type.replacingOccurrences(of: "_", with: " ").capitalized, type != "not_document")
}

let side = UIScreen.main.bounds.width - 50.0 * 2.0
let size = CGSize(width: side, height: side)
let origin = CGPoint(x: 50.0, y: 88.0)

let flow = DocumentFlow.configure(authorizationToken: token)
    .with(onEndFlow: onEndFlow)
    .with(onReciveResult: onReciveResult)
    .with(onReciveDocumentType: onReciveDocumentType)
    .with(lumaDiffCoefficient: 0.70)
    .with(expectedSizeKb: 1000)
    .with(trackingRect: CGRect(origin: origin, size: size))
    .withDebugViews()
    .build()

let viewController = flow.start()
viewController.modalPresentationStyle = .fullScreen

present(viewController, animated: true)
```

- Создание PassportFlow
#### Swift
```swift
let flow = PassportFlow.configure(authorizationToken: token)
    .with(onEndFlow: onEndFlow)
    .build()

let viewController = flow.start()
viewController.modalPresentationStyle = .fullScreen

present(viewController, animated: true)
```

## Засвет
При создании `FaceFlow` или `DocumentFlow` можно указать `lumaDiffCoefficient` от `0` до `1`, если значение будет больше `1`, то будет принято `1`, т.е. все будет приниматься и засвет не будет учитываться.
Этот коэффициент устанавливает максимальную высоту правого края гистограммы 
`Max = maxValue * lumaDiffCoefficient`

![Luma](/luma_clipped.png)

[Коэффициенты для расчета засвета из гистограммы RGB](https://developer.apple.com/documentation/accelerate/vimage/converting_color_images_to_grayscale)
или
[Тут](https://www.japanistry.com/histograms/)

## Credits

- Alex Belkovskiy ([@nearlydeadhipo](https://t.me/nearlydeadhipo))

## License

DBrainDocumentFlow is released under the MIT license. See LICENSE for details.
