FROM python:3.9-slim

WORKDIR /app

# 1. Install system dependencies (now including git)
RUN apt-get update && apt-get install -y \
    wget \
    git \  
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# 3. Download model weights
RUN mkdir -p /app/checkpoints && \
    wget -O /app/checkpoints/depth_anything_v2_vits.pth \
    https://huggingface.co/depth-anything/Depth-Anything-V2-Small/resolve/main/depth_anything_v2_vits.pth

# 4. Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 5. Copy application files
COPY . .

EXPOSE 5050

CMD ["python", "app.py"]