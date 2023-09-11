# 3TIER TERRAFORM PIPELINE

## 📄 프로젝트 설명

프로젝트 명 : 기간 한정 이벤트 쇼핑몰 서비스 구축

프로젝트 인원 : 1명

프로젝트 기간 : 2023.06 ~ 2023.07

프로젝트 소개 : 3일동안 이벤트성으로 운영되는 가상의 쇼핑몰 상황을 클라이언트로 설정하여 이에 따른 요구사항을 정의하고 상황에 맞는 AWS Service(Cloudfront, S3, ALB, ECS, ElastiCache, Aurora)를 사용하였습니다.
또한 이들을 Terraform을 이용하여 저만의 모듈을 만들어 인프라를 코드로 정의하고 Jenkins Pipeline을 통해 Build부터 Deployment까지 자동화 하는 프로젝트 입니다

***

## 📃 목차

[01. 클라이언트 상황 가정 ](#-01-클라이언트-상황-가정-)

[02. 요구사항 정의 ](#-02-요구사항-정의-)

[03. Jenkins Pipeline 다이어그램 ](#-03jenkins-pipeline-다이어그램-)

[04. 서비스 다이어그램 ](#-03-서비스-다이어그램-)

[05. 아키텍처 세부 구성 소개 ](#-05-핵심-서비스-소개-)

[06. Jenkins Pipeline 실행 및 구현 ](#-06-jenkins-pipeline-실행-및-구현-)

***

## [ 01 클라이언트 상황 가정 ] 

* 이벤트 기간 동안 하루에 약 20,000명의 유저가 몰릴 것이라 예상 

* 동일 기간한정 이벤트를 주기적으로 서비스 예정

* 기존에 존재하는 물리서버들은 다른 서비스를 운영중이며 전사 데이터를 보관중

* 물리 서버의 한계를 구애받지 않고자 클라우드로 배포 결정

***

## [ 02 요구사항 정의 ]

* 물리서버를 이용하지 않고, 모든 서비스를 클라우드 환경에 배포

* 안정적인 서비스를 위한 부하분산 및 고가용성 확보

* Iac를 통해 아키텍쳐 재사용성 확보 

* 하루마다 판매하는 물건의 종류가 바뀌므로, 이를 즉각 반영하는 CI/CD pipeline 구축

* DB의 고가용성 확보와 퍼포먼스 개선

* 이벤트 서비스의 관계자만 AWS Service 컨트롤 권한 부여

* 네트워크 보안 확보

***

## [ 03 Jenkins Pipeline 다이어그램 ]

<img width="1087" alt="3tier_pipeline_flow" src="https://github.com/heungbot/3tier-terraform-pipeline/assets/97264115/8e0c0018-1676-4b25-aa9c-c1d2bf0260c3">
   

* 크게 Init, Frontend 그리고 Backend로 나누어 각각의 세부 stage를 정의함.
* Terraform Plan, Apply, Build 및 TEST Stage에서 성공 여부를 Slack Plugin을 사용하여 알람을 받을 수 있도록 설정함

### 01. Init 

  1-1. 실행에 필요한 Docker, Terraform, Docker의 설치 여부, Daemon의 활성화 확인

  1-2. AWS CLI를 사용하여 ECR Login 

### 02. Frontend

  2-1. React로 구성된 Frontend 소스 코드에 대한 TEST Script 실행

  2-2. Build 과정을 거침

  2-3. 성공적으로 Build가 되었다면, Frontend에 대한 인프라를 Terraform Module을 사용하여 배포.

  2-4. 'build' 디렉토리를 CloudFront의 첫 번째 Origin인 S3 Bucket에 AWS CLI를 사용하여 업로드


### 03. Backend

  3-1. node.js로 구성된 Backend 소스 코드에 대한 TEST Script 실행 

  3-2. test script가 성공적으로 실행 됐다면, Cache와 DB의 Endpoint를 얻기 위해 Terraform Modudle 배포.

  3-3. docker를 사용하여 Image Build 후, AWS CLI를 이용하여 ECR에 업로드

  3-4. ECS Module을 사용하여 최종 배포 완료

*** 

## [ 04 서비스 다이어그램 ]

<img width="1173" alt="00_final_architecture_real" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/717f0f1a-2ef1-486a-8bb8-f7955ac8a7b5">
   
* Jenkins Pipeline을 통해 terraform으로 배포할 최종 아키텍처

***


## [ 05 아키텍처 세부 구성 소개 ]

### 5-1 Base Services


<img width="1180" alt="01_base_architecture_real" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/77ea2c96-bff1-467d-a956-ce524c14fbd4">
   
#### 1. CloudTrail : AWS 계정 관리, 운영 등을 지원하는 Service.
* 어떤 User가 어떤 Service를 컨트롤 하고 있는지 추적 가능

#### 2. ACM : SSl/TLS 인증서 프로비저닝, 관리 및 배포를 지원하는 Service
* ACM을 통해 발급받은 인증서를 통해 CloudFront의 CNAME, Route53과 연동하여 HTTPS 통신을 가능케 함

#### 3. CloudWatch : AWS Resource, Application을 위한 모니터링 서비스. 
* Cloudwatch에 수집되는 Metric과 Event를 이용하여 경보설정, auto scaling 그리고 lambda 등의 다양한 서비스와 통합 가능

#### 4. IAM : AWS에 대해 세분화된 엑세스 제어 제공.
* IAM Role을 통해 AWS Service에 특정 권한을 부여할 수 있으며, IAM User를 통해 일부 권한만 가지고 있는 User를 생성할 수 있음.
  
- Root 사용자는 모든 권한을 가지고 있기에 최대한 사용을 지양

- IAM을 사용하여 user 및 system에 대해 최소한의 권한을 적용

***

### 5-2 Network Services


<img width="949" alt="02_network_services" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/e603fb1c-d2b7-49f3-b6e3-450060623077">

#### 1. VPC : 사용자가 네트워크 대역(CIDR)을 지정하여 정의하는 논리적으로 격리된 가상의 네트워크
- 자체 데이터 센터에서 운영하는 기존 네트워크와 유사
- Virtual "Private" Cloud이기 때문에 사설 IP로 구성

#### 2. Subnet : VPC의 CIDR을 세부적으로 나눈 것으로, 서비스 마다 Subnet을 구분
* 첫 4개와 마지막 1개 IP는 AWS가 예약해두었음.
* Public Subnet : 외부와 연결된 subnet
* Private Subnet : 외부와 연결되지 않은 subnet

#### 3. Route Table : 트래픽 전달을 위한 라우팅의 이정표 역할.

#### 4. Internet Gateway : VPC 내부에 있는 Resource가 외부 인터넷과 통신을 하게 해주는 Gateway.
* VPC에 연결하여 외부와의 통신 활성화
* Route Table을 통해 Public Subnet과 연동

#### 5. NAT Gateway : 외부 인터넷이 연동되지 않는 Private Subnet 내에 존재하는 Resource들이 외부 인터넷과 통신할 수 있도록 하는 Gateway
* 특정 AZ에 생성되며 Elastic IP를 사용해야 함 
* Private Subnet - NAT Gateway - Internet Gateway - Internet
* 가용성 확보를 위한 Multi AZ에 이중화 구성 

#### 6. Bastion Host : Private Subnet에 존재하는 서비스들의 관리를 위한 Admin 서버. 
* publib subnet에 위치
* bastion host를 통한 작업의 양에 따라 instance 수를 늘리거나 multi az에 배치.
* 다른 Service의 Security Group에 bastion host의 Security Group을 허용하여 Bastion host의 접속 허용

#### 7. Security Group : EC2 Instance 단위로 Inbound, Outbound 트래픽을 제어하는 보안 서비스
* 허용 규칙은 적용할 수 있으나, 거부 규칙은 지정 불가능(whitelist 방식)

#### 8. Route53 :높은 가용성, 유연성을 가지는 완전 관리형 DNS 서비스
* Routing Policy를 통해 쿼리에 대한 응답 컨트롤 가능

***

### 5-3 Frontend Services

<img width="1182" alt="03_Frontend_services_real" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/bd89fb86-7c2d-4f08-a891-d4d30bfd814d">


#### 1. CloudFront : AWS의 CDN(Content Delivery Network) 서비스로, edge location을 통해 컨텐츠 cache 할 수 있음. 
* 동적 컨텐츠 또한 edge location을 통해 Endpoint User와 더욱 가깝운 연결을 유지하므로 전송 성능 증가
* AWS 백본 네트워크를 통해 컨텐츠 전송 성능 증가 
* 정적 컨텐츠의 Origin = S3 | 동적 컨텐츠의 Origin = ALB로 설정

#### 2. S3 : image, html 파일과 같은 컨텐츠를 대규모로 저장할 수 있는 객체 스토리지.
* 최소 3개의 AZ에 데이터가 복제되기 때문에 99.999999999%의 내구성을 가짐
* versioning, lifecycle 구성을 통해 유동적으로 객체 관리 가능
* 일반 User들의 bucket 접근을 막기 위해 Private Bucket으로 설정

#### OAC(Origin Access Control) : CloudFront 배포에게만 S3 Bucket에 액세스할 수 있도록 허용하여 Origin을 보호하는 방법.

<img width="910" alt="03_frontend_oac" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/20f78ab1-5dad-4a7f-97b7-db599b8513f8">

#### 3. ALB : 복수의 AZ에 존재하는 서버들에게 트래픽을 분산시켜 하나의 서버에 트래픽이 몰려 부하가 발생하는 것을 방지하는 로드 밸런서. 
* Layer 7(HTTP) 계층의 요청을 분산시킴 - HTTP(S) 기반으로 User와 Server가 통신하기 때문에 ALB 사용.
* CloudFront의 두 번째 Origin으로 외부와 통신 가능해야 하므로 Public Subnet에 위치
* Security Group은 CloudFront가 속한 Managed Prefix List를 허용
* Health Check를 통해 서버에 장애가 발생하면 비정상 서버로 간주하여 자동으로 트래픽 연결 차단, 정상 서버로 간주할 경우에만 트래픽 연결하므로 고가용성 제공 
* Listener Rule을 통해 ECS Task에 트래픽 라우팅

***

### 5-4 Backend Services


<img width="1175" alt="04_backend_services" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/2ad1e08e-6385-4b34-be92-dd5b1467dc6a">

#### 1. ECS : 컨테이너화된 Application을 쉽게 배포, 관리, 스케일링할 수 있도록 도와주는 완전 관리형 컨테이너 오케스트레이션 서비스.
* 외부에서의 직접적인 접속은 불가해야 하므로 Private Subnet에 위치
* 일주일 간 매일 판매 물품이 바뀌므로 Docker 이미지를 이용한 간단한 배포를 위해 ECS 사용
* 이벤트 판매 물품이 바뀌는 자정시간에 트래픽이 한 번에 몰리고, 나머지 시간은 낮은 트래픽이 예상되므로 Serverless Container Platform인 Fargate 선택
* Application Auto Scaling을 통해 특정 임계치를 넘을 경우, Task의 수를 조절하여 빠르고 유연하게 스케일링
* ECS Service의 Security Group은 ALB의 Security Group을 허용


#### 2. ECR : Docker Image를 AWS에 저장할 수 있도록 하는 완전 관리형 컨테이너 레지스트리 서비스.
* S3를 스토리지로 사용하여 뛰어난 가용성과 액세스 제공
* IAM 기반 인증을 통한 액세스 제어

***

### 5-5 Cache Service


<img width="1175" alt="05_cache_services" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/487dc92f-b044-4a76-9ed8-19b897c4d077">

#### ElastiCache : 분산 인 메모리 캐시를 손쉽게 생성하고 확장할 수 있는 서비스
* DB의 부하를 줄이고 Session 정보를 저장하여 User에게 빠른 응답을 제공하기 위해 사용.
* Redis와 Memcached 중, 비교적 복잡하지 않은 데이터 구조의 캐싱을 위해 Memcached 선택 
* Security Group은 Bastion Host의 SG와 ECS Service SG를 허용

### 5-5 DB Service


<img width="1181" alt="06_db_services" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/398c1a39-00a6-4fe3-8f1b-fd204a20086f">

#### Aurora : AWS에서 자체적으로 개발한 DB로 Cluster 단위.
* 이벤트 기간 동안 기존의 RDS보다 높은 퍼포먼스를 가져야 하기 때문에 Aurora 선택
* Replica를 활용한 고가용성(최대 15개의 Read Replica) 
* 3개의 AZ에 6개의 데이터 복사본이 유지 관리됨.
* 자동으로 Cluster 볼륨 크기 증가 가능(최대 128TiB)
* Master에 장애가 발생했을 경우, 자동으로 Replica 중 하나가 30초 이내로 Master로 승격되는 빠른 Failover 능력을 가짐
* Security Group은 Bastion Host의 SG, ECS Service 그리고 Memcached의 SG를 허용

***

## [ 06 Jenkins Pipeline 실행 및 구현 ]
<img width="1205" alt="3tier_pipeline_result" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/bea3062a-9ac0-4c93-bc22-dbf29c80b406">

* 모든 Stage가 정상적으로 수행되었으며, 생성된 서비스들은 AWS Console에서 확인 가능


### 1. Network


#### 1-1 VPC Resource Map
<img width="1384" alt="01_network_resource_map" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/e244cbe7-cd8f-4f7d-a74e-78ae8986879d">

#### 1-2 Security Groups
<img width="946" alt="10_security_groups" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/34b69698-8d3f-438d-9c0c-0e971dbc5eaa">

***

### 2. Frontend

#### 2-1. CloudFront Config
<img width="1160" alt="02_cloudfront_config" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/27c2a3a7-e1e4-46a7-9a07-3954e24e23c2">

#### 2-2. CloudFront Behavior and Origin Group
<img width="1215" alt="03_cloudfront_behavior_and_origin" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/f7079aee-ad52-44fc-b5b9-94bb85cebc71">

#### 2-3. OAC Bucket Policy

<img width="470" alt="04_origin_bucket_oac" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/ded31ffe-4e1e-416a-84d3-78533975674b">

#### 2-4. Second Origin ALB

<img width="584" alt="09_alb" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/980c4397-6df5-4b63-a7e5-3d85385dad2f">

***

### 3. Backend

#### 3-1. ECR Repository

<img width="1163" alt="05_ecr_repository" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/712c66f5-5064-4060-a1d8-a06874d4dea0">

#### 3-2. ECS Config

<img width="1028" alt="06_ecs_config" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/d1c9e3a4-a38a-4b52-83e8-c0b6aa0b1661">

***

### 4. ElastiCache

<img width="1201" alt="07_memcached_config" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/e38626e8-1a94-449f-8ad2-a43f77b8b218">

### 5. Aurora Cluster
<img width="940" alt="08_aurora_config" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/7155edf8-a140-4cd8-b19c-46b23819b063">

* 모든 terraform module이 정상적으로 배포되었음

<img width="948" alt="스크린샷 2023-08-11 오후 12 27 48" src="https://github.com/heungbot/Event_Shopping_Mall_Pipeline/assets/97264115/57d85f0c-c2f2-48df-a927-52a035acf95d">

* 중요 stage에 대한 알람이 정상적으로 slack channel에 전송되었음
