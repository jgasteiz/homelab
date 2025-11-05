FROM python:3.11-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    nodejs \
    npm \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install yarn
RUN npm install -g yarn

# Copy the generation script
COPY helm/docker/generate_blog.sh /generate_blog.sh
RUN chmod +x /generate_blog.sh

# Set working directory
WORKDIR /app

# Run the script by default
CMD ["/generate_blog.sh"]
