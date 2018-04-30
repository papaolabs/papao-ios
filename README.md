# Milou for iOS
> 유기견 보호소 위치 안내 및 커뮤니티

[![Swift Version][swift-image]][swift-url] [![GitHub issues](https://img.shields.io/github/issues/papaolabs/papao-ios.svg)](https://github.com/papaolabs/papao-ios/issues) ![Version][version-image] [![GitHub stars](https://img.shields.io/github/stars/papaolabs/papao-ios.svg)](https://github.com/papaolabs/papao-ios/stargazers)

Milou는 유기동물이 우리 삶의 일부가 되는 세상을 추구합니다. 잃어버린 동물과 주인을, 버려진 동물과 미래의 주인을 이어주는 새로운 플랫폼입니다.

<img src="https://cdn-pro.dprcdn.net/files/acc_602616/8gnBHn" width=300>
[데모 영상 보기](https://vimeo.com/267162144)

## 기능

현재 Milou의 iOS 앱에서 구현 된 `v1.0`의 기능은 다음과 같습니다.

| 기능 구분 | 기능명 | 기능정의 | 구현여부 |
|-------------------|-------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
| 주요기능 | 보호소 유기동물 조회 | - 이용자는 전국의 유기동물 정보를 조회할 수 있다. <br>- 이용자는 필터조건을 걸어 유기동물을 검색할 수 있다. | 전체 구현 |
| 주요기능 | 이용자등록 유기동물 조회 | - 이용자는 다른 이용자들이 등록한 유기동물 정보를 조회할 수 있다. <br>- 이용자는 해당 유기동물의 보호소 정보를 제공한다. | 전체 구현 |
| 주요기능 | 유기동물 정보 공유 | - 이용자는 유기동물 정보를 공유할 수 있다. | 전체 구현 |
| 주요기능 | 발견한 유기동물 정보 등록 | - 이용자는 습득한 유기동물 정보를 등록할 수 있다. | 전체 구현 |
| 주요기능 | 실종한 유기동물 정보 등록 | - 이용자는 실종된 유기동물 정보를 등록할 수 있다. | - 현재 In app purchase 형태의 후원 구현 - 각 보호소에 대한 후원시스템 향후 구현 |
| 주요기능 특화기능 | 후원 | - 이용자는 유기동물에게 후원할 수 있다.<br>- 시스템은 각 보호소에 대한 후원시스템을 제공한다. | 전체 구현 |
| 특화기능 | 실종 유기동물 유사데이터 제공 | - 시스템은 유기동물을 찾고 있는 이용자에 시스템 내의 해당 유기동물의 유사 데이터를 제공한다. <br>- 시스템은 실종동물에 대해 이미지매칭 알고리즘을 가동, 특정 시간마다 이용자에게 알려준다. | 전체 구현 |
| 특화기능 | 피드 서비스 | - 시스템은 컨텐츠 및 정보를 적절한 피드로 제공한다 | 전체 구현 |


## 개발 환경

- macOS Sierra 10.12.6+
- iOS 10.0+
- Xcode 9.0+

## 설치

#### CocoaPods
프로젝트를 빌드하기 위해선 연동 중인 라이브러리를 설치해야합니다.
Milou의 iOS 앱은 오픈소스 라이브러리 의존성을 [CocoaPods](http://cocoapods.org/)을 통해서 관리하고 있습니다.
CocoaPods의 설치 방법은 링크를 통하여 확인해주세요.

터미널을 통해 다음의 명령어를 입력해주세요.

```shell
$ cd /papao-ios
$ pod install
```

#### keys.plist
Milou에서는 앱 개발에 사용되는 외부 프레임워크의 보안 키를 별도의 파일로 관리 중입니다.
해당 파일은 team papao의 커미터에게 직접 전달 받아 사용하실 수 있습니다.
전달 받은 `keys.plist`파일은 프로젝트 최상단의 폴더에 위치시키면 됩니다.

## 컨트리뷰션

Milou는 여러분들의 컨트리뷰션을 환영합니다. 지금 [Issue](https://github.com/papaolabs/papao-ios/issues) 게시판에서 컨트리뷰션 가능한 내용을 확인해주세요.

## 정보

Team papao – [facebook page](https://www.facebook.com/pg/papaolabs) – closer527@gmail.com

[https://github.com/papaolabs](https://github.com/papaolabs/)

[swift-image]:https://img.shields.io/badge/swift-4.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[version-image]: https://img.shields.io/badge/version-v1.0-fc4e75.svg
