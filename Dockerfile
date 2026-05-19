FROM ubuntu:22.04

# Evitar preguntas interactivas durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar utilidades básicas, XFCE, servidor VNC y noVNC
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
    && rm -rf /var/lib/apt/lists/*

# Configurar variables de entorno para la pantalla virtual y el puerto de Railway
ENV DISPLAY=:1
ENV PORT=8080

# Crear script de inicio para arrancar los servicios en orden automático
RUN echo '#!/bin/bash\n\
Xvfb :1 -screen 0 1280x720x24 &\n\
sleep 2\n\
startxfce4 &\n\
sleep 2\n\
x11vnc -display :1 -nopw -listen localhost -xkb -forever &\n\
sleep 2\n\
websockify --web /usr/share/novnc/ $PORT localhost:5900\n\
' > /start.sh && chmod +x /start.sh

# Railway usa el puerto 8080 por defecto para el tráfico web HTTP
EXPOSE 8080

# Ejecutar el script al arrancar el contenedor
CMD ["/start.sh"]
