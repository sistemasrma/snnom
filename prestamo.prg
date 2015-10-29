**----------------------------------
**NOMBRE: prestamo.prg
**OBJETIVO: Menu de Recursos Humanos
**ALCANCE:
**PROCEDIMIENTOS:
**REFERENCIAS CRUZADAS:
**      programas:
**      base de datos/tabla:
** BITACORA DE CAMBIOS:
**      - Fecha:03.mar.2009  Autor:Edgan  Descripción: Se agrega un splash con los lineamientos para solicitud de prestamos.
**      - Fecha:03.mar.2009  Autor:Edgan  Descripción: Karina Olvera Solicita que se cambie la comision de apertura al 3% para fondo de ahorro y de 1.5% sobre saldos insolutos.
**      - Fecha:25.feb.2009  Autor:Edgan  Descripción: Karina Olvera Solicita que se cambie la tasa de interes al 3% para fondo de ahorro
**      - Fecha:20.ene.2009  Autor:Edgan  Descripción: Se agregan criterios para el prestamo por fondo de ahorro.
**      - Fecha:13.nov.2008  Autor:Edgan  Descripción: Creacion. Sustituye al documento actual que erea un HTML Se redistribuye la presentacion del formulario. 
** COMENTARIOS
**      - Fecha:20.nov.2008  Autor:Edgan L Descripción: Politicas para un préstamo.
**        El primer prestamo es por fondo de ahorro
**        Para prestamos de empresa maximo pagar en 10 semanas
**        Para prestamos de fondo de ahorro maximo pagar hasta 15 semanas
**        Deben transcurrir 6 meses para que otorguen el otro prestamo
**        Para prestamo x fondo de ahorro no se puede pedir mas de lo que tiene ahorrado la persona
**        Para el fondo de ahorro por cada prestamo realizado se cobra una comision de apertura del 1.5 sobre saldos insolutos.
**        La compañia no cobra comision de apertura.
**
**      - Fecha:13.nov.2008  Autor:Depto Sistemas Descripción: *** Desplegar el formulario de solicitud de reporte
**---------------------------------





FUNCTION Main(cIniFile)

    LOCAL cOutFile := ""
    LOCAL cInpFile := ""
    LOCAL cInpVars
    PRIVATE aVars
    PRIVATE cUsuar
    Public cNomAuto:="CONCEPCION KARINA OLVERA MONCADA" && Persona autorizada para el cambio de interes
    Public cSoloCom:="MARIA DEL CARMEN DIAZ MARTINEZ" && Persona limitada a dar solo prestamos por compañia
    Public cIntVer:=""
    Public cComVer:=""

   #include "grump.ch"
   Set Date British
   Set Epoch to 1950
   Set deleted on
   
  
   cVer="Prestamo.int [Desplegar el formulario de solicitud de reporte] Rel: 2009abr01 Edgan"

   ? cVer
   *** Leo parametros que mand¢ la pagina anterior.
    SuperJos(cIniFile,@cOutFile,@cInpFile)
    *** Todo el resto es cgi normal

    cInpVars := MemoRead(cInpFile)
    aVars    := SacaVars(cInpVars)
    
    ** Valido que el array de valores pasados tenga datos suficientes.
    ValArray(cOutFile,len(aVars),1,"")

    // Muestra las variables que recibe    
    **VeVarCGI()


    SET PRINTER TO (cOutFile)
    SET DEVICE TO PRINTER


    ** Extraigo clave universal de usuarios y nombre de usuario
    cClaUni:=aVars[1,1]
    ValUsuI04(cClaUni,"")
    
    && Deshabilita el cambio de interes si no se trata de una persona autorizada
    If(!Alltrim(cNomUsu)==Alltrim(cNomAuto))
        cIntVer:="readonly"
    EndIf
    If(Alltrim(cNomUsu)==Alltrim(cSoloCom))
        cComVer:="disabled" && deshabilita prestamo por fondo
    EndIf





    // La siguiente funcion es para declarar variables y valores de acuerdo a los parametros recibidos. Elimina dependencia de variable/posicion.
    FOR i := 1 TO LEN(aVars)
       declaraVar:=aVars[i,1]
       If(SubStr(declaraVar,1,8)=="required")
           declaraVar:=SubStr(declaraVar,9,10) //nombre de variable de maximo 10 caracteres quitando required
       Else
           declaraVar:=SubStr(declaraVar,1,10) //nombre de variable de maximo 10 caracteres
       EndIf
       &declaraVar:= aVars[i,2]
       //? "Nombre declarado:" + declaraVar
       //? "Valor declarado:" + &declaraVar
       //Edgan LR 13.nov.2008.  La cClaUni, clave de usuario debio haber sido creada junto con su valor en este bloque de creacion de variables
    NEXT            
   
    

    @ prow(),  0 say "Content-type: text/html"
    @ prow()+1,0 say ""        
    @ prow()+1,0 say '<html>'    
    @ prow()+1,0 say '<!-- ' + cVer + ' -->'
    @ prow()+1,0 say '<head>'
    @ prow()+1,0 say '<title></title>'
    @ prow()+1,0 say '<!-- saved from url=(0014)about:internet -->'
    @ prow()+1,0 say '<script>'

    @ prow()+1,0 say 'function checkrequiredEmp(which){'
    @ prow()+1,0 say '  var pass=true'
    @ prow()+1,0 say '  if (document.images){'
    @ prow()+1,0 say '    for (i=2;i<which.length;i++){'
    @ prow()+1,0 say '      var tempobj=which.elements[i]'
    @ prow()+1,0 say '      if (tempobj.name.substring(0,8)=="required"){'   
    @ prow()+1,0 say '        if (((tempobj.type=="text"||tempobj.type=="textarea")&&tempobj.value=="")||(tempobj.type.toString().charAt(0)=="s"&&tempobj.selectedIndex==-1)){'    
    @ prow()+1,0 say '            pass=false'
    @ prow()+1,0 say '            break'    
    @ prow()+1,0 say '        }'
    @ prow()+1,0 say '      }'
    @ prow()+1,0 say '    }'
    @ prow()+1,0 say '  }'
    @ prow()+1,0 say '  if (!pass){'
    @ prow()+1,0 say '    alert("No se puede calcular esta SOLICITUD porque los datos del empleado no están completos");'
    @ prow()+1,0 say '  }'
    @ prow()+1,0 say '  else{'    
    @ prow()+1,0 say '    if (document.solicitud.requiredSemanas.value>10 && document.solicitud.tipo[0].checked){' // Valida que no exceda de 10 semanas si se prestamo por compañia
    @ prow()+1,0 say '      var answer = confirm("El número máximo de semanas es 10.\nEsta solicitud la analizaran los directivos.Desea continuar? ");'
    @ prow()+1,0 say '      var okInteres= checaInt();'
    @ prow()+1,0 say '      if (answer && okInteres){'
    @ prow()+1,0 say '        which.GUARDAR.value = "SI"'
    @ prow()+1,0 say '        document.solicitud.submit();'
    @ prow()+1,0 say '      }'
    @ prow()+1,0 say '      else{document.solicitud.requiredSemanas.focus();}'
    @ prow()+1,0 say '    }'
    @ prow()+1,0 say '    else'
    @ prow()+1,0 say '    {'
    @ prow()+1,0 say '      if (document.solicitud.requiredSemanas.value>15 && document.solicitud.tipo[1].checked){' // Valida que no exceda de 15 semanas si se prestamo por fondo
    @ prow()+1,0 say '        var answer = confirm("El número máximo de semanas es 15.\nEsta solicitud la analizaran los directivos.Desea continuar? ");'
    @ prow()+1,0 say '        var okInteres= checaInt();'
    @ prow()+1,0 say '        if (answer && okInteres){'
    @ prow()+1,0 say '          which.GUARDAR.value = "SI"'
    @ prow()+1,0 say '          document.solicitud.submit();'
    @ prow()+1,0 say '        }'
    @ prow()+1,0 say '      }'
    @ prow()+1,0 say '      else{'
    @ prow()+1,0 say '        var okInteres= checaInt();'
    @ prow()+1,0 say '        if (okInteres){'
    @ prow()+1,0 say '          which.GUARDAR.value = "SI"'
    @ prow()+1,0 say '          document.solicitud.submit();'
    @ prow()+1,0 say '        }'
    @ prow()+1,0 say '      }'
    @ prow()+1,0 say '    }'
    @ prow()+1,0 say '  }'

//    @ prow()+1,0 say '  var pass=true'
//    @ prow()+1,0 say '  if (document.images){'
//    @ prow()+1,0 say '    for (i=0;i<which.length;i++){'
//    @ prow()+1,0 say '      var tempobj=which.elements[i]'
//    @ prow()+1,0 say '      if (tempobj.name.substring(0,8)=="required"){'
//    @ prow()+1,0 say '        if (((tempobj.type=="text"||tempobj.type=="textarea")&&tempobj.value=="")||(tempobj.type.toString().charAt(0)=="s"&&tempobj.selectedIndex==-1)){'
//    @ prow()+1,0 say '          pass=false'
//    @ prow()+1,0 say '          break'
//    @ prow()+1,0 say '        }'
//    @ prow()+1,0 say '      }'
//    @ prow()+1,0 say '    }'
//    @ prow()+1,0 say '  }'
//    @ prow()+1,0 say '  if (!pass){'
//    @ prow()+1,0 say '    alert("No se puede enviar esta SOLICITUD porque los datos no están completos")'
//    @ prow()+1,0 say '  }'
//    @ prow()+1,0 say '  else{'
//    @ prow()+1,0 say '    var okInteres= checaInt();'
//    @ prow()+1,0 say '    if (document.solicitud.requiredSemanas.value>10 && okInteres ){'
//    @ prow()+1,0 say '      var answer = confirm("El número máximo de semanas es 10.\nEsta solicitud la analizaran los directivos.Desea continuar? ");'
//    @ prow()+1,0 say '      if (answer){'
//    @ prow()+1,0 say '        which.GUARDAR.value = "SI"'
//    @ prow()+1,0 say '        document.solicitud.Enviar.disabled=true;'
//    @ prow()+1,0 say '        document.solicitud.submit();'
//    @ prow()+1,0 say '      }'
//    @ prow()+1,0 say '      else{document.solicitud.requiredSemanas.focus()}'
//    @ prow()+1,0 say '    }'
//    @ prow()+1,0 say '    else{'
//    @ prow()+1,0 say '      var okInteres= checaInt();'
//    @ prow()+1,0 say '      if (okInteres){'
//    @ prow()+1,0 say '        which.GUARDAR.value = "SI"'
//    @ prow()+1,0 say '        document.solicitud.Enviar.disabled=true;'
//    @ prow()+1,0 say '        document.solicitud.submit();'
//    @ prow()+1,0 say '      }'
//    @ prow()+1,0 say '    }'
//    @ prow()+1,0 say '  }'
    @ prow()+1,0 say '}'

    @ prow()+1,0 say 'function checkRequired(which){'
    @ prow()+1,0 say '  var pass=true'
    @ prow()+1,0 say '  if (document.images){'
    @ prow()+1,0 say '    for (i=2;i<which.length;i++){'
    @ prow()+1,0 say '      var tempobj=which.elements[i]'
    @ prow()+1,0 say '      if (tempobj.name.substring(0,8)=="required"){'   
    @ prow()+1,0 say '        if (((tempobj.type=="text"||tempobj.type=="textarea")&&tempobj.value=="")||(tempobj.type.toString().charAt(0)=="s"&&tempobj.selectedIndex==-1)){'
    @ prow()+1,0 say '          if ((tempobj.name.substring(8,11)!="Ofi")&&(tempobj.name.substring(8,11)!="Enc")){' // Descarta que se trate de los campos oficina y empresa ya que solo es una consulta
    @ prow()+1,0 say '            pass=false'
    @ prow()+1,0 say '            break'
    @ prow()+1,0 say '          }'
    @ prow()+1,0 say '        }'
    @ prow()+1,0 say '      }'
    @ prow()+1,0 say '    }'
    @ prow()+1,0 say '  }'
    @ prow()+1,0 say '  if (!pass){'
    @ prow()+1,0 say '    alert("No se puede calcular esta SOLICITUD porque los datos del empleado no están completos");'
    @ prow()+1,0 say '  }'
    @ prow()+1,0 say '  else{'    
    @ prow()+1,0 say '    if (document.solicitud.requiredSemanas.value>10 && document.solicitud.tipo[0].checked){' // Valida que no exceda de 10 semanas si se prestamo por compañia
    @ prow()+1,0 say '      var answer = confirm("El número máximo de semanas es 10.\nEsta solicitud la analizaran los directivos.Desea continuar? ");'
    @ prow()+1,0 say '      if (answer){'
    @ prow()+1,0 say   '      var okInteres= checaInt();'
    @ prow()+1,0 say   '      if (okInteres){'
    @ prow()+1,0 say '        which.GUARDAR.value = "NO"'
    @ prow()+1,0 say '        document.solicitud.submit();'
    @ prow()+1,0 say   '      }'
    @ prow()+1,0 say '      }'
    @ prow()+1,0 say  '    else{document.solicitud.requiredSemanas.focus();}'
    @ prow()+1,0 say '    }'
    @ prow()+1,0 say '    else'
    @ prow()+1,0 say '    {'
    @ prow()+1,0 say '      if (document.solicitud.requiredSemanas.value>15 && document.solicitud.tipo[1].checked){' // Valida que no exceda de 15 semanas si se prestamo por fondo
    @ prow()+1,0 say '        var answer = confirm("El número máximo de semanas es 15.\nEsta solicitud la analizaran los directivos.Desea continuar? ");'
    @ prow()+1,0 say '        if (answer){'
    @ prow()+1,0 say     '      var okInteres= checaInt();'
    @ prow()+1,0 say     '      if (okInteres){'
    @ prow()+1,0 say     '        which.GUARDAR.value = "NO"'
    @ prow()+1,0 say     '        document.solicitud.submit();'
    @ prow()+1,0 say     '      }'
    @ prow()+1,0 say '        }'
    @ prow()+1,0 say     '    else{document.solicitud.requiredSemanas.focus();}'
    @ prow()+1,0 say '      }'
    @ prow()+1,0 say '      else{'
    @ prow()+1,0 say '        var okInteres= checaInt();'
    @ prow()+1,0 say '        if (okInteres){'
    @ prow()+1,0 say '          which.GUARDAR.value = "NO"'
    @ prow()+1,0 say '          document.solicitud.submit();'
    @ prow()+1,0 say '        }'
    @ prow()+1,0 say '      }'
    @ prow()+1,0 say '    }'
    @ prow()+1,0 say '  }'
    @ prow()+1,0 say '}'


    @ prow()+1,0 say 'function checaInt(){'
    @ prow()+1,0 say '  if (document.solicitud.tipo[0].checked && document.solicitud.requiredInter.value!=10){' // el interes es del 10%
    @ prow()+1,0 say '    var answerInt = confirm("El interes debe ser del 10%.\nEsta solicitud la analizaran los directivos.Desea continuar? ");'
    @ prow()+1,0 say '    if (!answerInt){'
    @ prow()+1,0 say '    document.solicitud.requiredInter.focus(); return false;'
    //@ prow()+1,0 say '      return true;'    
    @ prow()+1,0 say '    }'
    //@ prow()+1,0 say '    else{document.solicitud.requiredInter.focus();return false;}'
    @ prow()+1,0 say '  }'

    @ prow()+1,0 say '  if (document.solicitud.tipo[0].checked && document.solicitud.requiredcComisi.value!=0){' //Edgan 2009mar03 el interes es del 1.5%
    @ prow()+1,0 say '    var answerInt = confirm("La comisión por apertura debe ser del 0%.\nEsta solicitud la analizaran los directivos.Desea continuar? ");'
    @ prow()+1,0 say '    if (!answerInt){'
    @ prow()+1,0 say '    document.solicitud.requiredcComisi.focus(); return false;'
    //@ prow()+1,0 say '      return true;'    
    @ prow()+1,0 say '    }'
    //@ prow()+1,0 say '    else{document.solicitud.requiredInter.focus(); return false;}'
    @ prow()+1,0 say '  }'



//    @ prow()+1,0 say '  if (document.solicitud.tipo[1].checked && document.solicitud.requiredInter.value!=1.5){' // el interes es del 1.5%
    @ prow()+1,0 say '  if (document.solicitud.tipo[1].checked && document.solicitud.requiredInter.value!=1.5){' //Edgan 2009mar03 el interes es del 1.5%
    @ prow()+1,0 say '    var answerInt = confirm("El interes debe ser del 1.5%.\nEsta solicitud la analizaran los directivos.Desea continuar? ");'
    @ prow()+1,0 say '    if (!answerInt){'
    @ prow()+1,0 say '    document.solicitud.requiredInter.focus(); return false;'
    //@ prow()+1,0 say '      return true;'    
    @ prow()+1,0 say '    }'
    //@ prow()+1,0 say '    else{document.solicitud.requiredInter.focus(); return false;}'
    @ prow()+1,0 say '  }'

    @ prow()+1,0 say '  if (document.solicitud.tipo[1].checked && document.solicitud.requiredcComisi.value!=3){' //Edgan 2009mar03 el interes es del 1.5%
    @ prow()+1,0 say '    var answerInt = confirm("La comisión por apertura debe ser del 3%.\nEsta solicitud la analizaran los directivos.Desea continuar? ");'
    @ prow()+1,0 say '    if (!answerInt){'
    @ prow()+1,0 say '    document.solicitud.requiredcComisi.focus(); return false;'
    //@ prow()+1,0 say '      return true;'    
    @ prow()+1,0 say '    }'
    //@ prow()+1,0 say '    else{document.solicitud.requiredInter.focus(); return false;}'
    @ prow()+1,0 say '  }'

    @ prow()+1,0 say '  return true;'
    @ prow()+1,0 say '}'


    cNota='           <ul>'
    cNota+='          <li>El primer prestamo del a&ntilde;o es por fondo de ahorro.<br></li>'
    cNota+='          </ul>'
    cNota+='          <ul>'
    cNota+='            <li>Para préstamos en los meses de Junio y Diciembre debe checarlo antes con el Departamento de Personal. <br></li>'
    cNota+='          </ul>'
    cNota+='          <ul>'
    cNota+='            <li>Los pagos no debe de exceder el 30% del sueldo semanal del empleado. <br></li>'
    cNota+='          </ul>'
    cNota+='          <ul>'
    cNota+='            <li>Se cobra una Comisión por apertura del 3%. <br></li>'
    cNota+='          </ul>'
    cNota+='          <ul>'
    cNota+='            <li>Los intereses se calculan sobre saldos insolutos.<br></li>'
    cNota+='          </ul>'
    cNota+='          <ul>'
    cNota+='          <li>El prestamo por fondo de ahorro se descuentan máximo a 15 semanas.<br></li>'
    cNota+='          </ul>'
    cNota+='          <ul>'
    cNota+='          <li>El prestamo no debe exceder la cantidad del fondo de ahorro del empleado.<br></li>'
    cNota+='          </ul>'

    

    @ prow()+1,0 say 'function notaFondo()'
    @ prow()+1,0 say '{'
    @ prow()+1,0 say '  document.getElementById("Notas").innerHTML="' + cNota + '";'    
//    @ prow()+1,0 say '  document.solicitud.requiredInter.value="1.5";'    
    @ prow()+1,0 say '  document.solicitud.requiredInter.value="1.5";' // Edgan 2009mar03 Se cambia el interes al 1.5%
    @ prow()+1,0 say '  document.solicitud.requiredcComisi.value="3";' // Edgan 2009mar03 Se cambia el interes al 1.5%
    @ prow()+1,0 say '}'

    
    cNota='           <ul>'
    cNota+='          <li>El primer prestamo del a&ntilde;o es por fondo de ahorro.<br></li>'
    cNota+='          </ul>'
    cNota+='          <ul>'
    cNota+='            <li>Para préstamos en los meses de Junio y Diciembre debe checarlo antes con el Departamento de Personal. <br></li>'
    cNota+='          </ul>'    
    cNota+='          <ul>'
    cNota+='            <li>Los pagos no deben de exceder el 30% del sueldo semanal del empleado. <br></li>'
    cNota+='          </ul>'
    cNota+='          <ul>'
    cNota+='          <li>Intereses del 10% sobre el monto del prestamo.<br></li>'
    cNota+='          </ul>'
    cNota+='          <ul>'
    cNota+='          <li>El prestamo por compa&ntilde;ía se descuenta máximo a 10 semanas.<br></li>'
    cNota+='          </ul>'


    @ prow()+1,0 say 'function notaComp()'
    @ prow()+1,0 say '{'
    @ prow()+1,0 say '  document.getElementById("Notas").innerHTML="' + cNota + '";'
    //@ prow()+1,0 say '  document.getElementById("idSueldo").innerHTML="Sueldo Bruto Mensual:";'
    @ prow()+1,0 say '  document.solicitud.requiredInter.value="10";'    
    @ prow()+1,0 say '  document.solicitud.requiredcComisi.value="0";' // Edgan 2009mar03 comision del 0%
    @ prow()+1,0 say '}'



    @ prow()+1,0 say '</script>'
    @ prow()+1,0 say '<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1"></head>'

    @ prow()+1,0 say '<body BGCOLOR="#CCCCCC" >'    
    fnSplash()&& Muesta una pantalla(html) Splash que contiene los lineamientos para elaborar prestamos.
    @ prow()+1,0 say    '<div id="contenido" style="display:none">'&&Div que oculta el contenido
    @ prow()+1,0 say '  <!--<div align="center"><center> -->'
    @ prow()+1,0 say '  <table width="95%" align="center"  border="0" BGCOLOR="#0080C0" cellborder="0" cellpadding="0">'
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td ALIGN="CENTER"><br> <font SIZE="4" FACE="Arial" COLOR="#400080"><b>Solicitud de Pr&eacute;stamo<br>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'
    @ prow()+1,0 say '      <tr>'
    @ prow()+1,0 say '          <td align="right" style="border-top:thin solid #FFFFFF">'
    @ prow()+1,0 say '              <form name="frmConsulta" action="/CGI-DOS/int1212.int" method="POST"> '
    @ prow()+1,0 say '                <input type="hidden" name="' + cClaUni + '" value="0">' // Edgan LR 13.nov.2008 Conservar la clave del usuario. 
    @ prow()+1,0 say '                <!-- <input TYPE="hidden" NAME="GUARDAR" value="SI">Mandar el numero de empleado cClaUni -->               '
    @ prow()+1,0 say '                   <input TYPE="hidden" NAME="Filtro" value="Autorizados">'
    @ prow()+1,0 say '              </form>'
    @ prow()+1,0 say '              <font color="#FFFFFF">Consultar:</font>'
    @ prow()+1,0 say '              <a href="javascript:document.frmConsulta.Filtro.value=' +CHR(39)+ 'Pendientes' +CHR(39)+ ';document.frmConsulta.submit();" style="color:#ffffff;">|Pendientes</a>'
    @ prow()+1,0 say '              <a href="javascript:document.frmConsulta.Filtro.value=' +CHR(39)+ 'Autorizados' +CHR(39)+ ';document.frmConsulta.submit();" style="color:#ffffff;">|Autorizados|</a>'
    @ prow()+1,0 say '              <a href="javascript:document.frmConsulta.Filtro.value=' +CHR(39)+ 'Nautorizados' +CHR(39)+ ';document.frmConsulta.submit();" style="color:#ffffff;">No autorizados|</a>'
    @ prow()+1,0 say '              <a href="javascript:document.frmConsulta.Filtro.value=' +CHR(39)+ 'Todos' +CHR(39)+ ';document.frmConsulta.submit();" style="color:#ffffff;">Todos</a>'
    @ prow()+1,0 say '          </td>'
    @ prow()+1,0 say '      </tr>'
    @ prow()+1,0 say '  </table>'

    /*@ prow()+1,0 say '     <!-- <table width="82%"align=center  border="0">'
    @ prow()+1,0 say '        <tr>'
    @ prow()+1,0 say '          <td COLSPAN="3"><table BORDER="1" ALIGN="DEFAULT" WIDTH="100%">'
    @ prow()+1,0 say '              <tr>'
    @ prow()+1,0 say '                <td BGCOLOR="#0080C0" ALIGN="CENTER"><br> <font SIZE="4" FACE="Arial" COLOR="#400080"><b>Solicitud edgan'
    @ prow()+1,0 say '                     de Préstamo<br>'
    @ prow()+1,0 say '                  <br>'
    @ prow()+1,0 say '                  </b></font></td>'
    @ prow()+1,0 say '              </tr>'
    @ prow()+1,0 say '            </table>'
    @ prow()+1,0 say '            <p><b><font FACE="Arial"><br>'
    @ prow()+1,0 say '              <br>'
    @ prow()+1,0 say '              </font></b></td>'
    @ prow()+1,0 say '        </tr>'
    @ prow()+1,0 say '        <tr>'
    @ prow()+1,0 say '          <td><font FACE="Arial" SIZE="2">Encargado </font> <input TYPE="TEXT"'
    @ prow()+1,0 say '      NAME="requiredEncargado" SIZE="25" MAXLENGTH="25"> </td>'
    @ prow()+1,0 say '          <td></td>'
    @ prow()+1,0 say '          <td><font FACE="Arial" SIZE="2">Oficina </font> <input TYPE="TEXT" NAME="requiredOficina" SIZE="15" MAXLENGTH="15"> </td>'
    @ prow()+1,0 say '        </tr>'
    @ prow()+1,0 say '        <tr>'
    @ prow()+1,0 say '          <td></td>'
    @ prow()+1,0 say '          <td></td>'
    @ prow()+1,0 say '          <td>&nbsp;</td>'
    @ prow()+1,0 say '        </tr>'
    @ prow()+1,0 say '        <tr>'
    @ prow()+1,0 say '          <td><font FACE="Arial" SIZE="2"><i><b>Datos del empleado<br>'
    @ prow()+1,0 say '            <br>'
    @ prow()+1,0 say '            </b></i></font></td>'
    @ prow()+1,0 say '          <td></td>'
    @ prow()+1,0 say '          <td></td>'
    @ prow()+1,0 say '        </tr>'
    @ prow()+1,0 say '        <tr>'
    @ prow()+1,0 say '          <td><font FACE="Arial" SIZE="2">Nombre'
    @ prow()+1,0 say '            <input TYPE="TEXT" NAME="requiredNombre" SIZE="27"'
    @ prow()+1,0 say '      MAXLENGTH="27">'
    @ prow()+1,0 say '            <br>'
    @ prow()+1,0 say '            <br>'
    @ prow()+1,0 say '            </font></td>'
    @ prow()+1,0 say '          <td><font FACE="Arial" SIZE="2">Número'
    @ prow()+1,0 say '            <input TYPE="TEXT" NAME="requiredNum" SIZE="6"'
    @ prow()+1,0 say '      MAXLENGTH="4">'
    @ prow()+1,0 say '            <br>'
    @ prow()+1,0 say '            <br>'
    @ prow()+1,0 say '            </font></td>'
    @ prow()+1,0 say '          <td><font FACE="Arial" SIZE="2">Empresa'
    @ prow()+1,0 say '            <input TYPE="TEXT" NAME="requiredEmpresa"'
    @ prow()+1,0 say '      SIZE="19" MAXLENGTH="20">'
    @ prow()+1,0 say '            <br>'
    @ prow()+1,0 say '            </font><br> </td>'
    @ prow()+1,0 say '        </tr>'
    @ prow()+1,0 say '        <tr>'
    @ prow()+1,0 say '          <td><font FACE="Arial" SIZE="2">Importe Solicitado<font FACE="Arial" SIZE="2">'
    @ prow()+1,0 say '            <input'
    @ prow()+1,0 say '      TYPE="TEXT" NAME="requiredMonto" SIZE="19" MAXLENGTH="20">'
    @ prow()+1,0 say '            <br>'
    @ prow()+1,0 say '            <br>'
    @ prow()+1,0 say '            <br>'
    @ prow()+1,0 say '            <br>'
    @ prow()+1,0 say '            </font></font></td>'
    @ prow()+1,0 say '          <td COLSPAN="2"><font FACE="Arial" SIZE="2">Semanas en que se cubrirá'
    @ prow()+1,0 say '            el préstamo:'
    @ prow()+1,0 say '            <input'
    @ prow()+1,0 say '      TYPE="TEXT" NAME="requiredSemanas" SIZE="2" MAXLENGTH="2">'
    @ prow()+1,0 say '            <br>'
    @ prow()+1,0 say '            </font><b><font SIZE="1" FACE="Arial"><u>Todos los prestamos se descontarán'
    @ prow()+1,0 say '            en máximo 10 semanas.</u></font></b></td>'
    @ prow()+1,0 say '        </tr>'
    @ prow()+1,0 say '        <tr>'
    @ prow()+1,0 say '          <td COLSPAN="3"><table BORDER="0" ALIGN="RIGHT" WIDTH="90%">'
    @ prow()+1,0 say '              <tr>'
    @ prow()+1,0 say '                <td ALIGN="RIGHT" VALIGN="TOP"><font FACE="Arial" SIZE="2"><b><i>NOTA:</i></b></font></td>'
    @ prow()+1,0 say '                <td><ul>'
    @ prow()+1,0 say '                    <font FACE="Arial" SIZE="2"><b>'
    @ prow()+1,0 say '                    <li>Si desea pedir un préstamo en los meses de Junio y Diciembre'
    @ prow()+1,0 say '                      debe checarlo antes con el Departamento de Personal. </li>'
    @ prow()+1,0 say '                    <li><br>'
    @ prow()+1,0 say '                    </li>'
    @ prow()+1,0 say '                    <li>Se cobra una Comisión por apertura del 4%. </li>'
    @ prow()+1,0 say '                    <li><br>'
    @ prow()+1,0 say '                    </li>'
    @ prow()+1,0 say '                    <li>Intereses semanales 4% sobre saldos insolutos.</li>'
    @ prow()+1,0 say '                    </b></font> </ul></td>'
    @ prow()+1,0 say '              </tr>'
    @ prow()+1,0 say '            </table></td>'
    @ prow()+1,0 say '        </tr>'
    @ prow()+1,0 say '        <tr>'
    @ prow()+1,0 say '          <td colspan="3" ALIGN="CENTER"><br> <input TYPE="SUBMIT" NAME="ENVIAR" VALUE="ENVIAR SOLICITUD" "&lt;/TD" >'
    @ prow()+1,0 say '            <br> </td>'
    @ prow()+1,0 say '        </tr>'
    @ prow()+1,0 say '      </table>'
    @ prow()+1,0 say '          '*/


    

    @ prow()+1,0 say '  <form Name="solicitud" ACTION="/CGI-DOS/rpresta.int" METHOD="POST" TARGET="_self">'
    @ prow()+1,0 say '  <input type="hidden" name="' + cClaUni + '" value="0">' // Edgan LR 13.nov.2008 Conservar la clave del usuario.     
    @ prow()+1,0 say '  <table width="95%" align=center  border="0" cellspacing="3" cellborder="0">'
    
    // >> Edgan 
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td  align="right" valign="top">'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2">Tipo de préstamo: </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td >'
    @ prow()+1,0 say '        <input type="radio" name="tipo" value="COMPANIA" checked onClick="notaComp();"/> Compañia'
    @ prow()+1,0 say '        <br>'
    @ prow()+1,0 say '        <input type="radio" name="tipo" value="FONDO" onClick="notaFondo();" ' +cComVer+ '/> Fondo'    
    @ prow()+1,0 say '      </td>'
    
    @ prow()+1,0 say '      <td width="40%" rowspan="12" valign="top" style="border-left: thin ridge #E6E6E6;text-align:justify">'
    @ prow()+1,0 say '        <b>&nbsp&nbsp&nbsp&nbsp&nbsp Notas:</b>'    
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2" id="Notas">' // Edgan escribe las notas de acuerdo al tipo de prestamo
    //@ prow()+1,0 say '        <font FACE="Arial" SIZE="2" >' 
    // Las notas son escritas con el javascript
    @ prow()+1,0 say '        </font>'
    @ prow()+1,0 say '      </td>'

    @ prow()+1,0 say '    </tr>'
    //<<
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td width="40%" align=right>'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2">Encargado: </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td width="20%">'
    @ prow()+1,0 say '          <input TYPE="TEXT"NAME="requiredEncargado" SIZE="25" MAXLENGTH="25">'
    @ prow()+1,0 say '      </td>'

    @ prow()+1,0 say '    </tr>'
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td  align=right>'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2">Oficina: </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td >'
    @ prow()+1,0 say '        <input TYPE="TEXT" NAME="requiredOficina" SIZE="25" MAXLENGTH="30">'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td >'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td align=left >'
    @ prow()+1,0 say '        <br>'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2"><b>Datos del empleado</b></font><br>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td align=right>'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2">Numero de empleado: </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td >'
    @ prow()+1,0 say '          <input TYPE="TEXT" NAME="requiredNum" SIZE="25" MAXLENGTH="4">'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td align=right>'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2">Nombre: </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td >'
    @ prow()+1,0 say '          <input TYPE="TEXT" NAME="requiredNombre" SIZE="25" MAXLENGTH="25" >'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'

    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td align=right>'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2">Empresa: </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td >'
    @ prow()+1,0 say '          <input TYPE="TEXT" NAME="requiredEmpresa" SIZE="25" MAXLENGTH="30">'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'

    @ prow()+1,0 say '       <tr>'
    @ prow()+1,0 say '      <td align=right>'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2" id="idSueldo">Sueldo Bruto Mensual: </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td >'                                                                                
    @ prow()+1,0 say '          <input TYPE="TEXT" NAME="requiredSueldo" SIZE="25" MAXLENGTH="25" style="text-align:right"/>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'
    
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td align=right>'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2">Importe solicitado: </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td >'
    @ prow()+1,0 say '          <input TYPE="TEXT" NAME="requiredMonto" SIZE="25" MAXLENGTH="20" style="text-align:right"/>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'    
    // >> Edgan 2009mar03 Campo de comision de apertura
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td align="right">'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2">Comisi&oacute;n de apertura:(%): </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td >'
    @ prow()+1,0 say '          <input TYPE="TEXT" NAME="requiredcComisi" SIZE="25" MAXLENGTH="3" style="text-align:right"/>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'
    // <<

    // >> Edgan anterior 2009mar03 tasa de interes
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td align="right">'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2">Tasa de interes(%): </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td >'
    @ prow()+1,0 say '          <input TYPE="TEXT" NAME="requiredInter" SIZE="25" MAXLENGTH="3" style="text-align:right" ' +cIntVer+ '/>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'
    // <<
    @ prow()+1,0 say '      <tr>'
    @ prow()+1,0 say '      <td align=right>'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2">Semana de inicio de descuento: </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td >'
    @ prow()+1,0 say '          <input TYPE="TEXT" NAME="requiredSemIni" SIZE="25" MAXLENGTH="2" style="text-align:right"/>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'
    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td align=right>'
    @ prow()+1,0 say '        <font FACE="Arial" SIZE="2">Semanas en las que se cubrira el prestamo: </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td >'
    @ prow()+1,0 say '          <input TYPE="TEXT" NAME="requiredSemanas" SIZE="25" MAXLENGTH="2" style="text-align:right"/>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'

    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td align="right">'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td align="center">'
    @ prow()+1,0 say '        <font FACE="verdana" SIZE="2pt">'
    @ prow()+1,0 say '           <input TYPE="hidden" NAME="GUARDAR" value="NO">'
    @ prow()+1,0 say '           <a href="javascript:checkRequired(document.solicitud);">_Simular Tabla de pagos_</a>' // Edgan Se cambia La palabra ver por Simular para que sea mas facil identificar con el usuario.
    @ prow()+1,0 say '        </font>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'


    @ prow()+1,0 say '    <tr>'
    @ prow()+1,0 say '      <td>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td align="center" >'
    @ prow()+1,0 say '        <input TYPE="BUTTON" NAME="Enviar" VALUE="Enviar" style="font-family: Arial; font-size: 9pt; font-weight:600" onClick="checkrequiredEmp(document.solicitud);" >'
    @ prow()+1,0 say '        <input TYPE="RESET" NAME="CLEAR" VALUE="Limpiar" style="font-family: Arial; font-size: 9pt;">'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '      <td>'
    @ prow()+1,0 say '      </td>'
    @ prow()+1,0 say '    </tr>'
    @ prow()+1,0 say '    </table>'    
    @ prow()+1,0 say '</form>'

    // Edgan LR. 13.nov.2008 Se cambia el metodo atras por un forma para que llame al html padre.    
    @ prow()+1,0 say '<FORM  NAME="frMenu" ACTION="/private/int0003.int" METHOD="POST" target="_self">'
    @ prow()+1,0 say '  <input type="hidden" name="' + cClaUni + '" value="0">' // Edgan LR 13.nov.2008 Conservar la clave del usuario. 
    @ prow()+1,0 say '  <font size="2"><a href="javascript: document.frMenu.submit();">'
    @ prow()+1,0 say '  <div align="center"><font size="2" face="Verdana, Arial, Helvetica, sans-serif">ATRAS</font></div>'
    @ prow()+1,0 say '</a></FONT></FORM>'
    *******

    @ prow()+1,0 say '          <script >notaComp();</script>'
    @ prow()+1,0 say '</div>' && div del id="contenido"
    @ prow()+1,0 say '</body>'
    @ prow()+1,0 say '</html>'


    SET DEVICE TO SCREEN
    SET PRINT OFF

RETURN


FUNCTION fnSplash()
    @ prow()+1,0 say '<div id="splash" style="display:block">'

    @ prow()+1,0 say '<script type="text/javascript">'
    @ prow()+1,0 say    'function fnSplashCierra(){'
    @ prow()+1,0 say    'document.getElementById("splash").style.display="none"'
    @ prow()+1,0 say    'document.getElementById("contenido").style.display="block"'
    @ prow()+1,0 say    '}'
    @ prow()+1,0 say '</script>'


    @ prow()+1,0 say '<table width="100%" border="0" cellpadding="6">'
    @ prow()+1,0 say    '<tr>'
    @ prow()+1,0 say        '<th colspan="2" valign="center">'
    @ prow()+1,0 say            '<span style="background-color:black;color:white;border-bottom:medium solid yellow;border-right:thick solid yellow;border-top:medium solid black;border-left:thick solid black;">PROCEDIMIENTO PARA SOLICITAR UN PR&Eacute;STAMO'
    @ prow()+1,0 say        '</th>'
    @ prow()+1,0 say    '</tr>'
    @ prow()+1,0 say    '<tr>'
    @ prow()+1,0 say        '<td colspan="2" style="font-size:15px;color:maroon">'
    @ prow()+1,0 say            '<br>IMPORTANTE: Revisa cuidadosamente la información, y ANTES de enviar el préstamo verifica que todo esté correcto, de lo contrario el préstamo será rechazado y deberás solicitarlo nuevamente en la semana siguiente.<br><br>'
    @ prow()+1,0 say        '</td>'
    @ prow()+1,0 say    '</tr>'
    @ prow()+1,0 say    '<tr>'
    @ prow()+1,0 say        '<td style="font-weight:bold">'
    @ prow()+1,0 say            'Pr&eacute;stamo por Compa&ntilde;&iacute;a'
    @ prow()+1,0 say        '</td>'
    @ prow()+1,0 say        '<td style="font-weight:bold">'
    @ prow()+1,0 say            'Fondo de Ahorro'
    @ prow()+1,0 say        '</td>'
    @ prow()+1,0 say    '</tr>'
    
    @ prow()+1,0 say    '<tr>'
    @ prow()+1,0 say        '<td valign="top">'
    @ prow()+1,0 say            '<ul>'
    @ prow()+1,0 say                '<li>Tener a la mano el &uacute;ltimo recibo de n&oacute;mina del trabajador.</li>'
    @ prow()+1,0 say                '<li>Verificar si el personal es eventual o de planta.</li>'
    @ prow()+1,0 say                '<li>Llenar el formato del sistema con los datos COMPLETOS Y CORRECTOS.</li>'
    @ prow()+1,0 say                '<li>La semana de inicio de descuento siempre ser&aacute; la siguiente a la que se esta corriendo.</li>'
    @ prow()+1,0 say                '<li>Si el trabajador es eventual, el monto m&aacute;ximo del pr&eacute;stamo es de $500 y debe tener aproximadamente 10 semanas de aportaciones.</li>'
    @ prow()+1,0 say                '<li>Si el solicitante es de planta, el monto m&aacute;ximo depende de su salario diario.</li>'
    @ prow()+1,0 say                '<li>Este pr&eacute;stamo tiene restricciones, ya que solo se puede descontar el 30% de su salario diario ( sin prestaciones ).</li>'
    @ prow()+1,0 say                '<li>Para determinar el monto de descuento semanal: (SD*30%)*7 = DESCUENTO SEMANAL.</li>'
    @ prow()+1,0 say                '<li>La cantidad que resulte, es el monto máximo a descontar a la semana, y con este dato podemos calcular un aproximado del monto m&aacute;ximo del pr&eacute;stamo. </li>'
    @ prow()+1,0 say                '<li>MONTO TOTAL (incluye intereses) = (DESCUENTO SEMANAL ) * (# SEMANAS, m&aacute;ximo 10 para liquidar el pr&eacute;stamo).</li>'
    @ prow()+1,0 say            '</ul>'
    @ prow()+1,0 say        '</td>'


    @ prow()+1,0 say        '<td valign="top">'
    @ prow()+1,0 say            '<ul>'
    @ prow()+1,0 say                '<li>Tener a la mano el &uacute;ltimo recibo de n&oacute;mina del trabajador.</li>'
    @ prow()+1,0 say                '<li>Verificar si el personal es eventual o de planta.</li>'
    @ prow()+1,0 say                '<li>Llenar el formato del sistema con los datos COMPLETOS Y CORRECTOS.</li>'
    @ prow()+1,0 say                '<li>La semana de inicio de descuento siempre ser&aacute; la siguiente a la que se esta corriendo.</li>'
    @ prow()+1,0 say                '<li>Si el trabajador es eventual, el monto m&aacute;ximo del pr&eacute;stamo es de $500 y debe tener aproximadamente 10 semanas de aportaciones.</li>'
    @ prow()+1,0 say                '<li>Si el solicitante es de planta, el monto m&aacute;ximo es el total de sus aportaciones, aproximadamente un mes de salario.</li>'
    @ prow()+1,0 say                '<li>El descuento semanal, puede ser de hasta el total de su salario (como aparece en el recibo de n&oacute;mina).</li>'
    @ prow()+1,0 say                '<li>El plazo se puede ampliar hasta por 15 semanas.</li>'
    @ prow()+1,0 say                '<li>Se cobra comisión del 3% por apertura del cr&eacute;dito.</li>'
    @ prow()+1,0 say                '<li>La tasa de inter&eacute;s es del 1.5% sobre saldos insolutos.</li>'
    @ prow()+1,0 say            '</ul>'
    @ prow()+1,0 say            '<div align="right"><span style="border:medium solid black;text-align:right"><input id="btnSplashCierra" align="center" type="button"  name="btnSplashCierra" " value="Continuar" style="padding-left: 5; padding-right: 5; padding-top: 1; padding-bottom: 2; color: Maroon; background-color: #939da4; font-weight: 600; cursor: hand; border-top:2px solid #414347; border-right:2px solid #414347; border-bottom:2px solid white; border-left:2px solid white; width:150px;height:22px" onClick="fnSplashCierra();"/></span></div>'
    @ prow()+1,0 say        '</td>'
    @ prow()+1,0 say    '</tr>'
    @ prow()+1,0 say '</table>'
    @ prow()+1,0 say '</div>'
    
RETURN .T.


///comentarios

