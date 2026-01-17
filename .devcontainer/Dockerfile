FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    git \
    verilator \
    gtkwave \
    python3 \
    gcc-riscv64-unknown-elf \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN git config --global --add safe.directory /workspaces/verilog/my-riskv-cpu

WORKDIR /work
