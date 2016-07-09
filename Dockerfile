FROM ubuntu:latest
MAINTAINER Vikram Chauhan <chauhanv@outlook.com>

# Declare environment variables
ENV DEBIAN_FRONTEND="noninteractive" \
 TERM="xterm" \
 PATH="/ffmpeg:$PATH" \
 PKG_CONFIG_PATH="/ffmpeg/build/lib/pkgconfig"

# Create directories
RUN mkdir /ffmpeg && \
 mkdir /ffmpeg/source && \
 mkdir /ffmpeg/build
WORKDIR /ffmpeg/source

# Install packages and build ffmpeg
RUN apt-get -y update && \
 apt-get -y install wget bzip2 \
  autoconf automake build-essential libass-dev libfreetype6-dev \
  libtheora-dev libtool libvorbis-dev \
  pkg-config texinfo zlib1g-dev \
  yasm libx264-dev libmp3lame-dev \
  cmake mercurial && \
 hg clone https://bitbucket.org/multicoreware/x265 && \
 cd x265/build/linux && \
 cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="/ffmpeg/build" -DENABLE_SHARED:bool=off ../../source && \
 make && \
 make install && \
 cd /ffmpeg/source && \
 wget -O fdk-aac.tar.gz https://github.com/mstorsjo/fdk-aac/tarball/master && \
 tar xzvf fdk-aac.tar.gz && \
 cd mstorsjo-fdk-aac* && \
 autoreconf -fiv && \
 ./configure --prefix="/ffmpeg/build" --disable-shared && \
 make && \
 make install && \
 make distclean && \
 cd /ffmpeg/source && \
 wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2 && \
 tar xjvf ffmpeg-snapshot.tar.bz2 && \
 cd ffmpeg && \
 ./configure \
   --prefix="/ffmpeg/build" \
   --pkg-config-flags="--static" \
   --extra-cflags="-I/ffmpeg/build/include" \
   --extra-ldflags="-L/ffmpeg/build/lib" \
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
   --enable-nonfree && \
 make && \
 make install && \
 make distclean && \
 apt-get clean && \
 apt-get autoclean && \
 apt-get autoremove && \
 rm -rf /ffmpeg/source && \
 rm -rf /ffmpeg/build

# Set entrypoint
ENTRYPOINT ["/ffmpeg/ffmpeg"]
