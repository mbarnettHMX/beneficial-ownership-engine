FROM python:3.9-slim


ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PATH=/opt/python/3/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/root/.local/bin \
    ODBCINI=/etc/odbc.ini \
    ODBCSYSINI=/etc


WORKDIR /api-backend


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        gcc \
        curl \
        gnupg \
        unixodbc \
        unixodbc-dev \
    && rm -rf /var/lib/apt/lists/*


RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - && \
    curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list && \
    apt-get update && \
    ACCEPT_EULA=Y apt-get install -y msodbcsql17

# Install Python Poetry
RUN curl -sSL https://install.python-poetry.org | python -

# Copy dependency files
COPY ./poetry.lock .
COPY ./pyproject.toml .

# Copy scripts directory
COPY ./scripts ./scripts

# Make scripts executable
RUN chmod +x ./scripts/install_python_deps.sh && \
    chmod +x ./scripts/start.sh

# Run script to install Python dependencies
RUN ./scripts/install_python_deps.sh

# Copy the entire application code
COPY . .

# Specify the entry point script
ENTRYPOINT ["./scripts/start.sh"]
