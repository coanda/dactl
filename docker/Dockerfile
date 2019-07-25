FROM debian:buster

RUN apt-get update -qq && apt-get install --no-install-recommends -qq -y \
    debhelper \
    meson \
    cmake \
    valac \
    libpeas-dev \
    libsoup2.4-dev \
    libgtksourceview-3.0-dev \
    librsvg2-dev \
    libwebkit2gtk-4.0-dev \
    locales \
    devscripts \
    build-essential \
    lintian \
    ruby-dev \
    rubygems \
    mlocate \
    libmatheval-dev

RUN apt install --no-install-recommends -qq -y curl ca-certificates
RUN curl -v https://packagecloud.io/install/repositories/coanda/public/script.deb.sh | bash

RUN apt install libcld-1.0-dev -y

RUN gem install rake -v '12.3.1'

RUN gem install package_cloud

# Locale for our build
RUN locale-gen C.UTF-8 && /usr/sbin/update-locale LANG=C.UTF-8
ENV LANG=C.UTF-8 LANGUAGE=C.UTF-8 LC_ALL=C.UTF-8

# package cloud token
ARG pc_token=xxx
ENV PACKAGECLOUD_TOKEN=$pc_token

#RUN useradd -ms /bin/bash user

#USER user
#WORKDIR /home/user

#COPY --chown=user:user . dactl

#RUN tar -zcvf libdactl_1.0.orig.tar.gz ./dactl

#WORKDIR /home/user/dactl

#RUN debuild

#WORKDIR /home/user
#RUN package_cloud push --skip-errors coanda/public/debian/buster *.deb
