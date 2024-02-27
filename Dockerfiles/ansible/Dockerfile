FROM python:slim-buster
RUN python -m pip install ansible ; pip install --user boto3
RUN apt update -y
RUN apt install openssh-client -y
CMD bash