#start from r-base
FROM rocker/r-ver:4.4.2

## Declares build arguments
ARG NB_USER
ARG NB_UID

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

RUN apt-get update -qq && apt-get -y --no-install-recommends install pandoc \
    && apt-get -y install libssl-dev python3 python3-pip jags libx11-dev git libcurl4-openssl-dev make libgit2-dev zlib1g-dev libzmq3-dev libfreetype6-dev libjpeg-dev libpng-dev libtiff-dev libicu-dev libfontconfig1-dev libfribidi-dev libharfbuzz-dev libxml2-dev

#add python
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

#Set up renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
#WORKDIR /home
COPY renv.lock renv.lock
ENV RENV_PATHS_LIBRARY renv/library

# Make sure the contents of our repo are in ${HOME}
COPY . ${HOME}
USER root
RUN export PATH="/usr/local/bin:$PATH"
RUN chown -R ${NB_UID} "/usr/local/lib"
RUN chown -R ${NB_UID} "/usr/local/bin"
RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}
WORKDIR ${HOME}
        
USER ${NB_USER}

## Run an install.R script, if it exists.

RUN awk -F: '{printf "%s:%s\n",$1,$3}' /etc/passwd

#Install conda environment
RUN conda env create -f qpt_conda_env.yaml

#restore environment from lockfile
RUN R -e "renv::restore()"
SHELL ["conda", "run", "-n", "qpt", "/bin/bash", "-c"]

