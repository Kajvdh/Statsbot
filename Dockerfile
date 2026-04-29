FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

RUN mkdir -p data config

EXPOSE 8033

VOLUME ["/app/data", "/app/config"]

ENTRYPOINT ["python", "main.py"]
