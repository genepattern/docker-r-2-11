# copyright 2017-2018 Regents of the University of California and the Broad Institute. All rights reserved.
FROM r-base:3.1.3

RUN mkdir /build && \
	mkdir -p /patches/rlib/2.11/site-library

COPY common/container_scripts/misc/Cairo_1.5-9.tar.gz /build/Cairo_1.5-9.tar.gz

RUN apt-get update && apt-get upgrade --yes && \
    apt-get install build-essential --yes && \
    apt-get install python-dev --yes && \
    apt-get install default-jre --yes && \
    apt-get install openjdk-7-jdk --yes && \
    wget --no-check-certificate https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py 
RUN pip install awscli 

RUN apt-get update && \
    apt-get install curl --yes && \
    apt-get install libfreetype6=2.5.2-3+deb8u2 --yes --force-yes && \
    apt-get install libfreetype6-dev --yes  --force-yes && \
    apt-get install libfontconfig1-dev --yes  --force-yes && \
    apt-get install libcairo2-dev --yes  --force-yes && \
    apt-get install libgtk2.0-dev --yes  --force-yes && \
    apt-get install -y xvfb --yes --force-yes && \
    apt-get install -y libxt-dev --yes  --force-yes
    

RUN  mkdir packages && \
    cd packages && \
    apt-get install tcl8.5-dev tk8.5-dev --yes && \
    curl -O http://cran.r-project.org/src/base/R-2/R-2.11.1.tar.gz && \
    tar xvf R-2.11.1.tar.gz && \
    cd R-2.11.1 && \
    ./configure --with-x=no --with-tcl-config=/usr/lib/x86_64-linux-gnu/tcl8.5/tclConfig.sh --with-tk-config=/usr/lib/x86_64-linux-gnu/tk8.5/tkConfig.sh && \
    make && \
    make check && \
    make install && \
    apt-get install libxml2-dev --yes && \
    apt-get install libcurl4-gnutls-dev --yes && \
    R CMD INSTALL /build/Cairo_1.5-9.tar.gz

COPY jobdef.json /build/jobdef.json
COPY common/container_scripts/misc/RunR.java /build/RunR.java
COPY common/container_scripts/installPackages.R-2 /build/source/installPackages.R
COPY rlib_install.sh /build/rlib_install.sh

COPY common/container_scripts/runS3OnBatch.sh /usr/local/bin/runS3OnBatch.sh
COPY common/container_scripts/runLocal.sh /usr/local/bin/runLocal.sh

RUN  cd /build && \
	./rlib_install.sh && \
    javac RunR.java && \
    chmod ugo+x /usr/local/bin/runS3OnBatch.sh 

COPY runS3Batch_postrun_custom.sh /usr/local/bin/runS3Batch_postrun_custom.sh 
COPY runS3Batch_prerun_custom.sh /usr/local/bin/runS3Batch_prerun_custom.sh

COPY Dockerfile /build/Dockerfile

ENV R_HOME=/usr/local/lib64/R
     
CMD ["/usr/local/bin/runS3OnBatch.sh" ]

