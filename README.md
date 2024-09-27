# Linux_Ramdisk

Script de bash para crear un disco virtual en la RAM.

Se pueden configurar los siguientes valores:

- Ruta del directorio a montar
- Tamaño

**Requerimientos:**

Instalación de `dialog` para la interfaz grafica del programa

**Notas:**

- Ejemplo para desmontar la ramdisk creada:
 
> sudo umount /mnt/my_ramdisk

- Eliminar el directorio sin usar:

> sudo rm -r /mnt/my_ramdisk

