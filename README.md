# Flameshot como PrintScreen no Cinnamon

Scripts para configurar o Flameshot como ferramenta padrão de captura de tela no Cinnamon, para diferentes distribuições.

## Qual script usar?
- **Manjaro/BigLinux Cinnamon:** `flameshot-cinnamon-setup-manjaro.sh`
- **Linux Mint, LMDE ou Cinnamon baseado em Ubuntu/Debian:** `flameshot-cinnamon-setup-mint-lmde.sh`

## Como usar (passo a passo)

1. **Baixe o script certo para sua distro**
2. **Abra o terminal na pasta do script**
3. **Dê permissão de execução:**
   ```bash
   chmod +x nome-do-script.sh
   ```
4. **Execute o script:**
   ```bash
   ./nome-do-script.sh
   ```
   - Digite sua senha se pedir (para instalar o Flameshot)

## O que o script faz?
- Instala o Flameshot
- Remove atalhos antigos de PrintScreen
- Cria atalho PrintScreen para o Flameshot
- Adiciona o Flameshot para iniciar junto com o sistema
- Mostra dicas de teste e diagnóstico

## Teste rápido
- Pressione **Print Screen**: o Flameshot deve abrir
- Reinicie o PC: o Flameshot deve aparecer na bandeja

## Se der erro
- Leia a mensagem no terminal
- Para diagnóstico, rode:
  ```bash
  gsettings get org.cinnamon.desktop.keybindings.media-keys screenshot
  echo $XDG_SESSION_TYPE
  cat ~/.config/autostart/flameshot.desktop
  ```

## Desinstalar manualmente
```bash
dconf reset -f /org/cinnamon/desktop/keybindings/custom-keybindings/custom0/
gsettings reset org.cinnamon.desktop.keybindings.media-keys screenshot
rm ~/.config/autostart/flameshot.desktop
```

---

**Dica:** Se não souber qual é sua distribuição, rode `lsb_release -a` no terminal.

**Desenvolvido pela comunidade BiGLinux**
