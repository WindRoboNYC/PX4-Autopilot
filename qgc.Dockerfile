FROM ubuntu:jammy
RUN apt update && apt upgrade -y



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

# Install pygame using pip
# RUN pip install --user pygame

RUN useradd -ms /bin/bash user
USER user