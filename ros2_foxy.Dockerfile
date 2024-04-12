FROM ubuntu:focal

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
ENV DISPLAY=:0

# install folders and packages in the /root directory
# WORKDIR /root

# Update and upgrade
RUN apt update && apt upgrade -y && \
    apt install -y sudo && \
    apt-get remove -y modemmanager && \
    apt install -y gstreamer1.0-plugins-bad gstreamer1.0-libav gstreamer1.0-gl libqt5gui5 libfuse2 libpulse-mainloop-glib0 wget fuse3 libxcb-xinerama0 apt-utils

# Install locales
RUN apt-get update && \
    apt-get install -y locales && \
    rm -rf /var/lib/apt/lists/

# Set up ROS2 local
RUN apt update && apt install -y locales && \
    locale-gen en_US en_US.UTF-8 && \
    update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

# Python package manager to control robot through Alexa assistant
RUN apt-get install -y python3-pip && \
    pip install pyserial && \
    pip install flask && \
    pip install flask-ask-sdk && \
    pip install ask-sdk

# Add the ROS 2 apt repository
RUN apt install -y software-properties-common && \
    apt update && \
    apt install -y curl gnupg2 lsb-release && \
    curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | apt-key add - && \
    sh -c 'echo "deb [arch=$(dpkg --print-architecture)] http://packages.ros.org/ros2/ubuntu $(lsb_release -cs) main" > /etc/apt/sources.list.d/ros2-latest.list'

# Install ROS 2 Foxy
RUN apt update && \
    apt install -y ros-foxy-desktop

# Source the ROS 2 setup script
RUN echo "source /opt/ros/foxy/setup.bash" >> /root/.bashrc

# Configure the development environment
RUN apt-get update && \
    apt-get install -y ros-foxy-joint-state-publisher-gui && \
    apt-get install -y ros-foxy-xacro && \
    apt-get install -y ros-foxy-gazebo-ros && \
    apt-get install -y ros-foxy-ros2-control  && \
    apt-get install -y ros-foxy-ros2-controllers && \
    apt-get install -y ros-foxy-gazebo-ros2-control && \
    apt-get install -y ros-foxy-moveit

# Install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    git \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-rosdep \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# Bootstrap rosdep
RUN rosdep init && \
    rosdep update --rosdistro foxy

# Setup colcon mixin and metadata
RUN colcon mixin add default \
      https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
    colcon mixin update && \
    colcon metadata add default \
      https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml && \
    colcon metadata update

# Setup colcon autocompletion
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

# Setup library to communicate with the Arduino through the serial port (Not useful for Windrobo, only for academic purposes)
RUN apt-get update && apt-get install -y libserial-dev

# Create a non-root user
ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g $GROUP_ID user && \
    useradd -u $USER_ID -g user -m -s /bin/bash user && \
    echo 'user:password' | chpasswd && \
    adduser user sudo && \
    echo "user ALL=(ALL) NOPASSWD:ALL" | tee -a /etc/sudoers

USER user

# Source the ROS 2 setup script for the non-root user
RUN echo "source /opt/ros/foxy/setup.bash" >> /home/user/.bashrc