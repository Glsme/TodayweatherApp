# 🌤️ 오늘비옴?

![오늘비옴](https://user-images.githubusercontent.com/88874280/236743728-e9f0c0fd-f775-4770-92b8-a7d1dd423a35.png)

### 당일 우천 여부 및 현재 및 미래 날씨를 확인할 수 있는 앱입니다. 

- LocationManager 및 API를 사용하여 현재 위치에 따른 실시간 날씨를 확인할 수 있습니다.
- WidgetKit을 사용하여 Widget으로 실시간 우천여부를 확인할 수 있습니다.

</br><br/>
</br><br/>

## 🛠️ 사용 기술 및 라이브러리

- `Swift`, `MVVM`, `SwiftUI`, `WidgetKit`, `CoreLocation`
- `Alamofire`
</br><br/>
</br><br/>

## 🗓️ 개발 기간

- 개발 기간: 2023년 2월 2일 ~ 2023년 3월 31일 (약 2개월)
- 세부 개발 기간

| 진행사항 | 진행기간 | 세부 내용 |
| --- | --- | --- |
| UI 및 기능 구현 | 2023.02.02 ~ 2023.02.13 | UI 구현 및 데이터 추출 • 화면 출력 기능 구현 |
| Widget 구현 | 2023.02.14 ~ 2023.03.10 | 기본 Widget 및 Lock Sreen 위젯 구현 |
| 최종 테스트 및 버그 수정 | 2023.03.10 ~ 2023.03.31 | 최종 테스트 및 기능 추가 작업, Widget 관련 버그 수정 |

</br><br/>
</br><br/>

## ✏️ 구현해야 할 기술

- SwiftUI를 사용하여 UI 구현
- 메서드 기능 분리
- WidgetKit을 사용하여 Widget 구현
- 네트워크 통신으로 API 호출 및 데이터 가공

</br><br/>
</br><br/>

## 💡 Trouble Shooting

- URLConvertible 내 Encoding issue
URLConvertible 내 Encoding structure 중,
`.addingPercentEncoding`을 필연적으로 사용하여 APIKey Error가 발생

    → Encoding structure custom하여 관련 메서드를 사용하지 않는 방향으로 설정
    
    → custom한 Encoding structure를 사용하여 해결
    

[관련 이슈 링크](https://github.com/Glsme/TodayweatherApp/issues/1)

</br><br/>
- Widget 사용 시 간헐적인 API 호출 에러 발생
    
    → 테스트 시 API 2개 이상 동시 호출 시 공공 데이터 포털 내 데이터 전달 오류로 확인


</br><br/>
</br><br/>

## 🤔 회고

- SwiftUI에 대해 처음 공부하고 적용해보면서 선언형 프로그래밍에 대해 직접적으로 알게 되었다.
- Widget을 구현하면서 터미널을 사용하여 직접적으로 디버깅이 되지 않는 것을 알고 Widget 내 화면에 디버깅 코드를 직접 띄웠었다. 추후 디버깅 방법에 대해 알게 되어 아이폰 자체에서 디버깅을 할 때 사용하면 좋을 것 같았다.
- 기존 한 화면을 기준으로 ViewModel을 사용했었는데, 이번 프로젝트에 경우 한 화면에 ViewModel의 역할이 너무 커져 의존성이 증가하는 것 같았다. 추후 ViewModel의 의존성 분리를 위해 ViewModel의 역할을 분리하는 등의 방법을 적용할 것이다.
- 출시를 계획하며 앱을 제작하였지만, API 호출 횟수 제한에 대한 이슈로 인하여 출시하지 못하게 되었다. 추후 앱을 제작하려 할 때 API 호출에 대한 이슈도 고려해야 한다는 것을 깨달았다.
</br><br/>
</br><br/>
