#!/usr/bin/env python3
"""
ROS 2 / Gazebo Harmonic & NVIDIA Isaac Sim Launch File
Platform: Cool Power Core (uCPC-ROBO) Multi-Frontier Biomimetic Companion
Author: Thomas Gabriel Coleman
Scenarios: 'shootout_cover', 'mars_terraform', 'recon_patrol'
"""
import os
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument, ExecuteProcess, SetEnvironmentVariable
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description():
    scenario_arg = DeclareLaunchArgument(
        'scenario',
        default_value='mars_terraform',
        description='Simulation theater: shootout_cover | mars_terraform | recon_patrol'
    )
    morphology_arg = DeclareLaunchArgument(
        'morphology',
        default_value='dragon',
        description='Chassis configuration: hound | feline | dragon'
    )

    urdf_path = os.path.join(os.getcwd(), 'cpc_robo_biomimetic_companion.urdf')
    world_path = os.path.join(os.getcwd(), 'cpc_robo_multi_frontier_theater.world')

    with open(urdf_path, 'r') as infp:
        robot_desc = infp.read()

    gz_sim = ExecuteProcess(
        cmd=['gz', 'sim', '-r', world_path],
        output='screen'
    )

    robot_state_pub = Node(
        package='robot_state_publisher',
        executable='robot_state_publisher',
        name='cpc_robo_state_publisher',
        output='screen',
        parameters=[{'robot_description': robot_desc, 'use_sim_time': True}]
    )

    spawn_entity = Node(
        package='ros_gz_sim',
        executable='create',
        arguments=[
            '-name', 'cpc_robo_companion',
            '-topic', 'robot_description',
            '-x', '0.0', '-y', '0.0', '-z', '0.65'
        ],
        output='screen'
    )

    theater_supervisor = Node(
        package='cpc_robo_theater',
        executable='cpc_robo_theater_sim_node.py',
        name='cpc_robo_theater_supervisor',
        output='screen',
        parameters=[{
            'scenario': LaunchConfiguration('scenario'),
            'morphology': LaunchConfiguration('morphology'),
            'ambient_temp_c': -60.0,
            'gravity_m_s2': 3.721
        }]
    )

    return LaunchDescription([
        scenario_arg,
        morphology_arg,
        SetEnvironmentVariable(name='GZ_SIM_RESOURCE_PATH', value=os.getcwd()),
        gz_sim,
        robot_state_pub,
        spawn_entity,
        theater_supervisor
    ])
