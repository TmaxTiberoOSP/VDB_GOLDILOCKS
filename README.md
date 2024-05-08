# VDB_GOLDILOCKS  
GovernmentProject - VDB_GOLDILOCKS
## Tibero 설치 매뉴얼
### VDB 내용이 반영된 tibero 7 바이너리 다운로드
예) tibero7-bin-VDB.tar.gz 다운로드
1. 바이너리 압축 해제
```
gunzip tibero7-bin-VDB.tar.gz
tar xvf tibero7-bin-VDB.tar
```
### 환경설정 
1. 압축을 푼 tibero 디렉토리에서 .profile 생성
```
vim .profile
export TB_HOME=/home/(username)/tibero(version)  -> ex) export TB_HOME=/data/test/tibero7
export TB_SID=tibero
export LD_LIBRARY_PATH=$TB_HOME/lib:$TB_HOME/client/lib
export PATH=$PATH:$TB_HOME/bin:$TB_HOME/client/bin
export LIBPATH=$TB_HOME/lib:$TB_HOME/client/lib:$LIBPATH
:wq
source .profile
```
2. license.xml 복사 
발급받은 license.xml 파일을 복사
```
cp license.xml $TB_HOME/license/
```
3. gen_tip.sh 수행하여 초기파라미터 관련 파일들 생성
```
sh $TB_HOME/config/gen_tip.sh
```
4. 포트 설정 
```
vi $TB_HOME/config/tibero.tip
vi $TB_HOME/client/config/tbdsn.tbr
```
위의 두 파일에서 LISTENER_PORT의 번호를 변경 (default: 8629)
5. 자동 스크립트 사용하여 빌드 및 설치, 구동
```
cd $TB_HOME/bin
sh tb_create_db.sh
```
6. 구축 완료 후 tbsql 수행
기본 sys 계정 password  : tibero
기본 tibero 계정 (dba) password : tmax
tbsql tibero/tmax를 활용해서 tbsql 접속
tbboot, tbdown 으로 tibero를 부팅시키거나, 끌수 있다.
## SunDB 설치 매뉴얼
1. docker 설치 - ubuntu 20.04 이미지 설치
```
sudo docker pull homebrew/ubuntu20.04
```
2. 이미지 이름 확인
```
sudo docker images
sudo mkdir /goldilocks
```
3. 컨테이너 생성
```
sudo docker run --name sunDB -p 22581:22581 -v /goldilocks:/goldilocks –shm-size=2G -i -t -d homebrew/ubuntu20.04
```
4. 컨테이너 구동 확인
```
sudo docker ps
# 안 켜져 있으면, sudo docker start [컨테이너 이름]
sudo docker start sunDB
# 컨테이너 정상 구동 확인
sudo docker exec -it --privileged sunDB /bin/bash
# 기본 컨테이너에는 unzip, vim, JAVA 등이 설치되어있지 않던 것으로 기억함.
sudo apt-get update
sudo apt-get install openjdk-8-jdk vim unzip
```
5. 시스템 변수 세팅 
```
sudo docker exec -it --privileged sunDB /bin/bash 명령어로 docker 에 접속 후 다음 설정
```
vim /etc/sysctl.conf 후 다음 맨 밑에 추가
```
fs.file-max = 65536
kernel.shmall = 8388608
kernel.shmmax = 34359738368
kernel.shmmni = 4096
kernel.sem = 250 32000 100 128
net.ipv4.ip_local_port_range = 9000 65500
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
```
vim /etc/security/limits.conf 후 다음 맨 밑에 추가
```
[username] soft nofile 65535
[username] hard nofile 65535
[username] soft nproc 65535
[username] hard nproc 65535
[username] soft memlock unlimited
[username] hard memlock unlimited
```
6. Goldilocks 설치
다음은 docker 가 아닌 터미널에서 수행
아래 링크에서 goldilocks 다운로드
<https://drive.google.com/file/d/1uc2dOqv8q0iCsF1f5Z40rMm9P9YcvcG1/view?usp=drive_web>
다운로드 된 폴더에서 sudo cp goldilocks-server-20c.20.1.26-linux-x86_64.tar.gz /goldilocks/goldilocks-server-20c.20.1.26-linux-x86_64.tar.gz
```
cd /goldilocks
sudo tar -xvzf goldilocks-server-20c.20.1.26-linux-x86_64.tar.gz -C /goldilocks/gold
```
7. 환경 변수 설정
다음은 docker에서 수행
vim ~/.bashrc 후 다음 맨 밑에 추가
```
export GOLDILOCKS_HOME=/goldilocks/gold/goldilocks_home
export GOLDILOCKS_DATA=/goldilocks/gold/goldilocks_data
export PATH=.:$GOLDILOCKS_HOME/bin:$PATH
export LD_LIBRARY_PATH=$GOLDILOCKS_HOME/lib:$LD_LIBRARY_PATH
export GOLDILOCKS_SHARED_MEMORY_STATIC_KEY=542353
export GOLDILOCKS_LISTEN_PORT=22581
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
source ~/.bashrc
```
8. License 발급
license 파일이 없는 경우, startup 시에 에러가 발생하기 때문에, 선재소프트 담당 연구원님께 데모 라이센스를 요청해야 한다.
라이센스 발급을 위해 필요한 정보는 다음과 같다. (docker container 안에서 수행)
```
hostname
uname -a
lscpu
cat /proc/meminfo
free -h
```
받은 라이센스 파일은 $GOLDILOCKS_HOME/license 에 넣으면 된다.
받은 라이선스 파일 이름은 license로 만든다.
9. DB 생성 및 구동
DB 생성
```
gcreatedb
```
DB 접속
```
gsql sys gliese --as sysdba
```
DB 구동
```
gSQL> startup
```
Database schema 정보 구축
```
gsql --as sysdba --import $GOLDILOCKS_HOME/admin/standalone/DictionarySchema.sql
gsql --as sysdba --import $GOLDILOCKS_HOME/admin/standalone/InformationSchema.sql
gsql --as sysdba --import $GOLDILOCKS_HOME/admin/standalone/PerformanceViewSchema.sql
```
10. Listener 구동
리스너를 따로 켜야만 원격으로 DB에 접속 가능하기 때문에 DBLink를 위해서는 필수적으로 리스너를 실행해야 한다.
리스너 on/off는 다음과 같이 할 수 있다.
```
# listener ON
glsnr --start
# listener OFF
glsnr --stop
```
11. Database 삭제
혹시라도 DB 설치를 잘못한 경우, 이를 삭제하고 다시 설치해야 한다.
```
rm -rf $GOLDILOCKS_DATA/db/*.dbf
rm -rf $GOLDILOCKS_DATA/wal/*.ctl
rm -rf $GOLDILOCKS_DATA/wal/*.log
rm -rf $GOLDILOCKS_DATA/archive_log/*.log
```
12. Data 테이블스페이스 생성
```
--- SYNTAX ---
--- CREATE TABLESPACE [테이블스페이스 명] DATAFILE [데이터파일 명] SIZE [크기];
--- EXAMPLE ---
gSQL> CREATE TABLESPACE SAMPLE_DATA_TBS DATAFILE 'sample_data_01.dbf' SIZE 1G;
```
13. 데이터 파일 추가
```
--- SYNTAX ---
--- ALTER TABLESPACE [테이블스페이스 명] ADD DATAFILE [데이터파일 명] SIZE [크기];
--- EXAMPLE ---
gSQL> ALTER TABLESPACE SAMPLE_DATA_TBS ADD DATAFILE 'sample_data_02.dbf' SIZE 1G;
```
14. TEMP 테이블 스페이스 생성
```
--- SYNTAX ---
--- CREATE TEMPORARY TABLESPACE [테이블스페이스 명] MEMORY [데이터파일 명] SIZE [크기];
--- EXAMPLE ---
gSQL> CREATE TEMPORARY TABLESPACE SAMPLE_TEMP_TBS MEMORY 'sample_temp_01' SIZE 1G;
```
15. 데이터 파일 추가
```
--- SYNTAX ---
--- ALTER TABLESPACE [테이블스페이스 명] ADD MEMORY [데이터파일 명] SIZE [크기];
--- EXAMPLE ---
gSQL> ALTER TABLESPACE SAMPLE_DATA_TBS ADD MEMORY 'sample_temp_02.dbf' SIZE 1G;
```
16. 유저 생성
```
--- SYNTAX ---
--- CREATE USER user_identifier IDENTIFIED BY password
--- [ DEFAULT TABLESPACE tablespace_name ]
--- [ TEMPORARY TABLESPACE tablespace_name ]
--- [ INDEX TABLESPACE tablespace_name ]
--- EXAMPLE ---
gSQL > create user TIBERO identified by tmax DEFAULT TABLESPACE SAMPLE_DATA_TBS TEMPORARY TABLESPACE SAMPLE_TEMP_TBS;
```
17. 유저 권한 설정
```
--- SYNTAX ---
--- GRANT ALL ON DATABASE TO [username];
--- EXAMPLE ---
gSQL> grant all on database to TIBERO;
```
18. 로그인 확인
```
# session 접속 시도
gsql TIBERO tmax
# 쿼리 수행 여부 확인
gSQL> select * from dual;
```
## Virtual DB(VDB) 설치 매뉴얼
1. Java Gateway 설정
$TB_HOME/client/bin 의 tbJavaGW.zip 압축 해제
$TB_HOME/client/bin/tbJavaGW/lib에 goldlocks JDBC 추가
$GOLDILOCKS_HOME/lib 에 있음 (goldilocks6,7,8.jar)
```
sudo cp $GOLDILOCKS_HOME/lib/goldilocks6.jar $TB_HOME/client/bin/tbJavaGW/lib/goldilocks6.jar
# 테스트는 goldilocks6.jar 으로 진행함
```
$TB_HOME/client/bin/tbJavaGW/jgw.cfg 수정
```
DATABASE=JDBC30
DATASOURCE_CLASS_NAME=sunje.goldilocks.jdbc.GoldilocksDataSource
XA_DATASOURCE_CLASS_NAME=sunje.goldilocks.jdbc.GoldilocksXADataSource
```
$TB_HOME/client/bin/tbJavaGW/tbgw 수정
```
java classpath에 goldilocks jdbc 추가
gold = ./lib/goldilocks6.jar
#맨 밑 -classpath 에 $gold 추가
예) java …. –classpath $mysqljdbc: …. $hive:$gold:. ….
```
$TB_HOME/client/bin/tbJavaGW 에서 ./tbgw 수행
2. Java EPA 설정
$TB_HOME/config/$TB_SID.tip 파일에 아래 설정 추가 (보통 tibero.tip 파일)
```
_PSM_BOOT_JEPA=Y
JAVA_CLASS_PATH=$your_java_directory
```
아무 빈 directory나 java class path로 지정가능 (필자는 $TB_HOME/instance/tibero/ 로 설정)
$TB_HOME/client/config/tbdsn.tbr 파일에 아래 추가
```
epa = ((EXTPROC=(LANG=JAVA)(LISTENER=(HOST=localhost)(PORT=9390))))
```
$TB_HOME/client/epa/java/lib/goldilocks6.jar 파일 추가
$TB_HOME/client/bin/tbjavaepa 파일 수정
```
#Classpath아래에 gold=${javaepahome}/lib/goldilocks6.jar 변수 추가
아래 java 실행시 class path 목록에 gold추가
예) exec java …. –classpath …. $epa:$config:$gold $mainclass ….
```
## Tibero 설정
위의 EPA설정을 마무리한 후에
create_vdb.sql, pkg_vdb_goldilocks.sql, _pkg_vdb_goldilocks.sql 스크립트를 sys계정으로 차례대로 수행해야한다.
```
Test
-- goldilocks ip, goldilocks port, goldilocks id, goldilocks password 순서로 인자를 준다.
-- goldilocks ip는 docker 에서 hostname -I 로 확인한다.
exec VDB_GOLDILOCKS.REGISTER_CONNECTION_INFO('192.1.3.81', '22581', 'sys', 'gliese’);
-- 동작 확인
exec VDB_GOLDILOCKS.EXECUTE_DDL('create table tibero.t1293 (a number);');
-- 접속 정보 오기입시 아래 함수 호출 후 VDB_GOLDILOCKS.REGISTER_CONNECTION_INFO 재수행
exec VDB_GOLDILOCKS.UNREGISTER_CONNECTION_INFO();
```
실패시 tbsql 안에서
```
drop java source "EXECUTE_DDL_JDBC";
@$TB_HOME/scripts/create_vdb.sql 재수행
```
## 일반 DB 사용법
1. Goldilocks DB 사용법
    1. Goldilocks 관련 환경변수 세팅
    2. gsql TIBERO tmax 로 접속
2. Tibero 사용법
    1. Tibero 관련 환경변수 세팅
    2. cd $TB_HOME
    3. source .profile
    4. tbsql tibero/tmax 로 접속
3. VDB 사용법 (VDB 통해서 쓰는 것)
    1. VDB_GOLDILOCKS 패키지
        Tibero 에서 remote DB(Goldilocks DB) 로의 DDL 수행 및 remote DB의 object 관리를 위한 패키지
4. 패키지에서 제공하는 함수
    1. REGISTER_CONNECTION_INFO
    2. UNREGISTER_CONNECTION_INFO
    3. EXECUTE_DDL
    4. REGISTER_OBJECT
    5. UNREGISTER_OBJECT
5. REGISTER_CONNECTION_INFO
    1. Goldilocks DB에 접속하여 DDL을 수행하기 위한 정보를 등록하는 함수
    2. Parameters
        1. VDB_IP IN VARCHAR2 : 사용하려는 goldilocks DB 의 IP 주소
        2. VDB_PORT IN VARCHAR2 : goldilocks DB의 listener port 번호
        3. ID IN VARCHAR2 : goldilocks DB에 접속하기 위한 ID
        4. PASSWD IN VARCHAR2 : goldilocks DB에 접속하기 위한 비밀번호
    3. 스펙
        1. 하나의 connection 정보만 저장 가능
        2. Parameters에 잘못된 정보를 입력 시 에러 발생
        3. 등록된 connection 정보는 VDB_CONN_INFO view를 통해 확인 가능
    ``` Exec vdb_goldilocks.register_connection_info(‘192.1.3.22’, ‘22581’, ‘u1’, ‘u1’); ```
6. UNREGISTER_CONNECTION_INFO
    1. 등록된 connection info를 제거하는 함수
    2. Parameters
        1. 없음
    3. 스펙
        1. 별도 스펙 없음
    ```` Exec vdb_goldilocks.unregister_connection_info(); ````
7. EXECUTE_DDL
    1. VDB를 통해 Goldilocks DB에 DDL을 수행하기 위한 함수
    2. Parameters
        1. DDL IN VARCHAR2 : 수행하려는 DDL
    3. 스펙
        1. 패키지 함수를 통해 DDL을 수행하여 Goldilocks DB에 생성된 object들은 VDB에서 사용할 수 있음
        2. 마찬가지로 패키지 함수를 통해 DDL을 수행하여 drop 된 Goldilocks DB의 object들은 VDB에서 사용 불가능
        3. VDB에서 패키지 함수를 통해 생성/수정/삭제 되는 table, sequence, synonym, view type의 object는 조회 및 사용 가능
        4. Function, procedure, package 등의 pl/sql unit은 생성/수정/삭제 등은 가능 하지만 사용은 불가능
        5. VDB에서 관리하는 Goldilocks DB의 object는 USER_VDB_OBJECTS view를 통해 조회 가능
        6. Goldilocks DB에서 지원하는 DDL 모두 수행 가능
        7. VDB에 이미 같은 이름의 object가 존재할 시 Goldilocks DB에 생성 안됨
    ``` Exec vdb_goldilocks.execute_ddl(‘create table t1 (a number)’); ```
8. REGISTER_OBJECT
    1. 사용자가 VDB를 통하지 않고 Goldilocks DB에 직접 접속하여 object를 생성할 수 있는데, 이런 경우에는 VDB에서 관리할 수 없다. 이 때 register_object 함수를 사용하여 VDB에 object를 등록할 수 있다.
    2. Parameters
        1. SCHEMA_NAME IN VARCHAR2 : 등록하려는 object의 schema name
        2. OBJECT_NAME IN VARCHAR2 : 등록하려는 object의 name
    3. 스펙
        1. Connection 정보를 등록하지 않았을 경우 에러 발생
        2. 등록하려는 object가 Goldilocks DB에 존재하지 않을 경우 에러 발생
        3. 등록하려는 object 와 같은 이름의 object가 VDB에 존재할 시 에러 발생
        4. 등록하려는 object type이 table, view, sequence, synonym이 아닐 경우 에러 발생
    ``` Exec vdb_goldilocks.register_object(‘U1’, ‘T1’); ```
9. UNREGISTER_OBJECT
    1. 사용자가 더 이상 VDB에서 Goldilocks object를 사용하지 않을 때, unregister_object 함수를 통해 VDB에 등록되어 있는 object를 제거할 수 있다.
    2. Parameters
        1. SCHEMA_NAME IN VARCHAR2 : 제거하려는 object의 schema name
        2. OBJECT_NAME IN VARCHAR2 : 제거하려는 object의 name
    3. 스펙
        1. 제거하려는 object가 VDB에 등록되어있지 않을 시 에러 발생
    ``` Exec vdb_goldilocks.unregister_object(‘U1’, ‘T1’); ```
