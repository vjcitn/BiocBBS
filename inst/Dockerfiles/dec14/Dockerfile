# Purpose is to do full builds of Bioc packages -- need latex and texinfo
# note pandoc already available
# This will be pushed to dockerhub 
# docker build -t vjcitn/bioc_bbspack2019:v1 dec14
# docker push vjcitn/bioc_bbspack2019:v1


FROM bioconductor/bioconductor_full:devel


RUN apt-get update
RUN apt-get install -y texlive-full texlive-xetex texinfo
