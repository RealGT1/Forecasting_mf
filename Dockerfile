# Use the official Python image from the Docker Hub
FROM python:3.9-slim AS builder

# Create a virtual environment in the container
RUN python -m venv /opt/venv

# Ensure venv is used:
ENV PATH="/opt/venv/bin:$PATH"

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install system dependencies and python dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends build-essential gcc && \
    pip install --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt && \
    apt-get remove --purge -y build-essential gcc && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /root/.cache/pip

# Copy the rest of the working directory contents into the container at /app
COPY . .

# Final stage
FROM python:3.9-slim

# Copy the virtual environment from the builder stage
COPY --from=builder /opt/venv /opt/venv

# Ensure venv is used:
ENV PATH="/opt/venv/bin:$PATH"

# Set the working directory in the container
WORKDIR /app

# Copy the application code from the builder stage
COPY --from=builder /app /app

# Make port 5000 available to the world outside this container
EXPOSE 5000

# Run app.py when the container launches
CMD ["python", "app.py"]
