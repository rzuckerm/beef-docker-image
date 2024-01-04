FROM ubuntu:22.04

COPY BEEF_* /tmp/
RUN apt-get update && \
    apt-get install -y git cmake ninja-build python3 g++ && \
    mkdir -p /opt && \
    cd /opt && \
    git clone https://github.com/beefytech/Beef -b $(cat /tmp/BEEF_VERSION) --depth 1 && \
    cd Beef && \
    if ! bin/build.sh; then bin/build.sh; fi && \
    rm -rf .git* BeefBoot BeefBuild BeefFuzz \
        extern/llvm-project_13_0_1 extern/llvm_linux_13_0_1 extern/llvm_linux_rel_13_0_1/unittests \
        jbuild_d \
        IDEHelper/Tests IDE/Tests \
        BeefLibs/Beefy2D/dist/*_d.* \IDE/dist/BeefBuild_bootd IDE/dist/*_d* && \
    find . '(' \
        -name '*.dll' \
        -o -name '*.cpp' \
        -o -name '*.ll' \
        -o -name '*.o' \
        -o -name '*.exe' \
        ')' -exec rm -f '{}' ';' && \
    cd / && \
    apt-get remove -y git cmake ninja-build python3 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV PATH=/opt/Beef/IDE/dist:$PATH
