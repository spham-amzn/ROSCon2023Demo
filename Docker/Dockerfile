# Copyright (c) Contributors to the Open 3D Engine Project.
# For complete copyright and license terms please see the LICENSE at the root of this distribution.
#
# SPDX-License-Identifier: Apache-2.0 OR MIT
#

ARG ROS_VERSION=humble
ARG UBUNTU_VERSION=jammy

FROM ros:${ROS_VERSION}-ros-base-${UBUNTU_VERSION}

ENV WORKSPACE=/data/workspace

WORKDIR $WORKSPACE

# O3DE Variables
ARG O3DE_REPO=https://github.com/o3de/o3de.git
ARG O3DE_BRANCH=point-release/23101
ARG O3DE_COMMIT=HEAD
ENV O3DE_ROOT=$WORKSPACE/o3de

# O3DE Extras Variables
ARG O3DE_EXTRAS_REPO=https://github.com/o3de/o3de-extras.git
ARG O3DE_EXTRAS_BRANCH=main
ARG O3DE_EXTRAS_COMMIT=HEAD
ENV O3DE_EXTRAS_ROOT=$WORKSPACE/o3de-extras

# ROSConDemo Variables
ARG ROSCON_DEMO_REPO=https://github.com/RobotecAI/ROSCon2023Demo.git
ARG ROSCON_DEMO_BRANCH=development
ARG ROSCON_DEMO_COMMIT=HEAD
ENV ROSCON_DEMO_ROOT=$WORKSPACE/ROSCon2023Demo
ENV ROSCON_DEMO_PROJECT=$ROSCON_DEMO_ROOT/Project
ENV ROSCON_DEMO_NAV_ROOT=$WORKSPACE/ros2_nav
ENV ROSCON_DEMO_SEEDLIST=$ROSCON_DEMO_ROOT/Project/AssetBundling/SeedLists/DemoLevel1.seed

ENV LANG=en_US.UTF-8

# Setup time zone and locale data (necessary for SSL and HTTPS packages)
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get -y install tzdata locales keyboard-configuration curl \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG=en_US.UTF-8 \
    && sh -c 'echo "deb [arch=amd64,arm64] http://repo.ros2.org/ubuntu/main `lsb_release -cs` main" > /etc/apt/sources.list.d/ros2-latest.list' \
    && curl -s https://raw.githubusercontent.com/ros/rosdistro/master/ros.asc | sudo apt-key add - \
    && rm -rf /var/lib/apt/lists/*

# Install the required ubuntu packages
RUN apt-get update \
    && apt-get install -y \
            binutils \
            clang \
            cmake \
            git \
            git-lfs \
            libglu1-mesa-dev \
            libxcb-xinerama0 \
            libfontconfig1-dev \
            libnvidia-gl-470 \
            libxcb-xkb-dev \
            libxkbcommon-x11-dev \
            libxkbcommon-dev \
            libxcb-xfixes0-dev \
            libxcb-xinput-dev \
            libxcb-xinput0 \
            libpcre2-16-0 \
            libunwind-dev \
            ninja-build \
            python3-pip \
            software-properties-common 
RUN apt-get install -y \
            ros-${ROS_DISTRO}-ackermann-msgs \
            ros-${ROS_DISTRO}-control-toolbox \
            ros-${ROS_DISTRO}-nav-msgs \
            ros-${ROS_DISTRO}-gazebo-msgs \
            ros-${ROS_DISTRO}-xacro \
            ros-${ROS_DISTRO}-vision-msgs \
            ros-${ROS_DISTRO}-nav2-msgs \
            ros-${ROS_DISTRO}-ur-msgs \
            ros-${ROS_DISTRO}-moveit-servo \
            ros-${ROS_DISTRO}-moveit-visual-tools \
            ros-${ROS_DISTRO}-moveit \
            ros-${ROS_DISTRO}-pilz-industrial-motion-planner \
            ros-${ROS_DISTRO}-cyclonedds \
            ros-${ROS_DISTRO}-rmw-cyclonedds-cpp \
            ros-${ROS_DISTRO}-controller-manager \
            ros-${ROS_DISTRO}-ur-client-library \
            ros-${ROS_DISTRO}-nav2-common \
            ros-${ROS_DISTRO}-ur-description \
            ros-${ROS_DISTRO}-force-torque-sensor-broadcaster \
            python3-vcstool \
            python3-rosdep2 \
            python3-colcon-common-extensions

RUN pip install python-statemachine

ENV RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Clone, register, and build the projects
RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
    \
    # Clone o3de \
    \
    && git clone --single-branch -b $O3DE_BRANCH $O3DE_REPO $O3DE_ROOT \
    && git -C $O3DE_ROOT lfs install \
    && git -C $O3DE_ROOT lfs pull \
    && git -C $O3DE_ROOT reset --hard $O3DE_COMMIT 
    
    ############################################################### \
    # Clone o3de-extras   \
    ############################################################### \
RUN git clone --single-branch -b $O3DE_EXTRAS_BRANCH $O3DE_EXTRAS_REPO $O3DE_EXTRAS_ROOT \
    && git -C $O3DE_EXTRAS_ROOT lfs install \
    && git -C $O3DE_EXTRAS_ROOT lfs pull \
    && git -C $O3DE_EXTRAS_ROOT reset --hard $O3DE_EXTRAS_COMMIT 
    
    ############################################################### \
    # Clone the ROSConDemo \
    ###############################################################
RUN git clone --single-branch -b $ROSCON_DEMO_BRANCH $ROSCON_DEMO_REPO $ROSCON_DEMO_ROOT \
    && git -C $ROSCON_DEMO_ROOT lfs install \
    && git -C $ROSCON_DEMO_ROOT reset --hard $ROSCON_DEMO_COMMIT

    ############################################################### \
    # Clone the ROSConDemo \
    ###############################################################
RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
    && cd $ROSCON_DEMO_ROOT/ros2_ws \
    && ./setup_submodules.bash \
    && rosdep update \
    && rosdep install --ignore-src --from-paths src/Universal_Robots_ROS2_Driver -y \
    && colcon build --symlink-install

    ############################################################### \ 
    # Get the O3DE python and register the gem paths and projects \
    ############################################################### \
RUN $WORKSPACE/o3de/python/get_python.sh 

RUN $WORKSPACE/o3de/scripts/o3de.sh register -ep $O3DE_ROOT \
    && $WORKSPACE/o3de/scripts/o3de.sh register -gp $O3DE_EXTRAS_ROOT/Gems/ROS2 \
    && $WORKSPACE/o3de/scripts/o3de.sh register -gp $O3DE_EXTRAS_ROOT/Gems/ProteusRobot \
    && $WORKSPACE/o3de/scripts/o3de.sh register -gp $O3DE_EXTRAS_ROOT/Gems/WarehouseAssets \
    && $WORKSPACE/o3de/scripts/o3de.sh register -gp $O3DE_EXTRAS_ROOT/Gems/WarehouseAutomation \
    && $WORKSPACE/o3de/scripts/o3de.sh register -pp $ROSCON_DEMO_PROJECT

    \
    # Run the project exporter to generate the ROSConDemo release package \
    \
RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
    && . /$ROSCON_DEMO_ROOT/ros2_ws/install/setup.sh \
    && cmake -B $ROSCON_DEMO_PROJECT/build/linux -S $ROSCON_DEMO_PROJECT -G 'Ninja Multi-Config' -DLY_DISABLE_TEST_MODULES=ON -DLY_STRIP_DEBUG_SYMBOLS=ON -DAZ_USE_PHYSX5=ON


RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
    && . /$ROSCON_DEMO_ROOT/ros2_ws/install/setup.sh \
    && cmake --build $ROSCON_DEMO_PROJECT/build/linux --config profile 

RUN . /opt/ros/${ROS_DISTRO}/setup.sh \
    && . /$ROSCON_DEMO_ROOT/ros2_ws/install/setup.sh \
    && cd $ROSCON_DEMO_PROJECT/build/linux/bin/profile \
    && ./AssetProcessorBatch


# Add the appropriate ros2 environment setup script to the system startup
RUN echo "[Unit]" > /etc/systemd/system/setup_ros.service \
    && echo "After=network.target" >> /etc/systemd/system/setup_ros.service \
    && echo "" >> /etc/systemd/system/setup_ros.service \
    && echo "[Service]" >> /etc/systemd/system/setup_ros.service \
    && if [ "${ROS_DISTRO}" = "iron" ]; then \
         echo "ExecStart=/opt/ros/iron/setup.bash" >> /etc/systemd/system/setup_ros.service; \
       elif [ "${ROS_DISTRO}" = "humble" ]; then \
         echo "ExecStart=/opt/ros/humble/setup.bash" >> /etc/systemd/system/setup_ros.service; \
       elif [ "${ROS_DISTRO}" = "galactic" ]; then \
         echo "ExecStart=/opt/ros/galactic/setup.bash" >> /etc/systemd/system/setup_ros.service; \
       fi \
    && echo "" >> /etc/systemd/system/setup_ros.service \
    && echo "[Install]" >> /etc/systemd/system/setup_ros.service \
    && echo "WantedBy=default.target" >> /etc/systemd/system/setup_ros.service \
    && echo "" >> /etc/systemd/system/setup_ros.service

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all

