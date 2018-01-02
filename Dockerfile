FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

MAINTAINER thuync <thuync.learning@gmail>

ARG THEANO_VERSION=rel-0.8.2
ARG TENSORFLOW_VERSION=1.4.0
ARG TENSORFLOW_ARCH=gpu
ARG KERAS_VERSION=1.2.0
ARG LASAGNE_VERSION=v0.1
ARG TORCH_VERSION=latest
ARG CAFFE_VERSION=master

RUN echo -e "\n**********************\nNVIDIA Driver Version\n**********************\n" && \
	cat /proc/driver/nvidia/version && \
	echo -e "\n**********************\nCUDA Version\n**********************\n" && \
	nvcc -V && \
	echo -e "\n\nBuilding your Deep Learning Docker Image...\n"

# Install some dependencies
RUN apt-get update && apt-get install -y \
		bc \
		build-essential \
		cmake \
		curl \
		g++ \
		gfortran \
		git \
		libffi-dev \
		libfreetype6-dev \
		libhdf5-dev \
		libjpeg-dev \
		liblcms2-dev \
		libopenblas-dev \
		liblapack-dev \
		libopenjpeg2 \
		libpng12-dev \
		libssl-dev \
		libtiff5-dev \
		libwebp-dev \
		libzmq3-dev \
		nano \
		pkg-config \
		python-dev \
		software-properties-common \
		unzip \
		vim \
		wget \
		zlib1g-dev \
		qt5-default \
		libvtk6-dev \
		zlib1g-dev \
		libjpeg-dev \
		libwebp-dev \
		libpng-dev \
		libtiff5-dev \
		libjasper-dev \
		libopenexr-dev \
		libgdal-dev \
		libdc1394-22-dev \
		libavcodec-dev \
		libavformat-dev \
		libswscale-dev \
		libtheora-dev \
		libvorbis-dev \
		libxvidcore-dev \
		libx264-dev \
		yasm \
		libopencore-amrnb-dev \
		libopencore-amrwb-dev \
		libv4l-dev \
		libxine2-dev \
		libtbb-dev \
		libeigen3-dev \
		python-dev \
		python-tk \
		python-numpy \
		python3-dev \
		python3-tk \
		python3-numpy \
		ant \
		default-jdk \
		doxygen \
		&& \
	apt-get clean && \
	apt-get autoremove && \
	rm -rf /var/lib/apt/lists/* && \
# Link BLAS library to use OpenBLAS using the alternatives mechanism (https://www.scipy.org/scipylib/building/linux.html#debian-ubuntu)
	update-alternatives --set libblas.so.3 /usr/lib/openblas-base/libblas.so.3

RUN git clone https://github.com/pyenv/pyenv.git ~/.pyenv \
    && git clone https://github.com/pyenv/pyenv-virtualenv.git ~/.pyenv/plugins/pyenv-virtualenv \
    && echo 'export PYENV_ROOT="$HOME/.pyenv"' >> /etc/profile.d/pyenv.sh \
    && echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> /etc/profile.d/pyenv.sh \
    && echo -e 'if command -v pyenv 1>/dev/null 2>&1; then\n  eval "$(pyenv init -)"\nfi' >> /etc/profile.d/pyenv.sh \
    && echo 'eval "$(pyenv virtualenv-init -)"' >> /etc/profile.d/pyenv.sh

RUN pyenv install anaconda3-4.3.1 \
    && pyenv install 3.5.3 \
    && pyenv virtualenv 3.5.3 deep-learning \
    && pyenv global deep-learning \
    && pip --no-cache-dir install \
            pyopenssl \
            ndg-httpsclient \
            pyasn1 \
    && pip --no-cache-dir install \
            numpy \
            scipy \
            nose \
            h5py \
            skimage \
            matplotlib \
            pandas \
            sklearn \
            sympy \
            Cython \
            ipykernel \
            ipython \
            jupyter \
            path.py \
            Pillow \
            pygments \
            six \
            sphinx \
            wheel \
            zmq \
    && python -m ipykernel.kernelspec \
    && pip install tensorflow-gpu==${TENSORFLOW_VERSION}

# Set up notebook config
COPY jupyter_notebook_config.py /root/.jupyter/

# Jupyter has issues with being run directly: https://github.com/ipython/ipython/issues/7062
COPY run_jupyter.sh /root/

# Expose Ports for TensorBoard (6006), Notebook (8888)
EXPOSE 6006 8888

WORKDIR "/root"
CMD ["/bin/bash"]
