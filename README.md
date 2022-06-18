# Library_Flutter

이 프로젝트는 크로스플랫폼 프로그래밍 과목 프로젝트로 Flutter을 사용하여 도서 검색 및 도서 리뷰를 주로 하는 어플리케이션이다.
기존 학교의 전자도서관에서 "왜 이 도서를 추천했는가?"를 알지 못하는 문제를 고치기 위해 도서의 리뷰를 작성하여 왜 이 도서를 추천했는지를 알려주는 것이 목표이다.

- login_page.dart, register_page : Firebase Authentication로 회원가입 시 email/password로 등록하여 email로 인증메일이 발송되고, 메일 인증 후 로그인 가능

- search_page.dart : Kakao OpenAPI를 활용하여 검색하고자 하는 도서 정보를 입력 후 검색하면 도서 정보 출력
- recommand_page.dart : Firebase Firestore Database를 활용하여 추천 도서를 입력하고, 각 입력된 도서들은 작성한 email을 기준으로 수정 및 삭제 가능
                        다른 계정으로 작성한 도서들은 수정 및 삭제가 불가능                              
