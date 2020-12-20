# TOPIC MODELLING ANALYSIS ON KOREAN POP LYRIC(R version)
본 프로젝트는 한국어 가사 텍스트를 대상으로 하는 토픽 모델링 자동 분류 효과를 테스트하기 위한 것이다. 데이터 소스는 [MELON](https://www.melon.com/)에서 "사랑" 키워드로 검색된 5000건 이상의 가사 원본 텍스트이며, 사용하는 모형은 LDA와 STM이다. 모형의 훈련 환경은 `R 3.9.*`이다.

## INTRODUCTION
In Korea, popular songs could be a very important way for people to express their "love" feelings, which inspired many researchers to excavate the hidden connections between humans’ love perception and popular songs with different genres based on the lyrics with "love-centered" keywords. Traditionally, a qualitative analysis of "love-centered" lyrics should focus on several typical instances extracted from the whole samples, generalizing the characteristics of a specific writer or brief period. However, with the development of computer science and statistics, it now provides a new perspective for us to elucidate the true meanings behind the natural language texts without human beings’ subjective interpretations. This quantitative analysis method, on the one hand, can efficiently relieve the manual classification burdens and generate a more precise sorting result even than human beings' doing. On the other hand, the rigidly quantized classification criteria sometimes can also incur several enigmatic conclusions conflicting with people's intuitional judgment. To demonstrate the practicability of it, this paper hence chose to manipulate 5082 Korean "love-centered" lyrics collected from online with 2 kinds of considerably valuable "topic models": LAD & STM, aimed to 1. verify the feasibility of automatically constructing a taxonomy system of "love-centered" lyrics; 2. examine and speculate a diachronic correlation between "love-centered" lyrics and published years. As a result, it is of great necessity to optimize the themes K selection when conducting a topic modeling experiment. And based on a reasonable classification, it is possible to observe a significant regressive trend on different groups of "love-centered" lyrics through years. But because of the performance limitation of topic modelling, there are still some biased cases that can be found, which implies a further improvement not just on technical parameter testing but also on a potential collaboration between quantitative and qualitative analysis.

## PROCESS
### Data Collection
1. 온라인 가사 검색 엔진(MELON)에서 핵심어 “사랑” 입력 후 여과 설정에 “가사”만 선택.
2. 검색 결과 총수 및 노래 가사 URL 확인(“songid” 목록에 저장).
3. 각 가사 URL에 개별 접속을 통해 “노래 제목”, “음반 제목”, “발매 시간”, “장르”, “가수 이름”, “작사가 이름”, “좋아요 수”, “가사” 총 8가지 정보 수집.
4. 만약 위 8종류 정보 중에 밝히지 않는 부분이 있으면, 일단 “NULL”으로 저장.
5. 발매 시간에 대해, 기존의 연/월/일(2000.1.1) 형태를 모조리 연-월-일(2000-1-1)로 변경; 만약 연도만 있고 구체적인 월, 일 정보가 없을 경우, 일제히 1월1일(01-01)로 채움; 만약 연도조차 불투명한 경우, 일제히 1970년 1월 1일(1970-01-01)로 채움.
6. 노래 가사 부분에 대해 재점검; 우선 한국어로 된 노래 가사만 선별한 후에 중복된 항목들을 일제히 삭제. 노래 가사 중에 띄어쓰기나 맞춤법 오류 등 문제에 원칙적으로 추가 교정 안함.

**Code:** [lyrics3.R](./codes/lyrics3.R "stop")

### Text Preprocessing
1. “lyrics” 항목에 저장한 모든 가사 내용을 하나씩 추출한 후 하나의 TXT로 묶음.
2. UTAGGER 프로그램에서 가사 TXT 파일을 불러온 후 형태소 자동 주석 진행.
3. UTAGGER 분석 결과를 “lyrics_tag” TXT 파일로 저장한 후에 R로 다시 불러들임.
4. R에서 형태소 단위 별로 POS주석 정보에 따라 각 가사 내용의 실질적 형태소 부분만 추출. (실질적 형태소 범위: 명사NN, 동사VV, 형용사VC/MM, 부사MA; 감탄사IC는 예외로 포괄했음)


### Topics "K" Optimization
### Model Training

## RESULTS

## CITEMENT


