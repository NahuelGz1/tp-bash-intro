#!/bin/bash

#permite nombrar el archivo txt de salida,  en caso de no hacerlo queda FILENAME
: "${FILENAME:=FILENAME}"
export FILENAME

#permite utilizar -d para eliminar entorno 
if [ "$1" = "-d" ]; then
    pkill -f "consolidar.sh" 2>/dev/null
    rm -rf ~/EPNro1
    echo "Entorno eliminado."
    exit 0
fi


cd ~

#menu interactivo
while [ "$opcion" != "7" ]; do
    echo "=== MENU PRINCIPAL ==="
    echo "1) Crear entorno"
    echo "2) Correr proceso"
    echo "3) Listar alumnos ordenados por padron"
    echo "4) Top 10 notas mas altas"
    echo "5) Buscar alumno por padron"
    echo "6) Visualizar log"
    echo "7) Salir"

    read -p "Opcion: " opcion

    case "$opcion" in
	
        #crea el entorno con archivos log, sh, directorios
        1)
            mkdir -p ~/EPNro1/entrada ~/EPNro1/salida ~/EPNro1/procesado
            touch ~/EPNro1/procesado.log
            echo "Entorno y log creado correctamente."
	    touch ~/EPNro1/salida/$FILENAME.txt
	    touch ~/EPNro1/consolidar.sh
	    cat << 'EOF' > ~/EPNro1/consolidar.sh
		#!/bin/bash
		FILENAME="${FILENAME:-FILENAME}"

                #procesa los archivos de entrada para cargarlos al final del archivo txt de salida 
		while true; do
    			for archivo in ~/EPNro1/entrada/*.txt; do
        			if [ -f "$archivo" ]; then
            				FECHA_HORA=$(date "+%d/%m/%Y %H:%M:%S")
            				cat "$archivo" >> ~/EPNro1/salida/$FILENAME.txt
            				echo "$FECHA_HORA - Procesado archivo ${archivo##*/}" >> ~/EPNro1/procesado.log
            				mv "$archivo" ~/EPNro1/procesado/
        			fi
    			done

    			sleep 5
		done
EOF
        	 ;;
	#ejecuta script consolidar.sh
        2)
            bash ~/EPNro1/consolidar.sh &
            ;;
	#ordena los alumnos del archivo txt en salida por padron
        3)
            if [ -f ~/EPNro1/salida/$FILENAME.txt ]; then
                echo "alumnos ordenados por padron"
                sort -n < ~/EPNro1/salida/$FILENAME.txt
            else
                echo "El archivo $FILENAME.txt no existe en la carpeta salida."
            fi
            ;;
	#muestra las 10 notas mas altas de los alumnos
        4)
            if [ -f ~/EPNro1/salida/$FILENAME.txt ]; then
                echo "TOP 10 notas mas altas"
                awk '{print $NF, $0}' ~/EPNro1/salida/$FILENAME.txt | sort -nr | head -n 10 | cut -d' ' -f2-
            else
                echo "El archivo $FILENAME.txt no existe en la carpeta salida."
            fi
            ;;
	#realiza una busqueda por padron de los alumnos
        5)
            if [ -f ~/EPNro1/salida/$FILENAME.txt ]; then
                read -p "Ingrese el nro de padron: " padron
                resultado=$(grep "^$padron" ~/EPNro1/salida/$FILENAME.txt)
                if [ -n "$resultado" ]; then
                    echo "$resultado"
                else
                    echo "El padron no existe en el archivo."
                fi
            else
                echo "El archivo $FILENAME.txt no existe en la carpeta salida."
            fi
            ;;
	#muestra el contenido procesado.log
        6)
            cat ~/EPNro1/procesado.log
            ;;
	#mata los procesos en segundo plano y sale del script
        7)
	    pkill -f "consolidar.sh" 2>/dev/null 
            exit 0
            ;;
	#se ejecuta si se ingresa una opcion invalida
        *)
            echo "Opción inválida, intente de nuevo."
            ;;
    esac
done
