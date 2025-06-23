FROM python:3.9-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    wget \
    libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Download model weights
RUN mkdir -p /app/checkpoints && \
    wget -O /app/checkpoints/depth_anything_v2_vits.pth \
    https://huggingface.co/depth-anything/Depth-Anything-V2-Small/resolve/main/depth_anything_v2_vits.pth

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy all application files
COPY . .

EXPOSE 5050

CMD ["python", "run.py", \
     "--encoder", "vits", \
     "--img-path", "images", \
     "--outdir", "output"]