FROM ubuntu:18.04

# install runtime
# NOTE ca-certificates needed for Anki and curl
RUN apt-get update && apt-get install -y \
    ca-certificates python \
    && rm -rf /var/lib/apt/lists/*

# build and install SIP
## see installation instructions http://pyqt.sourceforge.net/Docs/sip4/installation.html
ARG SIP_VERSION=4.19.12
ARG SIP_DOWNLOAD_URL=https://sourceforge.net/projects/pyqt/files/sip/sip-$SIP_VERSION/sip-$SIP_VERSION.tar.gz
ARG SIP_DOWNLOAD_SHA1=9f4d0f05ab814ddcde767669cfb6bc184bba931d
RUN buildDeps='build-essential curl python-dev' \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /usr/src/sip \
    && curl -sSL "$SIP_DOWNLOAD_URL" -o sip.tar.gz \
    && echo "$SIP_DOWNLOAD_SHA1 sip.tar.gz" | sha1sum -c - \
    && tar -xzf sip.tar.gz -C /usr/src/sip --strip-components=1 \
    && rm sip.tar.gz \
    && cd /usr/src/sip \
    && python2 ./configure.py \
    && cd / \
    && make -C /usr/src/sip -j4 \
    && make -C /usr/src/sip install \
    && rm -r /usr/src/sip \
    && apt-get purge -y --auto-remove $buildDeps

# install Qt4 libraries
RUN apt-get update && apt-get install -y \
    libqtcore4 libqtgui4 libqtwebkit4 \
    && rm -rf /var/lib/apt/lists/*

# build and install PyQt4
## see installation instructions http://pyqt.sourceforge.net/Docs/PyQt4/installation.html
ARG PYQT4_VERSION=4.12.1
ARG PYQT4_DOWNLOAD_URL=http://sourceforge.net/projects/pyqt/files/PyQt4/PyQt-$PYQT4_VERSION/PyQt4_gpl_x11-$PYQT4_VERSION.tar.gz
ARG PYQT4_DOWNLOAD_SHA1=5c34b883f9dda0b96fc6ed2637aa70aa63c0f0bd
RUN buildDeps='build-essential curl libqt4-dev libqtwebkit-dev libx11-dev libxext-dev python-dev' \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /usr/src/PyQt4 \
    && curl -sSL "$PYQT4_DOWNLOAD_URL" -o PyQt4.tar.gz \
    && echo "$PYQT4_DOWNLOAD_SHA1 PyQt4.tar.gz" | sha1sum -c - \
    && tar -xzf PyQt4.tar.gz -C /usr/src/PyQt4 --strip-components=1 \
    && rm PyQt4.tar.gz \
    && cd /usr/src/PyQt4 \
    && python2 ./configure.py --confirm-license -e QtCore -e QtGui -e QtNetwork -e QtWebKit \
    && cd / \
    && make -C /usr/src/PyQt4 -j4 \
    && make -C /usr/src/PyQt4 install \
    && rm -r /usr/src/PyQt4 \
    && apt-get purge -y --auto-remove $buildDeps

# install Anki
ARG ANKI_VERSION=2.0.52
ARG ANKI_DOWNLOAD_URL=https://github.com/darkdragon-001/anki/archive/v$ANKI_VERSION.tar.gz
RUN buildDeps='curl' \
    && apt-get update && apt-get install -y $buildDeps --no-install-recommends \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir -p /usr/share/anki \
    && curl -sSL "$ANKI_DOWNLOAD_URL" -o anki.tar.gz \
    && tar -xzf anki.tar.gz -C /usr/share/anki --strip-components=1 \
    && rm anki.tar.gz \
    && cd /usr/share/anki \
    && ./tools/build_ui.sh \
    && cd / \
    && apt-get purge -y --auto-remove $buildDeps

ENV LC_CTYPE=C.UTF-8
CMD ["/usr/share/anki/runanki"]

