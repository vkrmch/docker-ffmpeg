FROM debian:latest as ffmpeg
MAINTAINER Vikram Chauhan <me@vkrm.ch>

ARG FFMPEG_DIR="/ffmpeg"
ARG MAKEFLAGS="-j4"
ARG DEPS="ca-certificates \
        wget \
        bzip2 \
        autoconf \
        automake \
        build-essential \
        libass-dev \
        libfreetype6-dev \
        libtheora-dev \
        libtool \
        libvorbis-dev \
        pkg-config \
        texinfo \
        zlib1g-dev \
        yasm \
        libx264-dev \
        libx265-dev \
        libmp3lame-dev \
        cmake \
        mercurial"

ENV TERM="xterm" \
    FFMPEG_DIR=${FFMPEG_DIR} \
    PKG_CONFIG_PATH="$FFMPEG_DIR/build/lib/pkgconfig" \
    LD_LIBRARY_PATH="$FFMPEG_DIR/build/lib" \
    PATH="$FFMPEG_DIR:$LD_LIBRARY_PATH:$PKG_CONFIG_PATH:$PATH" \
    DEBIAN_FRONTEND="noninteractive"

RUN echo "***creating directories***" \
    && mkdir $FFMPEG_DIR \
    && mkdir $FFMPEG_DIR/lib \
    && mkdir $FFMPEG_DIR/source \
    && mkdir $FFMPEG_DIR/build \
    && echo "***installing packages***" \
    && apt-get -y update \
    && apt-get -y install --no-install-recommends ${DEPS} \
    && echo "***compiling aac***" \
    && cd $FFMPEG_DIR/source \
    && wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master \
    && tar xzvf fdk-aac.tar.gz \
    && cd mstorsjo-fdk-aac* \
    && autoreconf -fiv \
    && ./configure --prefix="$FFMPEG_DIR/build" --disable-shared --enable-static \
    && make \
    && make install \
    && make distclean \
    && echo "***compiling ffmpeg***" \
    && cd $FFMPEG_DIR/source \
    && wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 \
    && tar xjvf ffmpeg-snapshot.tar.bz2 \
    && cd ffmpeg \
    && ./configure \
        --prefix="$FFMPEG_DIR/build" \
        --extra-cflags="-I/ffmpeg/build/include" \
        --extra-ldflags="-L/ffmpeg/build/lib" \
        --extra-libs=-lpthread \
        --extra-libs=-ldl \
        --bindir="$FFMPEG_DIR" \
        --enable-gpl \
        --enable-libass \
        --enable-libfdk-aac \
        --enable-libfreetype \
        --enable-libmp3lame \
        --enable-libtheora \
        --enable-libvorbis \
        --enable-libx264 \
        --enable-libx265 \
        --enable-nonfree \
        --disable-doc \
        --disable-ffplay \
    && make \
    && make install \
    && make distclean \
    && echo "removing build files" \
    && rm -rf /ffmpeg/source \
    && rm -rf /ffmpeg/build \
    && echo "***moving libraries***" \
    && ldd $FFMPEG_DIR/ffmpeg | cut -d ' ' -f 3 | xargs -i cp {} $FFMPEG_DIR/lib \
    && ls -1 $FFMPEG_DIR/lib \
    && echo "***removing unneeded packages***" \
    && apt-get -y remove ${DEPS} \
    && echo "***cleaning up***" \
    && apt-get -y clean \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/*

FROM debian:latest
MAINTAINER Vikram Chauhan <me@vkrm.ch>

ARG FFMPEG_DIR="/ffmpeg"
ARG RUN_USER=ffmpeg
ARG RUN_GROUP=ffmpeg
ARG RUN_UID=5555
ARG RUN_GID=5555
ARG RUN_PASS=ffmpeg123@

ENV RUN_USER=${RUN_USER} \
    RUN_GROUP=${RUN_GROUP} \
    RUN_UID=${RUN_UID} \
    RUN_GID=${RUN_GID} \
    LD_LIBRARY_PATH="$FFMPEG_DIR/lib" \
    PATH="$FFMPEG_DIR:$LD_LIBRARY_PATH:$PATH"

COPY --from=ffmpeg $FFMPEG_DIR $FFMPEG_DIR
RUN groupadd -g $RUN_GID $RUN_GROUP \
    && useradd -m $RUN_GROUP -g $RUN_USER -u $RUN_UID -p $RUN_PASS \
    && chmod -R 755 $FFMPEG_DIR \
    && ffmpeg -buildconf

USER $RUN_USER

ENTRYPOINT ["/bin/bash", "-c"]