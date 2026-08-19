# Image for the nat_submit_client check.
#
# The check runs a submit client inside a container whose host name does not
# resolve for the qmaster. A stock base image is missing two things for that:
#
#   - binutils, because $SGE_ROOT/util/arch reads the glibc version out of the
#     C library with "strings". Without it the architecture comes out empty,
#     settings.sh builds a PATH that points nowhere and no client is found.
#   - an account matching the testsuite user, so the client submits as that
#     user instead of as root.
#
# The glibc version decides the architecture string rather than the
# distribution: util/arch answers lx-* above glibc 2.17, ulx-* at exactly
# 2.17 and xlx-* below it. Any current base image lands on lx-*, which is
# what a cluster normally has installed.

ARG BASE_IMAGE=ubuntu:24.04
FROM ${BASE_IMAGE}

RUN apt-get update && \
    apt-get install -y --no-install-recommends binutils && \
    rm -rf /var/lib/apt/lists/*

ARG TS_USER=sgetest
ARG TS_UID=1000
ARG TS_GID=1000

# The user has to carry the same id as in the cluster, so the client presents
# the identity the qmaster expects. Current Ubuntu images already ship an
# account on uid 1000, which has to give way first. Statements are separated by
# ";" rather than "&&" on purpose: a lookup that finds nothing is an ordinary
# outcome here and must not abort the rest.
RUN existing=$(getent passwd "${TS_UID}" | cut -d: -f1 || true); \
    if [ -n "${existing}" ]; then userdel -r "${existing}" 2>/dev/null || true; fi; \
    if ! getent group "${TS_GID}" >/dev/null; then \
       groupadd -g "${TS_GID}" "${TS_USER}"; \
    fi; \
    useradd -m -u "${TS_UID}" -g "${TS_GID}" -s /bin/sh "${TS_USER}"

USER ${TS_USER}
