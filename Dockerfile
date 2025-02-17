#start from r-base
FROM rocker/r-ver:4.4.2

RUN awk -F: '{printf "%s:%s\n",$1,$3}' /etc/passwd

USER root
ARG NB_USER=jovyan
ARG NB_UID=1000
ARG VERSION=4.4.2
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

RUN apt-get update -qq && apt-get -y --no-install-recommends install pandoc \
    && apt-get -y install libssl-dev python3 jags libx11-dev git libcurl4-openssl-dev make libgit2-dev zlib1g-dev libzmq3-dev libfreetype6-dev libjpeg-dev libpng-dev libtiff-dev libicu-dev libfontconfig1-dev libfribidi-dev libharfbuzz-dev libxml2-dev

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN export PATH="/usr/local/bin:$PATH"
RUN chown -R ${NB_UID} "/usr/local/lib"
RUN chown -R ${NB_UID} "/usr/local/bin"
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
WORKDIR ${HOME}

#add python
#RUN apt-get -y install python3 python3-pip
RUN python3 -m pip install --no-cache-dir notebook jupyterlab --break-system-packages
RUN pip install --no-cache-dir jupyterhub --break-system-packages
RUN export PATH="/usr/local/bin:$PATH"


#Add Anaconda
RUN wget https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh
RUN bash Anaconda3-5.0.1-Linux-x86_64.sh -b
RUN rm Anaconda3-5.0.1-Linux-x86_64.sh
ENV PATH /root/anaconda3/bin:$PATH
RUN conda update conda
RUN conda update anaconda
RUN conda update --all

#Install conda environment
RUN conda env create -f qpt_conda_env.yaml


#Set up renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
#WORKDIR /home
COPY renv.lock renv.lock
ENV RENV_PATHS_LIBRARY renv/library

#restore environment from lockfile
#USER ${NB_USER}
RUN R -e "renv::restore()"

SHELL ["conda", "run", "-n", "qpt", "/bin/bash", "-c"]
# Make sure the contents of our repo are in ${HOME}
#COPY . ${HOME}
#USER root
#RUN chown -R ${NB_UID} ${HOME}
#USER ${NB_USER}
