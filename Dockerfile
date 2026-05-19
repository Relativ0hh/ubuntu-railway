FROM ubuntu:22.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar utilidades, XFCE, VNC, noVNC, sudo y gosu
RUN apt-get update && apt-get install -y \
    ubuntu-desktop-minimal \
    xfce4 \
    xfce4-goodies \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    curl \
    bash \
    sudo \
    gosu \
    && rm -rf /var/lib/apt/lists/*

# ---- CREACIÓN DEL USUARIO PERMANENTE ----
RUN useradd -m -s /bin/bash franco && \
    echo "franco:As17sa71" | chpasswd && \
    usermod -aG sudo franco

# Configurar variables de entorno globales para que coincidan con franco
ENV DISPLAY=:1
ENV PORT=8080
ENV USER=franco
ENV HOME=/home/franco

# Crear script de inicio usando gosu para cambiar de usuario de verdad (limpiando entorno root)
RUN echo '#!/bin/bash\n\
Xvfb :1 -screen 0 1280x720x24 &\n\
sleep 2\n\
x11vnc -display :1 -nopw -listen localhost -xkb -forever &\n\
sleep 2\n\
websockify --web /usr/share/novnc/ $PORT localhost:5900 &\n\
sleep 2\n\
exec gosu franco startxfce4\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 8080

# Ejecutar el script al arrancar el contenedor
CMD ["/start.sh"]
