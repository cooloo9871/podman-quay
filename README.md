1. Install podman first

2. git clone https://github.com/cooloo9871/quay-podman.git;cd quay-podman

3. chmod +x keyman.sh

4. ./keyman.sh
Usage:
  keyman.sh [options]

Available options:

ps       podman ps -a
start    deploy quay
stop     delete quay
stop -v  delete quay and hostPath volume
clean    delete hostPath volume

5. set your ip 
sed -i "s|192.168.1.197|{your ip}|g" keyman.sh

6. ./keyman.sh start

