# docker build -t unbuntu_docker .
# docker run -d -p 12345:22 -v /home/docekr_data:/mnt/data --name my_server unbuntu_docker
# sudo docker exec my_server cat /etc/hosts

# sudo rm -rf  /root/.ssh/known_hosts 


FROM ubuntu:20.04
  
RUN apt-get update && apt-get install -y openssh-server

# -- install miniconda --
ENV PATH="/root/miniconda3/bin:${PATH}"
ARG PATH="/root/miniconda3/bin:${PATH}"
RUN apt-get update

RUN apt-get install -y wget && rm -rf /var/lib/apt/lists/*

RUN wget \
    https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh \
    && mkdir /root/.conda \
    && bash Miniconda3-latest-Linux-x86_64.sh -b \
    && rm -f Miniconda3-latest-Linux-x86_64.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> ~/.bashrc \
    && echo "export PATH="/root/miniconda3/bin:$PATH"" >> ~/.bashrc \
    && conda create -n crypto python=3.7 -y

# -- install miniconda --

# -- set ssh --
RUN mkdir /var/run/sshd
RUN echo 'root:screencast' | chpasswd

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
  
RUN echo "Port 22" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

EXPOSE 22
# -- set ssh --

CMD ["/usr/sbin/sshd", "-D"]



    
    
    
    
    
    
    
    
    
    
# =====================
# RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# ENV NOTVISIBLE "in users profile"
# RUN echo "export VISIBLE=now" >> /etc/profile