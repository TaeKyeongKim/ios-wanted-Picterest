
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
 - Presentation, Domain, Data, 3가지 Layer 로 구성되었습니다.
 - 해당 아키텍처는 `Clean Architecture` 의 개념을 적용하였고, `DDD(Domain Driven Design)` 방식으로 진행 되었습니다. 
   - Domain Layer 는 해당 어플리케이션의 핵심 로직을 포함하고 있습니다. Presentation, Data Layer 는 Domain Layer 를 의존하고 있어 Domain 에서 변경이 생길시 다른 레이어도 바뀐 로직에 따른 수정이 요구 됩니다. (반대로 Presentation, Data Layer 가 바뀌어도 Domain Layer 의 로직에는 수정이 필요하지 않습니다) 
 
 ![image](https://user-images.githubusercontent.com/36659877/201013194-b6424ab0-2fed-4342-b6ac-db5a6733491a.png)
  

### 책임과 역할

### Presentation Layer (MVVM 적용)
> [View] (View & ViewController)
- 사용자와 어플리케이션의 원활한 상호작용 을 도와줍니다.
- 사용자에게 업데이트된 화면을 보여주고, 이벤트 핸들링 을 담당합니다.

> [ViewModel]
- 필요한 데이터를 가공 및 받아와 View 에 전달합니다.
- View 에 보여지는 데이터의 생성 및 가공은 모두 ViewModel 에서 처리됩니다.
- 각 이벤트에 맞는 Usecase 를 이용하여 View 에서 요청된 작업을 진행합니다. 

### Domain Layer 

> [Model]
- 어플리케이션에 사용되는 핵심 정보들을 그룹화시켜 모델로 정의합니다. 
- 해당 어플리케이션은 `Image` 라는 모델을 가지고 있고, Unsplash API 에서 에 받아오는 정보중 이미지를 보여줄때 필요한 정보들을 모델화 시켰습니다. 

> [Usecase]
- 시스템의 동작을 사용자의 입장에서 표현한 시나리오이며, 시스템에 관련한 요구사항을 알아내는 과정입니다.
- 사용자가 이루려고하는 행동 하나하나를 인터페이스화 시켰고, 이를 통해 Usecase 만 보아도 어떤 기능을 하는 어플리케이션인지 파악할수 있습니다. 

> [Repository] (Interfaces) 
- 각 Usecase 에서 필요한 데이터를 Network Service 혹은 Persistent Storage 에서 가져오는 역할을 합니다. 
- Domain Layer 에서는 Reopository 의 인터페이스만 구성하고 구현체는 DataLayer 에서 구성됩니다. 따라서 Usecase 에서 Repository 는 dependency inversion 이 적용되어 data Layer 가 domain Layer 에 의존할수 있게 됩니다. 

### Data Layer 

> [Repository] (Implementation)
- 각 Usecase 에서 필요한 데이터를 Network Service 혹은 Persistent Storage 에서 가져오는 역할을 합니다. 
- 서버에서 받아오는 데이터 DTO, Persistent Storage 에서 받아오는 Entity 등이 Domain Model 로 맵핑 되는 곳입니다. 

> [NetworkService] 
- 네트워크 에 필요한 데이터를 요청하는 인터페이스와 로직을 가지고 있습니다. 
- 따라서 실질적인 Network 구현체에 사용되는 기술스텍은 사용자가 선택할수 있습니다. 
- 현재 프로젝트에선 URLSession 이 사용되었고 Network Layer 를 만들어 각 Usecase 마다 필요한 API 를 생성합니다.

> [Persistent Storage] 
- 이미지를 기기 내부에 저장하거나 삭제할때 사용됩니다. 
- 현재 프로젝트에선 CoreData 가 사용되었습니다.

---- 





## 기능 구현 
### Home 화면
 <p align="center">
  <img src="https://user-images.githubusercontent.com/36659877/181911873-7ea479ac-bd6c-41f5-ab06-ebcce0a5ea9d.gif" width="200" height="400"/>
 </p>

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

<p align="center">
  <img src="https://user-images.githubusercontent.com/36659877/181914656-83334c49-8906-40c3-9689-944603da1923.gif" width="200" height="400"/>
</p>

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

<details> 
<summary> 1.0 Network Layer 설계 </summary>

### 고민의 동기

- API 호출의 확장성/유지보수 를 고려하여 네트워크 레이어 설계

ex) 한 페이지에 나타낼수 있는 사진 개수를 변경/ 특정 사진만 검색하는 기능 이 추가 될경우 를 위하여 

<details>

  <summary> API 분석 </summary> 

  **사용 예:** 

  [https://api.unsplash.com/photos/?client_id=AK-](https://api.unsplash.com/photos/?client_id=AK-bF5BwmWGtMcRiSr3Kd74cD0f3QbYlTnhwwYoaxiI&per_page=50)

  [bF5BwmWGtMcRiSr3Kd74cD0f3QbYlTnhwwYoaxiI&per_page=50](https://api.unsplash.com/photos/?client_id=AK-bF5BwmWGtMcRiSr3Kd74cD0f3QbYlTnhwwYoaxiI&per_page=50)

  **Base:**

  → [https://api.unsplash.com/](https://api.unsplash.com/)

  **Paths:** 

  - 전체 사진 받기

  →  photos/

  **QueryItems:** 

  - Client_id ⇒ AccessKey

  <img width="906" alt="image" src="https://user-images.githubusercontent.com/36659877/188916020-b6d4538d-b022-4347-b215-fd0d57d225c6.png">


  ### Response

  ```swift
  [
    {
      "id": "LBI7cgq3pbM",
      "created_at": "2016-05-03T11:00:28-04:00",
      "updated_at": "2016-07-10T11:00:01-05:00",
      "width": 5245,
      "height": 3497,
      "color": "#60544D",
      "blur_hash": "LoC%a7IoIVxZ_NM|M{s:%hRjWAo0",
      "likes": 12,
      "liked_by_user": false,
      "description": "A man drinking a coffee.",
      "user": {
        "id": "pXhwzz1JtQU",
        "username": "poorkane",
        "name": "Gilbert Kane",
        "portfolio_url": "https://theylooklikeeggsorsomething.com/",
        "bio": "XO",
        "location": "Way out there",
        "total_likes": 5,
        "total_photos": 74,
        "total_collections": 52,
        "instagram_username": "instantgrammer",
        "twitter_username": "crew",
        "profile_image": {
          "small": "https://images.unsplash.com/face-springmorning.jpg?q=80&fm=jpg&crop=faces&fit=crop&h=32&w=32",
          "medium": "https://images.unsplash.com/face-springmorning.jpg?q=80&fm=jpg&crop=faces&fit=crop&h=64&w=64",
          "large": "https://images.unsplash.com/face-springmorning.jpg?q=80&fm=jpg&crop=faces&fit=crop&h=128&w=128"
        },
        "links": {
          "self": "https://api.unsplash.com/users/poorkane",
          "html": "https://unsplash.com/poorkane",
          "photos": "https://api.unsplash.com/users/poorkane/photos",
          "likes": "https://api.unsplash.com/users/poorkane/likes",
          "portfolio": "https://api.unsplash.com/users/poorkane/portfolio"
        }
      },
      "current_user_collections": [ // The *current user's* collections that this photo belongs to.
        {
          "id": 206,
          "title": "Makers: Cat and Ben",
          "published_at": "2016-01-12T18:16:09-05:00",
          "last_collected_at": "2016-06-02T13:10:03-04:00",
          "updated_at": "2016-07-10T11:00:01-05:00",
          "cover_photo": null,
          "user": null
        },
        // ... more collections
      ],
      "urls": {
        "raw": "https://images.unsplash.com/face-springmorning.jpg",
        "full": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg",
        "regular": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg&w=1080&fit=max",
        "small": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg&w=400&fit=max",
        "thumb": "https://images.unsplash.com/face-springmorning.jpg?q=75&fm=jpg&w=200&fit=max"
      },
      "links": {
        "self": "https://api.unsplash.com/photos/LBI7cgq3pbM",
        "html": "https://unsplash.com/photos/LBI7cgq3pbM",
        "download": "https://unsplash.com/photos/LBI7cgq3pbM/download",
        "download_location": "https://api.unsplash.com/photos/LBI7cgq3pbM/download"
      }
    },
    // ... more photos
  ]

  ```
  |Scheme|Host|Path|Query|
  |---|---|---|---|
  |https|api.unsplash.com|photos|client_id, page, per_page| 


  </details>

  > 해결
  ## [설계]

  ![image](https://user-images.githubusercontent.com/36659877/201081407-752b8580-3ad1-48e2-817e-16d24c2aa329.png)

  ## 역할과 책임 

  ### [APIConfigurable]
  - API 에대한 기본적인 정보들을 가지고 있습니다. 
      - api key: API 사용에 필요한 api key 
      - header: HTTP 해더 
      - baseURL: API 의 baseURL

  ### [EndPointable]
  - API 요청시 특정한 EndPoint 가르킬수있도록 하기위한 정보를 가지고 있습니다. 
      - method: HTTP 메소드
      - path: host 주소의 특정한 리소스를 받을수 있는 path 명시
      - queryItem: 특정한 path 에 받아올 리소스의 특정 제약사항을 명시


  ### [Requestable]
  - EndPoint 와 APIConfigurator 를 사용하여 최종적인 `URLRequest` 를 만듦니다. 
      - body: HTTP 요청시 body 에 보낼 데이터 
      - endPoint: 특정 EndPoint 

  ## NetworkLayer 의 사용과정 

  ![image](https://user-images.githubusercontent.com/36659877/201088856-ba846da3-99b0-464a-9509-6959670ebc5a.png)
  
</details> 

<details> 
  <summary> 2.0 사용자 이벤트에 따른 Model 데이터의 상태 변화와 데이터의 흐름 설계 </summary> 

  ### 고민의 동기
  
  1.0 사용자의 상호작용에 따른 DTO, Model, ViewModel 흐름 설계
  
  - 서버로부터 raw 한 데이터를 받기 위해 설계된 decoderable 한 데이터 스트럭처 `DTO`, 애플리케이션의 목적에 따라 만들어진 Domain Model `Model`, 화면에 보여지는 데이터를 관리해주는 `ViewModel` 과 같이 여러 개념의 데이터 스트럭처가 사용되었습니다. 
  
  - 비슷한 데이터를 가지고 있더라도 각각의 사용용도가 다르기 때문에 어떤 데이터가 언제 불리고, 어떤 책임과 역할을 하는지 정확한 흐름을 설계해봐야 겠다는 고민을 했습니다. 
  
  
  2.0 사용자 이벤트에 따른 Model 데이터 변화
  - 두개의 다른 화면에 사용되는 이미지 데이터는 사용자가 좋아요를 표시할때 사용되는 `Liked` 의 상태와 사용자의 메모 `Memo` 값의 여부만 다를뿐, 필요한 데이터는 같습니다. 
  - 완전히 공통적인 요소를 가지고 있기때문에 두 화면에서 사용되는 한개의 model, `Image` 를 사용해서 구현 하려고 진행했습니다. 
  - 하지만 요구사항을 구현하는과정에서 아래와 같은 문제 를 겪게 되었고 이미지가 저장되어질때 데이터의 변화 흐름을 수립해야 겠다는 고민을 했습니다. 
  
  > `Home` 화면에서 이미지를 저장할때 메모를 남기고 저장을 할때 
  
  - 사용자가 입력한 메모는 HomeViewModel 에 있는 Image 데이터의 `Like` 상태를 바꾸어주어도 되지만 `Memo` 에 사용자가 입력한 메모를 업데이트해주면 안됩니다. (Home 화면의 이미지 메모는 `N 번째 사진` 으로 그대로 남아 있어야합니다).  
  
<p align="center">
  <img src="https://user-images.githubusercontent.com/36659877/201116952-c494a33b-0a3c-4908-bdeb-eceba9885460.png" width="400" height="400"/>
</p>


  
  ### 해결 
  
  > 사용자의 상호작용에 따른 DTO, Model, ViewModel 흐름

  <img width="1690" alt="image" src="https://user-images.githubusercontent.com/36659877/190572103-6b08abe4-3fc4-4e89-a88f-711b49ccbc3f.png">

  1.0 서버에서 부터 raw 한 데이터들을 ImageDTO 를 사용하여 받는다. 

  2.0 실제 Cell 에 사용될 타입 과 디폴트 데이터들을 ImageDTO 에서 Image 로 맵핑한다. 

  3.0 ImageViewModel 에 실제로 화면에 보여지는 데이터 를 Image 를 사용해서 초기화/업데이트 한다. 

  4.0 Cell 에 ImageViewModel 을 맵핑 한다.

  5.0 Cell 은 사용자에게 이미지에 대한 정보를 보여준다. 

  6.0 사용자가 Cell 를 터치하여 input 이벤트를 발생시킨다. 

  7.0 사용자의 input 에 따라 Cell index 에 해당하는 Image 데이터 를 가지고 CoreData 에 변경된 정보를 저장/업데이트 한다. 

  8.0 CoreData 에 성공적으로 변경이 적용됐다면 Image 의 정보를 업데이트 한다. 

  9.0 업데이트 된정보로  3.0, 4.0, 5.0 과정을 되풀이한다.

  > 사용자 이벤트에 따른 Model 데이터의 상태 변화

  ***아래 다이어그램은 사용자가 이미지를 `저장` 할때 데이터의 변화를 나태냈습니다.*** 
  
  <p align="center">
    <img src="https://user-images.githubusercontent.com/36659877/201129172-2ee222ab-22b0-43d3-97c9-9a15a77b45c6.png" width="700" height="400"/>
  </p>
  
  - 1.0 선택한 index 에 있는 model 을 homeViewModel 로 부터 찾아줍니다. 
  - 2.0 순서에 맞는 model 의 copy 를 만들어 like, memo 정보를 바꾸어줍니다. 
  - 3.0 Image Model 은 ImageEntity 로 변환되어 persistent Store 에 저장됩니다. 
  - 4.0 Persistent Store 에 성공적으로 저장이 되었다면, 해당 image model 과 viewModel 의 like 상태를 `true` 로 변경해 줍니다. 
  - 5.0 `Save` 화면으로 전환될때 `SaveViewModel` 은 persistent Store 에 저장되어 있는 NSManagedObject 를 Fetch 해오고, Image Model 로 변환된 데이터를 가지고 있습니다. 
  - 6.0 Fetch 된 데이터를 `Save` 화면에 나타내 줍니다.  
 
  ***아래 다이어그램은 사용자가 이미지를 `삭제` 할때 데이터의 변화를 나태냈습니다.*** 
  
  <p align="center">
    <img src="https://user-images.githubusercontent.com/36659877/201153160-6a72d98c-7ec8-4a22-a763-f92ebd3654fc.png" width="700" height="400"/>
  </p>

  - 1.0 삭제가 선택된 index path 에 맞는 image 모델을 찾아줍니다. 
  - 2.0 persistent Store 에 저장되어 있던 Entity 중 id 가 같는 오브젝트를 삭제 합니다.
  - 3.0 성공적으로 삭제 되었다면 해당 Image 와 ImageViewModel 을 SaveViewModel 에서 삭제 시킵니다.
  - 4.0 Home 화면으로 전환되었을때 현재 persistent store 에 저장되어있는 NSManagedObject 들을 fetch 해옵니다.
  - 5.0 image Model 에서 liked 되어있는 model 들과 viewModel 중 persistent store 로부터 받아온데이터 에 없는 model 과 viewModel 의 like 상태를 false 로 업데이트시킵니다.   

</details> 


<details>
  <summary> 3.0 Custom CollectionView Layout 구현 </summary>
  
  ### 고민의 동기
  - 해당 어플리케이션의 `Home`,`Save` 화면은 CollectionView 로 구현이 되어있는데, 각각의 Cell 의 높이는 실제 이미지의 비율과 같은 비율로 화면에 나타나야합니다. 
  - 여기서 Cell 의 높이는 현재 주어진 CollectionView width 와 행의 개수를 고려해서 각각 Cell 의 height 를 설정해주어야합니다. 
  - 이때 `Home` 과 `Save` 화면 에 사용될 Layout 을 custom 하게 구현해야하는데, 1,2 개의 행 뿐만아니라 여러개의 행도 나타내어줄수있게 설계해 보려고 고민 했습니다. 

  > 해결 

  ### Custom CollectionView Layout 설계   
  
  <p align="center">
    <img src="https://user-images.githubusercontent.com/36659877/201158989-f124f494-a4db-4cf4-a21b-7ddfa74345c8.png" width="500" height="300"/>
  </p>
  
  ### 역할과 책임 
  
  ### [LayoutConfigurable]
  - 여러개의 열을 만들기 위한 핵심적인 데이터를 가지고 있습니다. 
    - numberOfColumns: 원하는 행의 개수를 지정할수 있습니다. 
    - section: 하나의 화면에 여러개의 section 이 있을때 각 section 마다 다른 개수의 행을 가질수 있도록 section 값을 주었습니다. 
    - cellPadding: cell 들의 간격을 나타냅니다.
    - cacheOptions: section 에 header, item, footer 등의 옵션을 줄수 있습니다. 
    - numberOfItemsPerPage: footer 가 있을 경우에 몇개의 item 마다 footer 의 position 을 업데이트 해주기 위해 선언했습니다. 
 
  ### [CustomLayoutDelegate]
  - 각 Cell 에 사용될 사진의 비율을 viewcontroller 에서부터 받아올수 도록 delegate 함수를 가지고 있습니다.
  
  ### [CustomLayout]
  - CollectionViewLayout 을 override 함으로써 prepare() 에 원하는 열개수만큼 보여지기 위해 로직을 구성하고 있습니다.
  
  
  > 결과 
  <p align="center">
    <img src="https://user-images.githubusercontent.com/36659877/201164989-c29b1ab5-cb42-47ed-8882-e0e71bf4964c.png" width="300" height="500"/>
  </p>
  
  <p align="center">
    <img src="https://user-images.githubusercontent.com/36659877/201164792-f35a4bef-adde-4dd6-b101-aed264014581.png" width="300" height="500"/>
  </p>
  
  <p align="center">
    <img src="https://user-images.githubusercontent.com/36659877/201164933-c429f597-5c81-4f3f-a7e2-b7384af89272.png" width="300" height="500"/>
  </p>

</details>


<details> 
  <summary> 4.0 Persistent Storage 구성하기 </summary>

  ### CoreData 구성 
     
  - 현 프로젝트의 기능은 ImageEntity 라는 NSManagedObject 1개로 요구사항을 충족시킬수 있다고 생각하여 1개의 Entity 만 선언하였고, 그 record 들을 관리하기위해 CoreData 를 사용했습니다.
  - persistentContainer 를 사용하여 defualt viewContext 로 persistent store 를 관리해줍니다.   
  - persistent store 에 있는 데이터를 fetching, insert, delete 등 (Heavy lifting) 작업을 진행할땐 private queue 에서 진행되도록 performBackgroundTask() 메소드를 사용합니다.  
  - 각작업이 끝나면 background context 를 저장하여 main context 에 자동으로 업데이트 되도록 구현 해주었습니다. 

</details>

<details> 
  <summary> 5.0 DIContainer, FlowCoordinator 구성 하기 </summary> 
  
  ### 고민의 동기
  - 컴포넌트들의 단일 책임원칙을 어떻게 하면 더 명확히 나눌수 있을까? 라는 고민에서부터 시작되었습니다. 
  - 어플리케이션에 사용되는 모든 컴포넌트의 초기화 를 한곳에서 관리하면 유지보수시 초기화 관련 버그나, 기능을 추가해야할때 DIContainer 의 어떤부분을 봐야할지 명확해지므로 구현해봐야겠다는 생각을 했습니다. 
  - 화면내의 Navigation logic 을 한군데 모아 관리하는 flowCoordinator 또한 적용해 보면 좋겠다는 생각이 들었습니다. 
    
  ### 해결 
  
  ### DIContainer 
  - 2가지의 DIContainer, `AppDIContainer` , `SceneDIContainer` 가 적용되었습니다. 
  
  - `AppDIContainer` : 
    - 핵심 네트워크 정보 (API key, baseURL, Header) 들을 사용해 Network Service 를 생성, SceneDIContainer 를 생성하는 역할을 합니다.
    - `AppConfigurator` 라는 클래스를 가지고 있는데, 이는 프로젝트에 사용되는 핵심 API 정보들을 가지고 있습니다. 이를 통해서 `Repository` 에 사용되는 `NetworkService` 를 생성해줍니다. 
    - 메소드 `makeSceneDIContainer()` 는 위에서 초기화된 네트워크 서비스들을 SceneDIContainer 의 Dependencies 에 주입해 SceneDIContainer 를 생성하게됩니다.

  - `SceneDIContainer` :
    - 어플리케이션에 사용되는 ViewController, viewModel, Usecase, Repository, CollectionViewLayout 등을 생성하는 역할을합니다. 
    - 모든 컴포넌트를 생성할수 있는 팩토리인 SceneDIContainer 는 FlowCoordinatorDependencies 라는 프로토콜을 채택하고 있는데, 각 화면의 ViewController 를 생성시켜주는 메소드 를 포함하고 있습니다.


  ### FlowCoordinator 
  - 2가지의 `AppFlowCoordinator`, `FlowCoordinator` 가 사용되었습니다.
  
  - `AppFlowCoordinator`: 
    - 앱이 시작될때 사용되는 Coordinator 로 AppDIContainer 를 사용하여 SceneDIContainer 를 생성, flowCoordinator 를 생성하여 어플리케이션의 시작을 알리는 역할을합니다.
    - SceneDelegate 에서부터 사용되고, TabBarController,  AppDIcontainer 를 생성자 parameter 로 할당받습니다. 

  - `FlowCoordinator`: 
    - 핵심 Embedded Controller 인 TabBarController 를 사용하여 탭을 구성하고 
    - 메소드 `start()` 에 구성한 tabBarItems 를 tabBarController 의 viewController 로 할당합니다.     

 
 ### SceneDelegate 에서부터 DIContainer 와 FlowCoordinator 의 상호관계 및 흐름 
 ![image](https://user-images.githubusercontent.com/36659877/201271682-b677f865-b8b1-4716-85ce-8f0ae2a47ae1.png) 
  - 1.0 AppDIcontainer 는 핵심 네트워크 configuration 을 AppConfiguration 으로 부터 정의되어있는 AppKey, BaseURL, Header, 등을 사용하여 NetworkSerivce 들을 생성, 소유하고 있습니다. 
  - 2.0 SceneDelegate 에서 window 로 사용될 rootViewController 를 TabBarController 로 할당하고, 생성된 tabBarController 과 AppDIContainer 를 사용하여 AppFlowCoordinator 를 생성해줍니다.
  - 3.0 AppFlowCoordinator 의 Start() 메소드 내에는 AppDIContainer 를 사용하여 SceneDIContainer 를 생성하게되는데, 이때 SceneDIContainer 의 Dependency 인 networkService 들은 APPDIContainer 에 정의되어있던 networkSerivce 가 사용됩니다.
  - 4.0 SceneDIContainer 의 메소드 `makeFlowCoordinator()` 를 통해서 FlowCoordinator 를 생성하게 됩니다. SceneDIContainer 는 TabBarController 를 가지고 있지 않기 때문에 FlowCoordinator 는 AppFlowCoordinator 가 가지고 있는 tabBarController 를 넘겨 받습니다. 
  - 5.0 마지막으로 FlowCoordinator 내부에서 TabBarItems 를 생성시킨다음, Start() 메소드를 통해 tabBarController 의 viewController 를 할당해줍니다.

 
 
 





  
  
</details>

<details>
  <summary> 6.0 MVVM + Clean Architecture 리팩토링 과정 </summary>
  
  1.0 [Domain Layer](https://live-a-life.tistory.com/56) 
  
  2.0 [Presentation Layer](https://live-a-life.tistory.com/60) 
  
</details>



## 버그 및 에러  노트 
- [첫번째 페이지에서 두번째 페이지로 넘어갈때 Footer 가 생기지 않는 현상](https://github.com/TaeKyeongKim/ios-wanted-Picterest/issues/2)
- [Save 화면 전환시 CGRectNull 에러](https://github.com/TaeKyeongKim/ios-wanted-Picterest/issues/3)

