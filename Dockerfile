FROM apache/airflow:2.3.3-python3.10

COPY ./dags/ ${AIRFLOW_HOME}/dags/
COPY ./plugins/ ${AIRFLOW_HOME}/plugins/

USER root

# GDAL
RUN apt-get update --yes && apt-get install -y --no-install-recommends \ 
    g++ libgdal-dev gdal-bin libpq-dev && rm -rf /var/lib/apt/lists/*
ARG CPLUS_INCLUDE_PATH=/usr/include/gdal
ARG C_INCLUDE_PATH=/usr/include/gdal

# RGIS
RUN apt-get update --yes && \
    apt-get install --yes --no-install-recommends \
	git cmake clang curl make libnetcdf-dev libudunits2-dev libgdal-dev libexpat1-dev libxext-dev libmotif-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/bmfekete/RGIS /tmp/RGIS && /tmp/RGIS/install.sh /usr/local/share && rm -rf /tmp/RGIS

# rgispy
RUN git clone https://github.com/dvignoles/rgispy.git /opt/rgispy
RUN chown -R airflow /opt/rgispy

USER airflow
# Pin setup tools for gdal issue
# https://stackoverflow.com/questions/69123406/error-building-pygdal-unknown-distribution-option-use-2to3-fixers-and-use-2
RUN pip install --upgrade --no-cache-dir setuptools==57.5.0
RUN pip install --no-cache-dir GDAL==$(gdal-config --version)
RUN pip install --no-cache-dir /opt/rgispy

ENV GHAASDIR="/usr/local/share/ghaas"
ENV PATH="/usr/local/share/ghaas/bin:/usr/local/share/ghaas/f:${PATH}"

# additional dependencies
COPY Makefile Makefile
COPY airflow.requirements.txt airflow.requirements.txt

RUN make internal-install-deps
