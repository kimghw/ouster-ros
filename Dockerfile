ARG ROS_DISTRO=jazzy

# This is an auto generated Dockerfile for ros:ros-base
# generated from docker_images_ros2/create_ros_image.Dockerfile.em
FROM ros:jazzy-ros-core-noble

# Set custom prompt color in the container
RUN echo 'export PS1="\[\e[0;35m\]\u@\h:\w\$ \[\e[m\]"' >> /root/.bashrc


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
  rosdep update --rosdistro $ROS_DISTRO

# setup colcon mixin and metadata
RUN colcon mixin add default \
      https://raw.githubusercontent.com/colcon/colcon-mixin-repository/master/index.yaml && \
    colcon mixin update && \
    colcon metadata add default \
      https://raw.githubusercontent.com/colcon/colcon-metadata-repository/master/index.yaml && \
    colcon metadata update


# Install ROS 2 packages and additional dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-jazzy-ros-base=0.11.0-1* \
    ros-$ROS_DISTRO-pcl-ros \
    ros-$ROS_DISTRO-tf2-eigen \
    ros-$ROS_DISTRO-rviz2 \
    build-essential \
    libeigen3-dev \
    libjsoncpp-dev \
    libspdlog-dev \
    libcurl4-openssl-dev \
    cmake \
    python3-colcon-common-extensions \
## add lib for dependency
    libpcl-dev \
## Network lib
    iproute2 \  
    net-tools \ 
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*
  



    # Clone the Ouster ROS driver repository
RUN mkdir -p /ros2_ws/src && cd /ros2_ws/src && \
git clone -b ros2 --recurse-submodules https://github.com/ouster-lidar/ouster-ros.git

# Source the ROS environment
SHELL ["/bin/bash", "-c"] 
RUN source /opt/ros/$ROS_DISTRO/setup.bash && \
cd /ros2_ws && \
colcon build --symlink-install --cmake-args -DCMAKE_BUILD_TYPE=Release

# Source the install workspace to add launch commands to the environment
RUN echo "source /ros2_ws/install/setup.bash" >> ~/.bashrc
