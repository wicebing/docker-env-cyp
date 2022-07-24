# docker build -t wicebing/env-cyp .
# sudo docker run -d -p 22222:22 -p 28888:8888 -v /home/bixea6000/docker_data:/root/data --name my_server wicebing/env-cyp
# sudo docker run --gpus all -d -p 21111:22 -p 21112:8888 -v /home/bixa6000/ehrs:/root/data --name my_ehrs wicebing/env-ehrs:gpus
# sudo docker exec my_server cat /etc/hosts

# sudo rm -rf  /root/.ssh/known_hosts 
# ssh-keygen -f "/home/bixea6000/.ssh/known_hosts" -R "172.17.0.2"

# ssh root@172.17.0.2
# jupyter lab  --port=8888 --allow-root --ip=0.0.0.0


FROM nvidia/cuda:11.4.2-devel-ubuntu20.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y tzdata \ 
    && apt-get install -y openssh-server \
    && apt-get install -y wget \ 
    && apt-get install -y build-essential \
    && apt-get install -y screen \
    && apt-get install -y htop \
    && rm -rf /var/lib/apt/lists/* \
    && mkdir /root/data

# -- install miniconda --
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-py37_4.9.2-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-py37_4.9.2-Linux-x86_64.sh -b \
    && rm -f Miniconda3-py37_4.9.2-Linux-x86_64.sh \
    && echo ". /root/miniconda3/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "conda activate" >> ~/.bashrc
# -- install miniconda --

# -- install package --
RUN conda update --all -y \ 
    && pip3 install --upgrade pip \
    && python -m pip install --upgrade pip
RUN python -m pip install transformers
RUN python -m pip install seaborn ipykernel ipywidgets lxml \
    && python -m pip install tensorflow lightgbm keras \
    && pip install shioaji
RUN python -m pip install scikit-learn requests tqdm\
    && python -m pip install pyfolio xgboost
RUN pip install finlab_crypto talib-binary yfinance PyPortfolioOpt ffn \
    && pip install --upgrade google-cloud-storage --upgrade google-api-python-client pygsheets \
    && pip install gspread-dataframe gspread python-binance Twisted service_identity
RUN conda install -c conda-forge pyreadstat -y \
    && conda install -c conda-forge matplotlib -y \
    && conda install -c conda-forge jupyterlab -y \
    && conda install -c conda-forge implicit -y \
    && conda install bottleneck -y \
    && conda install jupyter pandas -y
# -- install package --


# -- set ssh --
RUN mkdir /var/run/sshd \ 
    && echo 'root:bixe' | chpasswd

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && echo "Port 22" >> /etc/ssh/sshd_config \
    && echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config \
    && echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

EXPOSE 22
# -- set ssh --

CMD ["/usr/sbin/sshd", "-D"]



    
    
    
    
    
    
    
    
    
    
# =====================
# RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# ENV NOTVISIBLE "in users profile"
# RUN echo "export VISIBLE=now" >> /etc/profile