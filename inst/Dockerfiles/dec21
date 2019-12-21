# Purpose is to ensure sufficient python for BiocSklearn ... and basilisk

# docker build -t vjcitn/bioc_bbspack2019:v3 dec21
# docker push vjcitn/bioc_bbspack2019:v3


FROM vjcitn/bioc_bbspack2019:v2

RUN Rscript -e 'BiocManager::install("LTLA/basilisk")'
RUN sudo pip install h5py h5pyd scikit-learn pandas
RUN Rscript -e 'BiocManager::install("BiocSklearn")'
