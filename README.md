# DBrainDocumentFlow

## Table of contents

*   [Начало](#Начало)
*   [Использование](#Использование)
*   [Засвет](#Засвет)
*   [Константы](#Константы)
*   [Пример](#Пример)

## Начало

### 1. Разрешения
SDK использует камеру, необходимо добавить ключ с текстом разрешения `NSCameraUsageDescription` в `Info.plist` файл:

```xml
<key>NSCameraUsageDescription</key>
<string>Тест</string>
```

## Использование

### 1. Объекты Flow
Есть несколько объектов разных модулей

`FaceFlow` - Позволяет распозновать лица и отрпавлять на сервер фото или видео;

`DocumentFlow` - Позволяет сделать фотографию документа и отправить на распознание, после чего отобразить информацию;

`ThicknessCheckFlow` - Позволяет сделать фотографию докумерта и отправить на сервер, после чгео отобразить полученый от сервера результат.

### 2. Методы FlowProtocol

- Хендлер завершения (вызывается после успешной загрузки фото), по умолчанию `nil`
#### Swift
```swift
let onEndFlow: () -> Void = { [weak self] in
    self?.dismiss(animated: true)
}

flow.with(onEndFlow: onEndFlow)
```

- Настройки для отправки данных, по умолчанию не указаны,
где `uploadUrl` это url для загрузки, `fileKey` ключ файла в form-data,  `authorizationToken` ключ к заголовку `Authorize`
#### Swift
```swift
let url = URL(string: "https://test.com/test")!

flow.with(uploadUrl: url)
flow.with(fileKey: "file")
flow.with(authorizationToken: "Token 12345")
```

- Максимальный размер фото в  килобайтах, по умолчанию `400`
#### Swift
```swift
flow.with(expectedSizeKb: 400)
```

- Создание модуля и отображение модуля. Перед созданием необходимо вызвать метод `build()` после чего, методом `start()` можно получить сконфигурированный `UIViewController`
#### Swift
```swift
// Some configration
flow = flow.build()
let viewController = flow.start()
present(viewController, animated: true)
```

### 3. Face Flow
Умеет распозновать лица и делать фото.

#### 1. Создание
#### Swift
```swift
let faceFlow = FaceFlow.configure()
```

#### 2. Параметры
У объекта `FaceFlow` помимо функции `FlowProtocol` описаных выше, есть несколько фукций, позволяющий кастомизировать логику работы модуля.

- Установка зоны отслеживания, по умолчанию зона расчитывается так-же как и в примере
#### Swift
```swift
let width = UIScreen.main.bounds.width - 50.0 * 2.0
let height = width * 1.3

let size = CGSize(width: width, height: height)
let origin = CGPoint(x: 50.0, y: 88.0)

let zoneRect = CGRect(origin: origin, size: size)

faceFlow.with(trackingRect: zoneRect)
```

- Максимальный уровень засвета, по умолчанию `1` (засвет не учитывается),  подробнее [Засвет](#Засвет)
#### Swift
```swift
let lumaDiffCoefficient: CGFloat = 0.35

faceFlow.with(lumaDiffCoefficient: lumaDiffCoefficient)
```

- Отображение гистограммы и уровня максимального засвета, по умолчанию выключено
#### Swift
```swift
faceFlow.withDebugViews()
```

#### 3. Пример
Пример создания модуля для съемки фото
#### Swift
```swift
let width = UIScreen.main.bounds.width - 50.0 * 2.0
let height = width * 1.3

let size = CGSize(width: width, height: height)
let origin = CGPoint(x: 50.0, y: 88.0)

let zoneRect = CGRect(origin: origin, size: size)

let onEndFlow: () -> Void = { [weak self] in
    self?.dismiss(animated: true)
}

let url = URL(string: "https://9uz7ugvxia.execute-api.eu-west-1.amazonaws.com/prod/s3_uploader")!

let flow = FaceFlow.configure()
.with(onEndFlow: onEndFlow)
.with(trackingRect: zoneRect)
.with(uploadUrl: url)
.with(fileKey: "file")
.with(authorizationToken: "Token fdsdk_95408d2e1a89f25f82de1f930966a07c")
.build()

let viewController = flow.start()
present(viewController, animated: true)
```

### 4. DocumentFlow
Позволяет определять тип документа или определять паспорт, определить наличие текста в зоне и отправлять фото документа на сервер.

#### 1. Создание
Необходимо определить тип (`selectable` или `pasport` ) url для классификации / распознания, а так же токен для передачи в  заголовок Access.

#### Swift
```swift
let recognitionUrl = URL(string: "https://latest.dbrain.io/recognize?mode=default&hitl_sla=night&quality=75&dpi=300&pdf_raw_images=true")!
let classificationUrl = URL(string: "https://latest.dbrain.io/classify?mode=default&quality=75&dpi=300&pdf_raw_images=true")!
let token = "UQYkXD0yc72ZV72AoDNOecZBKq2z6LmMJhHQotDhNHMXP6RdN1HQZovqpy7WGye8"
let fileKey = "image"

let type: DocumentFlow.DocumentType = .selectable

let flow = DocumentFlow.configure(type: type, authorizationToken: token, classificationUrl: classificationUrl, recognitionUrl: recognitionUrl, fileKey: fileKey)
```

#### 2. Параметры
У объекта `DocumentFlow`, есть несколько фукций, позволяющий кастомизировать логику работы модуля.

- Хедлер результата полученного в результате анализа, позволяет возвращать строки для отображения, по умолчанию `nil`  (Так же если возвращать `nil` информация отображатся не будет)
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

- Хедлер результата полученного в результате классификации, позволяет возвращать строки и делать доступным/не доступным распознание, по умолчанию `nil` 
#### Swift
```swift
let onReciveDocumentType: ((_ type: String) -> (title: String, isEnabled: Bool)) = { type in
    return (type.replacingOccurrences(of: "_", with: " ").capitalized, type != "not_document")
}

documentFlow.with(onReciveDocumentType: onReciveDocumentType)
```

- Максимальный уровень засвета, по умолчанию `1` (засвет не учитывается),  подробнее [Засвет](#Засвет)
#### Swift
```swift
let lumaDiffCoefficient: CGFloat = 0.70

documentFlow.with(lumaDiffCoefficient: lumaDiffCoefficient)
```
#### 3. Пример
Пример создания модуля для сьемки и распознания документов

#### Swift
```swift
let onEndFlow: () -> Void = { [weak self] in
    self?.dismiss(animated: true)
}

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

let onReciveDocumentType: ((_ type: String) -> (title: String, isEnabled: Bool)) = { type in
    return (type.replacingOccurrences(of: "_", with: " ").capitalized, type != "not_document")
}

let recognitionUrl = URL(string: "https://latest.dbrain.io/recognize?mode=default&hitl_sla=night&quality=75&dpi=300&pdf_raw_images=true")!
let classificationUrl = URL(string: "https://latest.dbrain.io/classify?mode=default&quality=75&dpi=300&pdf_raw_images=true")!
let token = "UQYkXD0yc72ZV72AoDNOecZBKq2z6LmMJhHQotDhNHMXP6RdN1HQZovqpy7WGye8"
let fileKey = "image"

let type: DocumentFlow.DocumentType = sender.tag == 0 ? .selectable : .pasport

let flow = DocumentFlow.configure(type: type, authorizationToken: token, classificationUrl: classificationUrl, recognitionUrl: recognitionUrl, fileKey: fileKey)
.with(onEndFlow: onEndFlow)
.with(onReciveResult: onReciveResult)
.with(onReciveDocumentType: onReciveDocumentType)
.with(lumaDiffCoefficient: 0.70)
.build()

let viewController = flow.start()
present(viewController, animated: true)
```

### 5. ThicknessCheckFlow
Позволяет сделать фото и отправить для оброботки на сервер, после чего отобразить результат оброботки.

#### 1. Создание
#### Swift
```swift
let thicknessCheckFlow = ThicknessCheckFlow.configure()
```

#### 2. Параметры
У объекта `ThicknessCheckFlow` нет дополнительных функций не относящихся к  `FlowProtocol` описаных выше.

#### 3. Пример
Пример создания модуля для сьемки обработки фото.

#### Swift
```swift
let onEndFlow: () -> Void = { [weak self] in
    self?.dismiss(animated: true)
}

let url = URL(string: "http://104.248.29.23:8000/predict")!

let flow = ThicknessCheckFlow.configure()
    .with(onEndFlow: onEndFlow)
    .with(uploadUrl: url)
    .with(authorizationToken: "Token 1234")
    .with(fileKey: "image")
    .build()

let viewController = flow.start()
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

## Константы
Все константы для расчета засвета находятся в `CameraConstans`.

#### Swift
```swift
enum CameraConstans {
    static let redCoefficient: Float = 0.2126
    static let greenCoefficient: Float = 0.7152
    static let blueCoefficient: Float = 0.0722
}
```

## Пример

#### Swift
```swift

import UIKit

class ViewController: UIViewController {

    let onReciveResult: ([String: [String: Any]]) -> NSMutableAttributedString? = { result in
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

        let attributedString = NSMutableAttributedString(string: "")

        let titleTextColor = UIColor(red: 25.0 / 255.0, green: 28.0 / 255.0, blue: 31.0 / 255.0, alpha: 1.0)
        let titleAttributes: [NSAttributedString.Key: Any] = [.kern: 0.38,
                                                              .font: UIFont.systemFont(ofSize: 17.0, weight: .medium),
                                                              .foregroundColor: titleTextColor]
        let valueTextColor = UIColor(red: 25.0 / 255.0, green: 28.0 / 255.0, blue: 31.0 / 255.0, alpha: 0.8)
        let valueAttributes: [NSAttributedString.Key: Any] = [.kern: 0.38,
                                                              .font: UIFont.systemFont(ofSize: 17.0, weight: .regular),
                                                              .foregroundColor: valueTextColor]

        for (index, key) in result.keys.enumerated() {
            if let title = keyTitles[key], let value = result[key]?["text"] as? String {
                let attributedTitle = NSAttributedString(string: title, attributes: titleAttributes)
                let attributedValue = NSAttributedString(string: value, attributes: valueAttributes)
                attributedString.append(attributedTitle)
                attributedString.append(attributedValue)

                if index != result.keys.count - 1 {
                    let newString = NSAttributedString(string: "\n")
                    attributedString.append(newString)
                }

            }
        }

        return attributedString
    }

    lazy var onEndFlow: () -> Void = { [weak self] in
        self?.dismiss(animated: true)
    }

    @IBAction func ticknessTouchUpInside(_ sender: Any) {
        let url = URL(string: "http://104.248.29.23:8000/predict")!

        let flow = ThicknessCheckFlow.configure()
            .with(onEndFlow: onEndFlow)
            .with(uploadUrl: url)
            .with(authorizationToken: "Token 1234")
            .with(fileKey: "image")
            .build()

        let viewController = flow.start()
        present(viewController, animated: true)
    }

    @IBAction func facePhoto(_ sender: Any) {
        let width = UIScreen.main.bounds.width - 50.0 * 2.0
        let height = width * 1.3

        let size = CGSize(width: width, height: height)
        let origin = CGPoint(x: 50.0, y: 88.0)

        let zoneRect = CGRect(origin: origin, size: size)

        let url = URL(string: "https://9uz7ugvxia.execute-api.eu-west-1.amazonaws.com/prod/s3_uploader")!

        let flow = FaceFlow.configure(with: .photo)
            .with(onEndFlow: onEndFlow)
            .with(trackingRect: zoneRect)
            .with(turnAngle: 20.0)
            .with(straightRange: -5.0...5.0)
            .with(lumaDiffCoefficient: 0.35)
            .with(uploadUrl: url)
            .with(fileKey: "file")
            .with(authorizationToken: "Token fdsdk_95408d2e1a89f25f82de1f930966a07c")
            .build()

        let viewController = flow.start()
        present(viewController, animated: true)
    }

    @IBAction func faceVideo(_ sender: Any) {
        let width = UIScreen.main.bounds.width - 50.0 * 2.0
        let height = width * 1.3

        let size = CGSize(width: width, height: height)
        let origin = CGPoint(x: 50.0, y: 88.0)

        let zoneRect = CGRect(origin: origin, size: size)

        let url = URL(string: "https://9uz7ugvxia.execute-api.eu-west-1.amazonaws.com/prod/s3_uploader")!

        let flow = FaceFlow.configure(with: .video)
            .with(onEndFlow: onEndFlow)
            .with(trackingRect: zoneRect)
            .with(turnAngle: 20.0)
            .with(straightRange: -5.0...5.0)
            .with(lumaDiffCoefficient: 0.35)
            .with(uploadUrl: url)
            .with(fileKey: "file")
            .with(authorizationToken: "Token fdsdk_95408d2e1a89f25f82de1f930966a07c")
            .build()

        let viewController = flow.start()
        present(viewController, animated: true)
    }
    
    @IBAction func documentTouchUpInside(_ sender: Any) {
    
        let uploadUrl = URL(string: "https://passports.v2.dbrain.io/predict")!
        let token = "Token CrynEabComNucfeojvij"
        let fileKey = "image"
        
        let idData1 = DocumentIdData(id: "Test general",
                                     type: .general,
                                     trackingRect: DocumentFlow.defaultTrackingRect(for: .general),
                                     uploadUrl: uploadUrl,
                                     authorizationToken: token,
                                     fileKey: fileKey)
    
        let idData2 = DocumentIdData(id: "Test visa",
                                     type: .visa,
                                     trackingRect: DocumentFlow.defaultTrackingRect(for: .visa),
                                     uploadUrl: uploadUrl,
                                     authorizationToken: token,
                                     fileKey: fileKey)
    
        let idData3 = DocumentIdData(id: "Test passport",
                                     type: .migrationCardAndPassport,
                                     trackingRect: DocumentFlow.defaultTrackingRect(for: .migrationCardAndPassport),
                                     uploadUrl: uploadUrl,
                                     authorizationToken: token,
                                     fileKey: fileKey)
    
        let nationalityData1 = DocumentNationalityData(nationality: "Test 1", idDatas: [idData1])
        let nationalityData2 = DocumentNationalityData(nationality: "Test 2", idDatas: [idData1, idData2])
        let nationalityData3 = DocumentNationalityData(nationality: "Test 3", idDatas: [idData1, idData2, idData3])
        
        let values = [nationalityData1, nationalityData2, nationalityData3]
        
        let flow = DocumentFlow.configure(values: values)
            .with(onEndFlow: onEndFlow)
            .with(onReciveResult: onReciveResult)
            .with(lumaDiffCoefficient: 0.70)
            .build()
    
        let viewController = flow.start()
        present(viewController, animated: true)
    }

}
```
