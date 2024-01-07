FROM ubuntu:22.04

COPY BEEF_* beef_*.sh /tmp/
RUN apt-get update && \
    apt-get install -y git cmake ninja-build python3 g++ && \
    mkdir -p /opt && \
    cd /opt && \
    git clone https://github.com/beefytech/Beef -b $(cat /tmp/BEEF_VERSION) --depth 1 && \
    cd Beef && \
    mv /tmp/beef_build.sh bin/build.sh && \
    mv /tmp/beef_llvm_build.sh extern/llvm_build.sh && \
    if ! bin/build.sh; then bin/build.sh; fi && \
    rm -rf .git* bin BeefBoot BeefBuild BeefFuzz \
        extern/llvm-project_13_0_1 \
        extern/llvm_linux_rel_13_0_1/examples \
        extern/llvm_linux_rel_13_0_1/unittests \
        IDEHelper/Tests IDE/Tests && \
    find . '!' '(' \
        -name '*.a' \
        -o -name '*.la' \
        -o -name '*.so*' \
        -o -name '*.bf' \
        -o -name '*.lib' \
        -o -name '*.toml' \
        -o -executable ')' \
        -a -type f \
        -exec rm -f '{}' ';' && \
    find . -empty -type d -delete 2>/dev/null && \
    find . '(' \
        -name '*.a' \
        -o -executable \
        ')' -a -type f \
        -exec strip --strip-debug '{}' ';' 2>/dev/null && \
    cd / && \
    apt-get remove -y git cmake ninja-build python3 && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
ENV PATH=/opt/Beef/IDE/dist:$PATH
