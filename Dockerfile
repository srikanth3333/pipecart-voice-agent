FROM python:3.11-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    ffmpeg \
    libopus0 \
    libopus-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# Install uv
RUN pip install uv

# Set working directory
WORKDIR /app

# Copy dependency files first for better caching
COPY pyproject.toml uv.lock* ./

# Install Python dependencies
RUN uv sync --locked --no-install-project --no-dev

# Copy application files
COPY bot.py ./

# Install the project
RUN uv sync --locked --no-dev

# Set environment variables
ENV PYTHONPATH=/app
ENV PATH="/app/.venv/bin:$PATH"

# Railway will set PORT automatically
EXPOSE $PORT

# Run the application
CMD ["uv", "run", "bot.py"]