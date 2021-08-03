# docker build -t wicebing/env-cyp .
# sudo docker run -d -p 22222:22 -p 28888:8888 -v /home/bixea6000/docker_data:/root/data --name my_server wicebing/env-cyp
# sudo docker exec my_server cat /etc/hosts

# sudo rm -rf  /root/.ssh/known_hosts 
# ssh-keygen -f "/home/bixea6000/.ssh/known_hosts" -R "172.17.0.2"

# ssh root@172.17.0.2
# jupyter lab  --port=8888 --allow-root --ip=0.0.0.0


FROM ubuntu:20.04
  
RUN apt-get update \ 
    && apt-get install -y openssh-server \
    && apt-get install -y wget \ 
    && apt-get install -y build-essential \
    && apt-get install -y screen \
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
    && conda install -c conda-forge jupyterlab -y \
    && conda install -c conda-forge implicit -y \
    && conda install bottleneck -y \
    && conda install jupyter -y \
    && python -m pip install pandas requests tqdm seaborn tensorflow ipykernel keras lightgbm ipywidgets lxml numpy \
    && python -m pip install scikit-learn \
    && python -m pip install pyfolio xgboost \
    && pip install finlab_crypto talib-binary yfinance PyPortfolioOpt ffn \
    && pip install --upgrade google-cloud-storage --upgrade google-api-python-client pygsheets \
    && pip install gspread-dataframe gspread python-binance Twisted service_identity
# -- install package --


# -- set ssh --
RUN mkdir /var/run/sshd \ 
    && echo 'root:screencast' | chpasswd

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