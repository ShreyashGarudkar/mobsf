# Base image
FROM python:3.13-slim-bookworm

# Set Environment Variables
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONFAULTHANDLER=1 \
    MOBSF_USER=mobsf \
    USER_ID=9901 \
    MOBSF_PLATFORM=docker \
    MOBSF_ADB_BINARY=/usr/bin/adb \
    JAVA_HOME=/jdk-22.0.2 \
    PATH=/jdk-22.0.2/bin:/root/.local/bin:$PATH \
    DJANGO_SUPERUSER_USERNAME=mobsf \
    DJANGO_SUPERUSER_PASSWORD=mobsf

# Install System Dependencies
RUN apt update -y && \
    apt install -y --no-install-recommends \
    android-sdk-build-tools \
    android-tools-adb \
    build-essential \
    curl \
    fontconfig \
    fontconfig-config \
    git \
    libfontconfig1 \
    libjpeg62-turbo \
    libxext6 \
    libxrender1 \
    locales \
    python3-dev \
    sqlite3 \
    unzip \
    wget \
    xfonts-75dpi \
    xfonts-base && \
    echo "en_US.UTF-8 UTF-8" > /etc/locale.gen && \
    locale-gen en_US.UTF-8 && \
    update-locale LANG=en_US.UTF-8 && \
    apt upgrade -y && \
    curl -sSL https://install.python-poetry.org | python3 - && \
    apt autoremove -y && apt clean -y && rm -rf /var/lib/apt/lists/* /tmp/*

ARG TARGETPLATFORM

# 1. Setup working directory for the scripts phase
WORKDIR /home/mobsf/Mobile-Security-Framework-MobSF

# 2. Install wkhtmltopdf, OpenJDK and jadx via script
# We use 'bash' instead of 'sh' to avoid "Permission Denied" and shell compatibility issues
COPY scripts/dependencies.sh mobsf/MobSF/tools_download.py ./
RUN bash ./dependencies.sh

# 3. Install Python dependencies
COPY pyproject.toml poetry.lock* ./
RUN /root/.local/bin/poetry config virtualenvs.create false && \
    /root/.local/bin/poetry install --only main --no-root --no-interaction --no-ansi && \
    rm -rf /root/.cache/

# 4. Copy the rest of the source code
COPY . .

# 5. Fix permissions for the entrypoint and the mobsf user
# This is crucial because the 'mobsf' user needs to execute the start script
RUN chmod +x scripts/entrypoint.sh && \
    groupadd --gid $USER_ID $MOBSF_USER && \
    useradd $MOBSF_USER --uid $USER_ID --gid $USER_ID --shell /bin/bash && \
    chown -R $MOBSF_USER:$MOBSF_USER /home/mobsf

# 6. Final Cleanup of build-only tools to reduce image size
RUN apt remove -y git python3-dev wget && \
    apt autoremove -y && apt clean -y && \
    rm -rf /var/lib/apt/lists/* /tmp/*

# Healthcheck
HEALTHCHECK --interval=30s --timeout=10s --retries=3 CMD curl -f http://localhost:8000/ || exit 1

# Expose MobSF Port and Proxy Port
EXPOSE 8000 1337

# Switch to non-root user for security
USER $MOBSF_USER

# Run MobSF
CMD ["/home/mobsf/Mobile-Security-Framework-MobSF/scripts/entrypoint.sh"]