#start from r-base
FROM rocker/binder:4.4.2

## Declares build arguments
ARG NB_USER
ARG NB_UID

RUN echo ${NB_USER}
RUN awk -F: '{printf "%s:%s\n",$1,$3}' /etc/passwd

#RUN useradd -ms /bin/bash jovyan

COPY --chown=${NB_USER} . ${HOME}

ENV DEBIAN_FRONTEND=noninteractive
USER root
RUN echo "Checking for 'apt.txt'..." \
        ; if test -f "apt.txt" ; then \
        apt-get update --fix-missing > /dev/null\
        && xargs -a apt.txt apt-get install --yes \
        && apt-get clean > /dev/null \
        && rm -rf /var/lib/apt/lists/* \
        ; fi

RUN apt-get update -qq && apt-get -y --no-install-recommends install pandoc wget \
    && apt-get -y install libssl-dev python3 python3-pip jags libx11-dev git libcurl4-openssl-dev make libgit2-dev zlib1g-dev libzmq3-dev libfreetype6-dev libjpeg-dev libpng-dev libtiff-dev libicu-dev libfontconfig1-dev libfribidi-dev libharfbuzz-dev libxml2-dev

RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
COPY renv.lock renv.lock
ENV RENV_PATHS_LIBRARY renv/library
RUN echo ${NB_USER}
        
USER ${NB_USER}

RUN R -e "renv::restore()"
