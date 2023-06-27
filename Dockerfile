FROM golang:1.18 as builder
RUN apt update && apt install -y git && mkdir /app
RUN cd /app && git clone https://github.com/apache/spark
RUN useradd spark 
RUN chown -R spark /app
CMD ["sleep", "3600"]
