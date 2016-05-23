%Script para leer el puerto serial y almacenar los datos en un archivo

%--------------------------------------------------------------------------
%% Archivo y Configuración de adquisición
%Nombre archivo a generar
ruta_archivo = 'TestJSU_ecg8.data'; 

%tiempo de adquisición en segundos
tiempo_adq = input('Acquisition Time'); 
frec = input('Sampling Frequency');

%Acceder al buffer cada 0.2 s
s_tacq = 0.2;

% tamano_linea = round(n_bytes_segundo/2); 
% n_lineas = round(n_bytes_total/tamano_linea);
% n_bytes_total = n_lineas*tamano_linea;
% tiempo_adq_real = n_bytes_total/n_bytes_segundo;

%Permisos de creación, lectura y escritura con añadido de datos
f_id = fopen(ruta_archivo,'a+');

%--------------------------------------------------------------------------
%% Configuración del puerto serial
%Cerrar puertos, en caso de estar abiertos
a = instrfind;
delete(a);

%Configure el puerto
h_serial = serial('COM5'); %Cambie el número de puerto, por el valor adecuado
%h_serial = serial('COM12');
%Se desea acceder al puerto pocas veces por segundo, para garantizar que no
%haya pérdida de datos
%Buffer de 1 segundo
set(h_serial,'InputBufferSize', 10000000);
set(h_serial,'BaudRate',230400); % Cambiar de acuerdo a la configuración
set(h_serial,'Parity','none');
set(h_serial,'StopBits',1);
set(h_serial,'FlowControl','none');

%--------------------------------------------------------------------------
%% Haga la lectura de los datos
display ('Abriendo puerto...');
fopen(h_serial);
display ('¡Puerto abierto!');

s_ttotal = tic;
s_acqtimer = tic;

b_fin = false;
while (~b_fin)
    if (toc(s_acqtimer) >= s_tacq )
        s_BytesNow = h_serial.BytesAvailable;
        %Lea número entero de muestras
        if (s_BytesNow > 0)
            s_BytesToRead = (floor(s_BytesNow/27))*27;
            v_cola = fread(h_serial,s_BytesToRead);
            fseek (f_id,0,'eof');
            fwrite(f_id, v_cola);
            s_tparcial = toc(s_ttotal);
            if (s_tparcial > tiempo_adq)
                b_fin = true;
            end
            s_ptotal = (s_tparcial/tiempo_adq)*100;
            clc;
            display(['Porcentaje leído ', num2str(s_ptotal), '%']);
            s_acqtimer = tic;
        end
    end     
    s_tparcial = toc(s_ttotal);
    if (s_tparcial > tiempo_adq)
        toc(s_ttotal)
        b_fin = true;
    end
end



% while(i <= n_lineas)
%     if (s.BytesAvailable >= tamano_linea)
%         cola = fread(s,tamano_linea);
%         if(i == 1)
%              tic
%             display('Reading...')
%         end
% %       fseek(f_id, 0, 'eof');
%         fwrite(f_id,cola);
%         temp = (i/n_lineas) * 100;
%         clc;
%         display(['Porcentaje leído ', num2str(temp), ' %']);
%         i = i+1;
%         
%         
%     end
% end

fclose(f_id);
fclose(h_serial);
delete(h_serial);
display ('Fin de lectura');
beep