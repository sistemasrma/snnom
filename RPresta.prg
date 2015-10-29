** otro omentario   ----------------------------------
** otro omentario   ----------------------------------
** otro omentario   ----------------------------------
** otro omentario   ----------------------------------
** otro omentario   ----------------------------------
** otro omentario   ----------------------------------
** otro omentario   ----------------------------------
** otro omentario   ----------------------------------
** este comentario es para JL vea la actualizaion de github


** segundo comentario con JL -------------------------------------




**NOMBRE: rpresta.prg
**OBJETIVO: MUESTRA TABLA DE PAGOS en version imprimible. EN CASO DE REQUERIRSE GUARDA LA SOLICITUD Y LE ASIGNA FOLIO.
**ALCANCE:
**PROCEDIMIENTOS:
**REFERENCIAS CRUZADAS:
**              programas padre: PRESTAMO.HTM
**              programas hijo:
**              base de datos/tabla:
** BITACORA  CAMBIOS(incremental):
**               -Fecha:03.mar.2009 Autor:[Edgan LR]  Descripci๓n: Para prestamos por fondo, se agrega el campo de comision a la tabla.
**               -Fecha:27.ene.2009 Autor:[Edgan LR]  Descripci๓n: Se sustituye por default a un tipo de prestamo por fondo 
**                                                                 las solicitudes que se hicieron del 1 ene 2009 al 25 ene 2009
**                                                                 porque aun no contemplaba el tipo de prestamo el sistema.
**               -Fecha:22.ene.2009 Autor:[Edgan LR]  Descripci๓n: Realiza la tabla de pagos de fondos de prestamo.
**               -Fecha:21.ene.2009 Autor:[Edgan LR]  Descripci๓n: Se verifica que no exista una solicitud pendiente. Se aplican criterios de tipo de prestamo. 
**                                                                  se agregan los campos epr_tipo y epr_int a la tabla c:\intra_db\encprest.d01
**                                                                  se calcula por fondo de ahorro saldo insoluto. 
**               -Fecha:13.nov.2008 Autor:[Edgan LR]  Descripci๓n: Selectivo entre guardar o solo mostrar tabla. Verifica que no se escriba dos veces el prestamo.
**               -Fecha:5.nov.2008 Autor: [Edgan LR] Descripci๓n: Creaci๓n de programa
** COMENTARIOS  :
**               -Fecha:5.nov.2008 Autor:[Edgan LR]  Descripci๓n: Se usa solo este programa para desplegar la tabla de pagos. Ya sea recuperando el folio de prestamo
**                                                              o recibiendo los datos para un preview de pagos.
**--------------------------------
FUNCTION Main(cIniFile)
    LOCAL  cOutFile := ""
    LOCAL  cInpFile := ""
    LOCAL  cInpVars

    // Se declaran las variables que recibe el programa con valores por default. Longitud maxima de nombre 10 caracteres
    // las variables recibidas que vengan vacias, dejan la cadena en blanco
    Encargado:="VACIO"
    Oficina:="VACIO"
    Num:="VACIO"
    Nombre:="VACIO"
    Empresa:="VACIO"
    Monto:="VACIO"
    Semanas:="VACIO"
    SemIni:="VACIO"
    Folio:="VACIO"
    Sueldo:="VACIO"
    Guardar:="NO"
    status="CONSULTA"
    dFecha:=date()
    cHora:=Time()
    nInteres=0
    cComisi:="" // La comision viene del formulario prestamo.prg como cadena aqui se pasa a nComisi como numerica

    PRIVATE aVars
    PRIVATE cFolio

    #include "grump.ch"
    Set Date British
    Set Epoch to 1950
    Set deleted on

    *** Leo parametros que manda la pagina anterior.
    SuperJos(cIniFile,@cOutFile,@cInpFile)
    *** Todo el resto es cgi normal
    cxOutFile := cOutFile
    cInpVars := MemoRead(cInpFile)
    aVars    := SacaVars(cInpVars)

    // Establece el  archivo de salida
    SET PRINTER TO (cOutFile)
    SET DEVICE TO PRINTER

    ** Extraigo clave universal de usuarios y nombre de usuario cNomUsu
    cClaUni:=aVars[1,1]
    ValUsuI04(cClaUni,"")

    cVer:= "rpresta.prg  [Desplegando tabla de pagos de prestamo] Rel. 2009mar03 18_27 Edgan"
    ? cVer
    * Para ver las variables que extraigo
    **VeVarCGI()
    
     ** Valido que el array de valores pasados tenga datos suficientes.
     ValArray(cOutFile,len(aVars),1,"")

    // Ya no se traen datos de usuario desde el programa que hace llamado a este modulo
    ** Reviso si el usuario tiene acceso a este modulo antes de ejecutarlo
    ** y trae el nombre del usuario.
    //ValUsuI04(cClaUni,"int1001")


    // La siguiente funcion es para declarar variables y valores de acuerdo a los parametros recibidos. Elimina dependencia de variable/posicion.
    FOR i := 1 TO LEN(aVars)
        declaraVar:=aVars[i,1]
        If(SubStr(declaraVar,1,8)=="required")
            declaraVar:=SubStr(declaraVar,9,10) //nombre de variable de maximo 7 caracteres quitando required
        Else
            declaraVar:=SubStr(declaraVar,1,10) //nombre de variable de maximo 7 caracteres
        EndIf
        &declaraVar:= aVars[i,2]
        //? "Nombre declarado:" + declaraVar
        //? "Valor declarado:" + &declaraVar
    NEXT
    
    
    //nInteres=VAL(Inter)/100 // Edgan LR   

    // si recibe un Id de prestamo que lo recupere y que calcule.
    
    If Folio<>"VACIO"  && Guardar="NO"  // Es una consulta de folio  
        Use C:\intra_db\encprest.d01 alias prestamos Index c:\intra_db\encprx1.x01 New Shared
        go top
        seek (Folio)    
        If found()            
            Oficina=Prestamos->EPR_FOLIO
            Encargado=Prestamos->EPR_ENCAR
            Oficina=Prestamos->EPR_OFICI
            Num=Prestamos->EPR_NUTRA
            Nombre=Prestamos->EPR_TRABA
            Empresa=Prestamos->EPR_EMPRE
            Monto=Prestamos->EPR_IMPOR
            Semanas=Prestamos->EPR_SEMAN
            Sueldo=Prestamos->EPR_SUELDO
            SemIni=Prestamos->EPR_SEMI
            dFecha:=Prestamos->EPR_FEC
            cHora:=Prestamos->EPR_HORA
            Tipo:=Prestamos->EPR_TIPO
            Inter:=Prestamos->EPR_INTE
            status:=PRESTAMOS->EPR_AUTO 
            cComisi:=PRESTAMOS->EPR_COMISI
        Else
            Mensaback("No se encontro el folio","Por favor avise a sistemas")
        EndIF


//        // >> Edgan 27.ene.2009 Asignacion de tipo de prestamo a los capturados al arranque del 2009 que tuvieron problemas
//        If len(alltrim(Prestamos->EPR_TIPO)) = 0 .AND. YEAR(Prestamos->EPR_FEC)=2009// Para los prestamos que no tienen indicado el tipo de prestamo. Esos campos fueron del 1ene2009 al 26ene2009
//            If REC_LOCK()
//                REPLACE Prestamos->EPR_TIPO WITH "FONDO"   
//                REPLACE Prestamos->EPR_INTE WITH "1.5"
//                Tipo:=Prestamos->EPR_TIPO
//                Inter:=Prestamos->EPR_INTE
//            EndIF            
//        EndIF
//        If len(ALLTRIM(Prestamos->EPR_INTE))=0 .AND. alltrim(Prestamos->EPR_TIPO)="FONDO"
//            If REC_LOCK()
//                REPLACE Prestamos->EPR_INTE WITH "1.5"
//                Inter:=Prestamos->EPR_INTE
//            EndIF                                    
//        EndIF

//        // <<
        Close prestamos
    End If
    
    nInteres=VAL(Inter)/100 //Edgan LR Se mueve aqui para asegurar que ya existe la variable inter, ya sea por valor reibido de form o por un folio
    nComisi:=val(cComisi)/100


    // Valida que se pueda guardar correctamente
    If Guardar="SI"                       

        // Evitar que guarden dos veces el mismo prestamo. esto puede ocurrir con un "actualizar" de la pagina
        Use C:\intra_db\encprest.d01 alias prestamos New Shared
        //Index on alltrim(PRESTAMOS->EPR_NUTRA) + dtos(PRESTAMOS->EPR_FEC) To C:\intra_db\encprx2.x01
        Index on PRESTAMOS->EPR_NUTRA To C:\intra_db\encprx2.x01 // Edgan LR ordena por numero de trabajador para checar que no tenga una solicitud de pendiente.

        go top
        seek alltrim(Num) //revisa que no tenga una solicitud pendiente        
        Do While !Eof() .AND. alltrim(PRESTAMOS->EPR_NUTRA)=alltrim(Num) 
           If PRESTAMOS->EPR_AUTO = "P"
              exit
           EndIF
           skip
        End Do


        SET PRINTER TO (cOutFile)
        SET DEVICE TO PRINTER

        //If found() .AND. ENCPRST->EPR_FEC = DATE() // temporal revisar que no tenga un prestamo pendiente de autorizacion
        If alltrim(PRESTAMOS->EPR_NUTRA)=alltrim(Num) .AND. PRESTAMOS->EPR_AUTO = "P"
            ? "Solicitud pendiente"
            MensaBack("Aviso", "El trabajador tiene una solicitud pendiente de prestamo con el folio:" + '<form name="formConsulta" method="post" action="/PRIVATE/RPRESTA.INT" target="_self">' + ' <input type="hidden" name="' + cClaUni + '" value="0">' + '<input type="hidden" name="Folio" value="' + alltrim(PRESTAMOS->EPR_FOLIO) + '">' + '</form>' + '    <a class="A" href="javascript:document.formConsulta.submit();"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + PRESTAMOS->EPR_FOLIO + '</font></a> <br><br> Dirijase al apartado de autorizaciones para autorizar o cancelar esta solicitud y proceder con una <i>nueva solicitud</i>')
        Else
            USAME("CTRLFINT") // control de folio de prestamo
            GO 2
            IF REC_LOCK()
               REPLACE CTRLFINT->CFI_FOLIO WITH (CTRLFINT->CFI_FOLIO + 1)
                cFolio:=ALLTRIM(STR(CTRLFINT->CFI_FOLIO))
                cFolio:=ReformIz(cFolio,6,"0")
                Folio=cFolio
            ENDIF
            CLOSE CTRLFINT
        EndIf
        Close prestamos



        USAME("ENCPREST")
        SELECT ENCPREST
        IF ADD_REC()
            /*REPLACE  ENCPREST->EPR_FOLIO WITH cFolio // Edgan LR. 5.nov.2008 Se toman los valores por nombre de la variable que genera al recibir parametros
            REPLACE  ENCPREST->EPR_OFICI WITH Oficina
            REPLACE  ENCPREST->EPR_FECHA WITH cVar1(1)
            REPLACE  ENCPREST->EPR_ENCAR WITH cVar1(1)
            REPLACE  ENCPREST->EPR_TRABA WITH cVar1(3)
            REPLACE  ENCPREST->EPR_NUTRA WITH cVar1(4)
            REPLACE  ENCPREST->EPR_EMPRE WITH cVar1(5)
            REPLACE  ENCPREST->EPR_IMPOR WITH cVar1(6)
            REPLACE  ENCPREST->EPR_SEMAN WITH cVar1(7)
            REPLACE  ENCPREST->EPR_HORA  WITH TIME()
            REPLACE  ENCPREST->EPR_FEC   WITH DATE()*/
            
//            // Evitar que guarden dos veces el mismo prestamo. esto puede ocurrir con un "actualizar" de la pagina
//            Use C:\intra_db\encprest.d01 alias prestamos New Shared
//            Index on alltrim(ENCPREST->EPR_NUTRA) + dtos(ENCPRST->EPR_FEC) To C:\intra_db\encprx2.x01
//            go top
//            seek alltrim(Num) + dtos(DATE()) //que no asigne dos veces prestamo el mismo dia al mismo empleado
//            If found() .AND. ENCPRST->EPR_FEC = DATE()
//                MensaBack("Aviso", "Este prestamo ya esta registrado el dia de hoy con el folio:" + '<form name="formConsulta" method="post" action="/PRIVATE/RPRESTA.INT" target="_self">' + ' <input type="hidden" name="' + cClaUni + '" value="0">' + '<input type="hidden" name="Folio" value="' + PRESTAMOS->EPR_FOLIO + '">' + '</form>' + '    <a class="A" href="javascript:document.formConsulta.submit();"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">' + PRESTAMOS->EPR_FOLIO + '</font></a>'       )
//            Else
//                USAME("CTRLFINT") // control de folio de prestamo
//                GO 2
//                IF REC_LOCK()
//                   REPLACE CTRLFINT->CFI_FOLIO WITH (CTRLFINT->CFI_FOLIO + 1)
//                    cFolio:=ALLTRIM(STR(CTRLFINT->CFI_FOLIO))
//                    cFolio:=ReformIz(cFolio,6,"0")
//                    Folio=cFolio
//                ENDIF
//                CLOSE CTRLFINT

                REPLACE  ENCPREST->EPR_FOLIO  WITH cFolio
                REPLACE  ENCPREST->EPR_OFICI  WITH Upper(Oficina)
                REPLACE  ENCPREST->EPR_ENCAR  WITH Upper(Encargado)
                REPLACE  ENCPREST->EPR_TRABA  WITH Upper(Nombre)
                REPLACE  ENCPREST->EPR_NUTRA  WITH Num
                REPLACE  ENCPREST->EPR_EMPRE  WITH Upper(Empresa)
                REPLACE  ENCPREST->EPR_SUELDO WITH Sueldo
                REPLACE  ENCPREST->EPR_IMPOR  WITH Monto
                REPLACE  ENCPREST->EPR_SEMAN  WITH Semanas
                REPLACE  ENCPREST->EPR_SEMI   WITH SemIni
                REPLACE  ENCPREST->EPR_HORA   WITH TIME()
                REPLACE  ENCPREST->EPR_FEC    WITH DATE()
                REPLACE  ENCPREST->EPR_AUTO   WITH 'P'
                REPLACE  ENCPREST->EPR_NOMEL  WITH Upper(cNomUsu)                
                
                REPLACE  ENCPREST->EPR_TIPO   WITH Upper(Tipo)                
                REPLACE  ENCPREST->EPR_INTE   WITH Inter
                REPLACE  ENCPREST->EPR_COMISI WITH cComisi
                //Temporal incluir tipo de prestamo
                //Incluir la tasa de interes
            //EndIF
            //Close prestamos         
        ENDIF
        CLOSE ENCPREST        
    EndIF //GUARDAR="SI"

    
    //>> Edgan Acumula los intereses insolutos y calcula el promedio de pago optimo para que sean equitativos los pagos.
    If Tipo="FONDO"
            // se calculan pagos iniciales
            //cCapital  := (val(Monto)* 1.015)/val(Semanas)            
            cCapital  := ((val(Monto)))/val(Semanas) 
            cInsoluto := val(Monto )*(1+nComisi) // Edgan 2009mar03 usuario define Comision de apertura
            ? "INSOLUTO" + STR(CINSOLUTO)
            //cAcumulado:=round ((val(Monto)*( 1 + nComisi)) * nIntereses, 2) //calcla intereses iniciales sobre el monto y u comision de apertura
            cAcumulado:=0 // Intereses acumulados
            aPago:={}
            For x:=1 to val(Semanas) //Datos
                ? "insoluto:" + STR(CINSOLUTO) + "interes: " + str( round(cInsoluto * nInteres, 2) ) 
                cAcumulado=round( cAcumulado + (cInsoluto * nInteres), 2)
                cInsoluto=round( (cInsoluto * (1+nInteres)) - round((cCapital + (cInsoluto * nInteres)),2 ), 2)
                aadd(aPago, round(cCapital + (cInsoluto * nInteres), 2)  )
            Next x
            ? "Interes acumulado" + str(cAcumulado)
            ? "Insoluto:" + str(cInsoluto)
            sumatoria:=0
            for x:=1 to len(apago)
                sumatoria= sumatoria + apago[x]
            next x
            cProm:=sumatoria/len(apago)
            ? "Pagos promedio" + str(cprom)
           
           // Se calcula pagos equitativos
            cMas:=1.0 // Se deja tal cual porque quizas el promedio se adapta bien
            cIncreme:=cMas
            cPenultimo=0
            cUltimo=val(Monto)
            cAbono:=0
            cCapital:=0
            cDescuento:=0
            DO while cPenultimo<cUltimo                
                cInsoluto := round((val(Monto )*(1+nComisi)), 2) // Interes calculado sobre saldo insoluto
                ? "INSOLUTO" + STR(CINSOLUTO)
                //cAcumulado:=round (val(Monto)*0.015, 2)
                cAcumulado=0
                aPago:={}
                cAbono=round(cProm * cMas, 2) // Incrementa un punto porcentual el monto del pago
                ? "Abono:"  + alltrim(str(cAbono)) + "fACTOR DE MULTIPLICACION:" + alltrim(str(cMas))
                For x:=1 to val(Semanas) //Datos
                    
                    ? "prestamo -INSOLUTO - " + STR(CINSOLUTO)
                    cAcumulado=round( cAcumulado + round((cInsoluto * nInteres), 2), 2)                    
                    
                    If cAbono > cInsoluto .OR. x = val(Semanas)
                        cAbono = cInsoluto +  round((cInsoluto * nInteres), 2)
                        cCapital= cInsoluto // Lo que falto por pagar
                    Else
                        cCapital= round(cAbono - round( (cInsoluto * nInteres), 2), 2)
                    EndIF                    

                    //cCapital= round(cAbono - round( (cInsoluto * nInteres), 2), 2)
                    ? "Abono:" + str(cAbono) + "insoluto:" + alltrim(STR(CINSOLUTO)) + "Capital:" + alltrim(str(cCapital)) + "interes: " + alltrim(str( round(cInsoluto * nInteres, 2) ) )
                    cInsoluto=round(cInsoluto-cCapital, 2)
                    aadd(aPago, round(cAbono, 2)  )
                                        
                Next x
                cPenultimo=apago[len(apago)-1]
                cUltimo=apago[len(apago)]
                ? "Penultimo:" + str(cPenultimo)
                ? "Ultimo:" + str(cUltimo)
                cIncreme=cMas
                cMas=cMas + 0.001                
                
                ? "Interes acumulado" + str(cAcumulado)
                ? "Insoluto:" + str(cInsoluto)
            End Do
            cAbono=round(cProm * cIncreme, 2)
            cResAbono:=cAbono
            cDescuento=cAbono
            
            *************************************
            // Ahora se calculan los pagos con los abonos promedio para escribir en el encabezado de tabla de pagos

                cInsoluto := round((val(Monto )*(1+nComisi)), 2) //Edgan 2009mar03 Usuario define Comision de apertura
                cResInso:=cInsoluto
                ? "INSOLUTO" + STR(CINSOLUTO)
                //cAcumulado:=round (val(Monto)*0.015, 2)
                cAcumulado=0
                aPago:={}                
                nTotalPaga:=0
                ? "Abono:"  + alltrim(str(cAbono)) + "fACTOR DE MULTIPLICACION:" + alltrim(str(cMas))
                For x:=1 to val(Semanas) //Datos
                    ? "prestamo -INSOLUTO - " + STR(CINSOLUTO)
                    cAcumulado=round( cAcumulado + round((cInsoluto * nInteres), 2), 2)
                    ? "acumulado" + str(cAcumulado)
                    
                    If cAbono > cInsoluto .OR. x = val(Semanas)
                        cAbono = cInsoluto +  round((cInsoluto * nInteres), 2)
                        cCapital= cInsoluto
                    Else
                        cCapital= round(cAbono - round( (cInsoluto * nInteres), 2), 2)
                    EndIF                    

                    
                    ? "Abono:" + str(cAbono) + "insoluto:" + alltrim(STR(CINSOLUTO)) + "Capital:" + alltrim(str(cCapital)) + "interes: " + alltrim(str( round(cInsoluto * nInteres, 2) ) )
//                    @ prow()+1,0 say '  <tr>'
//                    @ prow()+1,0 say '    <td align="center">' + str(x)
//                    @ prow()+1,0 say '    </td>'
//                    @ prow()+1,0 say '    <td align="center" style="font-size: x-small;">' + str(val(SemIni) + x - 1)
//                    @ prow()+1,0 say '    </td>'
//                    @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform(cCapital, "$ 999,999,999.99") //Capital
//                    @ prow()+1,0 say '    </td>'
//                    @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform(round(cInsoluto * nInteres, 2), "$ 999,999,999.99") //Intereses
//                    @ prow()+1,0 say '    </td>'
//                    @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform(cAbono, "$ 999,999,999.99") // Descuento Semanal<br>(Abono)
//                    @ prow()+1,0 say '    </td>'
                    cInsoluto=round(cInsoluto-cCapital, 2)
                    aadd(aPago, round(cAbono, 2)  )
                    nTotalPaga=nTotalPaga + cAbono
//                    @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform( cInsoluto, "$ 999,999,999.99") //Saldo. Monto total menos los depositos realizados en semanas transcurridas
//                    @ prow()+1,0 say '    </td>'       
                // <<

//                @ prow()+1,0 say '  </tr>'
                Next x
                cAbono=cResAbono
                cInsoluto=cResInso

                ? "------------------------------------------------------------"

    EndIF
    // <<


// >> Edgan Se manda un aviso de alert con javascript
// Determina si procede prestamo. el descuento semanal debe ser 30% o menor del sueldo percibido por semana.
//    If (val(Sueldo) * 0.30)/4 < ( (val(Monto) * (1+nInteres))/VAL(Semanas) )
//        Mensaback("El monto solicitado para prestamo excede el limite del 30% del sueldo del empleado","No procede prestamo") // Temporal que solo sea un aviso pero que deje continuar con la solicitud
//    EndIF
// << 
    // si no recibe el id de prestamo que haga los calculos con la info del nombre del empleado y fecha de pago, que es una consulta de pagos.
    
    SET PRINTER TO (cOutFile)
    SET DEVICE TO PRINTER

    @ prow(),0   say "Content-type: text/html"
    @ prow()+1,0 say ""
    @ prow()+1,0 say '<html>'
    @ prow()+1,0 say '<meta name="Version" content="' + cVer +'" />'    
    @ prow()+1,0 say '<head>'
    @ prow()+1,0 say '<title>Tabla de pagos por pr้stamo. Folio de pr้stamo: '+ IIF(Folio=="VACIO", "{Modo consulta}", Folio) + '</title>'
    @ prow()+1,0 say '<link href="/Comunes_cs.css" rel="stylesheet" type="text/css">' // Edgan LR. 30.oct.2008 formato de reporte autorizado
    @ prow()+1,0 say '<!-- saved from url=(0014)about:internet -->'
    @ prow()+1,0 say '<style type="text/css">'
    @ prow()+1,0 say '.recuadro {border:thin solid #F5F5F5F5; font-size: 11px;}'
    @ prow()+1,0 say '</style>'
    @ prow()+1,0 say '<script language="javascript" src="/comunes.js"></script>'


    
    cRegresar:='<div width="100%" align="right" ><b><a href="javascript:history.back(1)" style="font-size:12px;"> .:Atr&aacute;s&nbsp&nbsp&nbsp</a></b></div>'

    // Decide si va a guardar o no.
    If Guardar="NO"
        @ prow()+1,0 say '<script language="javascript">'
        @ prow()+1,0 say "var Regresar='"  + cRegresar + "'"
        @ prow()+1,0 say 'EscribeEncabezado(Regresar)'
        @ prow()+1,0 say '</script>'
    Else
        status="P"
        @ prow()+1,0 say '<script languaje="javascript">'
        @ prow()+1,0 say '  alert("Su informaci๓n se guardo con ้xito.\nEspere la autorizaci๓n.");'
        @ prow()+1,0 say '</script>'        
          cRegresar:='<div width="100%" align="right" ><b><form name="frmSol" action="/private/prestamo.int" method="post" target="_self"><input type="hidden" name="'+cClaUni+'" value="0"> </form><a href="javascript:document.frmSol.submit()" style="font-size:10px;">[x]Terminar&nbsp&nbsp&nbsp</a></b></div>'                    
        @ prow()+1,0 say '<script language="javascript">' //Escribe el encabezado flotante
        //Prepara las variables de tipo string que va a mandar. Se hace con el fin de evitar la complicacion de comillas y comillas simples
        @ prow()+1,0 say "var cNombre='Guardar'" // Dentro del codigo JS se declara la variable que contiene el nombre del boton
        cCadena:='<table align="center" width="100%" border="0" cellpading="0" cellborder="0"><tr><td width="90%" style="color:#9E0000" align="center">&nbsp;</td><td>'
        @ prow()+1,0 say "var StrHtml='" + cCadena + cRegresar + "</td></tr></table>'" // envia la cadena con inicio y fin de apostrofe        
        @ prow()+1,0 say 'EscribeEncabezado(StrHtml)' //escribe el encabezado flotante// envia una solca cadena
        @ prow()+1,0 say '</script>'
    End IF

    @ prow()+1,0 say '</head>'
    
    @ prow()+1,0 say '<body>'

    // Escribe el encabezado con formato estandar de reporte autorizado
    @ prow()+1,0 say '<br><br><table width="100%" cellspacing=1 border="0" align="center" >'
    @ prow()+1,0 say '<tr class="inferior" ><td Width="70%"  rowspan="2" align="left" class=titb2 valign=top style="border-bottom: thin solid #5F5F5F">'

    @ prow()+1,0 say '  <table border="0" width="100%" >'
    @ prow()+1,0 say '    <tr>'    
    @ prow()+1,0 say '      <td width="100%" class=titb2 colspan="2">'+Upper(Empresa)+' </td>'
    @ prow()+1,0 say '    </tr>'
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td align=left class=titb2 colspan="2" >'
    //@ prow()+1,0 say ' Solicitud de prestamos. [Tabla de pagos]'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'    
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td style="font-family:Verdana; font-size: 10px; color: darkblue;" width="10%">Encargado:</td>'
    @ prow()+1,0 say '      <td style="font-family:Verdana; font-size: 10px; color: darkblue;" align="left" width="90%">'+IIF(Encargado=="", "{Modo de consulta}", Upper(Encargado))+' </td>'
    @ prow()+1,0 say '    </tr>'
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td style="font-family:Verdana; font-size: 10px; color: darkblue;">Oficina:</td>'
    @ prow()+1,0 say '      <td style="font-family:Verdana; font-size: 10px; color: darkblue;" align="left" >'+IIF(Oficina=="", "{Modo de consulta}", Upper(Oficina))+' </td>'
    @ prow()+1,0 say '    </tr>'
    @ prow()+1,0 say '  </table>'
    
    @ prow()+1,0 say '</td>'     
    @ prow()+1,0 say '     <td Width="30%" align=center class=celln>Solicitud de prestamos<br>[Tabla de pagos]</td>'
    @ prow()+1,0 say '  <tr class="inferior">'
    @ prow()+1,0 say '      <td Width="30%" align=center class=celln>Fecha: <b>' + Substr(Fecha_esp(dFecha),6,11)   +'</b>  Hora: <b>'+substr(cHora,1,5) +'</b></td>'
    @ prow()+1,0 say '  </tr>'
    @ prow()+1,0 say '</table>'

    //Escribe la tabla con la informacion del empleado y general del prestamo.
    ** Primer tabla    
    @ prow()+1,0 say '<br><table border="0" width="88%" cellpadding="0" style="border-spacing: 0px;">'
    // Edgan
    @ prow()+1,0 say '  <tr>'
    @ prow()+1,0 say '    <td width="23%" align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Tipo de pr้stamo: '
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td width="22%" align="left" class="recuadro">' + IIF(LEN(ENTIDADES(UPPER(LOK(Tipo))))=0, "ANTERIOR AL 2009", ENTIDADES(UPPER(LOK(Tipo))))// Indica que el prestamo es anterior al 2009 y no se cuenta con esa informacion en el sistema, solo en las hojas que se firmaron al momento del prestamo.
    ? "tipo+" + tipo
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td width="5%" align="right">'
    @ prow()+1,0 say '   </td>'
    @ prow()+1,0 say '    <td width="27%" align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Status:'
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td align="left" class="recuadro" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;">'  + IIF(status="S", "AUTORIZADO", IIF(status="P", "PENDIENTE", IIF(status="CONSULTA", "{CONSULTA}", "ANTERIOR09")) )
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '  </tr>'
    // <<
    @ prow()+1,0 say '  <tr>'
    @ prow()+1,0 say '    <td width="23%" align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Numero de empleado: '
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td width="22%" align="right" class="recuadro">' + Num
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td width="5%" align="right">'
    @ prow()+1,0 say '   </td>'
    @ prow()+1,0 say '    <td width="27%" align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Descuento semanal:'
    @ prow()+1,0 say '    </td>' 
    
    If  Tipo="FONDO"
        @ prow()+1,0 say '    <td width="18%" align="right" class="recuadro" style="border: double">' + transform(cAbono, "$ 999,999,999.99")
    Else                    
        @ prow()+1,0 say '    <td width="18%" align="right" class="recuadro" style="border: double">' + transform((val(Monto)/val(Semanas))*(1+nInteres), "$ 999,999,999.99")
    EndIF    
    
    
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '  </tr>'
    @ prow()+1,0 say '  <tr>'
    @ prow()+1,0 say '    <td  align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Nombre de empleado: '
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td align="left" class="recuadro" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;">' + Upper(Nombre)
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td  align="right">'
    @ prow()+1,0 say '   </td>'
    @ prow()+1,0 say '    <td  align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Tasa de  interes(%):'
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td  align="right" class="recuadro">' +  str(nInteres * 100)
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '  </tr>'
    @ prow()+1,0 say '  <tr>'
    @ prow()+1,0 say '    <td  align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Sueldo Mensual:'
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td  align="right" class="recuadro">' + transform(val(sueldo), "$ 999,999,999.99")// Monto
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td  align="right" >'
    @ prow()+1,0 say '   </td>'
    @ prow()+1,0 say '    <td  align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Plazo de pago(Semanas):'
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td  align="right" class="recuadro">' + Semanas // Calcular el monto de lols intereses
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '  </tr>'
    @ prow()+1,0 say '  <tr>'
    @ prow()+1,0 say '    <td  align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;">Prestamo solicitado: '
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td  align="right" class="recuadro">' + transform(val(Monto), "$ 999,999,999.99") 
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td align="right">'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '    <td  align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Semana de inicio de descuento:'
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td align="right" class="recuadro">' + SemIni // Calcular el monto total
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '  </tr>'
    @ prow()+1,0 say '  <tr>'
    @ prow()+1,0 say '    <td align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Intereses causados:'
    @ prow()+1,0 say '    </td>' 
    
    If  Tipo="FONDO"
        @ prow()+1,0 say '    <td align="right" class="recuadro">' + transform(cAcumulado , "$ 999,999,999.99")        
    Else                    
        @ prow()+1,0 say '    <td align="right" class="recuadro">' + transform((val(Monto) * nInteres), "$ 999,999,999.99")        
    EndIF    

    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td align="right">'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '    <td align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Semana de fin de pago: '
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td align="right" class="recuadro">' + str(val(SemIni)+val(Semanas))
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '  </tr>'

    @ prow()+1,0 say '  <tr>'
//    @ prow()+1,0 say '    <td align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Total a pagar: '
//    @ prow()+1,0 say '    </td>' 

//    If  Tipo="FONDO"
//        @ prow()+1,0 say '    <td align="right" class="recuadro">' + transform((val(Monto) + cAcumulado), "$ 999,999,999.99")          // obtener numero de semana automaticamente
//    Else                    
//        @ prow()+1,0 say '    <td align="right" class="recuadro">' + transform((val(Monto) * (1+nInteres)), "$ 999,999,999.99")          // obtener numero de semana automaticamente
//    EndIF      

//    @ prow()+1,0 say '    </td>' 
//    @ prow()+1,0 say '    <td align="right">'
//    @ prow()+1,0 say '    </td>'
    
    If  Tipo="FONDO"
        @ prow()+1,0 say '    <td align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Comisi๓n por ap.(' + cComisi + '%): '
        @ prow()+1,0 say '    </td>'

        @ prow()+1,0 say '    <td align="right" class="recuadro">' + transform(val(Monto)*nComisi, "$ 999,999,999.99")          // obtener numero de semana automaticamente
    Else                    
        @ prow()+1,0 say '    <td align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Comisi๓n por ap.(' + cComisi + '%): '
        @ prow()+1,0 say '    </td>'
        @ prow()+1,0 say '    <td align="right" class="recuadro">' + transform(val(Monto)*nComisi, "$ 999,999,999.99")          // obtener numero de semana automaticamente
    EndIF      

    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td align="right">'
    @ prow()+1,0 say '    </td>'

    @ prow()+1,0 say '    <td align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;">Folio de pr้stamo:'
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td align="right" class="recuadro" style="font-family:Verdana; font-size: 12px;border-spacing: 0px;white-space:nowrap;"><b>'+ IIF(Folio=="VACIO", "{Modo consulta}", Folio) + '</b>'
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '  </tr>'




    //>> Edgan
    @ prow()+1,0 say '  <tr>'
    @ prow()+1,0 say '    <td align="left" style="font-family:Verdana; font-size: 10px;border-spacing: 0px;white-space:nowrap;"> Total a pagar: '
    @ prow()+1,0 say '    </td>' 

    If  Tipo="FONDO"
        @ prow()+1,0 say '    <td align="right" class="recuadro">' + transform(nTotalPaga, "$ 999,999,999.99")   
    Else                    
        @ prow()+1,0 say '    <td align="right" class="recuadro">' + transform((val(Monto) * (1+nInteres)), "$ 999,999,999.99") 
    EndIF      

    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td align="right">'
    @ prow()+1,0 say '    </td>'

    @ prow()+1,0 say '    <td'
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '    <td >'
    @ prow()+1,0 say '    </td>' 
    @ prow()+1,0 say '  </tr>'

    //<<


    @ prow()+1,0 say '</table>'
    
    ** Segunda tabla de pagos
    @ prow()+1,0 say '<font size="1">'
    @ prow()+1,0 say '<br><table width="100%" border="1" cellspacing="0" style="font-size:small">'
    @ prow()+1,0 say '  <tr >' //Titulo
    @ prow()+1,0 say '    <td colspan="6" align="center" class="celln"> DESCUENTO SEMANAL POR CONCEPTO DE PRษSTAMO'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '  </tr>'
    @ prow()+1,0 say '  <tr>' //Encabezado de la tabla
    @ prow()+1,0 say '    <td class=tt01 align="center">No. Pago'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '    <td class=tt01 align="center">Semana'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '    <td class=tt01 align="center">Capital'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '    <td class=tt01 align="center"> Intereses'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '    <td class=tt01 align="center"> Descuento Semanal<br>(Abono)'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '    <td class=tt01 align="center">Saldo'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '  </tr>'
    @ prow()+1,0 say '  <tr>'     

    @ prow()+1,0 say '    <td align="center">-' // Escribe una columna que inicializa el saldo
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '    <td align="center">-'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '    <td align="center">-'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '    <td align="center">-'
    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '    <td align="center">-'
    @ prow()+1,0 say '    </td>'    

    If  Tipo="FONDO"
        @ prow()+1,0 say '    <td align="right">' + transform((val(Monto) * (1+nComisi)), "$ 999,999,999.99")         
    Else                    
        @ prow()+1,0 say '    <td align="right">' + transform((val(Monto) * (1+nInteres)), "$ 999,999,999.99")         
    EndIF      

    @ prow()+1,0 say '    </td>'
    @ prow()+1,0 say '  </tr>'            

    Do Case
        Case Tipo="COMPANIA"
            cCapital := val(Monto)/val(Semanas)
            cInsoluto:= val(Monto)
            For x:=1 to val(Semanas) //Datos
                @ prow()+1,0 say '  <tr>'
                @ prow()+1,0 say '    <td align="center">' + str(x)
                @ prow()+1,0 say '    </td>'
                @ prow()+1,0 say '    <td align="center" style="font-size: x-small;">' + str(val(SemIni) + x - 1)
                @ prow()+1,0 say '    </td>'
                @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform(cCapital, "$ 999,999,999.99") //Capital
                @ prow()+1,0 say '    </td>'
                @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform((val(Monto)/val(Semanas))*nInteres, "$ 999,999,999.99") //Intereses
                @ prow()+1,0 say '    </td>'
                @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform((val(Monto)/val(Semanas))*(1+nInteres), "$ 999,999,999.99") // Descuento Semanal<br>(Abono)
                @ prow()+1,0 say '    </td>'
                @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform( (val(Monto)*(1+nInteres)) - ( ((val(Monto)/val(Semanas))*(1+nInteres)) * x), "$ 999,999,999.99") //Saldo. Monto total menos los depositos realizados en semanas transcurridas
                @ prow()+1,0 say '    </td>'
                // <<
                @ prow()+1,0 say '  </tr>'
            Next x
                                
                
        Case Tipo="FONDO"
                // cInsoluto  && Trae el valor del calculo de pagos equitativos
                ? "INSOLUTO" + STR(CINSOLUTO)
                //cAcumulado:=round (val(Monto)*0.015, 2)
                cAcumulado=0
                aPago:={}                
                ? "Abono:"  + alltrim(str(cAbono)) + "fACTOR DE MULTIPLICACION:" + alltrim(str(cMas))
                For x:=1 to val(Semanas) //Datos
                    ? "prestamo -INSOLUTO - " + STR(CINSOLUTO)
                    cAcumulado=round( cAcumulado + round((cInsoluto * nInteres), 2), 2)                    
                    ? "acumulado" + str(cAcumulado)
                    
                    If cAbono > cInsoluto .OR. x = val(Semanas)
                        cAbono = cInsoluto +  round((cInsoluto * nInteres), 2)
                        cCapital= cInsoluto
                    Else
                        cCapital= round(cAbono - round( (cInsoluto * nInteres), 2), 2)
                    EndIF                    

                    
                    ? "Abono:" + str(cAbono) + "insoluto:" + alltrim(STR(CINSOLUTO)) + "Capital:" + alltrim(str(cCapital)) + "interes: " + alltrim(str( round(cInsoluto * nInteres, 2) ) )
                    @ prow()+1,0 say '  <tr>'
                    @ prow()+1,0 say '    <td align="center">' + str(x)
                    @ prow()+1,0 say '    </td>'
                    @ prow()+1,0 say '    <td align="center" style="font-size: x-small;">' + str(val(SemIni) + x - 1)
                    @ prow()+1,0 say '    </td>'
                    @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform(cCapital, "$ 999,999,999.99") //Capital
                    @ prow()+1,0 say '    </td>'
                    @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform(round(cInsoluto * nInteres, 2), "$ 999,999,999.99") //Intereses
                    @ prow()+1,0 say '    </td>'
                    @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform(cAbono, "$ 999,999,999.99") // Descuento Semanal<br>(Abono)
                    @ prow()+1,0 say '    </td>'
                    cInsoluto=round(cInsoluto-cCapital, 2)
                    aadd(aPago, round(cAbono, 2)  )
                    @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform( cInsoluto, "$ 999,999,999.99") //Saldo. Monto total menos los depositos realizados en semanas transcurridas
                    @ prow()+1,0 say '    </td>'       
                // <<

                @ prow()+1,0 say '  </tr>'

                                        
                Next x
                cPenultimo=apago[len(apago)-1]
                cUltimo=apago[len(apago)]
                ? "Penultimo:" + str(cPenultimo)
                ? "Ultimo:" + str(cUltimo)

                cIncreme=cMas
                cMas=cMas + 0.01                
                
                ? "Interes acumulado" + str(cAcumulado)
                ? "Insoluto:" + str(cInsoluto)
                    
    End Case


//    cCapital := val(Monto)/val(Semanas)
//    cInsoluto:= val(Monto)
//    For x:=1 to val(Semanas) //Datos
//        @ prow()+1,0 say '    <td align="center">' + str(x)
//        @ prow()+1,0 say '    </td>'
//        @ prow()+1,0 say '    <td align="center" style="font-size: x-small;">' + str(val(SemIni) + x - 1)
//        @ prow()+1,0 say '    </td>'
//        //>> Edgan Se adapta al tipo fondo sobre saldo insoluto
////        @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform((val(Monto)/val(Semanas)), "$ 999,999,999.99") //Capital
////        @ prow()+1,0 say '    </td>'
////        @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform((val(Monto)/val(Semanas))*nInteres, "$ 999,999,999.99") //Intereses
////        @ prow()+1,0 say '    </td>'
////        @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform((val(Monto)/val(Semanas))*(1+nInteres), "$ 999,999,999.99") // Descuento Semanal<br>(Abono)
////        @ prow()+1,0 say '    </td>'
////        @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform( (val(Monto)*(1+nInteres)) - ( ((val(Monto)/val(Semanas))*(1+nInteres)) * x), "$ 999,999,999.99") //Saldo. Monto total menos los depositos realizados en semanas transcurridas
////        @ prow()+1,0 say '    </td>'
//        If Tipo="COMPANIA"
//            @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform(cCapital, "$ 999,999,999.99") //Capital
//            @ prow()+1,0 say '    </td>'
//            @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform((val(Monto)/val(Semanas))*nInteres, "$ 999,999,999.99") //Intereses
//            @ prow()+1,0 say '    </td>'
//            @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform((val(Monto)/val(Semanas))*(1+nInteres), "$ 999,999,999.99") // Descuento Semanal<br>(Abono)
//            @ prow()+1,0 say '    </td>'
//            @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform( (val(Monto)*(1+nInteres)) - ( ((val(Monto)/val(Semanas))*(1+nInteres)) * x), "$ 999,999,999.99") //Saldo. Monto total menos los depositos realizados en semanas transcurridas
//            @ prow()+1,0 say '    </td>'
//        Else
//            @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform(cCapital, "$ 999,999,999.99") //Capital
//            @ prow()+1,0 say '    </td>'
//            @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform( (cInsoluto * nInteres), "$ 999,999,999.99")  //Intereses
//            @ prow()+1,0 say '    </td>'
//            @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform( cCapital + (cInsoluto * nInteres)  , "$ 999,999,999.99") // Descuento Semanal<br>(Abono)
//            @ prow()+1,0 say '    </td>'
//            cInsoluto=(cInsoluto * (1+nInteres)) - (cCapital + (cInsoluto * nInteres))
//            @ prow()+1,0 say '    <td align="right" style="font-size: x-small;">' + transform((cInsoluto*(1+nInteres)), "$ 999,999,999.99") //Saldo. Monto total menos los depositos realizados en semanas transcurridas
//            @ prow()+1,0 say '    </td>'
//        EndIF
        
//        // <<

//        @ prow()+1,0 say '  </tr>'
//    Next x
    @ prow()+1,0 say '</table>'
    @ prow()+1,0 say '</font>'

    @ prow()+1,0 say '<br>' // texto para firmas
    @ prow()+1,0 say '<table align="center" width="99%" >'
    @ prow()+1,0 say '<tr><td style="text-align:justify;font-size: x-small">'
    @ prow()+1,0 say 'Yo <u><b>C.' + Upper(Nombre) + '</b></u> acepto que debo y pagare incondicionalmente a la empresa <b>' + Upper(Empresa) + '</b>'//Pie del contrato
    @ prow()+1,0 say 'y/o a la <b>SRA. ENRIQUETA GONZALEZ VALENCIA</b> en esta ciudad de Mexico la cantidad de <b>'


    If Tipo="FONDO"
        //@ prow()+1,0 say  transform(cPenultimo, "$ 999,999,999.99") 
        @ prow()+1,0 say transform(round(val(Monto) + (val(Monto) * nComisi ) + cAcumulado, 2), "$ 999,999,999.99") // Edgan 2009mar03 total a pagar
    Else        
//        @ prow()+1,0 say  transform((val(Monto)/val(Semanas))*(1+nInteres), "$ 999,999,999.99")
        @ prow()+1,0 say transform((val(Monto) * (1+nInteres)), "$ 999,999,999.99") // Edgan 2009mar03 total a pagar
    EndIF    

    @ prow()+1,0 say 'mn.</b> en <b>' + Semanas +  '</b> abonos semanales consecutivos, comenzando'
    @ prow()+1,0 say 'la semana numero <b>' + SemIni + '</b> y terminando la semana numero <b>' + str( val(SemIni) + val(Semanas) ) + '</b> por concepto de prestamo,  mismo que me es entregado en los t&eacute;rminos convenidos al momento en que es firmado de este documento.'
    @ prow()+1,0 say '</tr></td>'
    @ prow()+1,0 say '</table>'
    
    @ prow()+1,0 say '<br>'
    @ prow()+1,0 say '<table align="center" width="100%" border="0" cellspacing="30" >'//firmas de documento
    @ prow()+1,0 say '  <tr>'
    @ prow()+1,0 say '   <td width="33%" style="border-bottom: thin solid #000000">&nbsp'
    @ prow()+1,0 say '   </td>'
    @ prow()+1,0 say '   <td width="33%" style="border-bottom:thin solid #000000">&nbsp'
    @ prow()+1,0 say '   </td>'
    @ prow()+1,0 say '   <td width="33%" style="border-bottom:thin solid #000000">&nbsp'
    @ prow()+1,0 say '   </td>'
    @ prow()+1,0 say '  </tr>'
    @ prow()+1,0 say '  <tr>'
    @ prow()+1,0 say '   <td align="center"><b>Nombre y Firma<br>Primer Aval</b>'
    @ prow()+1,0 say '   </td>'
    @ prow()+1,0 say '   <td align="center"><b>Nombre y Firma<br>Segundo Aval</b>'
    @ prow()+1,0 say '   </td>'
    @ prow()+1,0 say '   <td align="center"><b>Nombre y Firma<br>Deudor</b>'
    @ prow()+1,0 say '   </td>'
    @ prow()+1,0 say '  </tr>'
    @ prow()+1,0 say '</table>'
    // formulario oculto que reenvia los valores mismos que recibio este CGI
    @ prow()+1,0 say '<form Name="formGuardar" ACTION="/CGI-DOS/Rpresta.exe"  METHOD="POST">'
    //Crea el formulario con los valores que tiene que reenviar
    FOR i := 1 TO LEN(aVars)
        declaraVar:=aVars[i,1]
        //solamente extrae el nombre de la variable como ya estan declaradas, solo usa & para extraer el valor
        If(SubStr(declaraVar,1,8)=="required")
            declaraVar:= SubStr(declaraVar,9,10) //nombre de variable de maximo 7 caracteres quitando required
        Else
            declaraVar:= SubStr(declaraVar,1,10) //nombre de variable de maximo 7 caracteres
        EndIf
        //? "Variable creada:" + declaraVar
        @ prow()+1,0 say'<input type="hidden" name="' + declaraVar + '" VALUE="' + &declaraVar +'">'
        //? "Nombre declarado:" + declaraVar
        //? "Valor declarado:" + &declaraVar
    NEXT
    @ prow()+1,0 say '</form>'//cierra parentesis de la funcion encabezado

    // >> Edgan El aviso de que excede el 30% del sueldo va aqui para permitir que se cargue la pagina primero
    If (val(Sueldo) * 0.30)/4 < ( (val(Monto) * (1+nInteres))/VAL(Semanas) ) 
        @ prow()+1,0 say '<script>'
        @ prow()+1,0 say 'alert("El monto solicitado para prestamo excede el limite del 30% \ndel sueldo semanal del empleado que es de $'+ alltrim(str( round( (val(Sueldo) * 0.30)/4 ,2 ) ) ) + '");'
        @ prow()+1,0 say '</script>'
    EndIF
    // <<

    @ prow()+1,0 say '</body>'
    @ prow()+1,0 say '</html>'

  SET DEVICE TO SCREEN
  SET PRINT OFF
RETURN




//Edgan LR. 10.nov.2008 Se comenta el codigo original porque se hicieron modificaciones funcionales al codigo. Como  guardar y consultar dentro del mismo GCI
/***----------------------------------
**NOMBRE: int1202.prg
**OBJETIVO: RECIBE SOLICITUD DE PRESTAMO Y LA GUARDA
**ALCANCE:
**PROCEDIMIENTOS:
**REFERENCIAS CRUZADAS:
**      programas padre: prestamo.htm
**      programas hijo:
**      base de datos/tabla:
** BITACORA  CAMBIOS(incremental):
**       -Fecha:5.nov.2008 Autor: Edgan LR  Descripci๓n: Nuevo procedimiento de creacoin de variables para evitar la dependencia de posicion dentro del arreglo recibido.
**                                                       Ademas de que guarde la informacion correcta en los campos correctos.
**       -Fecha:Anterior al 5.nov.2008  Autor: ฟ? Descripci๓n: Creaci๓n de programa
***      RECIBE LA SOLICITUD DE PRESTAMO Y LA GUARDA A SU DBF
**---------------------------------



FUNCTION Main()
   LOCAL cOutFile := GETE("OUTPUT_FILE") // obtenemos el nombre del archivo de salida
   LOCAL cInpFile := GETE("CONTENT_FILE") // obtenemos el nombre del archivo de entrada
   LOCAL cInpVars //cadena de caracteres con las variables extraidas del archivo
   Private  aVars   //arreglo con las variables extraidas del codigo

   cInpVars := MemoRead(cInpFile) //Leemos el archivo de entrada
   aVars := SacaVars(cInpVars)    //obtenemos un arreglo con las variables de la forma

  // Edgan LR. 05.NOV.2008 La siguiente funcion es para declarar variables y valores de acuerdo a los parametros recibidos. Elimina dependencia de variable/posicion.
  FOR i := 1 TO LEN(aVars)
    declaraVar:=aVars[i,1]

      If(SubStr(declaraVar,1,8)=="required")
        declaraVar:= SubStr(declaraVar,9,7) //nombre de variable de maximo 7 caracteres quitando required
      Else
        declaraVar:= SubStr(declaraVar,1,7) //nombre de variable de maximo 7 caracteres
      EndIf
      &declaraVar:= aVars[i,2]
      //? "Nombre declarado:" + declaraVar
      //? "Valor declarado:" + &declaraVar
  NEXT

   // asignamos al archivo de salida la impresora 
   SET PRINTER TO (cOutFile)
   SET DEVICE TO PRINTER

   // Mostramos la tabla de pagos



	*** 1) PRIMERO LE ASIGNO FOLIO Y ACTUALIZO CTRLFINT.
	USAME("CTRLFINT")
	GO 2
	IF REC_LOCK()
	   REPLACE CTRLFINT->CFI_FOLIO WITH (CTRLFINT->CFI_FOLIO + 1)
		cFolio:=ALLTRIM(STR(CTRLFINT->CFI_FOLIO))
		cFolio:=ReformIz(cFolio,6,"0")
	ENDIF
	CLOSE CTRLFINT

	*** 2) GRABO LA SOLICITUD DE PRESTAMO A SU DBF.

	USAME("ENCPREST")

	SELECT ENCPREST
	IF ADD_REC()
      /*REPLACE  ENCPREST->EPR_FOLIO WITH cFolio // Edgan LR. 5.nov.2008 Se toman losvalores por nombre de la variable que genera al recibir parametros
      REPLACE  ENCPREST->EPR_OFICI WITH Oficina
	  REPLACE  ENCPREST->EPR_FECHA WITH cVar1(1)
      REPLACE  ENCPREST->EPR_ENCAR WITH cVar1(1)
      REPLACE  ENCPREST->EPR_TRABA WITH cVar1(3)
      REPLACE  ENCPREST->EPR_NUTRA WITH cVar1(4)
      REPLACE  ENCPREST->EPR_EMPRE WITH cVar1(5)
      REPLACE  ENCPREST->EPR_IMPOR WITH cVar1(6)
      REPLACE  ENCPREST->EPR_SEMAN WITH cVar1(7)
      REPLACE  ENCPREST->EPR_HORA  WITH TIME()
      REPLACE  ENCPREST->EPR_FEC   WITH DATE()*/

      /*
      REPLACE  ENCPREST->EPR_FOLIO WITH cFolio
      REPLACE  ENCPREST->EPR_OFICI WITH Oficina
      REPLACE  ENCPREST->EPR_ENCAR WITH Encarga
      REPLACE  ENCPREST->EPR_TRABA WITH Nombre
      REPLACE  ENCPREST->EPR_NUTRA WITH Num
      REPLACE  ENCPREST->EPR_EMPRE WITH Empresa
      REPLACE  ENCPREST->EPR_IMPOR WITH Monto
      REPLACE  ENCPREST->EPR_SEMAN WITH Semanas
      REPLACE  ENCPREST->EPR_HORA  WITH TIME()
      REPLACE  ENCPREST->EPR_FEC   WITH DATE()

  ENDIF

	CLOSE ENCPREST
    *** 3) MANDAMOS PAGINA DE QUE SE GRABO BIEN Y SE REENVIAN VALORES PARA QUE SE IMPRIMA LA TABLA DE PAGOS.
    GRABEOK("SU SOLICITUD HA SIDO GRABADA CON EXITO","CON EL FOLIO : "+cFolio)
	*** 4) TERMINAMOS FUNCION.
   SET DEVICE TO SCREEN
   SET PRINT OFF

RETURN

* Pantalla en html que dice que se grabo bien el documento.
* ya esta activo el doc. de regreso al cliente...
FUNCTION GRABEOK(cMensa1,cMensa2)

@ prow(),  0 say "Content-type: text/html"
@ prow()+1,0 say ""
@ prow()+1,0 say '<html>'
@ prow()+1,0 say '<head>'
@ prow()+1,0 say '<title></title>'
@ prow()+1,0 say '</head>'
@ prow()+1,0 say '<body  bgcolor="#cccccc" >'
@ prow()+1,0 say '<table width="100%" border="0" align="center">'
@ prow()+1,0 say '<tr>'
@ prow()+1,0 say '<td colspan="3">&nbsp;</td>'
@ prow()+1,0 say '</tr>'
@ prow()+1,0 say '<tr>'
@ prow()+1,0 say '<td colspan="3">'
@ prow()+1,0 say '<div align="center"><img src="/OTHEC/gifs/14767084.gif" width="576" height="14"></div>'
@ prow()+1,0 say '</td>'
@ prow()+1,0 say '</tr>'
@ prow()+1,0 say '<tr>'
@ prow()+1,0 say '<td colspan="3">'
@ prow()+1,0 say '<div align="center"></div>'
@ prow()+1,0 say '</td>'
@ prow()+1,0 say '</tr>'
@ prow()+1,0 say '<tr>'
@ prow()+1,0 say '<td colspan="3">'
@ prow()+1,0 say '<p align="center">&nbsp;</p>'
@ prow()+1,0 say '<p align="center">&nbsp;</p>'
@ prow()+1,0 say '<p align="center"><font size="2" face="Arial"><b><font color="#000099" size="3" face="Georgia, Times New Roman, Times, serif">'
@ prow()+1,0 say cMensa1+'</font></b></font></p>'
@ prow()+1,0 say '<p align="center">&nbsp;</p>'
@ prow()+1,0 say '<p align="center">&nbsp;</p>'
@ prow()+1,0 say '<p align="center"><font size="2" face="Arial"><b><font color="#000099" size="3" face="Georgia, Times New Roman, Times, serif">'
@ prow()+1,0 say cMensa2+'</font></b></font></p>'
@ prow()+1,0 say '<p align="center">&nbsp;</p>'
@ prow()+1,0 say '</td>'
@ prow()+1,0 say '</tr>'
@ prow()+1,0 say '<tr>'
@ prow()+1,0 say '<td colspan="3">'

// Edgan LR. Reenviamos los datos para que impriman la tabla de pagos.
//@ prow()+1,0 say '<div align="center"><b><a href="javascript:history.back(3)">ACEPTAR</a></b></div>'
@ prow()+1,0 say '<form name="frmTabla">'
@ prow()+1,0 say '<div align="center"><b><a href="javascript: document.frmTabla.submit()" target="_self">ACEPTAR</a></b></div>'
@ prow()+1,0 say '</form>'

@ prow()+1,0 say '</td>'
@ prow()+1,0 say '</tr>'
@ prow()+1,0 say '<tr>'
@ prow()+1,0 say '<td width="33%">&nbsp; </td>'
@ prow()+1,0 say '<td width="33%">&nbsp; </td>'
@ prow()+1,0 say '<td width="33%">&nbsp; </td>'
@ prow()+1,0 say '</tr>'
@ prow()+1,0 say '<tr>'
@ prow()+1,0 say '<td colspan="3">'
@ prow()+1,0 say '<div align="center"><img src="/OTHEC/gifs/14767084.gif" width="576" height="14"></div>'
@ prow()+1,0 say '</td>'
@ prow()+1,0 say '</tr>'
@ prow()+1,0 say '</table>'

//


@ prow()+1,0 say '</body>'
@ prow()+1,0 say '</html>'
CLOSE ALL
SET DEVICE TO SCREEN
SET PRINT OFF
QUIT
Return

RETURN

/* ZONA QUE MANDA EL PRESTAMO DE REGRESO


   @ prow(),0 say "Content-type: text/html"       // esta linea es INDISPENSABLE
   @ prow()+1,0 say ""                            // este espacio es forzoso tambien
   * a partir de aqui todo es HTML
   @ prow()+1,0 say " <HTML><HEAD>"
   @ prow()+1,0 say " <TITLE>Solicitu de prestamo </TITLE>"

//   FOR nCiclo := 1 TO LEN(aVars)
//      @ prow()+1,0 say "<B>"+aVars[nCiclo,1]+ "</B>     " + CaracEspec(aVars[nCiclo,2])
//   NEXT


@ prow()+1,0 say "</HEAD>"
@ prow()+1,0 say "<BODY BGCOLOR="+Com("#FFFFFF")+" BACKGROUND="+Com("FIGURAS/Bg13_84.jpg")+">"
@ prow()+1,0 say "<BR>"
@ prow()+1,0 say "<CENTER><TABLE BORDER="+Com("0")+" ALIGN="+Com("center")+" WIDTH="+Com("70%")+" BGCOLOR="+Com("Black")+">"
@ prow()+1,0 say "<TR>"
@ prow()+1,0 say "<TD COLSPAN="+Com("3")+" BGCOLOR="+Com("White")+">"
@ prow()+1,0 say "<TABLE BORDER="+Com("0")+" ALIGN="+Com("DEFAULT")+" WIDTH="+Com("100%")+">"
@ prow()+1,0 say "<TR BGCOLOR="+Com("White")+">"
@ prow()+1,0 say "<TD><IMG BORDER="+Com("0")+" SRC="+Com("/FIGURAS/Othec22.gif")+"><BR>"
@ prow()+1,0 say "<BR>"
@ prow()+1,0 say "</TD>"
@ prow()+1,0 say "<TD ALIGN="+Com("CENTER")+"><B><FONT SIZE="+Com("4")+" FACE="+Com("Arial")+"><BR>"
@ prow()+1,0 say "<B><FONT SIZE="+Com("4")+" FACE="+Com("Arial")+">Solicitud de Pr&#233;stamo</FONT></B>"
@ prow()+1,0 say "<BR>"
@ prow()+1,0 say "<BR>"
@ prow()+1,0 say "</FONT></B>"
@ prow()+1,0 say "</TD>"
@ prow()+1,0 say "</TR>"
@ prow()+1,0 say "</TABLE>"
@ prow()+1,0 say "<FONT FACE="+Com("Arial")+">"
@ prow()+1,0 say "<HR>"
@ prow()+1,0 say "<BR>"
@ prow()+1,0 say "</FONT><B><FONT FACE="+Com("Arial")+">"
@ prow()+1,0 say "<FONT FACE="+Com("Arial")+" SIZE="+Com("2")+"><FONT FACE="+Com("Arial")+" SIZE="+Com("2")+">"
@ prow()+1,0 say "</FONT>"
@ prow()+1,0 say "<TABLE BORDER="+Com("0")+" ALIGN="+Com("DEFAULT")+" WIDTH="+Com("100%")+">"
@ prow()+1,0 say "<TR BGCOLOR="+Com("White")+">"
@ prow()+1,0 say "<TD></TD>"
@ prow()+1,0 say "<TD><B><FONT FACE="+Com("Arial")+"><FONT FACE="+Com("Arial")+" SIZE="+Com("2")+">"
@ prow()+1,0 say "<TABLE BORDER="+Com("0")+" ALIGN="+Com("RIGHT")+" WIDTH="+Com("80%")+">"
@ prow()+1,0 say "<TR>"
@ prow()+1,0 say "<TD><FONT FACE="+Com("Arial")+" SIZE="+Com("2")+">Fecha : <B><I>"+cVar1(1)+"</I></B></FONT></TD>"
@ prow()+1,0 say "</TR>"
@ prow()+1,0 say "<TR>"
@ prow()+1,0 say "<TD><FONT FACE="+Com("Arial")+" SIZE="+Com("2")+">Oficina: <B><I>"+cVar1(2)+"</I></B></FONT></TD>"
@ prow()+1,0 say "</TR>"
@ prow()+1,0 say "<TR>"
@ prow()+1,0 say "<TD><FONT FACE="+Com("Arial")+" SIZE="+Com("2")+">Encargado :<B><I>"+cVar1(3)+"</I></B></FONT></TD>"
@ prow()+1,0 say "</TR>"
@ prow()+1,0 say "</TABLE>"
@ prow()+1,0 say "<BR>"
@ prow()+1,0 say "</FONT></B></TD>"
@ prow()+1,0 say "</TR>"
@ prow()+1,0 say "<TR BGCOLOR="+Com("White")+">"
@ prow()+1,0 say "<TD><FONT COLOR="+Com("White")+"><FONT FACE="+Com("Arial")+"><FONT FACE="+Com("Arial")+" SIZE="+Com("2")+">"
@ prow()+1,0 say "<FONT FACE="+Com("Arial")+" SIZE="+Com("2")+" COLOR="+Com("Black")+">Empleado: <B><I>"+cVar1(4)+"</I></B></FONT><BR>"
@ prow()+1,0 say "<BR>"
@ prow()+1,0 say "<FONT FACE="+Com("Arial")+" SIZE="+Com("2")+" COLOR="+Com("Black")+">N&#250;mero:  <B><I>"+cVar1(5)+"</I></B><BR>"
@ prow()+1,0 say "<BR>"
@ prow()+1,0 say "<FONT FACE="+Com("Arial")+" SIZE="+Com("2")+" COLOR="+Com("Black")+">Empresa: <B><I>"+cVar1(6)+"</I></B><BR>"
@ prow()+1,0 say "<BR>"
@ prow()+1,0 say "<FONT FACE="+Com("Arial")+" SIZE="+Com("2")+" COLOR="+Com("Black")+">Importe Solicitado: <B> <I>"+cVar1(7)+"</I></B> <BR>"
@ prow()+1,0 say "<BR>"
@ prow()+1,0 say "<FONT FACE="+Com("Arial")+" SIZE="+Com("2")+" COLOR="+Com("Black")+">Semanas para pagar el pr&#233;stamo: <B><I>"+cVar1(8)+" </I></B><</FONT></TD>"
@ prow()+1,0 say "<TD><BR>"
@ prow()+1,0 say "</TD>"
@ prow()+1,0 say "</TR>"
@ prow()+1,0 say "</TABLE>"
@ prow()+1,0 say "</FONT></B></TD>"
@ prow()+1,0 say "<TD BGCOLOR="+Com("Black")+"></TD>"
@ prow()+1,0 say "</TR>"
@ prow()+1,0 say "<TR>"
@ prow()+1,0 say "<TD COLSPAN="+Com("3")+"></TD>"
@ prow()+1,0 say "<TD BGCOLOR="+Com("Black")+"></TD>"
@ prow()+1,0 say "</TR>"
@ prow()+1,0 say "</TABLE></CENTER>"
@ prow()+1,0 say "</BODY>"
@ prow()+1,0 say "</HTML>"

SET DEVICE TO Screen
SET PRINTER off
Return
*/
*************** Termina la modificacion. //Edgan LR. 10.nov.2008 Se comenta el codigo original porque se hicieron modificaciones funcionales al codigo. Como  guardar y consultar dentro del mismo GCI


*____________________________________________________________________________
Function  cVar1(nNum)
Local Var := aVars[nNum,2]
Return(Var)
*____________________________________________________________________________
Function Com(cTxt)
cTxt := Chr(34)+cTxt+Chr(34)
return cTxt
*____________________________________________________________________________
FUNCTION SacaVars(cInpVars)
   LOCAL aVRet := {}, aVnom := {}, aVvar := {}
   LOCAL nCiclo
   LOCAL cVarNom := "", cVal := ""

   /* espacios en blanco */
   cInpVars := STRTRAN(cInpVars,"+"," ")

   /* acentos min๚sculas*/
   cInpVars := STRTRAN(cInpVars,"%E1",CHR(160))
   cInpVars := STRTRAN(cInpVars,"%E9",CHR(130))
   cInpVars := STRTRAN(cInpVars,"%ED",CHR(161))
   cInpVars := STRTRAN(cInpVars,"%F3",chr(162))
   cInpVars := STRTRAN(cInpVars,"%FA",CHR(163))

	cInpVars := STRTRAN(cInpVars,"%21",CHR(33)) //  !
   cInpVars := STRTRAN(cInpVars,"%22",CHR(34)) //  "
   cInpVars := STRTRAN(cInpVars,"%23",CHR(35)) //  #
   cInpVars := STRTRAN(cInpVars,"%24",CHR(36)) //  $
   cInpVars := STRTRAN(cInpVars,"%25",CHR(37)) //  %
   cInpVars := STRTRAN(cInpVars,"%26",CHR(38)) //  &
   cInpVars := STRTRAN(cInpVars,"%27",CHR(39)) //  '
   cInpVars := STRTRAN(cInpVars,"%28",CHR(40)) //  (
   cInpVars := STRTRAN(cInpVars,"%29",CHR(41)) //  )

   cInpVars := STRTRAN(cInpVars,"%2A",CHR(42)) //  *
   cInpVars := STRTRAN(cInpVars,"%2B",CHR(43)) //  +
   cInpVars := STRTRAN(cInpVars,"%2C",CHR(44)) //  ,
   cInpVars := STRTRAN(cInpVars,"%2D",CHR(45)) //  -
   cInpVars := STRTRAN(cInpVars,"%2E",CHR(46)) //  .
   cInpVars := STRTRAN(cInpVars,"%2F",CHR(47)) //  /

   cInpVars := STRTRAN(cInpVars,"%3A",CHR(58)) //  :
   cInpVars := STRTRAN(cInpVars,"%3B",CHR(59)) //  ;
   cInpVars := STRTRAN(cInpVars,"%3C",CHR(60)) //  <
   cInpVars := STRTRAN(cInpVars,"%3D",CHR(61)) //  =
   cInpVars := STRTRAN(cInpVars,"%3E",CHR(62)) //  >
   cInpVars := STRTRAN(cInpVars,"%3F",CHR(63)) //  ?

   cInpVars := STRTRAN(cInpVars,"%0D",CHR(13)) //  Retorno de carro o Enter

   /*e๑es mayusculas y min๚sculas*/
   cInpVars := STRTRAN(cInpVars,"%F1",chr(164))
   cInpVars := STRTRAN(cInpVars,"%D1",CHR(165))

   FOR nCiclo := 1 TO LEN(cInpVars)
      DO CASE
         CASE SUBSTR(cInpVars,nCiclo,1) == "="
            AADD(aVnom,cVarNom)
            cVarNom := ""
         CASE SUBSTR(cInpVars,nCiclo,1) == "&"
            AADD(aVvar,cVarNom)
            cVarNom := ""
          OTHERWISE
         cVarNom += SUBSTR(cInpVars,nCiclo,1)
      ENDCASE
   NEXT
   AADD(aVvar,cVarNom)

   FOR nCiclo := 1 TO LEN(aVnom)
       AADD(aVret,{aVnom[nCiclo],aVvar[nCiclo]})
   NEXT
RETURN (aVret)
*******************************************************
****   zona de funciones comunes **********************
*อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
*  Funcion que llena con cCar a la izquierda mas el cTexto hasta lograr una
*  cadena de longitud igual a nLen
Function ReformIz(cTexto,nLen,cCar)
Local cTexFin:=""

		cTexto:=Alltrim(cTexto)
		cTexto:=StrTran(cTexto," ","",1)
		FOR i:=Len(cTexto) TO nLen - 1
			cTexFin:=cTexFin + cCar
		NEXT
			cTexFin:=cTexFin + cTexto

Return cTexFin
*ออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ
*  Funcion que llena con cCar a la derecha mas el cTexto hasta lograr una
*  cadena de longitud igual a nLen

Function ReformDe(cTexto,nLen,cCar)
Local cTexFin:=""

		cTexto:=Alltrim(cTexto)
		cTexto:=StrTran(cTexto," ","",1)

		FOR i:=Len(cTexto) TO nLen - 1
			cTexFin:=cTexFin + cCar
		NEXT
			cTexFin:=cTexto + cTexFin

Return cTexFin
*อออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออ


/*
ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
บ Codigo:   Usame(nombredbf)                               บ
บ Modulo:   Apertura de bases en modulos varios            บ
บ Llamado:  Directo                                        บ
ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
*/
Function Usame(nom_dbf)
    base_au := ""
    indi_a1 := ""
    indi_a2 := ""
    indi_a3 := ""
    alias:=""
    PAR_EMPN:="01"
    PAR_DATOS:="C:\INTRA_DB\"

    DO CASE
        CASE Upper(Trim(nom_dbf)) =  "CTRLFINT"
            base_au := PAR_DATOS  + "CTRLFINT.D"  + par_EmPN
            alias:="CTRLFINT"
        CASE Upper(Trim(nom_dbf)) =  "ENCPREST"
            base_au := PAR_DATOS  + "ENCPREST.D"  + par_EmPN
            alias   := "ENCPREST"
            indi_a1 := PAR_DATOS  + "ENCPRx1.X" + par_EmPN
    ENDCASE

    IF Indi_a1<>""
        USE &base_au ALIAS &ALIAS NEW SHARED
    ELSE
        USE &base_au INDEX &indi_a1 ALIAS &ALIAS NEW SHARED
    ENDIF

Return
*ออออออออออออออออออออออออออออออออออออออ


**********************
FUNCTION Entidades(cCadena) // Edgan 08.ene.09 Correccion de entidades HTML (caracteres especiales)
// Convierte a minusculas las letras de las entidades html con el fin de que sean interpretadas
// correctamente por el navegador y no muestre caracteres raros.    
    cAux:=""
    cSalida:=""
    For EnX:=1 to Len(alltrim(cCadena))
        nAux=""
        If SUBSTR(cCadena, Enx, 1) = "&"            
            nPos:= EnX + 2 // Incrementa para saltarse el caracter inmediato siguiente            

            Do While SUBSTR(cCadena, nPos, 1)<>";" .AND. nPos<=Len(alltrim(cCadena)) // Busca el punto y coma para asegurarse que se trata de una entidad
                nPos++                                                
            End Do

            If SUBSTR(cCadena, nPos, 1)=";"   // Garantiza que encontro el cierre de la entidad
                cAux= SUBSTR(cCadena, Enx, 2)                                   // Copia el ampersand y el caracter siguiente tal cual
                cAux= cAux + LOWER( SUBSTR(cCadena, Enx + 2, (nPos-Enx - 2) ) )     // copia la entidad convertida a minusculas
                cAux= cAux + SUBSTR(cCadena, nPos, 1)                           // Copia el punto y coma
                cSalida = cSalida + cAux
                EnX = nPos
                ? cAux
            Else 
                cSalida = cSalida + SUBSTR(cCadena, Enx, LEN(cCadena))
            EndIF                
        Else
            cSalida = cSalida + SUBSTR(cCadena, Enx, 1)
        EndIF        
    Next    
RETURN cSalida



