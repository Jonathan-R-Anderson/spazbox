FROM python:3.11-slim

WORKDIR /app
COPY . /app

RUN pip install flask web3 requests

CMD ["python", "controller.py"]
