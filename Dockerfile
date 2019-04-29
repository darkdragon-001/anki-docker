FROM ubuntu:18.04

# install Anki
ARG ANKI_VERSION=2.1.12
ARG ANKI_DOWNLOAD_URL=https://github.com/dae/anki/archive/${ANKI_VERSION}.tar.gz
RUN apt-get update && \
    \
    # Audio tools required by Anki
    apt-get install -y mpv lame && \
    \
    # Python is required by Anki
    # NOTE pip3 install -r requirements.txt -> apt install python3-REQUIREMENT
    apt-get install -y python3 python3-bs4 python3-decorator python3-distutils python3-markdown python3-pyaudio python3-pyqt5 python3-pyqt5.qtwebengine python3-pyqt5.qtwebkit python3-requests python3-send2trash && \
    \
    # Install Anki
    # NOTE ca-certificates installed by python3-requests
    apt-get install -y curl make pyqt5-dev-tools && \
    curl -sSL "${ANKI_DOWNLOAD_URL}" -o anki.tar.gz && \
    mkdir -p /usr/src/anki && \
    tar -xzf anki.tar.gz -C /usr/src/anki --strip-components=1 && \
    rm anki.tar.gz && \
    cd /usr/src/anki && \
    ./tools/build_ui.sh && \
    make install && \
    cd / && \
    rm -r /usr/src/anki && \
    apt-get purge -y --auto-remove curl make pyqt5-dev-tools && \
    \
    # Clean-up
    rm -rf /var/lib/apt/lists/*

# Set locale to UTF-8
ENV LANG=C.UTF-8

# Force Qt to use software acceleration for OpenGL
ENV QMLSCENE_DEVICE softwarecontext

# start Anki
CMD ["/usr/bin/anki"]

