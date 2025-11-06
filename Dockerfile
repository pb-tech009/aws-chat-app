# Use official MongoDB base image
FROM mongo:latest

# (Optional) You can add initialization scripts or config here
# COPY ./init.js /docker-entrypoint-initdb.d/

# Set default environment variables (optional)
ENV MONGO_INITDB_ROOT_USERNAME=mongoadmin
ENV MONGO_INITDB_ROOT_PASSWORD=secret

# Default port
EXPOSE 27017
