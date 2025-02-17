#start from r-base
FROM rocker/binder:4.4.2

## Declares build arguments
USER root
ARG NB_USER=jovyan
ARG NB_UID=1000
RUN useradd -ms /bin/bash jovyan
RUN usermod -l jovyan rstudio
RUN groupmod -n jovyan rstudio
RUN usermod -d /home/jovyan -m jovyan

# Install conda here, to match what repo2docker does
ENV CONDA_DIR=/srv/conda
# ENV CONDA_DIR=/opt/conda

# Add our conda environment to PATH, so python, mamba and other tools are found in $PATH
ENV PATH ${CONDA_DIR}/bin:${PATH}
ENV NCPUS=${NCPUS:--1}

COPY --chown=${NB_USER} . ${HOME}
#COPY --chown=${NB_USER} /home/rstudio /home/jovyan

ENV DEBIAN_FRONTEND=noninteractive
RUN echo "Checking for 'apt.txt'..." \
        ; if test -f "apt.txt" ; then \
        apt-get update --fix-missing > /dev/null\
        && xargs -a apt.txt apt-get install --yes \
        && apt-get clean > /dev/null \
        && rm -rf /var/lib/apt/lists/* \
        ; fi

RUN apt-get update -qq && apt-get -y --no-install-recommends install pandoc wget \
    && apt-get -y install libssl-dev python3 python3-pip jags libx11-dev git libcurl4-openssl-dev make libgit2-dev zlib1g-dev libzmq3-dev libfreetype6-dev libjpeg-dev libpng-dev libtiff-dev libicu-dev libfontconfig1-dev libfribidi-dev libharfbuzz-dev libxml2-dev
RUN echo NB_USER
RUN awk -F: '{printf "%s:%s\n",$1,$3}' /etc/passwd
#add python
#RUN python3 -m pip install --no-cache-dir notebook jupyterlab --break-system-packages
#RUN pip install --no-cache-dir jupyterhub --break-system-packages
RUN export PATH="/usr/local/bin:$PATH"


#Add Anaconda
RUN echo "Installing Miniforge..." \
    # && curl -sSL "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge-${MINIFORGE_VERSION}-Linux-$(uname -m).sh" > installer.sh \
    # && curl -sSL "https://github.com/conda-forge/miniforge/releases/download/${MINIFORGE_VERSION}/Miniforge-${MINIFORGE_VERSION}-Linux-x86_64.sh" > installer.sh \
    && curl -sSL "https://github.com/conda-forge/miniforge/releases/download/23.11.0-0/Miniforge3-23.11.0-0-Linux-x86_64.sh" > installer.sh \
    && /bin/bash installer.sh -u -b -p ${CONDA_DIR} \
    && rm installer.sh \
    && conda clean -afy \
    # After installing the packages, we cleanup some unnecessary files
    # to try reduce image size - see https://jcristharif.com/conda-docker-tips.html
    && find ${CONDA_DIR} -follow -type f -name '*.a' -delete \
    && find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete

RUN find ${CONDA_DIR} -follow -type f -name '*.a' -delete
RUN find ${CONDA_DIR} -follow -type f -name '*.pyc' -delete

RUN install2.r --error --skipmissing --skipinstalled -n "$NCPUS" pacman languageserver reticulate IRkernel renv remotes

RUN install2.r --skipinstalled IRkernel
RUN r -e "IRkernel::installspec(prefix='${CONDA_DIR}')"

#WORKDIR /home
COPY renv.lock renv.lock
ENV RENV_PATHS_LIBRARY renv/library
RUN echo NB_USER
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
RUN echo ${NB_USER}
RUN awk -F: '{printf "%s:%s\n",$1,$3}' /etc/passwd
## Run an install.R script, if it exists.

#RUN awk -F: '{printf "%s:%s\n",$1,$3}' /etc/passwd

#Install conda environment
RUN conda env create -f qpt_conda_env.yaml
ENV PATH="/home/jovyan/miniconda/bin:$PATH"
ENV PATH "$PATH:/home/jovyan/.local/bin"
RUN echo ${NB_USER}
RUN awk -F: '{printf "%s:%s\n",$1,$3}' /etc/passwd
#restore environment from lockfile
RUN R -e "renv::restore()"
#SHELL ["conda", "run", "-n", "qpt", "/bin/bash", "-c"]

