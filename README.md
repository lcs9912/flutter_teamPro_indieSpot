<img src="https://capsule-render.vercel.app/api?type=waving&color=233067&height=150&section=header" />

# 프로젝트
<div align="center">
  <img src="https://github.com/Jeongseonil/Indie_Spot/blob/main/assets/indiespot.png?raw=true" width="300" height="300"/>
</div>

<h2>🔎 프로젝트 정보</h2>
<div><b>📆 2023.10.23 ~ 2023.11.13 (22일)</b></div>
<div>더조은컴퓨터아카데미 수강 두 번째 단체 프로젝트.</div>
<br>
<br>

# 프로젝트 소개

<div font-size:150%>우리 앱은 예술가와 상업 공간을 연결하는 플랫폼으로, 간편한 공연 일정 및 장소 등록과 홍보가 가능합니다. 아티스트들은 더 많은 관객을 유치하고, 상업 공간 소유자들은 시설을 효과적으로 활용하여 수익을 창출할 수 있습니다.</div>

<br>

# 프로젝트 팀원 & 담당기능
|정선일|김성호|방대혁|이승준|이찬신|
|---|---|---|---|---|
|버스킹 등록, 버스킹(스팟) 목록, 버스킹(스팟)상세,포인트 상세, 충전, 환전, 목록, 영상 리스트, 영상 상세, 상업공간 목록, 공지사항, 관리자|로그인, 비밀번호 변경, 아티스트 등록,게시글 쓰기, 게시글 목록, 게시글 수정|메뉴바, 하단바, 버스킹(일정) 목록, 후원, 받은 후원 내역, 후원 내역, 영상 등록, 상업공간상세, 상업공간 예약, 상업공간 예약내역|회원가입, 버스킹 상세, 리뷰/별점, 마이페이지, 프로필 변경, 팔로워,팔로잉 목록,고객센터|메인화면, 팀/솔로 신청, 아티스트 수정, 아티스트 목록, 아티스트 상세, 상업공간등록|

<br>

# 스택
<img src="https://img.shields.io/badge/Flutter-02569B?style=flat-square&logo=flutter&logoColor=FFFFFF"/> <img src="https://img.shields.io/badge/Dart-0175C2?style=flat-square&logo=dart&logoColor=FFFFFF"/> <img src="https://img.shields.io/badge/Firebase-FFCA28?style=flat-square&logo=firebase&logoColor=FFFFFF"/> <img src="https://img.shields.io/badge/Github-181717?style=flat-square&logo=github&logoColor=FFFFFF"/> <img src="https://img.shields.io/badge/AndroidStudio-3DDC84?style=flat-square&logo=androidstudio&logoColor=FFFFFF"/> 

<br>

# 주요기능

<h3>버스킹 장소안내</h3>
<ul>
  <li>구글 맵 API를 활용한 쉬운 위치 찾기</li>
</ul>
<h3>아티스트 홍보를 위한 영상공유 기능</h3>
<ul>
  <li>구글 Youtube API를 활용한 쉬운 영상등록</li>
</ul>
<h3>응원하는 아티스트를 후원하는 기능</h3>
<ul>
  <li>결제 API를 사용하여 안전한 결제 지원</li>
</ul>

# 담당파트 
## 메인페이지
<ul>
  <li>
    인기순 의 버스킹 일정 과 상업공간 공연 일정 확인이 가능하고
    사용자 중심의 관점으로 많이찾는 서비스를 메인화면의 출력하여 사용자가 편하게 이용할 수 있도록 UI를 구현 하였습니다.
  </li>
</ul>

<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/a6f0b848-c3e7-4cc2-9f54-62900585594a" width="20%">
<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/cafcb9b8-760c-4052-9ebc-8b12c72b08ac" width="20%">

## 상업공간 등록
<ul>
  <li>
    사업자 권한이 없는 경우 등록을 방지하기 위해 사업자 등록증을 첨부 하도록 하여 이를 방지했습니다.
  </li>
  <li>
    상업공간 의 주소는 Google MAP API 를 이용해 검색하여 입력 하도록 구현하였고,
    공간 이미지, 공간소개 를 통해 일반 회원이 어떠한 공간인지 확인할 수 있습니다.
  </li>
  <li>
    영업시간, 지원장비, 장르, 가용인원, 렌탈 비용을 입력하여 아티스트 회원이 대여할때 필요한 정보를 확인할 수 있습니다.
    아티스트 회원이 상업공간을 대여할때 발생하는 수수료로 수익창출이 가능합니다.
  </li>
</ul>
<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/6d6f8151-1d4a-4bb9-bfd2-f0afe5a1a43c" width="20%">
<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/2f4cca95-6476-477b-b8fd-5a79c7621033" width="20%">
<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/a11f5a1f-93a9-4ff1-bca7-9c3f78bc683f" width="20%">

## 아티스트 목록
<ul>
  <li>
    아티스트 회원을 인기순, 최신순, 가입순으로 정렬이 가능하고,
    관심있는 장르 를 선택하여 해당 장르만 출력이 되도록 구현하였습니다.또한 팀명으로도 검색이 가능합니다.
  </li>
</ul>
<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/280dd7f1-9f6d-4f34-a885-f6901af83b9d)" width="20%">
<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/1f34f269-973d-44c1-8016-13897bcb24b7" width="20%">

## 아티스트 상세
<ul>
  <li>
    팔로우 기능과 아티스트의 상세 정보를 볼수 있습니다.
  </li>
  <li>
    소개 탭에는 팀의 정보를 볼수 있고
    공연일정 탭은 아티스트가 등록한 버스킹, 상업공간 공연일정을 확인 할수 있습니다.
    클립탭은 아티스트가 등록한 무대영상을 볼 수있고 클릭하면 유튜브 영상으로 감상 할수 있습니다.
  </li>
  <li>
    아티스트 리더권한으로 해당 페이지를 들어가면 팀관리, 후원기록, 정보수정이 가능도록 구현하였습니다. 
  </li>
</ul>
<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/32f79405-bd2f-464e-8060-c41d53ba89cb" width="20%">
<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/6e49b4af-f426-493a-b9ef-62228cb0eea6)" width="20%">
<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/8a0824bf-8122-4cf8-b359-8b6ff0ca1e15" width="20%">

## 팀 가입신청 / 신청내역 확인
<ul>
  <li>
    일반 회원 권한으로 아티스트 상세페이지에 들어가면 팀 가입신청이 가능합니다.
    어필 할수 있는 내용을 작성하여 가입 신청이 가능합니다.
  </li>
  <li>
    팀의 리더가 팀관리 페이지에서 신청 내역을 확인 할수 있고, 수락과 거절이 가능합니다.
  </li>
</ul>
<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/78ee5564-2413-4cbe-bfe0-332531961950" width="20%">
<img src="https://github.com/lcs9912/flutter_teamPro_indieSpot/assets/137017212/2be6f89a-c8c9-40c8-83be-350a0eaf19e7)" width="20%">

# 기능 구상도 & 데이터 베이스 구상
https://docs.google.com/spreadsheets/d/17j2rgXfsVzLLVs930gcgggOC80-VTxdDG6CiF0lXQEk/edit?usp=sharing

# 화면설계
https://www.figma.com/file/LbLGCvXW7OTjC1ewjsd5ek/%ED%94%8C%EB%9F%AC%ED%84%B0?type=design&mode=design&t=8HRRIaUez8AsEXY0-1

# 시연 영상

https://youtu.be/Y3ygFW4pYEo

<img src="https://capsule-render.vercel.app/api?type=waving&color=233067&height=150&section=footer" />

