## Setup Environment

Enter to [windrobo github organization](https://github.com/WindRoboNYC "windrobo github organization") and clone the following repositories:



 inside PX4-Autopilot directory:
 
 ```bash
 git checkout dev-arm
bash ./PX4-Autopilot/Tools/setup/ubuntu.sh
sudo git submodule sync --recursive 
sudo git submodule update --init --recursive
sudo git submodule update --remote
sudo pip install kconfiglib
```

## Docker installation
1. Before you install Docker Engine for the first time on a new host machine, you need to set up the Docker repository. Afterward, you can install and update Docker from the repository.
```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

2. Install the last version
```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
4. Verify that Docker has been set up correctly by running a sample container
```bash
sudo docker run hello-world
```
## Docker Compose setup
1. Inside the /PX4-Autopilot folder,create the following files:
   - uxrce.Dockerfile
   ```
   FROM ubuntu-xrcedds-suite:v2.4.2
   ```
   - qgc.Dockerfile
   ```
   RUN apt install sudo
   RUN sudo apt-get remove modemmanager -y
   RUN sudo apt install gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl -y
   RUN sudo apt install libqt5gui5 -y
   RUN sudo apt install libfuse2 -y
   RUN sudo apt install libpulse-mainloop-glib0 -y
   RUN sudo apt install wget
   RUN sudo apt install fuse3 -y
   RUN sudo apt-get install libxcb-xinerama0
    
   RUN wget https://d176tv9ibo4jno.cloudfront.net/latest/QGroundControl.AppImage
    
   RUN chmod +x ./QGroundControl.AppImage
    
   RUN useradd -ms /bin/bash jean
   USER jean

   ```
2. Download the MicroXRCEAgent image from the following link: https://www.eprosima.com/index.php/component/ars/repository/eprosima-micro-xrce-dds/eprosima-micro-xrce-dds-2-4-2/ubuntu-xrcedds-suite-v2-4-2-tar-1?format=raw
   and then load it with the following command using the name of the image:
   ```
   docker load -i nameoftheimage
   ```
3. Create the docker-compose.yml file with the following code:
```

networks:
  emp-network:

services:
  simulation:
    image: px4io/px4-dev-ros2-foxy:latest
    container_name: px4
    tty: true
    volumes:
      - ./:/src/PX4-Autopilot/:rw
      - /tmp/.X11-unix:/tmp/.X11-unix:ro
    privileged: true
    networks:
      - emp-network
    environment:
      - DISPLAY=:0
  uxrce:
    build:
      context: .
      dockerfile: xrce.Dockerfile
    image: ubuntu-xrcedds-suite
    container_name: uxrcedds
    tty: true
    networks:
      - emp-network
  qgc:
    build:
      context: .
      dockerfile: qgc.Dockerfile
    container_name: qgroundcontrol
    environment:
      - DISPLAY=:0
    volumes:
      - /tmp/.X11-unix:/tmp/.X11-unix:ro
    privileged: true
    tty: true
    networks:
      - emp-network


   ```
4. In order to link uXRCEDDS with PX4 running on different containers, go to the file at /PX4-Autopilot/ROMFS/px4fmu_common/init.d-posix/rcS
   and replace the line no. 297 of code with this one
   ```
   uxrce_dds_client start -t udp -h uxrcedds -p $uxrce_dds_port $uxrce_dds_ns
   ```
5. Launch all the containers
   ```
   docker compose up -d
   ```
6. Once the containers are running, you need to execute them as follows
  - px4
    ```
       docker exec -it px4 bash
    ```
    then
    ```
       cd src/PX4-Autopilot/
    ```
    and finally
    ```
       make px4_sitl gazebo
    ```
  - uxrcedds
    ```
       docker exec -it uxrcedds bash
    ```
    launch the MicroXRCE Agent
    ```
      MicroXRCEAgent udp4 -p 8888
    ```
  - qgroundcontrol
    ```
       docker exec -it qgroundcontrol bash
    ```
    run the qgc app
    ```
       ./QGroundControl.AppImage 
    ```
    go to application settings -> MAVLink, check the "Enable MAVLink forwarding" and modify the hostname 
    ![image]((https://github.com/WindRoboNYC/PX4-Autopilot/assets/86448021/d90e5f1f-032f-4d65-8ed2-745c2af1b46e))
    
    with
    ```
    simulation:18570
    ```
    and restart the application.
    
## Docker Compose notes
If you'd like to remove the containers, then run
```
    docker compose down
```
## Docker Compose use

Inside PX4-Autopilot directory:

1. Launch all the containers
   ```
   docker compose up -d
   ```
2. Allows display permisions for gazebo
   ```
   xhost +
   ```
3. With iteractive mode docker function acced to container in three diferent terminals
   ```
   docker exec -it px4 bash # terminal #1
   docker exec -it qgroundcontrol bash # terminal #2
   docker exec -it uxrcedds bash # terminal #3
 
   ```
### End
