![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/vikramchauhan/ffmpeg.svg) ![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/vikramchauhan/ffmpeg.svg)

# docker-ffmpeg 
Docker ffmpeg image with ffprobe

### How to use ###

Get the image

    docker pull vikramchauhan/ffmpeg

Run interactive

    docker run -it vikramchauhan/ffmpeg <programname> <options>

where `<programname>` is `ffmpeg` or `ffprobe`

### Configuration ###
`ffmpeg` has been compiled with following configuration:


    configuration:
        --prefix=/ffmpeg/build
        --extra-cflags=-I/ffmpeg/build/include
        --extra-ldflags=-L/ffmpeg/build/lib
        --extra-libs=-lpthread
        --extra-libs=-ldl
        --bindir=/ffmpeg
        --enable-gpl
        --enable-libass
        --enable-libfdk-aac
        --enable-libfreetype
        --enable-libmp3lame
        --enable-libtheora
        --enable-libvorbis
        --enable-libx264
        --enable-libx265
        --enable-nonfree
        --disable-doc
        --disable-ffplay
