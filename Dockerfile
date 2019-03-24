FROM debian:latest as ffmpeg
MAINTAINER Vikram Chauhan <me@vkrm.ch>

# Declare environment variables
ENV DEBIAN_FRONTEND="noninteractive" \
    TERM="xterm" \
    PATH="/ffmpeg:$PATH" \
    PKG_CONFIG_PATH="/ffmpeg/build/lib/pkgconfig"

# Create directories
RUN mkdir /ffmpeg \
    && mkdir /ffmpeg/lib \
    && mkdir /ffmpeg/source \
    && mkdir /ffmpeg/build
WORKDIR /ffmpeg/source

# Install packages and build ffmpeg
RUN apt-get -y update \
    && apt-get -y install --no-install-recommends \
        ca-certificates \
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
        libmp3lame-dev \
        cmake \
        mercurial \
    && hg clone https://bitbucket.org/multicoreware/x265 \
    && cd x265/build/linux \
    && cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/ffmpeg/build" -DENABLE_SHARED:bool=off ../../source \
    && make \
    && make install \
    && cd /ffmpeg/source \
    && wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master \
    && tar xzvf fdk-aac.tar.gz \
    && cd mstorsjo-fdk-aac* \
    && autoreconf -fiv \
    && ./configure --prefix="/ffmpeg/build" --disable-shared \
    && make \
    && make install \
    && make distclean \
    && cd /ffmpeg/source \
    && wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 \
    && tar xjvf ffmpeg-snapshot.tar.bz2 \
    && cd ffmpeg \
    && ./configure \
        --prefix="/ffmpeg/build" \
        --pkg-config-flags="--static" \
        --extra-cflags="-I/ffmpeg/build/include" \
        --extra-ldflags="-L/ffmpeg/build/lib" \
        --extra-libs=-lpthread \
        --bindir="/ffmpeg" \
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
    && make \
    && make install \
    && make distclean \
    && echo removing build files \
    && rm -rf /ffmpeg/source \
    && rm -rf /ffmpeg/build \
    && echo moving libraries \
    && mkdir /ffmpeg/lib \
    && ldd /ffmpeg/ffmpeg | cut -d ' ' -f 3 | xargs -i cp {} /ffmpeg/lib \
    && echo removing unneeded packages \
    && apt-get -y remove \
        ca-certificates \
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
        libmp3lame-dev \
        cmake \
        mercurial \
    && apt-get -y clean \
    && apt-get -y autoclean \
    && apt-get -y autoremove \
    && rm -rf /var/lib/apt/lists/* \
    && LD_LIBRARY_PATH=/ffmpeg/lib \
    && ffmpeg -buildconf

FROM debian:latest
MAINTAINER Vikram Chauhan <me@vkrm.ch>

ENV LD_LIBRARY_PATH=/ffmpeg/lib
ENV RUN_UID=5555
ENV RUN_GID=5555
ENV PATH="/ffmpeg:$PATH"
ENV RUN_USER=ffmpeg
ENV RUN_GROUP=ffmpeg
ENV RUN_PASS=ffmpeg123@

RUN groupadd -g $RUN_GID $RUN_GROUP \
    && useradd -m $RUN_GROUP -c "ffmpeg Account" -g $RUN_USER -u $RUN_UID -p $RUN_PASS

COPY --from=ffmpeg /ffmpeg /ffmpeg
RUN chmod -R 755 /ffmpeg
USER $RUN_USER

# Set entrypoint
ENTRYPOINT ["/bin/bash","-c"]