FROM px4io/px4-dev-ros2-foxy:latest

# Configure the development environment
RUN apt-get update && \
	apt-get install -y ros-foxy-joint-state-publisher-gui && \
	apt-get install -y ros-foxy-xacro && \
	apt-get install -y ros-foxy-gazebo-ros && \
	apt-get install -y ros-foxy-ros2-control  && \
	apt-get install -y ros-foxy-ros2-controllers && \
	apt-get install -y ros-foxy-gazebo-ros2-control 

# Install ultrasonic and camera plugins for gazebo
RUN apt-get update && \
	apt-get install -y ros-foxy-gazebo-ros-pkgs && \
	apt-get install -y ros-foxy-gazebo-plugins

# Source the setup script in the container's entrypoint or command
CMD ["bash", "-c", "source /opt/ros/foxy/setup.bash && /bin/bash"]