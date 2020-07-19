FROM fedora:32
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}
RUN curl -o /etc/yum.repos.d/bintray-reznikmm-matreshka.repo \
 https://bintray.com/reznikmm/matreshka/rpm && \
 dnf --assumeyes install gcc-gnat && \
 dnf --assumeyes install gprbuild && \
 dnf --assumeyes install make && \
 dnf --assumeyes install python3-notebook && \
 dnf --assumeyes install jupyter-ada-kernel && \
 echo Version 19.07.2020 && \
 adduser --comment "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}
# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN chown -R ${NB_UID} ${HOME} && \
 find /usr/lib/python3.8/site-packages/notebook/static \
  -name main.min.js -or -name meta.js -exec sed -i -e \
  '/x-ttcn-asn/s#$#{name: "Ada", mime: "text/x-ada", mode: "ada", ext: ["ads", "adb", "ada"]},#' \
  {} \; && \
 cat /usr/lib/python3.8/site-packages/notebook/static/components/codemirror/mode/ada/ada.js >> \
 /usr/lib/python3.8/site-packages/notebook/static/notebook/js/main.min.js
USER ${NB_USER}
