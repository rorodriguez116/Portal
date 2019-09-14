# Portal
[![Version](https://img.shields.io/cocoapods/v/Portal.svg?style=flat)](https://cocoapods.org/pods/Portal)
[![License](https://img.shields.io/cocoapods/l/Portal.svg?style=flat)](https://cocoapods.org/pods/Portal)
[![Platform](https://img.shields.io/cocoapods/p/Portal.svg?style=flat)](https://cocoapods.org/pods/Portal)

Portal is a simple abstraction layer of FirebaseFirestore and FirebaseAuth, it saves you a lot of work by automatycally parsing  document snapshots into your data layer model by using generics at its core. Portal also allows you to use FirebaseAuth with a very easy to use API to sign-in & sign-up new users into FirebaseAuth and create its mirror representation into your  database all done by PortalAuth while maintaining your specified data layer model.

## Requirements

- iOS 12.0+

## Installation

Portal is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'Portal'
```
## Usage
<p> Portal uses generics to identify what model it should use with your database path, to do so it uses generics at is core. Models used by Portal must conform to the PortalModel protocol. </p>

### Creating a Model
<p> Let's declare a struct Pet which will be used as the base data layer model for this example.</p>

```swift

struct Pet: PortalModel {

    var id: String
    let name: String
    let age: Int
    
    init(id: String) {
        self.id = id
    }
}

```

### Creating a Portal
<p>To instantiate a new Portal you need to specify what model it will use and at what path in your database.</p>
  
```swift
let portal = Portal<Pet>(path: "pets")

```
### Portal Events
<p> To use Portal's features you must access them by the .event function. In this example we'll use the .new event to create a new document with the structure of type Pet in your database in the path pets </p>

>  If no id is specified when instantiatig the model Portal will autimatically assign a unique id using Firestore. The id is used for setting the document path and it's also added to the document attributes.

```swift 
let portal = Portal<Pet>(path: "pets")
let myPet = Pet(id: "MyPetID", name: "Monchi", age: 3)

portal.event(.new(myPet)) { (result) in
    switch result { 
        case .success: print("Success! Your data has been succesfully created")
        case .failure(let error): print(error)
    }
}

```

## License

Portal is available under the MIT license. See the LICENSE file for more info.
