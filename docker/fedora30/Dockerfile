# Test install libcld on Fedora 30
#
# docker build --tag=libcld-fedora30 .
#

FROM fedora:30

# Install dependencies
RUN dnf install -y git                         \
                   meson                       \
                   ninja-build                 \
                   gnome-common                \
                   intltool                    \
                   gcc                         \
                   vala                        \
                   libgee-devel                \
                   json-glib-devel             \
                   gsl-devel                   \
                   libxml2-devel               \
                   libmatheval-devel           \
                   comedilib-devel

COPY . dactl

WORKDIR /dactl
RUN rm -rf _build
RUN meson _build
RUN ninja -C _build install
