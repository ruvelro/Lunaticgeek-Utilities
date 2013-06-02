#!/bin/bash

# se borra la pantalla
clear

#Pide la contraseña de sudo #-s hace que gksu se comporte como sudo #-l muestra la pantalla de login 
[ "$UID" != "0" ] && gksu -s -l "$0"

echo "$user" 
#

echo '              ______________________________ '
echo '             |     Lunaticgeek Utilities    |'
echo '             |          V. 13.04.01         |'
echo '             |          by. ruvelro         |'
echo '             |______www.lunaticgeek.com_____|'
echo ''
echo Operacion solicitada por el usuario: ${USER}
echo 'Para cancelar presione Ctrl+Z'
echo ''
echo 'El script se esta ejecutando, por favor, espere...'
echo ''

#
# Variables Locales
TFCName="Lunaticgeek Utilities 13.04.01"
TFCVersion="13.04.01"
LogDay=$(date '+%Y-%m-%d')
LogTime=$(date '+%Y-%m-%d %H:%M:%S')
#logFile=/var/log/Lunaticgeek_Utilities_$LogDay.log
homedir=/home/${USER}/
logFile=$homedir/Lunaticgeek_Utilities_$LogDay.log
userName=$(eval echo $SUDO_USER)
ubuntuVerRelT=$(cat /etc/lsb-release | awk 'BEGIN {FS="DISTRIB_RELEASE="} {print $2;}') 
ubuntuVerRel=$(echo $ubuntuVerRelT)
installChkLog=()

#
# Detectando la versión de Ubuntu instalada
if [ $(echo "$ubuntuVerRel < 12.04" | bc ) -eq 1 ]
  then
    tweakTool="Gnome Tweak Tool"
fi
if [ "$ubuntuVerRel" = "12.04" ] 
  then
    tweakTool="MyUnity"
fi
if [ "$ubuntuVerRel" = "12.10" ] 
  then
    tweakTool="Unity Tweak Tool *"
fi
# Usamos BC para calcular la coma flotante
if [ $(echo "$ubuntuVerRel > 12.10" | bc ) -eq 1 ] 
  then
    tweakTool="Unity Tweak Tool"
fi

#
# Funcciones
## Comprobaremos si el programa está instalado
FINSTALLED() {
   checkInstall=$(dpkg -s $* | grep -i "Status")   
   checkOk=$(echo "$checkInstall" | grep -i -o "ok")
   if [ ! "$checkOk" ] 
     then
       echo "false"
     else
       echo "true"
   fi
}
##Instalación exitosa
FINSTALLOK () {
   # Contruir Array
   if [ "$installChkLog" = "" ] 
     then 
       # Primer objeto
       installChkLog=( TRUE "$*" Ok )
     else
       # Anexar Array
       installChkLog+=( TRUE "$*" Ok )
   fi
}
##Instalación Erronea
FINSTALLERR () {
   # Contruir Array
   if [ "$installChkLog" = "" ] 
     then 
       # Primer objeto
       installChkLog=( FALSE "$*" Error )
     else
       # Anexar Array
       installChkLog+=( FALSE "$*" Error )
   fi
}

## Añadir lanzador a Unity 
FADDLAUNCHER() {
   newLauncher="'application:\/\/$*.desktop'"
   currentList=`sudo -u $userName gsettings get com.canonical.Unity.Launcher favorites`
   checkList=$(echo $currentList | grep $* )
   if [ ! "$checkList" ]
     then
       newList=$(echo $currentList | sed s/]/", $newLauncher]"/ )
       sudo -u $userName gsettings set com.canonical.Unity.Launcher favorites "$newList"
   fi
}



#
##Comienza el código Zenity 
#
selection=$(zenity  --list  --title "RW Labs - $TFCName" --text "<b>Selecciona los programas que deseas instalar</b>\n* Las PPA se añadirán automáticamente durante la instalación" --checklist  --width=800 --height=600 \
--column "Selección" --column "Programa" --column="Descripción" \
FALSE "***HERRAMIENTAS DEL SISTEMA***" "Selecciona los progranas que desees" \
TRUE "System Software Update" "Actualizar el sistema" \
TRUE "Restricted Multimedia Extras" "Codecs de vídeo y extras restirngidos" \
TRUE "$tweakTool" "Configuración de escritorio." \
TRUE "Faenza *" "Tema de iconos" \
TRUE "XScreenSaver" "Salvapantallas" \
TRUE "Mc" "Explorador de archivos para terminal" \
TRUE "Htop" "Monitor de sistema para terminal" \
TRUE "Gnome-System-Log" "Visor de sucesos" \
TRUE "Gparted" "Gestor de particiones" \
TRUE "Synaptic" "Gestor de paquetes Synaptic" \
TRUE "Qalculate" "Calculadora" \
TRUE "Gdebi" "Instalador de paquetes deb" \
TRUE "Cups-PDF" "Impresora PDF" \
TRUE "Gnome-System-Tools" "Herramientas del sistema de Gnome" \
TRUE "Compiz-Config-Manager" "Configurador de Compiz" \
TRUE "LmSensors" "Lector de sensores" \
TRUE "Gkrellm" "Lector de sensores en GTK" \
TRUE "Lshw" "Lector de Hardware" \
TRUE "Qpxtool" "Analizador de lectores opticos" \
TRUE "Qtnx" "Probar aplicaciones sin instalar desde la Store" \
TRUE "Byobu *" "Terminal multiventana" \
TRUE "Ubuntu-Tweak *" "Configurador del sistema" \
TRUE "Wine *" "Emulador de Windows" \
TRUE "Indicator-Multiload *" "Widget que muestra el uso del PC" \
TRUE "Nautilus-Actions-Extra *" "Acciones extra para el menu contextual" \
TRUE "Y-PPA-Manager *" "Editor de PPA" \
TRUE "Window-List *" "Lista las ventanas activas" \
TRUE "Indicator-Stickynotes *" "Notas en el escritorio" \
TRUE "Calendar Indicator *" "Google Calendar" \
TRUE "KeyPassX" "Gestor de contraseñas" \
TRUE "K3B" "Suite de grabacion de discos" \
TRUE "AcetoneISO" "Montador de imagenes ISO" \
TRUE "Isomaster" "Gestor de imagenes ISO" \
TRUE "Wallch" "Cambia el fondo automáticamente" \
TRUE "Screenlets" "Widgets de escritorio" \
TRUE "Classicmenu-Indicator" "Menu clasido de Gnome en el panel de Unity" \
TRUE "VirtualBox-4.1" "Maquinas virtuales (En pruebas)" \
TRUE "VirtualBox-4.2" "Maquinas virtuales (En pruebas)" \
FALSE "." "." \
FALSE "***PROGRAMAS DE INTERNET***" "Selecciona los progranas que desees" \
TRUE "My Weather Indicator *" "Aplicación de tiempo" \
TRUE "Google Chrome *" "Navegador" \
TRUE "Skype" "Messenger" \
TRUE "DropBox" "Compartir archivos" \
TRUE "Samba" "Compartir archivos con Windows" \
TRUE "SSH Server" "Acceso Remoto" \
TRUE "FileZilla" "Cliente FTP" \
TRUE "Vinagre" "Escritorio Remoto" \
TRUE "Jdownloader *" "Gestor de descargas" \
TRUE "Chromium-Daily *" "Navegador web" \
TRUE "Namebench" "Comprobador de DNS" \
TRUE "Firefox-Daily *" "Navegador Firefox Dayly" \
TRUE "Emesene *" "Messenger" \
TRUE "Pidgin" "Multimensajeria" \
TRUE "Amule" "Version de eMule para Linux" \
TRUE "Elinks" "Navegador web para terminal" \
TRUE "Slurm" "Monitor de red" \
FALSE "." "." \
FALSE "***PROGRAMAS DE AUDIO/VIDEO/IMAGEN***" "Selecciona los progranas que desees" \
TRUE "VLC" "Reproductor" \
TRUE "GIMP *" "Editor de imágenes" \
TRUE "XBMC *" "Media Center" \
TRUE "Inkscape" "Editor de gráficos vectoriales" \
TRUE "OpenShot" "Editor de Video" \
TRUE "Kdenlive" "Editor de Video" \
TRUE "Cinelerra *" "Editor de vídeo" \
TRUE "Pitivi" "Editor de video" \
TRUE "Avidemux" "Editor de video" \
TRUE "Kino" "Editor de video" \
TRUE "HandBrake *" "Conversor de video" \
TRUE "Audacity" "Editor de audio" \
TRUE "Audacious *" "Reproductor de musica" \
TRUE "Pinta *" "Editor grafico" \
TRUE "Redimages *" "Redimensionador masivo de imagenes" \
TRUE "Linux-Multimedia-Studio *" "Editor profesional de audio" \
TRUE "Moc" "Reproductor de musica en terminal" \
TRUE "Soundconverter" "Conversor de audio" \
TRUE "Gnome-Paint" "Programa similar al paint" \
TRUE "Darktable *" "Procesador de imágenes" \
TRUE "Gnome-Recorder" "Grabador de escritorio" \
TRUE "Mplayer" "Reproductor de video" \
TRUE "UFW" "Firewall para Ubuntu" \
TRUE "Winff" "Conversor de vídeo" \
TRUE "Transmageddon" "Conversor de video" \
TRUE "Shutter" "Aplicación de pantallazos" \
TRUE "Cheese" "Programa para webcam" \
FALSE "." "." \
FALSE "***JUEGOS***" "Selecciona los progranas que desees" \
TRUE "Steam *" "Platforma de juego" \
TRUE "Pyenglish *" "Aprender ingles" \
TRUE "PlayOnLinux" "Wine para juegos de Windows" \
TRUE "BSDGames" "Juegos BSD" \
TRUE "Xtron" "Tron para terminal" \
TRUE "Abuse" "Juego Abuse" \
FALSE "." "." \
FALSE "***OFIMATICA***" "Selecciona los progranas que desees" \
TRUE "LibreOffice *" "Suite Ofimatica" \
TRUE "Scribus" "Maquetación de paginas web" \
TRUE "PDF Tools" "Editor PDF" \
TRUE "Indicator-Keylock *" "Visor de Mayusculas Activas" \
TRUE "Dia" "Editor de diagramas" \
TRUE "OCRfeeder" "Lector OCR" \
TRUE "PDFedit" "Editor de PDF" \
TRUE "Simple-Scan" "Programa de escaner" \
TRUE "GScan2PDF" "Programa de escaner" \
TRUE "Calibre" "Catalogador de ebooks" \
TRUE "Emacs" "Editor de textos profesional" \
TRUE "Basket" "Administrador de notas" \
TRUE "Geany" "Editor de textos" \
--separator=","); 


if [ ! "$selection" = "" ] 
  then
    # Comprobar la disponibilidad de dpkg - se debe ser sudo
    dpkgLock=$(lsof /var/lib/dpkg/lock)
    if [ "$dpkgLock" ]
      then
        # Bloqueado
        zenity  --question  --title "RW Labs - $TFCName" --text "<big><b>El gestor de instalación está ocupado</b></big>\n\nPulsa <b>''continuar''</b> para forzar su cierre y continuar" --width=600 --ok-label="Continuar" --cancel-label="Cancelar"
                   
        case $? in
          0)
            # Continuar
            # Matar el proceso que bloquea dpkg 
            sudo fuser -vk /var/lib/dpkg/lock
            # Arreglar paquetes a medio instalar
            sudo dpkg --configure -a
            # Continuar la instalación
            echo "# Gestor de instalación cerrado. Continuamos..."
          ;;
          1)
            # Cancelar
            zenity --warning --text="<big><b>La instalación se ha cancelado.</b></big>\n\nLunaticgeek Utilities se cerrará." --title="RW Labs - $TFCName" --width=500
            exit
	  ;;
         -1)
            echo "# Ha ocurrido un error inesperado."
            exit
	  ;;
        esac 
    fi

    # Comprobando el bloqueo de apt. Se debe ser sudo
    aptLock=$(lsof /var/lib/apt/lists/lock)
    if [ "$aptLock" ]
      then
        # archivo bloqueado
        zenity  --question  --title "RW Labs - $TFCName" --text "<big><b>Apt está bloqueado.</b></big>\n\nPulsa <b>continuar</b> para forzar su cierre y continuar" --width=600 --ok-label="Continuar" --cancel-label="Cancelar"
                   
        case $? in
          0)
            # Continuar
            # Matar el proceso 
            sudo fuser -vk /var/lib/apt/lists/lock
            # Continuar la instalación
            echo "# Update manager closed"
          ;;
          1)
            # Cancelar
            zenity --warning --text="<big><b>La instalación se ha cancelado.</b></big>\n\nLunaticgeek Utilities se cerrará." --title="RW Labs - $TFCName" --width=500
            exit
	  ;;
         -1)
            echo "# Ha ocurrido un error inesperado."
            exit
	  ;;
        esac 
    fi

    # Comienza el código de Zenity 
    echo "$LogTime uss: [$userName] * $TFCName $TFCVersion - Log activado" >> $logFile
    (
    # Cuenta los elementos seleccionados
    installCount=$(echo $selection | awk -F, '{print NF}')
    # Incrementa el contador
    progressBarVal=0
    taskNum=1
    counterInc=$(echo "scale=0; 100/$installCount" | bc )
    # Contador = 0 para el primer elemento

    # 0. Activa el repositorio Ubuntu Partner ya que muchas instalaciones dependen de él.
    echo "$progressBarVal" ; sleep 0.1
       echo "$LogTime uss: [$userName] 0. Activa Repositorio Ubuntu Partner" >> $logFile
       echo "# $progressBarVal% Completado. Comienza la instalación"
       # Añadir Partners a la lista de repositorios
       sudo sed -i "/^# deb .*partner/ s/^# //" /etc/apt/sources.list
       sudo sed -i "/^# deb-src .*partner/ s/^# //" /etc/apt/sources.list

       # Actualizar Repositorios
       sudo apt-get update 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
      
       echo "# Repositorio Ubuntu Partner activado"  
      

    # 1. Apt-get update
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "System")
       if [ "$option" -eq "1" ] 
         then
           echo "$LogTime uss: [$userName] 1. Actualizar Software" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Actualizar Software"

           # Actualizar
           # apt-get upgrade
           sudo apt-get -y upgrade 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando actualizaciones...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Solucionar problemas
sudo apt-get -y -f install 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Verificando la instalacion ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Actualizar barra de progreso
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Sistema Actualizado"  
           taskNum=$(expr $taskNum + 1 )  
       fi

    # 2. Instalar Restricted Extras
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Restricted")      
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "ubuntu-restricted-extras" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Ubuntu Restricted Extras"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount - Restricted Extras instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 2. Instalar Restricted Extras" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Restricted Extras"
           # Aceptar MS EULA
           sudo sh -c "echo ttf-mscorefonts-installer msttcorefonts/accepted-mscorefonts-eula select true | debconf-set-selections"
           # Instalar MS Core Fonts
           sudo apt-get install -y ttf-mscorefonts-installer --quiet 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando MS Core Fonts ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close
           # Instalar restricted extras
           sudo apt-get install -y ubuntu-restricted-extras 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Restricted Extras ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close
           # Instalar Medibuntu PPA
           ## Medibuntu
           
           sudo wget --output-document=/etc/apt/sources.list.d/medibuntu.list http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Medibuntu PPA ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close 
           ## Actualizar repositorios
           sudo apt-get --quiet update 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close 
           
           sudo apt-get --yes --quiet --allow-unauthenticated install medibuntu-keyring 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Medibuntu PPA Key ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close 
           ## DVD playback 
           sudo apt-get install -y libdvdcss2 w32codecs w64codecs app-install-data-medibuntu apport-hooks-medibuntu 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Activando DVD playback ...</b></big>"  --width=500 --pulsate --no-cancel --auto-close
           
           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Restricted Extras ..."
           installStatus=$( FINSTALLED "ubuntu-restricted-extras" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Ubuntu Restricted Extras"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Ubuntu Restricted Extras"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Ubuntu Restricted Extras instalado."  
           taskNum=$(expr $taskNum + 1 )
       fi

    # 3. Instalar Tweak Tool dependiendo de la versión de Ubuntu
    echo "$progressBarVal" ; sleep 0.1

       ## Gnome Tweak Tool para todas las anteriores a 12.04
       option=$(echo $selection | grep -c "Gnome Tweak Tool")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "gnome-tweak-tool" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Gnome Tweak Tool"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Gnome Tweak Tool instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]
         then
           echo "$LogTime uss: [$userName] 3. Gnome Tweak Tool" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Gnome Tweak Tool"  
           # Instalar Tweak Tool
           sudo apt-get install -y gnome-tweak-tool 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Gnome Tweak Tool ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Gnome Tweak Tool ..."
           installStatus=$( FINSTALLED "gnome-tweak-tool" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Gnome Tweak Tool"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "gnome-tweak-tool"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Gnome Tweak Tool"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Gnome Tweak Tool instalado."  
           taskNum=$(expr $taskNum + 1 )  
       fi

       ## MyUnity para 12.04
       option=$(echo $selection | grep -c "MyUnity")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "myunity" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "MyUnity"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  MyUnity instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 3. Instalar MyUnity" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar MyUnity"  
           # Instalar Tweak Tool
           sudo apt-get install -y myunity 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando MyUnity ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de MyUnity ..."
           installStatus=$( FINSTALLED "myunity" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "MyUnity"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "myunity"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "MyUnity"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - MyUnity instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

        ## Unity Tweak Tool para 12.10 con PPA y nativo 12.10
        option=$(echo $selection | grep -c "Unity Tweak Tool")
        # Comprobar si está seleccionada 
        if [ "$option" -eq "1" ] 
          then
            # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
            installStatus=$( FINSTALLED "unity-tweak-tool" )
            if [ "$installStatus" = "true" ] 
              then
                # Instalación correcta, añadir a la lista de correctos
                echo "$LogTime uss: [$userName] [OK] instalado" >> $logFile
                FINSTALLOK "Unity Tweak Tool"
                # Actualizar la barra de progreso 
                progressBarVal=$(expr $progressBarVal + $counterInc )  
                echo "# $progressBarVal% completado. $taskNum of $installCount -  Unity Tweak Tool instalado"  
                taskNum=$(expr $taskNum + 1 )
            fi
        fi
        # Si está seleccionado y no instalado, continuar    
        if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]
          then
            # Instalar PPA Ubuntu 12.10 
            if [ "$ubuntuVerRel" = "12.10" ] 
              then
                # Añadir PPA Unity Tweak Tool Daily
                sudo add-apt-repository -y ppa:freyja-dev/unity-tweak-tool-daily 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Unity Tweak Tool PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
                # Actualizar Repositorios
                sudo apt-get --quiet update 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
                # Activado Repositorio Unity Tweak Tool
            fi
            # Instalar Tweak Tool
            echo "$LogTime uss: [$userName] 3. Instalar Unity Tweak Tool" >> $logFile
            echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Unity Tweak Tool"  
            sudo apt-get install -y unity-tweak-tool 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Unity Tweak Tool ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Unity Tweak Tool ..."
           installStatus=$( FINSTALLED "unity-tweak-tool" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Unity Tweak Tool"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "unity-tweak-tool"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Unity Tweak Tool"
           fi

            # Actualizar barra de progreso al finalizar
            progressBarVal=$(expr $progressBarVal + $counterInc )  
            echo "# $progressBarVal% completado. $taskNum of $installCount - Unity Tweak Tool instalado."  
            taskNum=$(expr $taskNum + 1 )
        fi

    # 4. Instalar Faenza Icon Theme
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Faenza")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "faenza-icon-theme" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Faenza Icon Theme"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount - Faenza Icon Theme instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 4. Instalar Faenza Icon Theme" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Faenza Icon Theme"
           # Añadir repositorio de WebUp8 PPA  
           sudo add-apt-repository -y -y ppa:webupd8team/themes 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo WebUp8 PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Instalar Faenza Icon Theme
           sudo apt-get install -y faenza-icon-theme 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Faenza icon theme ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Faenza Icon Theme ..."
           installStatus=$( FINSTALLED "faenza-icon-theme" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Faenza Icon Theme"
               # Set Faenza as default icons
               sudo -u $userName gsettings set org.gnome.desktop.interface icon-theme "Faenza-Dark"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Faenza Icon Theme"
           fi


           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Faenza Icon Theme instalado."
           taskNum=$(expr $taskNum + 1 )
        fi

    # 4.1 Instalar XScreenSaver
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "XScreenSaver")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "xscreensaver" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "XScreenSaver"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  XScreenSaver instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 4.1 Instalar XScreenSaver" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar XScreenSaver"  
           # Remove Gnome Screensaver
           sudo apt-get remove -y gnome-screensaver 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Eliminando Gnome Screensaver ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar XScreenSaver
           sudo apt-get install -y xscreensaver xscreensaver-gl-extra xscreensaver-data-extra 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando XScreenSaver ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de XScreenSaver ..."
           installStatus=$( FINSTALLED "xscreensaver" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "XScreenSaver"
               # Crear entrada de auto-inicio para XScreeSaver
               sudo echo "[Desktop Entry]" >> /etc/xdg/autostart/screensaver.desktop
               sudo echo "Name=Screensaver" >> /etc/xdg/autostart/screensaver.desktop 
               sudo echo "Type=Application" >> /etc/xdg/autostart/screensaver.desktop
               sudo echo "Exec=xscreensaver -nosplash" >> /etc/xdg/autostart/screensaver.desktop
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "XScreenSaver"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - XScreenSaver instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 4.2 Instalar My Weather Indicator
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Weather")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "my-weather-indicator" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "My Weather Indicator"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  My Weather Indicator instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 4.2 Instalar My Weather Indicator" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar My Weather Indicator"  
           # Añadir repositorio de My Weather Indicator PPA  
           sudo add-apt-repository -y ppa:atareao/atareao 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo My Weather Indicator PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar My Weather Indicator
           sudo apt-get install -y my-weather-indicator 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando My Weather Indicator ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de My Weather Indicator ..."
           installStatus=$( FINSTALLED "my-weather-indicator" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "My Weather Indicator"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "My Weather Indicator"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - My Weather Indicator instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 4.3 Instalar Calendar Indicator
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Calendar")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "calendar-indicator" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Calendar Indicator"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Calendar Indicator instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 4.3 Instalar Calendar Indicator" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Calendar Indicator"  
           # Comprobar si Weather Indicator está instalado para no volver a añadir la PPA
           option=$(echo $selection | grep -c "Weather")
           if [ "$option" -eq "0" ] 
             then
               # Añadir repositorio de Calendar Indicator PPA  
               sudo add-apt-repository -y ppa:atareao/atareao 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Calendar Indicator PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
               # Actualizar Repositorios
               sudo apt-get --quiet update 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           fi
           # Instalar Calendar Indicator
           sudo apt-get install -y calendar-indicator 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Calendar Indicator ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Calendar Indicator ..."
           installStatus=$( FINSTALLED "calendar-indicator" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Calendar Indicator"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Calendar Indicator"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Calendar Indicator instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 5. Instalar Google Chrome
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Chrome")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "google-chrome-stable" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Google Chrome"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Google Chrome instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 5. Instalar Google Chrome" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Google Chrome"
           # Añadir repositorio de Google PPA  
           wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
           sudo sh -c 'echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list' 
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Google Chrome
           sudo apt-get install -y google-chrome-stable 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Google Chrome ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Google Chrome ..."
           installStatus=$( FINSTALLED "google-chrome-stable" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Google Chrome"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "google-chrome"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Google Chrome"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Google Chrome instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 6. Instalar LibreOffice 4
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "LibreOffice")
       if [ "$option" -eq "1" ] 
         then
           echo "$LogTime uss: [$userName] 6. Instalar LibreOffice" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar LibreOffice"  
           # Añadir repositorio de LibreOffice PPA  
           sudo add-apt-repository -y ppa:libreoffice/ppa 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo LibreOffice PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar LibreOffice
           sudo apt-get -y dist-upgrade 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando LibreOffice ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Solucionar posibles problemas de actualización
		   sudo apt-get -y -f install 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Verifying ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           #sudo apt-get install -y libreoffice 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando LibreOffice ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de LibreOffice ..."
           installStatus=$( FINSTALLED "libreoffice" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "LibreOffice"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "libreoffice-startcenter"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "LibreOffice"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - LibreOffice instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 7. Instalar Skype
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Skype")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "skype" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Skype"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Skype instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 7. Instalar Skype" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Skype"  
           # Instalar Skype
           sudo apt-get install -y skype 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Skype ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Skype ..."
           installStatus=$( FINSTALLED "skype" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Skype"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "skype"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Skype"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Skype instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 8. Instalar DropBox
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "DropBox")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "nautilus-dropbox" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "DropBox"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  DropBox instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
          then
            echo "$LogTime uss: [$userName] 8. Instalar DropBox" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar DropBox"  
            # Instalar DropBox
            sudo apt-get install -y nautilus-dropbox 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando DropBox ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de DropBox ..."
           installStatus=$( FINSTALLED "nautilus-dropbox" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "DropBox"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "DropBox"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - DropBox instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 9. Instalar VLC
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "VLC")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "vlc" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "VLC"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  VLC instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 9. Instalar VLC" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar VLC"  
           # Instalar VLC
           sudo apt-get install -y vlc 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando VLC ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de VLC ..."
           installStatus=$( FINSTALLED "vlc" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "VLC"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "vlc"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "VLC"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - VLC instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 10. Instalar XBMC
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "XBMC")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "xbmc" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "XBMC"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  XBMC instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar XBMC" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar XBMC"  
           # Añadir repositorio de XBMC PPA  
           sudo add-apt-repository -y ppa:team-xbmc/ppa 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo XBMC PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar XBMC
           sudo apt-get install -y xbmc xbmc-standalone 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando XBMC ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de XBMC ..."
           installStatus=$( FINSTALLED "xbmc" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "XBMC"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "xbmc"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "XBMC"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - XBMC instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 11. Instalar GIMP
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "GIMP")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "gimp" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "GIMP"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  GIMP instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
         then
           echo "$LogTime uss: [$userName] 11. Instalar GIMP" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar GIMP"  
           # Añadir repositorio de GIMP PPA  
           sudo add-apt-repository -y ppa:otto-kesselgulasch/gimp 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo GIMP PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar GIMP
           sudo apt-get install -y gimp 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando GIMP ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de GIMP ..."
           installStatus=$( FINSTALLED "gimp" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "GIMP"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "gimp"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "GIMP"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - GIMP instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 11.1 Instalar Darktable
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Darktable")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "darktable" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Darktable"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Darktable instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
         then
           echo "$LogTime uss: [$userName] 11.1 Instalar Darktable" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Darktable"  
           # Instalar PPA for versions before 13.04 as ppa has not been updated yet
           if [ $(echo "$ubuntuVerRel < 13.04" | bc ) -eq 1 ] 
             then
               # Añadir repositorio de Darktable PPA  
               sudo add-apt-repository -y ppa:pmjdebruijn/darktable-release 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Darktable PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
               # Actualizar Repositorios
               sudo apt-get --quiet update 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           fi
           ## Instalar Quantal PPA for Raring as PPA is not updated yet - NOTE: Temporary
           if [ $(echo "$ubuntuVerRel == 13.04" | bc ) -eq 1 ] 
             then
               sudo add-apt-repository -y 'deb http://ppa:pmjdebruijn/darktable-release quantal main'  2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Darktable PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
               # Actualizar Repositorios
               sudo apt-get --quiet update 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           fi
           # Instalar Darktable
           sudo apt-get install -y darktable 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Darktable ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Darktable ..."
           installStatus=$( FINSTALLED "darktable" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Darktable"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "darktable"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Darktable"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Darktable instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 12. Instalar Inkscape
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Inkscape")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "inkscape" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Inkscape"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Inkscape instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
          then
            echo "$LogTime uss: [$userName] 12. Instalar Inkscape" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Inkscape"  
            # Instalar Inkscape
            sudo apt-get install -y inkscape 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Inkscape ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Inkscape ..."
           installStatus=$( FINSTALLED "inkscape" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Inkscape"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "inkscape"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Inkscape"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Inkscape instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 13. Instalar Scribus
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Scribus")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "scribus" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Scribus"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Scribus instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
         then
           echo "$LogTime uss: [$userName] 13. Instalar Scribus" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Scribus"  
           # Instalar Scribus
           sudo apt-get install -y scribus 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Scribus ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Scribus ..."
           installStatus=$( FINSTALLED "scribus" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Scribus"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "scribus"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Scribus"
           fi


           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Scribus instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 14. Instalar SAMBA
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Samba")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "samba" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Samba"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Samba instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
         then
           echo "$LogTime uss: [$userName] 14. Instalar SAMBA" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Samba"  
           # Instalar SAMBA
           sudo apt-get install -y samba samba-common libpam-smbpass winbind smbclient libcups2 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Samba</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Samba ..."
           installStatus=$( FINSTALLED "samba" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Samba"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Samba"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Samba instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 15. Instalar PDF Tools
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "PDF")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "pdfmod" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "PDF Tools"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  PDF tools instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
          then
            echo "$LogTime uss: [$userName] 15. Instalar PDF Tools" >> $logFile
            echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar PDF Tools"  
            # Instalar PDF Tools
            sudo apt-get install -y pdfmod pdfshuffler pdfchain 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando PDF Tools ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de PDF Tools ..."
           installStatus=$( FINSTALLED "pdfmod" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "PDF Tools"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "pdfmod"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "PDF Tools"
           fi

            # Actualizar barra de progreso al finalizar
            progressBarVal=$(expr $progressBarVal + $counterInc )  
            echo "# $progressBarVal% completado. $taskNum of $installCount - PDF Tools instalado."  
            taskNum=$(expr $taskNum + 1 )
        fi

    # 16. Instalar SSH Server
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "SSH")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "openssh-server" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "SSH Server"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  SSH Server instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]    
         then
           echo "$LogTime uss: [$userName] 16. Instalar SSH Server" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar SSH Server"  
           # Instalar SSH Server
           sudo apt-get install -y openssh-server 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando SSH Server ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de SSH Server ..."
           installStatus=$( FINSTALLED "openssh-server" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "SSH Server"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "SSH Server"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - SSH Server instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 16.1 Instalar Vinagre
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Vinagre")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "vinagre" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Vinagre"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Vinagre instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 16.1 Instalar Vinagre" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Vinagre"  
           # Instalar Vinagre
           sudo apt-get install -y vinagre 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Vinagre ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Vinagre ..."
           installStatus=$( FINSTALLED "vinagre" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Vinagre"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "vinagre"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Vinagre"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Vinagre instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 17. Instalar FileZilla
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "FileZilla")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "filezilla" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "FileZilla"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  FileZilla instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 17. Instalar FileZilla" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar FileZilla"  
           # Instalar FileZilla
           sudo apt-get install -y filezilla 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando FileZilla</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de FileZilla ..."
           installStatus=$( FINSTALLED "filezilla" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "FileZilla"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "filezilla"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "FileZilla"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - FileZilla instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 20.0 Instalar OpenShot
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "OpenShot")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "openshot" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "OpenShot"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  OpenShot instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 20.0 Instalar OpenShot" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar OpenShot"  
           # Instalar OpenShot
           sudo apt-get install -y openshot 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando OpenShot ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de OpenShot ..."
           installStatus=$( FINSTALLED "openshot" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "OpenShot"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "openshot"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "OpenShot"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - OpenShot instalado."  
           taskNum=$(expr $taskNum + 1 )
       fi

    # 20.1 Instalar Kdenlive
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Kdenlive")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "kdenlive" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Kdenlive"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Kdenlive instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 20.1 Instalar Kdenlive" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Kdenlive"  
           # Instalar Kdenlive
           sudo apt-get install -y kdenlive 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Kdenlive ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Kdenlive ..."
           installStatus=$( FINSTALLED "kdenlive" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Kdenlive"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "kde4-kdenlive"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Kdenlive"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Kdenlive instalado."  
           taskNum=$(expr $taskNum + 1 )
       fi

    # 21. Instalar HandBrake
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "HandBrake")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "handbrake-gtk" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "HandBrake"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  HandBrake instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 21. Instalar HandBrake" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Handbrake"  
           # Añadir repositorio de Handbrake PPA  

           ## Add for all before 13.04
           if [ $(echo "$ubuntuVerRel < 13.04" | bc ) -eq 1 ] 
             then
               sudo add-apt-repository -y ppa:stebbins/handbrake-releases  2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo HandBrake PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
               # Actualizar Repositorios
               sudo apt-get --quiet update 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           fi
           ## Add Quantal for Raring because PPA is not updated yet NOTE : Temporary
           if [ $(echo "$ubuntuVerRel == 13.04" | bc ) -eq 1 ] 
             then
               sudo add-apt-repository -y 'deb http://ppa.launchpad.net/stebbins/handbrake-releases/ubuntu quantal main'  2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo HandBrake PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
               # Actualizar Repositorios
               sudo apt-get --quiet update 2>&1 | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           fi
          
           # Instalar Handbrake
           sudo apt-get install -y handbrake-gtk 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando HandBrake ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Handbrake ..."
           installStatus=$( FINSTALLED "handbrake-gtk" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Handbrake"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "ghb"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Handbrake"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Handbrake instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 22. Instalar Audacity
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Audacity")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "audacity" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Audacity"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Audacity instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 22. Instalar Audacity" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Audacity"  
           # Instalar Audacity
           sudo apt-get install -y audacity 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Audacity ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Audacity ..."
           installStatus=$( FINSTALLED "audacity" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Audacity"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "audacity"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Audacity"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Audacity instalado."  
           taskNum=$(expr $taskNum + 1 )
       fi

    # 23. Instalar Steam
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Steam")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "steam" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Steam"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Steam instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 23. Instalar Steam" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Steam"  
           # Instalar Steam
           sudo apt-get install -y steam 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Steam ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Steam ..."
           installStatus=$( FINSTALLED "steam" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Steam"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "steam"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Steam"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Steam instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

    # 24. Instalar KeePassX
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "KeePassX")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "keepassx" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "KeePassX"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  KeePassX instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]  
         then
           echo "$LogTime uss: [$userName] 24. Instalar KeePassX" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar KeePassX"  
           # Instalar KeePassX
           sudo apt-get install -y keepassx 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando KeePassX ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de KeepassX ..."
           installStatus=$( FINSTALLED "keepassx" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "KeepassX"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "keepassx"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "KeepassX"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - KeePassX instalado."  
           taskNum=$(expr $taskNum + 1 )
       fi

    # 25. Instalar Shutter
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Shutter")
        # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "shutter" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Shutter"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Shutter instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ] 
         then
           echo "$LogTime uss: [$userName] 24. Instalar Shutter" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Shutter"  
           # Instalar Shutter
           sudo apt-get install -y shutter 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Shutter ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Shutter ..."
           installStatus=$( FINSTALLED "shutter" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Shutter"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "shutter"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Shutter"
           fi
          
           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Shutter instalado." 
           taskNum=$(expr $taskNum + 1 )
       fi
       
       # 26. Instalar Audacious
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Audacious")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "audacious" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Audacious"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Audacious instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Audacious" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Audacious"  
           # Añadir repositorio de Audacious PPA  
           sudo add-apt-repository -y ppa:nilarimogard/webupd8 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Audacious PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Audacious
           sudo apt-get install -y audacious 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Audacious ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Audacious ..."
           installStatus=$( FINSTALLED "audacious" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Audacious"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "audacious"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Audacious"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Audacious instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
		# 27. Instalar Jdownloader
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Jdownloader")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "jdownloader" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Jdownloader"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Jdownloader instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Jdownloader" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Jdownloader"  
           # Añadir repositorio de Jdownloader PPA  
           sudo add-apt-repository -y ppa:jd-team/jdownloader 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Jdownloader PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Jdownloader
           sudo apt-get install -y jdownloader 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Jdownloader ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Jdownloader ..."
           installStatus=$( FINSTALLED "jdownloader" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Jdownloader"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "jdownloader"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Jdownloader"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Jdownloader instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 28. Instalar Chromium Daily
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Chromium-Daily")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "chromium-browser" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Chromium Daily"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Chromium Daily instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Chromium Daily" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Chromium Daily"  
           # Añadir repositorio de Chromium Daily PPA  
           sudo add-apt-repository -y ppa:chromium-daily/stable 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Chromium Daily PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Chromium Daily
           sudo apt-get install -y chromium-browser chromium-browser-l10n 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Chromium Daily ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Chromium Daily ..."
           installStatus=$( FINSTALLED "chromium-browser" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Chromium Daily"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "chromium-browser"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Chromium Daily"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Chromium Daily instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 29. Instalar Namebench
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Namebench")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "namebench" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Namebench"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Namebench instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Namebench" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Namebench"  
           # Añadir repositorio de Namebench PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Namebench PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Namebench
           sudo apt-get install -y namebench 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Namebench ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Namebench ..."
           installStatus=$( FINSTALLED "namebench" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Namebench"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "namebench"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Namebench"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Namebench instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

	# 30. Instalar Byobu
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Byobu")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "byobu" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Byobu"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Byobu instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Byobu" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Byobu"  
           # Añadir repositorio de Byobu PPA  
           sudo add-apt-repository -y ppa:byobu/ppa 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Byobu PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Byobu
           sudo apt-get install -y byobu 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Byobu ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Byobu ..."
           installStatus=$( FINSTALLED "byobu" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Byobu"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "byobu"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Byobu"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Byobu instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

	# 31. Instalar Firefox Daily
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Firefox-Daily")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "firefox-trunk" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Firefox Daily"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Firefox Daily instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Firefox Daily" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Firefox Daily"  
           # Añadir repositorio de Firefox Daily PPA  
           sudo add-apt-repository -y ppa:ubuntu-mozilla-daily/ppa 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Firefox Daily PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Firefox Daily
           sudo apt-get install -y firefox-trunk 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Firefox Daily ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Firefox Daily ..."
           installStatus=$( FINSTALLED "firefox-trunk" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Firefox Daily"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "firefox-trunk"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Firefox Daily"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Firefox Daily instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
	# 32. Instalar Cinelerra
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Cinelerra")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "cinelerra-cv" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Cinelerra"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Cinelerra instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Cinelerra" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Cinelerra"  
           # Añadir repositorio de Cinelerra PPA  
           sudo add-apt-repository -y ppa:cinelerra-ppa/ppa 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Cinelerra PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Cinelerra
           sudo apt-get install -y cinelerra-cv 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Cinelerra ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Cinelerra ..."
           installStatus=$( FINSTALLED "cinelerra-cv" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Cinelerra"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "cinelerra"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Cinelerra"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Cinelerra instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
    # 33. Instalar Ubuntu Tweak
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Ubuntu-Tweak")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "ubuntu-tweak" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Ubuntu Tweak"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Ubuntu Tweak instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Ubuntu Tweak" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Ubuntu Tweak"  
           # Añadir repositorio de Ubuntu Tweak PPA  
           sudo add-apt-repository -y ppa:ubuntu-tweak-testing/ppa 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Ubuntu Tweak PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Ubuntu Tweak
           sudo apt-get install -y ubuntu-tweak 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Ubuntu Tweak ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Ubuntu Tweak ..."
           installStatus=$( FINSTALLED "ubuntu-tweak" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Ubuntu Tweak"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "ubuntu-tweak"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Ubuntu Tweak"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Ubuntu Tweak instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
    # 34. Instalar Wine
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Wine")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "wine1.5" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Wine"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Wine instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Wine" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Wine"  
           # Añadir repositorio de Wine PPA  
           sudo add-apt-repository -y ppa:ubuntu-wine/ppa 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Wine PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Wine
           sudo apt-get install -y wine1.5 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Wine ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Wine ..."
           installStatus=$( FINSTALLED "wine1.5" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Wine"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "wine1.5"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Wine"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Wine instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
    # 35. Instalar Indicator Keylock
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Indicator-Keylock")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "indicator-keylock" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Indicator Keylock"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Indicator Keylock instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Indicator Keylock" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Indicator Keylock"  
           # Añadir repositorio de Indicator Keylock PPA  
           sudo add-apt-repository -y ppa:tsbarnes/indicator-keylock 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Indicator Keylock PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Indicator Keylock
           sudo apt-get install -y indicator-keylock 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Indicator Keylock ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Indicator Keylock ..."
           installStatus=$( FINSTALLED "indicator-keylock" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Indicator Keylock"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "keylock"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Indicator Keylock"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Indicator Keylock instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
    # 36. Instalar Indicator Multiload
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Indicator-Multiload")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "indicator-multiload" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Indicator Multiload"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Indicator Multiload instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Indicator Multiload" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Indicator Multiload"  
           # Añadir repositorio de Indicator Multiload PPA  
           sudo add-apt-repository -y ppa:indicator-multiload/stable-daily 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Indicator Multiload PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Indicator Multiload
           sudo apt-get install -y indicator-multiload 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Indicator Multiload ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Indicator Multiload ..."
           installStatus=$( FINSTALLED "indicator-multiload" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Indicator Multiload"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "indicator-multiload"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Indicator Multiload"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Indicator Multiload instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi

	# 37. Instalar Pinta
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Pinta")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "pinta" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Pinta"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Pinta instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Pinta" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Pinta"  
           # Añadir repositorio de Pinta PPA  
           sudo add-apt-repository -y ppa:pinta-maintainers/pinta-stable 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Pinta PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Pinta
           sudo apt-get install -y pinta 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Pinta ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Pinta ..."
           installStatus=$( FINSTALLED "pinta" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Pinta"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "pinta"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Pinta"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Pinta instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
    # 38. Instalar Redimages
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Redimages")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "redimages" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Redimages"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Redimages instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Redimages" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Redimages"  
           # Añadir repositorio de Redimages PPA  
           sudo add-apt-repository -y ppa:upubuntu-com/graphics 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Redimages PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Redimages
           sudo apt-get install -y redimages 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Redimages ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Redimages ..."
           installStatus=$( FINSTALLED "redimages" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Redimages"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "redimages"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Redimages"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Redimages instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi


	# 39. Instalar Emesene
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Emesene")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "emesene" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Emesene"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Emesene instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Emesene" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Emesene"  
           # Añadir repositorio de Emesene PPA  
           sudo add-apt-repository -y ppa:emesene-team/emesene-stable 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Emesene PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Emesene
           sudo apt-get install -y emesene 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Emesene ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Emesene ..."
           installStatus=$( FINSTALLED "emesene" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Emesene"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "emesene"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Emesene"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Emesene instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
    # 40. Instalar Nautilus Actions Extra
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Nautilus-Actions-Extra")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "nautilus-actions-extra" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Nautilus Actions Extra"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Nautilus Actions Extra instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Nautilus Actions Extra" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Nautilus Actions Extra"  
           # Añadir repositorio de Nautilus Actions Extra PPA  
           sudo add-apt-repository -y ppa:nae-team/ppa 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Nautilus Actions Extra PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Nautilus Actions Extra
           sudo apt-get install -y nautilus-actions-extra 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Nautilus Actions Extra ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Nautilus Actions Extra ..."
           installStatus=$( FINSTALLED "nautilus-actions-extra" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Nautilus Actions Extra"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "nautilus-actions-extra"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Nautilus Actions Extra"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Nautilus Actions Extra instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
    # 41. Instalar Y PPA Manager
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Y-PPA-Manager")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "y-ppa-manager" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Y PPA Manager"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Y PPA Manager instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Y PPA Manager" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Y PPA Manager"  
           # Añadir repositorio de Y PPA Manager PPA  
           sudo add-apt-repository -y ppa:webupd8team/y-ppa-manager 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Y PPA Manager PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Y PPA Manager
           sudo apt-get install -y y-ppa-manager 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Y PPA Manager ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Y PPA Manager ..."
           installStatus=$( FINSTALLED "y-ppa-manager" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Y PPA Manager"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "y-ppa-manager"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Y PPA Manager"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Y PPA Manager instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
    # 42. Instalar Window List
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Window-List")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "window-list" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Window List"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Window List instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Window List" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Window List"  
           # Añadir repositorio de Window List PPA  
           sudo add-apt-repository -y ppa:jwigley/window-list 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Window List PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Window List
           sudo apt-get install -y window-list 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Window List ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Window List ..."
           installStatus=$( FINSTALLED "window-list" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Window List"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "window-list"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Window List"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Window List instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
    # 43. Instalar Indicator Stickynotes
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Indicator-Stickynotes")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "indicator-stickynotes" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Indicator Stickynotes"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Indicator Stickynotes instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Indicator Stickynotes" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Indicator Stickynotes"  
           # Añadir repositorio de Indicator Stickynotes PPA  
           sudo add-apt-repository -y ppa:umang/indicator-stickynotes 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Indicator Stickynotes PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Indicator Stickynotes
           sudo apt-get install -y indicator-stickynotes 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Indicator Stickynotes ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Indicator Stickynotes ..."
           installStatus=$( FINSTALLED "indicator-stickynotes" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Indicator Stickynotes"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "indicator-stickynotes"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Indicator Stickynotes"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Indicator Stickynotes instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
    # 44. Instalar Pyenglish
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Pyenglish")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "pyenglish" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Pyenglish"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Pyenglish instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Pyenglish" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Pyenglish"  
           # Añadir repositorio de Pyenglish PPA  
           sudo add-apt-repository -y ppa:costales/pyenglish 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Pyenglish PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Pyenglish
           sudo apt-get install -y pyenglish 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Pyenglish ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Pyenglish ..."
           installStatus=$( FINSTALLED "pyenglish" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Pyenglish"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "pyenglish"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Pyenglish"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Pyenglish instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi 
        
    # 45. Instalar Linux Multimedia Studio
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Linux-Multimedia-Studio")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "lmms-common" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Linux Multimedia Studio"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Linux Multimedia Studio instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Linux Multimedia Studio" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Linux Multimedia Studio"  
           # Añadir repositorio de Linux Multimedia Studio PPA  
           sudo add-apt-repository -y ppa:dns/sound 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Linux Multimedia Studio PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Linux Multimedia Studio
           sudo apt-get install -y lmms lmms-common 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Linux Multimedia Studio ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Linux Multimedia Studio ..."
           installStatus=$( FINSTALLED "lmms-common" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Linux Multimedia Studio"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "lmms"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Linux Multimedia Studio"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Linux Multimedia Studio instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
####
####
	# 10. Instalar Moc
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Moc")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "moc" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Moc"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Moc instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Moc" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Moc"  
           # Añadir repositorio de Moc PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Moc PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Moc
           sudo apt-get install -y moc 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Moc ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Moc ..."
           installStatus=$( FINSTALLED "moc" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Moc"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "moc"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Moc"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Moc instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
		
		# 10. Instalar Sound Converter
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Soundconverter")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "soundconverter" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Sound Converter"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Sound Converter instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Sound Converter" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Sound Converter"  
           # Añadir repositorio de Sound Converter PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Sound Converter PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Sound Converter
           sudo apt-get install -y soundconverter 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Sound Converter ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Sound Converter ..."
           installStatus=$( FINSTALLED "soundconverter" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Sound Converter"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "soundconverter"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Sound Converter"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Sound Converter instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        
		# 10. Instalar Gnome Paint
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Gnome-Paint")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "gnome-paint" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Gnome Paint"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Gnome Paint instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Gnome Paint" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Gnome Paint"  
           # Añadir repositorio de Gnome Paint PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Gnome Paint PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Gnome Paint
           sudo apt-get install -y gnome-paint 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Gnome Paint ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Gnome Paint ..."
           installStatus=$( FINSTALLED "gnome-paint" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Gnome Paint"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "gnome-paint"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Gnome Paint"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Gnome Paint instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Pidgin
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Pidgin")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "pidgin" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Pidgin"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Pidgin instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Pidgin" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Pidgin"  
           # Añadir repositorio de Pidgin PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Pidgin PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Pidgin
           sudo apt-get install -y pidgin 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Pidgin ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Pidgin ..."
           installStatus=$( FINSTALLED "pidgin" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Pidgin"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "pidgin"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Pidgin"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Pidgin instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Amule
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Amule")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "amule" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Amule"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Amule instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Amule" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Amule"  
           # Añadir repositorio de Amule PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Amule PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Amule
           sudo apt-get install -y amule 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Amule ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Amule ..."
           installStatus=$( FINSTALLED "amule" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Amule"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "amule"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Amule"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Amule instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
                
        # 10. Instalar Dia
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Dia")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "dia" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Dia"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Dia instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Dia" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Dia"  
           # Añadir repositorio de Dia PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Dia PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Dia
           sudo apt-get install -y dia 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Dia ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Dia ..."
           installStatus=$( FINSTALLED "dia" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Dia"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "dia"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Dia"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Dia instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar OCRfeeder
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "OCRfeeder")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "ocrfeeder" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "OCRfeeder"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  OCRfeeder instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar OCRfeeder" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar OCRfeeder"  
           # Añadir repositorio de OCRfeeder PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo OCRfeeder PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar OCRfeeder
           sudo apt-get install -y ocrfeeder 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando OCRfeeder ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de OCRfeeder ..."
           installStatus=$( FINSTALLED "ocrfeeder" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "OCRfeeder"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "ocrfeeder"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "OCRfeeder"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - OCRfeeder instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar PDF Edit
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "PDFedit")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "pdfedit" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "PDF Edit"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  PDF Edit instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar PDF Edit" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar PDF Edit"  
           # Añadir repositorio de PDF Edit PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo PDF Edit PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar PDF Edit
           sudo apt-get install -y pdfedit 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando PDF Edit ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de PDF Edit ..."
           installStatus=$( FINSTALLED "pdfedit" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "PDF Edit"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "pdfedit"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "PDF Edit"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - PDF Edit instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Simple Scan
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Simple-Scan")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "simple-scan" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Simple Scan"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Simple Scan instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Simple Scan" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Simple Scan"  
           # Añadir repositorio de Simple Scan PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Simple Scan PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Simple Scan
           sudo apt-get install -y simple-scan 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Simple Scan ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Simple Scan ..."
           installStatus=$( FINSTALLED "simple-scan" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Simple Scan"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "simple-scan"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Simple Scan"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Simple Scan instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar GScan2PDF
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "GScan2PDF")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "gscan2pdf" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "GScan2PDF"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  GScan2PDF instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar GScan2PDF" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar GScan2PDF"  
           # Añadir repositorio de GScan2PDF PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo GScan2PDF PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar GScan2PDF
           sudo apt-get install -y gscan2pdf 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando GScan2PDF ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de GScan2PDF ..."
           installStatus=$( FINSTALLED "gscan2pdf" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "GScan2PDF"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "gscan2pdf"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "GScan2PDF"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - GScan2PDF instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Avidemux
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Avidemux")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "avidemux" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Avidemux"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Avidemux instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Avidemux" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Avidemux"  
           # Añadir repositorio de Avidemux PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Avidemux PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Avidemux
           sudo apt-get install -y avidemux 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Avidemux ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Avidemux ..."
           installStatus=$( FINSTALLED "avidemux" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Avidemux"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "avidemux"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Avidemux"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Avidemux instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Kino
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Kino")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "kino" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Kino"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Kino instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Kino" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Kino"  
           # Añadir repositorio de Kino PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Kino PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Kino
           sudo apt-get install -y kino 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Kino ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Kino ..."
           installStatus=$( FINSTALLED "kino" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Kino"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "kino"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Kino"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Kino instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Pitivi
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Pitivi")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "pitivi" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Pitivi"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Pitivi instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Pitivi" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Pitivi"  
           # Añadir repositorio de Pitivi PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Pitivi PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Pitivi
           sudo apt-get install -y pitivi 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Pitivi ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Pitivi ..."
           installStatus=$( FINSTALLED "pitivi" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Pitivi"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "pitivi"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Pitivi"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Pitivi instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Cheese
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Cheese")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "cheese" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Cheese"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Cheese instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Cheese" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Cheese"  
           # Añadir repositorio de Cheese PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Cheese PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Cheese
           sudo apt-get install -y cheese 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Cheese ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Cheese ..."
           installStatus=$( FINSTALLED "cheese" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Cheese"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "cheese"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Cheese"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Cheese instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Gnome Recorder
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Gnome-Recorder")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "recordmydesktop" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Gnome Recorder"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Gnome Recorder instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Gnome Recorder" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Gnome Recorder"  
           # Añadir repositorio de Gnome Recorder PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Gnome Recorder PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Gnome Recorder
           sudo apt-get install -y recordmydesktop 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Gnome Recorder ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Gnome Recorder ..."
           installStatus=$( FINSTALLED "recordmydesktop" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Gnome Recorder"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "recordmydesktop"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Gnome Recorder"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Gnome Recorder instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Winff
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Winff")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "winff" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Winff"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Winff instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Winff" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Winff"  
           # Añadir repositorio de Winff PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Winff PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Winff
           sudo apt-get install -y ffmpeg winff 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Winff ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Winff ..."
           installStatus=$( FINSTALLED "winff" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Winff"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "winff"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Winff"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Winff instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Transmageddon
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Transmageddon")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "transmageddon" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Transmageddon"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Transmageddon instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Transmageddon" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Transmageddon"  
           # Añadir repositorio de Transmageddon PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Transmageddon PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Transmageddon
           sudo apt-get install -y transmageddon 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Transmageddon ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Transmageddon ..."
           installStatus=$( FINSTALLED "transmageddon" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Transmageddon"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "transmageddon"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Transmageddon"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Transmageddon instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        
        # 10. Instalar K3B
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "K3B")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "k3b" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "K3B"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  K3B instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar K3B" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar K3B"  
           # Añadir repositorio de K3B PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo K3B PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar K3B
           sudo apt-get install -y k3b 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando K3B ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de K3B ..."
           installStatus=$( FINSTALLED "k3b" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "K3B"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "k3b"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "K3B"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - K3B instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar AcetoneISO
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "AcetoneISO")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "acetoneiso" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "AcetoneISO"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  AcetoneISO instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar AcetoneISO" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar AcetoneISO"  
           # Añadir repositorio de AcetoneISO PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo AcetoneISO PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar AcetoneISO
           sudo apt-get install -y acetoneiso 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando AcetoneISO ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de AcetoneISO ..."
           installStatus=$( FINSTALLED "acetoneiso" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "AcetoneISO"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "acetoneiso"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "AcetoneISO"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - AcetoneISO instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Isomaster
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Isomaster")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "isomaster" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Isomaster"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Isomaster instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Isomaster" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Isomaster"  
           # Añadir repositorio de Isomaster PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Isomaster PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Isomaster
           sudo apt-get install -y isomaster 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Isomaster ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Isomaster ..."
           installStatus=$( FINSTALLED "isomaster" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Isomaster"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "isomaster"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Isomaster"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Isomaster instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Geany
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Geany")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "geany" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Geany"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Geany instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Geany" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Geany"  
           # Añadir repositorio de Geany PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Geany PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Geany
           sudo apt-get install -y geany 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Geany ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Geany ..."
           installStatus=$( FINSTALLED "geany" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Geany"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "geany"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Geany"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Geany instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Htop
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Htop")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "htop" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Htop"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Htop instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Htop" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Htop"  
           # Añadir repositorio de Htop PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Htop PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Htop
           sudo apt-get install -y htop 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Htop ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Htop ..."
           installStatus=$( FINSTALLED "htop" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Htop"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "htop"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Htop"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Htop instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Gnome System Log
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Gnome-System-Log")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "gnome-system-log" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Gnome System Log"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Gnome System Log instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Gnome System Log" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Gnome System Log"  
           # Añadir repositorio de Gnome System Log PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Gnome System Log PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Gnome System Log
           sudo apt-get install -y gnome-system-log 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Gnome System Log ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Gnome System Log ..."
           installStatus=$( FINSTALLED "gnome-system-log" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Gnome System Log"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "gnome-system-log"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Gnome System Log"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Gnome System Log instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Gparted
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Gparted")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "gparted" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Gparted"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Gparted instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Gparted" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Gparted"  
           # Añadir repositorio de Gparted PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Gparted PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Gparted
           sudo apt-get install -y gparted 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Gparted ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Gparted ..."
           installStatus=$( FINSTALLED "gparted" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Gparted"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "gparted"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Gparted"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Gparted instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Synaptic
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Synaptic")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "synaptic" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Synaptic"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Synaptic instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Synaptic" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Synaptic"  
           # Añadir repositorio de Synaptic PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Synaptic PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Synaptic
           sudo apt-get install -y synaptic 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Synaptic ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Synaptic ..."
           installStatus=$( FINSTALLED "synaptic" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Synaptic"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "synaptic"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Synaptic"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Synaptic instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Qalculate
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Qalculate")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "qalculate" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Qalculate"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Qalculate instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Qalculate" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Qalculate"  
           # Añadir repositorio de Qalculate PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Qalculate PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Qalculate
           sudo apt-get install -y qalculate 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Qalculate ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Qalculate ..."
           installStatus=$( FINSTALLED "qalculate" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Qalculate"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "qalculate"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Qalculate"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Qalculate instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Abuse
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Abuse")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "abuse" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Abuse"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Abuse instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Abuse" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Abuse"  
           # Añadir repositorio de Abuse PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Abuse PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Abuse
           sudo apt-get install -y abuse 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Abuse ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Abuse ..."
           installStatus=$( FINSTALLED "abuse" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Abuse"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "abuse"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Abuse"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Abuse instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Gdebi
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Gdebi")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "gdebi" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Gdebi"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Gdebi instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Gdebi" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Gdebi"  
           # Añadir repositorio de Gdebi PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Gdebi PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Gdebi
           sudo apt-get install -y gdebi 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Gdebi ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Gdebi ..."
           installStatus=$( FINSTALLED "gdebi" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Gdebi"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "gdebi"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Gdebi"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Gdebi instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Mplayer
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Mplayer")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "mplayer" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Mplayer"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Mplayer instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Mplayer" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Mplayer"  
           # Añadir repositorio de Mplayer PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Mplayer PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Mplayer
           sudo apt-get install -y mplayer 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Mplayer ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Mplayer ..."
           installStatus=$( FINSTALLED "mplayer" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Mplayer"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "mplayer"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Mplayer"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Mplayer instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Elinks
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Elinks")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "elinks" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Elinks"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Elinks instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Elinks" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Elinks"  
           # Añadir repositorio de Elinks PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Elinks PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Elinks
           sudo apt-get install -y elinks 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Elinks ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Elinks ..."
           installStatus=$( FINSTALLED "elinks" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Elinks"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "elinks"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Elinks"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Elinks instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Mc
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Mc")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "mc" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Mc"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Mc instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Mc" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Mc"  
           # Añadir repositorio de Mc PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Mc PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Mc
           sudo apt-get install -y mc 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Mc ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Mc ..."
           installStatus=$( FINSTALLED "mc" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Mc"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "mc"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Mc"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Mc instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Emacs
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Emacs")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "emacs" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Emacs"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Emacs instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Emacs" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Emacs"  
           # Añadir repositorio de Emacs PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Emacs PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Emacs
           sudo apt-get install -y emacs 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Emacs ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Emacs ..."
           installStatus=$( FINSTALLED "emacs" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Emacs"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "emacs"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Emacs"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Emacs instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar BSDGames
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "BSDGames")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "bsdgames" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "BSDGames"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  BSDGames instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar BSDGames" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar BSDGames"  
           # Añadir repositorio de BSDGames PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo BSDGames PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar BSDGames
           sudo apt-get install -y bsdgames 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando BSDGames ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de BSDGames ..."
           installStatus=$( FINSTALLED "bsdgames" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "BSDGames"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "bsdgames"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "BSDGames"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - BSDGames instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Xtron
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Xtron")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "xtron" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Xtron"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Xtron instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Xtron" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Xtron"  
           # Añadir repositorio de Xtron PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Xtron PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Xtron
           sudo apt-get install -y xtron 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Xtron ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Xtron ..."
           installStatus=$( FINSTALLED "xtron" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Xtron"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "xtron"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Xtron"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Xtron instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Gnome System Tools
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Gnome-System-Tools")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "gnome-system-tools" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Gnome System Tools"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Gnome System Tools instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Gnome System Tools" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Gnome System Tools"  
           # Añadir repositorio de Gnome System Tools PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Gnome System Tools PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Gnome System Tools
           sudo apt-get install -y gnome-system-tools 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Gnome System Tools ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Gnome System Tools ..."
           installStatus=$( FINSTALLED "gnome-system-tools" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Gnome System Tools"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "gnome-system-tools"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Gnome System Tools"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Gnome System Tools instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Compiz Config Manager
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Compiz-Config-Manager")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "compizconfig-settings-manager" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Compiz Config Manager"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Compiz Config Manager instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Compiz Config Manager" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Compiz Config Manager"  
           # Añadir repositorio de Compiz Config Manager PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Compiz Config Manager PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Compiz Config Manager
           sudo apt-get install -y compizconfig-settings-manager 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Compiz Config Manager ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Compiz Config Manager ..."
           installStatus=$( FINSTALLED "compizconfig-settings-manager" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Compiz Config Manager"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "compizconfig-settings-manager"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Compiz Config Manager"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Compiz Config Manager instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar LmSensors
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "LmSensors")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "lm-sensors" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "LmSensors"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  LmSensors instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar LmSensors" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar LmSensors"  
           # Añadir repositorio de LmSensors PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo LmSensors PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar LmSensors
           sudo apt-get install -y lm-sensors 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando LmSensors ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de LmSensors ..."
           installStatus=$( FINSTALLED "lm-sensors" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "LmSensors"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "lm-sensors"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "LmSensors"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - LmSensors instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Gkrellm
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Gkrellm")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "gkrellm" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Gkrellm"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Gkrellm instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Gkrellm" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Gkrellm"  
           # Añadir repositorio de Gkrellm PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Gkrellm PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Gkrellm
           sudo apt-get install -y gkrellm 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Gkrellm ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Gkrellm ..."
           installStatus=$( FINSTALLED "gkrellm" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Gkrellm"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "gkrellm"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Gkrellm"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Gkrellm instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Cups PDF
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Cups-PDF")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "cups-pdf" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Cups PDF"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Cups PDF instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Cups PDF" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Cups PDF"  
           # Añadir repositorio de Cups PDF PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Cups PDF PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Cups PDF
           sudo apt-get install -y cups-pdf 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Cups PDF ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Cups PDF ..."
           installStatus=$( FINSTALLED "cups-pdf" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Cups PDF"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "cups-pdf"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Cups PDF"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Cups PDF instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Lshw
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Lshw")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "lshw" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Lshw"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Lshw instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Lshw" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Lshw"  
           # Añadir repositorio de Lshw PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Lshw PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Lshw
           sudo apt-get install -y lshw lshw-gtk 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Lshw ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Lshw ..."
           installStatus=$( FINSTALLED "lshw" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Lshw"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "lshw"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Lshw"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Lshw instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Qpxtool
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Qpxtool")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "qpxtool" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Qpxtool"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Qpxtool instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Qpxtool" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Qpxtool"  
           # Añadir repositorio de Qpxtool PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Qpxtool PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Qpxtool
           sudo apt-get install -y qpxtool 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Qpxtool ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Qpxtool ..."
           installStatus=$( FINSTALLED "qpxtool" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Qpxtool"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "qpxtool"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Qpxtool"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Qpxtool instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Basket
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Basket")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "basket" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Basket"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Basket instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Basket" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Basket"  
           # Añadir repositorio de Basket PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Basket PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Basket
           sudo apt-get install -y basket 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Basket ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Basket ..."
           installStatus=$( FINSTALLED "basket" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Basket"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "basket"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Basket"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Basket instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Calibre
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Calibre")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "calibre" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Calibre"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Calibre instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Calibre" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Calibre"  
           # Añadir repositorio de Calibre PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Calibre PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Calibre
           sudo apt-get install -y calibre 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Calibre ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Calibre ..."
           installStatus=$( FINSTALLED "calibre" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Calibre"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "calibre"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Calibre"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Calibre instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Wallch
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Wallch")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "wallch" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Wallch"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Wallch instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Wallch" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Wallch"  
           # Añadir repositorio de Wallch PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Wallch PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Wallch
           sudo apt-get install -y wallch 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Wallch ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Wallch ..."
           installStatus=$( FINSTALLED "wallch" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Wallch"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "wallch"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Wallch"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Wallch instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Slurm
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Slurm")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "slurm" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Slurm"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Slurm instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Slurm" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Slurm"  
           # Añadir repositorio de Slurm PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Slurm PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Slurm
           sudo apt-get install -y slurm 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Slurm ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Slurm ..."
           installStatus=$( FINSTALLED "slurm" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Slurm"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "slurm"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Slurm"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Slurm instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Screenlets
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Screenlets")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "screenlets" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Screenlets"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Screenlets instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Screenlets" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Screenlets"  
           # Añadir repositorio de Screenlets PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Screenlets PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Screenlets
           sudo apt-get install -y screenlets 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Screenlets ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Screenlets ..."
           installStatus=$( FINSTALLED "screenlets" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Screenlets"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "screenlets"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Screenlets"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Screenlets instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Qtnx
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Qtnx")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "qtnx" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Qtnx"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Qtnx instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Qtnx" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Qtnx"  
           # Añadir repositorio de Qtnx PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Qtnx PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Qtnx
           sudo apt-get install -y qtnx 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Qtnx ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Qtnx ..."
           installStatus=$( FINSTALLED "qtnx" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Qtnx"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "qtnx"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Qtnx"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Qtnx instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar UFW
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "UFW")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "ufw" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "UFW"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  UFW instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar UFW" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar UFW"  
           # Añadir repositorio de UFW PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo UFW PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar UFW
           sudo apt-get install -y ufw gufw 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando UFW ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de UFW ..."
           installStatus=$( FINSTALLED "ufw" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "UFW"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "ufw"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "UFW"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - UFW instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi        
              
        # 10. Instalar PlayOnLinux
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "PlayOnLinux")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "playonlinux" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "PlayOnLinux"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  PlayOnLinux instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar PlayOnLinux" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar PlayOnLinux"  
           # Añadir repositorio de PlayOnLinux PPA  
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo PlayOnLinux PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar PlayOnLinux
           sudo apt-get install -y playonlinux 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando PlayOnLinux ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de PlayOnLinux ..."
           installStatus=$( FINSTALLED "playonlinux" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "PlayOnLinux"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "playonlinux"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "PlayOnLinux"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - PlayOnLinux instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Virtualbox 4.1
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "VirtualBox-4.1")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "virtualbox" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "VirtualBox 4.1"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  VirtualBox 4.1 instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar VirtualBox 4.1 " >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar VirtualBox 4.1"  
           # Añadir repositorio de Virtualbox PPA  
		   #wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
		   #sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" > /etc/apt/sources.list.d/virtualbox.list'
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Virtualbox PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           #sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Virtualbox
           sudo apt-get install -y virtualbox virtualbox-guest-additions-iso 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Virtualbox ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           #Añadir el usuario al grupo de VirtualBox para poder usar los USB
           sudo usermod -aG vboxusers $USER
           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de VirtualBox 4.1..."
           installStatus=$( FINSTALLED "virtualbox" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Virtualbox"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "virtualBox 4.1"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "VirtualBox 4.1"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Virtualbox 4.1 instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Virtualbox 4.2
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "VirtualBox-4.2")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "virtualbox-4.2" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "VirtualBox 4.2"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  VirtualBox 4.2 instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar VirtualBox 4.2" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar VirtualBox 4.2"  
           # Añadir repositorio de Virtualbox PPA  
		   wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
           sudo sh -c 'echo "deb http://download.virtualbox.org/virtualbox/debian $(lsb_release -sc) contrib" >> /etc/apt/sources.list'
           #sudo add-apt-repository -y [PPA] 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Virtualbox PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Virtualbox
           sudo apt-get install -y virtualbox-4.2 virtualbox-guest-additions-iso 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Virtualbox ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           #Añadir el usuario al grupo de VirtualBox para poder usar los USB
           sudo usermod -aG vboxusers $USER
           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de VirtualBox 4.2..."
           installStatus=$( FINSTALLED "virtualbox-4.2" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "VirtualBox 4.2"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "virtualBox 4.2"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "VirtualBox 4.2"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Virtualbox 4.2 instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
        # 10. Instalar Classicmenu Indicator
    echo "$progressBarVal" ; sleep 0.1
       option=$(echo $selection | grep -c "Classicmenu-Indicator")
       # Comprobar si está seleccionada 
       if [ "$option" -eq "1" ] 
         then
           # Comprobar si el programa está instalado
           echo "# $progressBarVal% completado. $taskNum of $installCount - Comprobando software instalado"
           installStatus=$( FINSTALLED "classicmenu-indicator" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               FINSTALLOK "Classicmenu Indicator"
               # Actualizar la barra de progreso 
               progressBarVal=$(expr $progressBarVal + $counterInc )  
               echo "# $progressBarVal% completado. $taskNum of $installCount -  Classicmenu Indicator instalado"  
               taskNum=$(expr $taskNum + 1 )
           fi
       fi
       # Si está seleccionado y no instalado, continuar    
       if [ "$option" -eq "1" ] && [ "$installStatus" = "false" ]   
         then
           echo "$LogTime uss: [$userName] 10. Instalar Classicmenu Indicator" >> $logFile
           echo "# $progressBarVal% completado. $taskNum of $installCount - Instalar Classicmenu Indicator"  
           # Añadir repositorio de Classicmenu Indicator PPA  
           sudo add-apt-repository -y ppa:diesch/testing 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Añadiendo Classicmenu Indicator PPA ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Actualizar Repositorios
           sudo apt-get --quiet update 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Actualizando el Centro de Software ...</b></big>" --width=500 --pulsate --no-cancel --auto-close
           # Instalar Classicmenu Indicator
           sudo apt-get install -y classicmenu-indicator 2>&1 | sed -u 's/.* \([0-9]\+%\)\ \+\([0-9.]\+.\) \(.*\)/\1\n# Downloading at \2\/s, About \3/' | zenity --progress --title="RW Labs - $TFCName" --text="<big><b>Instalando Classicmenu Indicator ...</b></big>" --width=500 --pulsate --no-cancel --auto-close

           # Comprobar si el programa se ha instalado bien
           echo "# $progressBarVal% completado. $taskNum of $installCount - Verificando la instalación de Classicmenu Indicator ..."
           installStatus=$( FINSTALLED "classicmenu-indicator" )
           if [ "$installStatus" = "true" ] 
             then
               # Instalación correcta, añadir a la lista de correctos
               echo "$LogTime uss: [$userName] [OK] Instalación exitosa" >> $logFile
               FINSTALLOK "Classicmenu Indicator"
               # Añadir icono al escritorio y/o sidebar
               FADDLAUNCHER "classicmenu-indicator"
             else
               # Instalación erronea, añadir a la lista de error
               echo "$LogTime uss: [$userName] [ERROR] Instalación erronea" >> $logFile
               FINSTALLERR "Classicmenu Indicator"
           fi

           # Actualizar barra de progreso al finalizar
           progressBarVal=$(expr $progressBarVal + $counterInc )  
           echo "# $progressBarVal% completado. $taskNum of $installCount - Classicmenu Indicator instalado."  
           taskNum=$(expr $taskNum + 1 )
        fi
        
#####
#####

    echo "99"
    echo "# 99% del resumen de la instalación" ; sleep 0.1
    
    # Acabada la instalación...
    zenity --list --title="$TFCName $TFCVersion - Resumen de la instalación" --text="<b>RW Labs</b>\nVisita: <tt><a href='http://www.lunaticgeek.com'>www.lunaticgeek.com</a></tt>"  --ok-label="Hecho" --checklist --separator="," --column="Instalado" --column="Programa" --column="Instalar" "${installChkLog[@]}" --width=800 --height=600

    echo "# 100% Completado." ; sleep 0.1

    # Fin del código de Zenity
    ) |
    zenity --progress \
           --title="RW Labs - $TFCName" \
           --text="Instalando los extras que faltan..." \
           --width=500 \
           --ok-label="Acabado (por fin)" \
           --percentage=0 
           

    if [ "$?" = -1 ] ; then
      zenity --error \
             --text="Installation canceled."
    fi


  fi

# Ya está (Por fin).

clear
echo '' 
echo '' 
echo '######################'
echo '#        FIN         #'
echo '######################'
# Mensaje para finalizacion
echo ''
echo '------------------------'
echo 'OPERACIONES FINALIZADAS'
echo '------------------------'
echo ''
echo ''
echo 'Colaboradores:' 
echo '' 
echo 'edkalrio'
echo 'bpmircea'
echo '' 
echo '' 
echo 'Agradecimientos'
echo ''
echo 'Ubuntu After Install'
echo ''
echo ''
echo '...Pulse una tecla para salir'
read salir

exit;

###
###
###




