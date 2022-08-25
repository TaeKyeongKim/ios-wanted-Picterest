
# Picterest 
![iOS 13.0+](https://img.shields.io/badge/iOS-13.0%2B-lightgrey) ![Xcode 13.3](https://img.shields.io/badge/Xcode-13.3-blue)


- [Unsplash API](https://unsplash.com/developers) 를 이용하여 사용자가 다양한 이미지를 보고 메모와 함께 이미지를 저장할수 있는 어플입니다. 
- 두개의 화면으로 이루어진 어플이며 아래와 같은 역할을 합니다. 

  > `Home` : API를 통해 사진 목록을 보여주는 화면입니다.
  
  > `Save` : ⭐️ 를 표시한 ‘저장된’ 사진 목록을 보여주는 화면입니다.
  
----

## 팀원 소개 
| [@Kai](https://github.com/TaeKyeongKim)|
| ------------------------------------------------------------------------------------------ |
| <img src="https://avatars.githubusercontent.com/u/36659877?v=4" width="100" height="100"/> | 

----
## Architecture
![image](https://user-images.githubusercontent.com/36659877/181913974-cfdfd837-21bb-4819-ab53-93162d212a2f.png)

### 책임과 역할

### [View] (View & ViewController)

- 사용자와 어플리케이션의 원활한 상호작용 을 도와줍니다.
- 사용자에게 업데이트된 화면을 보여주고, 이벤트 핸들링 을 담당합니다.

### [ViewModel]

- 현재 어플리케이션에 적용된 ViewModel 의 계념은 1:M 의 ViewModel:ViewController 로 설정하였습니다. (한개의 ViewModel 이 여러개의 ViewController 에서 사용될수 있습니다.)
- 필요한 데이터를 가공, 찾아서 View 에 전달합니다.
- 데이터의 모든 변화는 ViewModel 에서 처리됩니다.
- ViewController 에서 부터 전달받은 특정한 이벤트 에 필요한 **데이터** 를 찾아서 전해줍니다.
- 필요시 Repository 에 요청을 보내서 데이터를 fetch 해옵니다.
- Repository 에서 부터 받은 DTO 를 뷰에 바로 보여주기 쉽게 제작된 객체 (Entity) 로 맵핑시켜 줍니다.

### [Repository]

- ViewModel 에서 필요한 데이터를 네트워크 혹은, 각종 저장소에서 가져와 전달합니다.
- 네트워크 서비스를 이용하여 특정 API request 및, Data 를 DTO 로 디코딩 해줍니다.
- Disk 와 coreData 에 데이터를 저장합니다.
---- 

## NetWork Layer

### [필요 목적]

→ API 호출의 확장성/유지보수 를 고려하여 네트워크 레이어 설계

ex) 한 페이지에 나타낼수 있는 사진 개수를 변경/ 특정 사진만 검색하는 기능 이 추가 될경우 를 위하여 

### [API 분석]
> https://api.unsplash.com/photos/?client_id=(API_Key)&page=1&per_page=15

|Scheme|Host|Path|Query|
|---|---|---|---|
|https|api.unsplash.com|photos|client_id, page, per_page| 

### [설계]
![image](https://user-images.githubusercontent.com/36659877/181914299-d6da2133-fe42-46a4-b630-6f48b9c8bb2d.png)

### 역할과 책임 

### [EndPoint]

- API 요청시 필요한 필수 EndPoint 정보들과 이에 준하는 URL 을 가지고 있습니다.
    - scheme:  URL 프로토콜을 명시
    - host:  리소스를 가지고 있는 URL host 명시
    - path: host 주소의 특정한 리소스를 받을수 있는 path 명시
    - queryItem: 특정한 path 에 받아올 리소스의 특정 제약사항을 명시
    - url : 위 정보들을 사용하여 완성된 URL (Computed property)

### [Request]

- 서버 요청 시 필요한 request 정보를 가지고 있습니다.
    - requestType: HTTP 요청 타입
    - body: 요청시 같이 보낼 데이터
    - endPoint

### [NetworkService]
- `URLRequest` 객체를 사용하여 서버와 직접적인 커뮤니케이션을 담당합니다.


## 기능 구현 
### Home 화면
|**로드 완료 된 홈 화면 및 Pagination 구현**|
|---|
|<img src="https://user-images.githubusercontent.com/36659877/181911873-7ea479ac-bd6c-41f5-ab06-ebcce0a5ea9d.gif" width="200" height="400"/>|

### [기능 및 레이아웃 구성]

> [Layout] 

- 2개의 열을 가진 가변형 높이의 Cell을 가진 레이아웃으로 구성합니다.
- 두 열 중 길이가 짧은 열의 아래쪽으로 새로운 사진을 배치합니다
- 사진은 원본 이미지의 종횡비 를 계산하여 잘림, 왜곡 없이 표현 되었습니다.
- 저장된 이미지는 `별 모양 버튼` 이 채워진 채로 표현 됩니다. 

> [Caching]  

- 다운로드 된 이미지는 memory caching 을 진행하여 스크롤이 될시 미리 저장된 이미지 를 사용합니다. 
- 이미지 좌상단 `별 모양 버튼` 을 누르면 메모를 남길수 있는 Alert 이 나타납니다.
- Alert 을 통해 사진을 저장할시, `FileManager` 는 해당이미지를 `diskCaching` 하고, `CoreData` 에 이미지에 대한 정보를 저장합니다. 


### Save 화면

|**이미지 저장 과정**|
|---|
|<img src="https://user-images.githubusercontent.com/36659877/181914656-83334c49-8906-40c3-9689-944603da1923.gif" width="200" height="400"/>|

### [기능 및 레이아웃 구성]

> [Layout] 
- 저장된 사진이 없을시 `Default` 화면이 보여집니다.
- 1개의 열을 가진 가변형 높이의 Cell을 가진 레이아웃으로 구성합니다.
- 사진은 원본 이미지의 종횡비 를 계산하여 잘림, 왜곡 없이 표현 되었습니다.
- 이미지 좌상단 `별 모양 버튼` 이 채워진 채로 표현 됩니다. 
- 사진 우상단에 저장된 메모를 보여줍니다.

> [이미지 삭제]  
- 사진을 길게 눌러 삭제할 수 있습니다.
- Alert을 통해 삭제 여부를 재확인합니다.
- 삭제 시, 해당이미지 가 `diskCache` 된 파일을 삭제하고, 선택된 이미지에 대한 정보를 `CoreData` 에서 삭제 합니다.

--- 
## 고민과 해결

### 1.0 데이터 `Save`, `Load`, `Delete` 흐름과 Model 설계 

### [Models] 

- ImageDTO 

```swift
struct ImageDTO: Decodable { 
let id: String
  let width: Int
  let height: Int
  let imageURL: ImageURL
}

struct ImageURL: Decodable {
  let url: URL
}
```
- ID
`선택 이유:`  저장한 데이터를 ID 값으로 매칭 시키기 위함.
- 사진의 원본 url
`선택 이유:` 이미지를 다운로드 받고 화면에 보여주기 위한 URL 
- 원본 width, height
`선택 이유:` 이미지의 비율에 맞춰서 화면상에 보여주기 위함.

→ API 호출로 부터 받는 Response 의 raw 한 데이터를 받을수 있는 그릇 역할을 하는 객체

- ImageEntity

```swift 
final class ImageEntity: Identifiable {
let id: String
  let imageURL: URL
  private(set) var width: CGFloat?
  private(set) var height: CGFloat?
  private(set) var isLiked: Bool
  private(set) var memo: String?
  private(set) var image: UIImage?
  private(set) var storedDirectory: URL?
}
```

→ 서버 응답으로 부터 받아온 DTO 객체 프로퍼티 들은 Raw 한 타입을 가지고 있어서 View 에 쉽게 사용하기 위해 캐스팅 작업을 거쳐야합니다.

→ 따라서 필요에 맞게 DTO 프로퍼티들을 가공한 객체를 Entity 라고 불르고, 위와 같이 설계 하였습니다. 

→ 현 프로젝트에서 Entity 는 Cell 의 ViewModel 이라고도 생각할수 있습니다.

→ 저장 여부를 판단하기 위해서 `isLiked` 라는 변수를 주었습니다. 

→ 메모, 저장여부 들은 계속 바뀔수 있는 프로퍼티 들이고 참조된 객체들의 상태를 바로 변경 함으로써 화면상에 특정 이미지 객체의 저장 상태를 확인 할수 있게 됩니다. 
그렇기 때문에 `Imageentity` 를 `class` 로 작성하였습니다.

- ImageData 

```swift
@objc(ImageData)
public class ImageData: NSManagedObject {
  @NSManaged public var id: String
  @NSManaged public var memo: String?
  @NSManaged public var imageURL: URL
  @NSManaged public var storedDirectory: URL?
}
```
→ CoreData 에 사용되는 entity 로써, 사용자가 저장할 이미지의 정보를 위와같이 정의해주었습니다.

### [`Save`, `Load`, `Delete` 흐름]

![image](https://user-images.githubusercontent.com/36659877/181915085-59edcfba-8f04-47f4-9bb9-87af2b60689e.png)

- 전체적인 저장, 불러오기 흐름은 `ImageEntity` 에서 `ImageData` 의 캐스팅 작업이 주된 가운데, `ViewModel` 들과 `Repository` 사이의 교류로 이루어 집니다.

- `Repository` 에는 `FileManager`, `CoreDataManager` 를 총괄하고 있는 `ImageManager`가 ViewModel 에서 부터온 요청을 처리해줍니다. (아래 다이어그램은 단방향으로 도식화 시킨 일련의 흐름과 Repository 의 계층 을 도식화 했습니다)

- `Delete` 또한 같은 흐름으로 구현 되었습니다.

![image](https://user-images.githubusercontent.com/36659877/181915661-bda102bd-f7ba-47ed-93ad-eebc8478f48d.png)

### 2.0 Pagination 구현

> 문제 

**`한 페이지에는 15개의 사진을 배치합니다.`**

> 해결 

→ 사용자가 CollectionView 의 끝에 접근시, API 호출이 되면서 15 개의 이미지를 가져오고, collectionView 는 더해진 cell 만큼 scroll 가능해집니다.

→ `Observable` 패턴을 사용해 fetch 되는 item 마다 collectionView 에 insert 해주도록 구현했습니다.

### 3.0 CustomCollectionViewLayout 구현

> 문제
- `2개의 열을 가진 가변형 높이의 Cell을 가진 레이아웃으로 구성합니다.`
- `추가`: CollectionView 가 끝까지 스크롤 되고 새로운 이미지들을 불러올때 CollectionView 끝에 Loading Indicator 를 보여줍니다.

> 해결 

→ Custom CollectionViewLayout 을 사용하여 높이 가변 Cell 및 Loading Indicator Footer 를 구현 하였습니다. 

→ 가변 Height 는 각 이미지의 종횡비율 을 구합니다.

> ex) 1980 x  1080 ⇒ 이미지 ratio = 1980 / 1080 = 1.7777…

→ 따라서 CustomLayout 의 item height 설정을 `prepare()` 에서 계산하고, `UICollectionViewLayoutAttributes` 을 생성해주었습니다.

### 4.0 이미지 Disk Caching 

> 문제 
- 현재 사용자가 이미지를 저장하면 현재 실행되고 있는 시뮬레이터의 GUID 는 빌드가 될때마다 바뀌는것을 확인했습니다. 이미지를 저장할때마다 새로운 simulator GUID 의 디렉토리로 저장하기 때문에 저장된 디렉토리 `storedDirectory` 에서 이미지 데이터를 불러오는 로직이 기능을 하지 못하게 되었습니다. 

> 해결 

→ `storedDirectory` 를 지우고, 실행 때마다 fileManager 가 가르키고 있는 GUID 디렉토리 주소로 이미지 id 를 사용해서 디스크 캐싱 처리를 해주었습니다.   

## 버그 및 에러  노트 
- [첫번째 페이지에서 두번째 페이지로 넘어갈때 Footer 가 생기지 않는 현상](https://github.com/TaeKyeongKim/ios-wanted-Picterest/issues/2)
- [Save 화면 전환시 CGRectNull 에러](https://github.com/TaeKyeongKim/ios-wanted-Picterest/issues/3)
