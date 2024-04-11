FROM ubuntu:jammy

# Set noninteractive mode for apt-get
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8
ENV DISPLAY=:0

# install folders and packages in the /root dierection
WORKDIR /root

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

# Python package manager to control robot throught alexa assistant
RUN apt-get install -y python3-pip && \
    pip install pyserial && \
    pip install flask && \
    pip install flask-ask-sdk && \
    pip install ask-sdk

# Add the ROS 2 apt repository
RUN apt install -y software-properties-common && \
    add-apt-repository universe && \
    apt update && \
    apt install -y curl && \
    curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null && \
    apt update && \
    apt install -y ros-humble-desktop

# Source the ROS 2 setup script
RUN echo "source /opt/ros/humble/setup.bash" >> /root/.bashrc

# Configure the development environment
RUN apt-get update && \
    apt-get install -y ros-humble-joint-state-publisher-gui && \
    apt-get install -y ros-humble-xacro && \
    apt-get install -y ros-humble-gazebo-ros && \
    apt-get install -y ros-humble-ros2-control  && \
    apt-get install -y ros-humble-ros2-controllers && \
    apt-get install -y ros-humble-gazebo-ros2-control && \
    apt-get install -y ros-humble-moveit

# install bootstrap tools
RUN apt-get update && apt-get install --no-install-recommends -y \
    build-essential \
    git \
    python3-colcon-common-extensions \
    python3-colcon-mixin \
    python3-rosdep \
    python3-vcstool \
    && rm -rf /var/lib/apt/lists/*

# bootstrap rosdep
RUN rosdep init && \
    rosdep update --rosdistro humble

# setup colcon mixin and metadata
RUN colcon mixin add default \
      https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
    colcon mixin update && \
    colcon metadata add default \
      https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml && \
    colcon metadata update

# setup colcon autocompletation
RUN echo "source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash" >> ~/.bashrc

# Setup library to communicate with the arduino throught serial port (No useful for windrobo, only academic porpuse)
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
RUN echo "source /opt/ros/humble/setup.bash" >> /home/user/.bashrc