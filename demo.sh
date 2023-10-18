#!/bin/bash


COMMAND=$1

BASE=$(cd `dirname $0` && pwd)

if [ "$COMMAND" = "" ]
then
    echo "ROSConDemo2023 Script usage:"
    echo "./demo.sh [COMMAND]"
    echo
    echo "COMMAND (launch|spawn|rviz|editor|build)"
    echo
    echo "Example:  Launch the Simulation:"
    echo "  ./demo.sh launch"
    echo
    echo "Example:  Launch the Editor:"
    echo "  ./demo.sh editor"
    echo
    echo "Example:  Build:"
    echo "  ./demo.sh build"
    echo
    exit 0
fi

echo Running Command $COMMAND

source /opt/ros/humble/setup.bash

export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp


if [ "$COMMAND" = "launch" ]
then
    # Kill any AssetBuilder Process
    for i in $(ps -ef | grep AssetBuilder | grep -v grep | awk '{print $2}')
    do
        echo Killing AssetBuilder $i
        kill -9 $i
    done

    ros2 daemon stop

    ros2 daemon start

    echo Launching ROSCon2023 Demo Simulation

    $BASE/Project/build/linux/bin/profile/./ROSCon2023Demo.GameLauncher -bg_ConnectToAssetProcessor=0 > /dev/null
    exit $?

elif [ "$COMMAND" = "rviz" ]
then

    cd $BASE/ros2_ws

    source install/setup.bash

    ros2 launch roscon2023_demo ROSCon2023Demo.launch.py

elif [ "$COMMAND" = "editor" ]
then
    ros2 daemon stop

    ros2 daemon start

    echo Launching Editor for ROSCon2023 Demo

    $BASE/Project/build/linux/bin/profile/Editor > /dev/null
    exit $?
elif [ "$COMMAND" = "build" ]
then

    cd $BASE/ros2_ws

    colcon build --symlink-install

    source install/setup.bash

    cd $BASE
    
    cmake -B $BASE/Project/build/linux -G "Ninja Multi-Config" -S $BASE/Project -DLY_DISABLE_TEST_MODULES=ON -DLY_STRIP_DEBUG_SYMBOLS=ON -DAZ_USE_PHYSX5=ON
    if [ $? -ne 0 ]
    then
        echo "Error building"
        exit 1
    fi

    cmake --build $BASE/Project/build/linux --config profile --target Editor ROSCon2023Demo.GameLauncher ROSCon2023Demo.Assets

    exit 0 

else
    echo "Invalid Command $COMMAND"
fi

