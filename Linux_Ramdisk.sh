#!/bin/bash
# -*- ENCODING: UTF-8 -*-

main()
{
	local titulo="CREATING - VIRTUAL DISK ON RAM"
	local ramdisk_path=""
	local ramdisk_path_default="/mnt/ramdisk"
	local ramdisk_min_size=1
	local ramdisk_max_size=$(free -m | awk '/^Mem:/{print $4}')
	local ramdisk_size=$ramdisk_min_size
	local opcion_valida="false"
	while [ $opcion_valida = "false" ]
	do
	    clear
        regex_ramdisk_size='^[0-9]+$'
        ramdisk_size=$(input_custom_ramdisk_size "$titulo" "\n\n ❯ Ingresar el tamaño (MB) \n\n RegEx: ^[0-9]+$ \n\n Espacio disponible:  $ramdisk_max_size (MB) \n " 15 48 "$ramdisk_size")
        if [[ (-n "$ramdisk_size") && ("$ramdisk_size" =~ $regex_ramdisk_size) ]]; then
        {
            if [[ $ramdisk_size -ge $ramdisk_min_size && $ramdisk_size -le $ramdisk_max_size ]]; then
            {
                regex_ramdisk_path='^(/[A-Za-z0-9.]+[-A-Za-z0-9_]*)+$'
                ramdisk_path=$(input_custom_ramdisk_path "$titulo" "\n\n ❯ Ruta del archivo \n\n RegEx: ^(/[A-Za-z0-9.]+[-A-Za-z0-9_]*)+$ \n " 13 48 "$ramdisk_path_default-$(date +"%d%m%y-%H%M%S")-$ramdisk_size-MB")
                if [[ (-n "$ramdisk_path") && ("$ramdisk_path" =~ $regex_ramdisk_path) ]]; then
                {
                    opcion_valida="true"
                    (dialog --title "$titulo" \
                        --stdout \
                        --yesno "\n [ Ruta ]\n ❯ $ramdisk_path\n\n [ Tamaño ]\n ❯ $ramdisk_size MB\n\n [ Espacio restante ]\n ❯ $((ramdisk_max_size-ramdisk_size)) MB\n\n ¿Desea continuar?" 16 46)
                    returncode=$?
                    if [[ $returncode = 0 ]]; then
                    {
                        if [ ! -d "$ramdisk_path" ]; then
                        {
                            (dialog --title "$titulo" \
                                --stdout \
                                --yesno "\n\n La ruta $ramdisk_path no existe !!\n\n ¿Desea crearlo y continuar?" 11 50)
                            returncode=$?
                            if [[ $returncode = 0 ]]; then
                            {
                                sudo mkdir -p "$ramdisk_path"
                                create_ramdisk ${ramdisk_path} ${ramdisk_size}
                            }
                            else
                            {
                                show_custom_message "$titulo" "\n\n La creación de la ramdisk fue cancelada !!\n\n Codigo de error: $?" 11 50
                                opcion_valida="false"
                                break
                            }
                            fi
                        }
                        else
                        {
                            create_ramdisk ${ramdisk_path} ${ramdisk_size}
                        }
                        fi
                    }
                    else
                    {
                        show_custom_message "$titulo" "\n\n La creación de la ramdisk fue cancelada !!\n\n Codigo de error: $?" 10 48
                        opcion_valida="false"
                        break
                    }
                    fi
                }
                else
                {
                    opcion_valida="false"
                    show_custom_message "$titulo" "\n\n La ruta ingresada no es valida!\n" 10 42
                    ramdisk_path=$ramdisk_path_default
                }
                fi
            }
            else
            {
                opcion_valida="false"
                show_custom_message "$titulo" "\n\n Ingrese un valor entre $ramdisk_min_size y $ramdisk_max_size\n" 10 42
                ramdisk_size=$ramdisk_min_size
            }
            fi
        }
        else
        {
            opcion_valida="false"
            show_custom_message "$titulo" "\n\n El valor ingresado tiene que ser numerico!\n" 10 42
            ramdisk_size=$ramdisk_min_size
        }
        fi
    done
    show_custom_message "$titulo" "\n\n           Hasta pronto" 8 40
}

input_custom_ramdisk_path()
{
    local titulo="$1"
    local mensaje_dialog="$2"
    local width="$3"
    local height="$4"
    local default_path="$5"
    ramdisk_path=$(dialog --title "$titulo" \
        --stdout \
        --inputbox "$mensaje_dialog" "$width" "$height" "$default_path")
    echo "$ramdisk_path"
}

input_custom_ramdisk_size()
{
    local titulo="$1"
    local mensaje_dialog="$2"
    local width="$3"
    local height="$4"
    local default_size="$5"
    ramdisk_size=$(dialog --title "$titulo" \
        --stdout \
        --inputbox "$mensaje_dialog" "$width" "$height" "$default_size")
    echo "$ramdisk_size"
}

show_custom_message(){
    local titulo="$1"
    local mensaje_dialog="$2"
    local width="$3"
    local height="$4"
    (dialog --title "$titulo" \
         --stdout \
         --msgbox "$mensaje_dialog" "$width" "$height")
}

create_ramdisk()
{
    local ramdisk_path="$1"
    local ramdisk_size="$2"
    sudo mount -t tmpfs -o size=${ramdisk_size}M tmpfs ${ramdisk_path}
    local ramdisk_status=$(df -h $ramdisk_path)
    show_custom_message "$titulo" "\n\n ❯ Más detalles:\n\n $ramdisk_status\n\n" 13 65
}

main
