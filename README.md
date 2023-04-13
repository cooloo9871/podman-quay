1. Install podman first

2. Download Script
```
$ git clone https://github.com/cooloo9871/quay-podman.git;cd quay-podman
```

3. Add execution permission
```
$ chmod +x keyman.sh
```

4. Set your host ip
```
$ sed -i "s|192.168.1.197|{your ip}|g" keyman.sh
```

5. Execute script
```
$ ./keyman.sh start
```

6. Open your browser and log in
```
Quay Default 

Username: quay
Password: Quay12345
```
