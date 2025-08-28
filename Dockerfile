FROM python:3.11

# Install system dependencies for OpenCV
RUN apt-get update && apt-get install -y \
    libgl1-mesa-dev \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    ffmpeg \
    libgstreamer1.0-0 \
    libgstreamer-plugins-base1.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /app

# Enable bytecode compilation
ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

# Copy dependency files first
COPY uv.lock pyproject.toml ./

# Install the project's dependencies (removed cache mount)
RUN uv sync --locked --no-install-project --no-dev

# Copy the application code
COPY ./bot.py bot.py

# Railway provides PORT env variable
ENV HOST=0.0.0.0

# Run the bot
CMD ["uv", "run", "python", "-c", "import os; port = os.getenv('PORT', '7860'); exec(f'import sys; sys.argv = [\"bot.py\", \"--host\", \"0.0.0.0\", \"--port\", \"{port}\"]; exec(open(\"bot.py\").read())')"]
