FROM rocker/geospatial:4.4.2

RUN awk -F: '{printf "%s:%s\n",$1,$3}' /etc/passwd

USER root

ENV NB_USER="rstudio"
ENV VIRTUAL_ENV="/opt/venv"
ENV PATH="${VIRTUAL_ENV}/bin:${PATH}"
ENV HOME="/home/${NB_USER}"

RUN echo ${HOME}

WORKDIR ${HOME}
COPY --chown=${NB_USER} . .
RUN chmod +x install_jupyter.sh
RUN ls -alh
RUN install_jupyter.sh

RUN apt-get update -qq && apt-get -y --no-install-recommends install pandoc wget \
    && apt-get -y install libssl-dev python3 python3-pip jags libx11-dev git libcurl4-openssl-dev make libgit2-dev zlib1g-dev libzmq3-dev libfreetype6-dev libjpeg-dev libpng-dev libtiff-dev libicu-dev libfontconfig1-dev libfribidi-dev libharfbuzz-dev libxml2-dev

EXPOSE 8888

CMD ["jupyter", "lab", "--ip", "0.0.0.0", "--no-browser"]

#RUN chown ${HOME} rstudio

#USER ${NB_USER}

#Set up renv
USER ${NB_USER}
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
WORKDIR /home/docker_renv
COPY renv.lock renv.lock
ENV RENV_PATHS_LIBRARY renv/library
RUN R -e "renv::restore()"

WORKDIR /home/${NB_USER}
