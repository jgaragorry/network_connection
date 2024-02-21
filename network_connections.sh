#!/bin/bash

##########################################################
# Script: network_connections.sh
# Descripción: Este script muestra información del sistema, incluyendo configuración de firewall, SELinux, tarjetas de red, puertos escuchando, puertos abiertos, conexiones actuales y cantidad de conexiones.
# Autor: Jose Garagorry <jj@softraincorp.com>
##########################################################

# Obtener información de la distribución y release de Linux
distro=$(cat /etc/*release | grep "^NAME" | head -n1 | awk -F= '{print $2}' | tr -d '"')
release=$(cat /etc/*release | grep "^VERSION_ID" | head -n1 | awk -F= '{print $2}' | tr -d '"')

echo -e "\e[1;34mDistribución de Linux:\e[0m $distro"
echo -e "\e[1;34mRelease:\e[0m $release"

# Verificar si el firewall está activo
if [[ "$distro" == *"Ubuntu"* || "$distro" == *"Debian"* ]]; then
    if [ -x "$(command -v ufw)" ]; then
        firewall_status=$(ufw status | grep "Status" | awk '{print $2}')
        if [ "$firewall_status" == "active" ]; then
            echo -e "\n\e[1;34mConfiguración del Firewall (UFW):\e[0m"
            ufw status verbose
        else
            echo -e "\n\e[1;33mEl Firewall (UFW) no está activo.\e[0m"
        fi
    else
        echo -e "\n\e[1;33mEl Firewall (UFW) no está instalado.\e[0m"
    fi
elif [[ "$distro" == *"CentOS"* || "$distro" == *"Red Hat"* ]]; then
    if [ -x "$(command -v firewall-cmd)" ]; then
        firewall_status=$(systemctl is-active firewalld)
        if [ "$firewall_status" == "active" ]; then
            echo -e "\n\e[1;34mConfiguración del Firewall (Firewalld):\e[0m"
            firewall-cmd --list-all
        else
            echo -e "\n\e[1;33mEl Firewall (Firewalld) no está activo.\e[0m"
        fi
    else
        echo -e "\n\e[1;33mEl Firewall (Firewalld) no está instalado.\e[0m"
    fi
fi

# Verificar si SELinux está activo
if [ -x "$(command -v sestatus)" ]; then
    selinux_status=$(sestatus | grep "SELinux status" | awk '{print $3}')
    echo -e "\n\e[1;34mEstado de SELinux:\e[0m $selinux_status"
fi

# Obtener información de tarjetas de red y sus IPs
echo -e "\n\e[1;34mTarjetas de Red y sus IPs:\e[0m"
ip addr | grep "inet " | awk '{print $2, $7}'

# Obtener puertos escuchando
echo -e "\n\e[1;34mPuertos Escuchando:\e[0m"
netstat -tuln | grep "LISTEN"

# Obtener puertos abiertos
echo -e "\n\e[1;34mPuertos Abiertos:\e[0m"
netstat -tun | grep "ESTABLISHED"

# Obtener conexiones actuales y cantidad de conexiones
echo -e "\n\e[1;34mConexiones Actuales y Cantidad:\e[0m"
netstat -tan | grep "ESTABLISHED"
connections_count=$(netstat -tan | grep "ESTABLISHED" | wc -l)
echo -e "\n\e[1;34mCantidad de Conexiones:\e[0m $connections_count"

