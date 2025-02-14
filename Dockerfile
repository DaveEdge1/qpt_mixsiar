#start from r-base
FROM rocker/binder

USER root
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER ${NB_USER}
ENV NB_UID ${NB_UID}
ENV HOME /home/${NB_USER}

RUN adduser --disabled-password \
    --gecos "Default user" \
    --uid ${NB_UID} \
    ${NB_USER}

COPY . ${HOME}
#Install JAGS
#from apt
RUN apt-get -y update \
    && apt-get -y install jags

RUN chown -R ${NB_UID} ${HOME}
USER ${NB_USER}

#update Ubuntu

#  && apt-get install adduser

#ARG NB_USER=user1
#ARG NB_UID=1000
#ENV USER ${NB_USER}
#ENV NB_UID ${NB_UID}
#ENV HOME /home/${NB_USER}

#RUN usermod -d /home/user1 -l newname node

#RUN adduser --disabled-password \
#    --gecos "Default user" \
#    --uid ${NB_UID} \
#    ${NB_USER}

#RUN chown -R ${NB_UID} ${HOME}
#RUN chown -R ${NB_UID} /opt/user1

#WORKDIR ${HOME}
#USER ${NB_USER}

#ENV PATH $PATH:/home/${NB_USER}/.local/bin

#add python
RUN apt-get -y install python3 python3-pip
RUN python3 -m pip install --no-cache-dir notebook jupyterlab --break-system-packages
RUN pip install --no-cache-dir jupyterhub --break-system-packages

#WORKDIR /opt/user1/

#from source
# RUN apt-get update && . /etc/environment \
#   && wget sourceforge.net/projects/mcmc-jags/files/JAGS/4.x/Source/JAGS-4.3.2.tar.gz  -O jags.tar.gz \
#   && tar -xf jags.tar.gz \
#   && cd JAGS* && ./configure && make -j4 && make install

## httr authentication uses this port
#EXPOSE 1410
#ENV HTTR_LOCALHOST 0.0.0.0

#set up environment in Jupyter
COPY qpt_conda_env.yaml qpt_conda_env.yaml
COPY pip_install_from_conda_yaml.py pip_install_from_conda_yaml.py
RUN python3 pip_install_from_conda_yaml.py

#Set up renv
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
#WORKDIR /home
COPY renv.lock renv.lock
ENV RENV_PATHS_LIBRARY renv/library

#restore environment from lockfile
#USER ${NB_USER}
RUN R -e "options(renv.config.pak.enabled = TRUE); renv::restore()"


# Make sure the contents of our repo are in ${HOME}
#COPY . ${HOME}
#USER root
#RUN chown -R ${NB_UID} ${HOME}
#USER ${NB_USER}
