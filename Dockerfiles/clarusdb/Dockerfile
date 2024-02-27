FROM python:alpine
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN apk add curl
COPY . /app
WORKDIR /app
EXPOSE 80
CMD python ./clarusdb.py 