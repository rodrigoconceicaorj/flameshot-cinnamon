#!/bin/bash

# Script para configurar o Flameshot como ferramenta padrão de captura de tela na interface COSMIC (System76) no BitLinux/Manjaro
# Autor: Comunidade BitLinux
# Versão: 1.1

# Cores e símbolos
VERDE="\e[32m"
VERMELHO="\e[31m"
AMARELO="\e[33m"
RESET="\e[0m"
CHECK="${VERDE}✔️${RESET}"
ERRO="${VERMELHO}❌${RESET}"
INFO="${AMARELO}ℹ️${RESET}"

clear

echo -e "${INFO} Iniciando configuração do Flameshot para COSMIC..."

echo -e "${AMARELO}Se aparecer mensagem de erro ao desativar atalhos, é normal no COSMIC. Siga normalmente!${RESET}"

# 1. Verifica se o Flameshot está instalado

echo -e "${INFO} Etapa 1: Verificando instalação do Flameshot..."
if ! command -v flameshot &>/dev/null; then
    echo -e "${INFO} Flameshot não encontrado. Instalando..."
    if sudo pacman -S flameshot --noconfirm; then
        echo -e "  ${CHECK} Flameshot instalado com sucesso."
    else
        echo -e "  ${ERRO} Falha ao instalar o Flameshot. Verifique sua conexão ou permissões."
        exit 1
    fi
else
    version=$(flameshot --version | head -n 1)
    echo -e "  ${CHECK} Flameshot já está instalado: ${version}"
fi

# 2. Remove atalhos padrão de PrintScreen do GNOME/COSMIC

echo -e "${INFO} Etapa 2: Desativando atalhos padrão de PrintScreen..."
success=true
for key in screenshot screenshot-window screenshot-area; do
    if gsettings set org.gnome.settings-daemon.plugins.media-keys "$key" "[]" 2>/dev/null; then
        echo -e "  ${CHECK} Atalho '$key' desativado."
    else
        echo -e "  ${AMARELO}Ignorando atalho '$key' (não existe ou não é usado no COSMIC).${RESET}"
    fi
done

# 3. Cria atalho personalizado para o Flameshot

echo -e "${INFO} Etapa 3: Criando atalho personalizado para Flameshot..."
CUSTOM_PATH="/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
dconf reset -f "$CUSTOM_PATH"
if dconf write "${CUSTOM_PATH}binding" "['Print']" \
   && dconf write "${CUSTOM_PATH}command" "'env XDG_CURRENT_DESKTOP=GNOME /usr/bin/flameshot gui'" \
   && dconf write "${CUSTOM_PATH}name" "'Flameshot'"; then
    dconf write /org/gnome/settings-daemon/plugins/media-keys/custom-keybindings "['custom0']"
    echo -e "  ${CHECK} Atalho personalizado criado com sucesso!"
else
    echo -e "  ${ERRO} Falha ao configurar o atalho personalizado."
fi

# 4. Adiciona Flameshot à inicialização automática

echo -e "${INFO} Etapa 4: Adicionando Flameshot à inicialização automática..."
mkdir -p ~/.config/autostart
cat > ~/.config/autostart/flameshot.desktop <<EOF
[Desktop Entry]
Type=Application
Name=Flameshot
Comment=Iniciar Flameshot na inicialização
Exec=env XDG_CURRENT_DESKTOP=GNOME flameshot
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
EOF

if [ -s ~/.config/autostart/flameshot.desktop ]; then
    echo -e "  ${CHECK} Flameshot configurado para iniciar automaticamente."
else
    echo -e "  ${ERRO} Falha ao criar o arquivo de inicialização."
fi

# 5. Detecta sessão gráfica

echo -e "${INFO} Etapa 5: Verificando tipo de sessão gráfica..."
session_type="${XDG_SESSION_TYPE:-x11}"
echo -e "  Sessão detectada: ${session_type}"

if [ "$session_type" = "wayland" ]; then
    echo -e "${AMARELO}⚠️ Wayland detectado. Algumas funções podem não funcionar corretamente."
    if flatpak list | grep org.flameshot.Flameshot > /dev/null; then
        echo -e "${INFO} Ajustando permissões para Flatpak..."
        flatpak override org.flameshot.Flameshot --filesystem=home --talk-name=org.freedesktop.portal.Screenshot
        echo -e "  ${CHECK} Permissões ajustadas com sucesso."
    else
        echo -e "  ${ERRO} Flameshot Flatpak não encontrado. Use a versão instalada via pacman."
    fi
else
    echo -e "  ${CHECK} Sessão X11 detectada. Nenhuma ação adicional necessária."
fi

# 6. Finalização e recomendações

echo -e "\n${VERDE}✅ Configuração concluída com sucesso!${RESET}"
echo -e "${INFO} Testes recomendados:"
echo -e "  • Pressione a tecla ${AMARELO}Print Screen${RESET} → Flameshot deve abrir."
echo -e "  • Reinicie o sistema → Verifique se o Flameshot aparece na bandeja."
echo -e "${INFO} Se algo não funcionar, rode os comandos abaixo para diagnóstico:"
echo -e "  gsettings get org.gnome.settings-daemon.plugins.media-keys screenshot"
echo -e "  echo \$XDG_SESSION_TYPE"
echo -e "  cat ~/.config/autostart/flameshot.desktop" 