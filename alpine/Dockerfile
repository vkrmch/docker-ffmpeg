FROM alpine:latest as ffmpeg
LABEL org.opencontainers.image.authors="hello@vikramchauhan.com"

ARG FFMPEG_DIR="/ffmpeg"
ARG MAKEFLAGS="-j4"
ARG DEPS="ca-certificates \
        libressl \
        wget \
        bzip2 \
        autoconf \
        automake \
        build-base \
        libtheora-dev \
        libtool \
        libvorbis-dev \
        texinfo \
        yasm \
        x264-dev \
        lame-dev \
        cmake \
        mercurial \
        coreutils \
        libass-dev \
        x265-dev"

ENV TERM="xterm" \
    FFMPEG_DIR=${FFMPEG_DIR} \
    PKG_CONFIG_PATH="$FFMPEG_DIR/build/lib/pkgconfig" \
    LD_LIBRARY_PATH="$FFMPEG_DIR/build/lib" \
    PATH="$FFMPEG_DIR:$LD_LIBRARY_PATH:$PKG_CONFIG_PATH:$PATH"

RUN echo "***creating directories***" \
    && mkdir $FFMPEG_DIR \
    && mkdir $FFMPEG_DIR/lib \
    && mkdir $FFMPEG_DIR/source \
    && mkdir $FFMPEG_DIR/build \
    && echo "***installing packages***" \
    && apk add --no-cache --update ${DEPS}\
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
        --extra-cflags="-I$FFMPEG_DIR/build/include" \
        --extra-ldflags="-L$FFMPEG_DIR/build/lib" \
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
    && echo "***moving libraries***" \
    && ldd $FFMPEG_DIR/ffmpeg | cut -d ' ' -f 3 | xargs cp -t $FFMPEG_DIR/lib \
    && ls -1 $FFMPEG_DIR/lib \
    && echo "***removing unneeded packages***" \
    && apk del ${DEPS} \
    && echo "***cleaning up***" \
    && rm -rf $FFMPEG_DIR/source \
    && rm -rf $FFMPEG_DIR/build \
    && rm -rf /var/cache/apk/*

FROM alpine:latest
MAINTAINER Vikram Chauhan <me@vkrm.ch>

ARG FFMPEG_DIR="/ffmpeg"
ARG RUN_USER=ffmpeg
ARG RUN_GROUP=ffmpeg
ARG RUN_UID=5555
ARG RUN_GID=5555

ENV RUN_USER=${RUN_USER} \
    RUN_GROUP=${RUN_GROUP} \
    RUN_UID=${RUN_UID} \
    RUN_GID=${RUN_GID} \
    LD_LIBRARY_PATH="$FFMPEG_DIR/lib" \
    PATH="$FFMPEG_DIR:$LD_LIBRARY_PATH:$PATH"

COPY --from=ffmpeg $FFMPEG_DIR $FFMPEG_DIR
RUN addgroup -g $RUN_GID $RUN_GROUP \
    && adduser -G $RUN_GROUP -u $RUN_UID -D $RUN_USER \
    && chmod -R 755 $FFMPEG_DIR \
    && ffmpeg -buildconf

USER $RUN_USER

ENTRYPOINT ["sh", "-c"]