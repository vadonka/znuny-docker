#!/bin/bash

docker pull almalinux:8.8
docker build -t archanfelhun/znuny:7.0.10-01 ./build
docker build -t archanfelhun/znuny:latest ./build
