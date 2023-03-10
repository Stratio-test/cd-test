FROM stratio/stratio-spark:3.1.1-2.0.0-f820e86
RUN apt update && apt install -y git && mkdir /app
RUN cd /app && git clone https://github.com/apache/spark
RUN useradd spark 
RUN chown -R spark /app
CMD ["sleep", "3600"]
