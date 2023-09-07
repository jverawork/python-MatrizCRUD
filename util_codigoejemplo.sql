PROCEDURE CRE_EJECUTADEBITO_P (
        AI_TIPOPROCESO         IN VARCHAR2,
        AI_FECHACARGA          IN DATE,    
        AO_ERROR               OUT VARCHAR2,
        AO_MENSAJEERROR       OUT VARCHAR2)
    IS
        CURSOR C_PQENMORA
        IS
            SELECT CRE.NUMAFI NUMAFI,
            CRE.NUMPREAFI NUMPREAFI,
            CRE.ORDPREAFI ORDPREAFI,
            CRE.CODPRETIP CODPRETIP,
            CRE.CODPRECLA CODPRECLA,
            CRE.CODDIVPOL CODDIVPOL,
            CRE.FECPREAFI FECPREAFI,
            CRE.CODTIPSOLSER CODTIPSOLSER,
            CRE.NUMSOLSER NUMSOLSER,
            SAC.CD_IDREGISTRO,
            CRE.CR_OPERACIONSAC,
            CRE.RUCEMP RUCEMP,
            SAC.CD_NUT,
            SAC.CD_FECHAEFECTIVASAC,
            SAC.CD_VALORLIQUIDACIONSAC,
            (SELECT A.APENOMAFI FROM IESS_OWNER.KSPCOTAFILIADOS A WHERE A.NUMAFI = CRE.NUMAFI) APENOMAFI,
            AC.AC_ESTADO ESTADOCES,
            CRE.CODESTPRE CODESTPRE
            FROM IESS_OWNER.KSCRETCREDITOS CRE
            INNER JOIN PQ_OWNER.CRE_CREDITOSDEBITOSAC_T SAC
            ON SAC.CD_NUMAFI = CRE.NUMAFI 
            AND SAC.CD_OPERACIONSAC = CRE.CR_OPERACIONSAC 
            INNER JOIN PQ_OWNER.CRE_ACTUALIZACESANTIAS_TBL AC
            ON AC.AC_NUMAFI = CRE.NUMAFI
            WHERE 
            SAC.CD_ESTADOAFECOPE = 'ENV'
            AND SAC.CD_ESTADOPROCESO = 'SDE'
            AND SAC.CD_FECHACARGA = AI_FECHACARGA                            ------------------------------------------------------PRUEBAS DE GASTOS ADM
            AND CRE.CODESTPRE = 'VIG'
            AND AC.AC_TIPO = 'MENSUAL' 
            --AND SAC.CD_NUMAFI = '0917863458'                            
            ORDER BY CRE.FECPREAFI;
        
        
        CURSOR C_TOTALAPROCESAR IS
            SELECT COUNT(1) APROCESAR
            FROM PQ_OWNER.CRE_CREDITOSDEBITOSAC_T SAC
            WHERE SAC.CD_ESTADOAFECOPE = 'ENV'
            AND   SAC.CD_ESTADOPROCESO = 'SDE'
            AND   SAC.CD_FECHACARGA = AI_FECHACARGA;
            
            
        CURSOR C_RESUMENPROCESADOS
        IS
            SELECT 'REGISTROS PROCESADOS: ' MENSAJE, COUNT(1) VALOR
            FROM PQ_OWNER.CRE_CREDITOSDEBITOSAC_T
            WHERE TRUNC(CD_FECHACARGA) = AI_FECHACARGA
            AND NVL(CD_ESTADOPROCESO, '-') IN ('EJE', 'PRO')
            AND NVL(CD_ESTADOAFECOPE, '-') IN ('ADA', 'CDA')
            UNION ALL
            SELECT 'REGISTROS NO PROCESADOS: ' MENSAJE, COUNT(1) VALOR
            FROM PQ_OWNER.CRE_CREDITOSDEBITOSAC_T
            WHERE TRUNC(CD_FECHACARGA) = AI_FECHACARGA
            AND NVL(CD_ESTADOPROCESO, '-') NOT IN ('EJE', 'PRO')
            AND NVL(CD_ESTADOAFECOPE, '-') NOT IN ('ADA', 'CDA')
            UNION ALL
            SELECT 'TOTAL REGISTROS: ' MENSAJE, COUNT(1) VALOR
            FROM PQ_OWNER.CRE_CREDITOSDEBITOSAC_T
            WHERE TRUNC(CD_FECHACARGA) = AI_FECHACARGA;    
        

        TYPE T_PQENMORA IS TABLE OF C_PQENMORA%ROWTYPE INDEX BY PLS_INTEGER;
        L_PQENMORA    T_PQENMORA;


        TYPE T_TOTALAPROCESAR     IS TABLE OF C_TOTALAPROCESAR%ROWTYPE INDEX BY PLS_INTEGER;
        L_TOTALAPROCESAR          T_TOTALAPROCESAR;
        
        
        TYPE T_RESUMENPROCESADOS IS TABLE OF C_RESUMENPROCESADOS%ROWTYPE INDEX BY PLS_INTEGER;
        L_RESUMENPROCESADOS      T_RESUMENPROCESADOS;
        
        L_INICIOPROCESO     DATE;
        L_FINPROCESO        DATE;
        L_DURACIONPROCESO   VARCHAR2(200);
        L_NOMBREARCHIVO        VARCHAR2(200);
        L_EMAILMENSAJE      VARCHAR2(2000);
        
        L_PROCESADOS        PLS_INTEGER := 0;
        L_TIPODEBITO        PLS_INTEGER := 0;
        L_NUMEROLINEAS        PLS_INTEGER := 0;
        
        L_ESTADOCREDITO        IESS_OWNER.KSCRETCREDITOS.CODESTPRE%TYPE;
        L_VALORSALDO        IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_VALORLIQUIDACIONSAC%TYPE;
        L_OBSERVACIONSAC       IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_OBSERVACION%TYPE;
        L_OBSERVACIONBIT    IESS_OWNER.CRE_BITACORAS_TBL.BI_OBSERVACION%TYPE;
        
        R_BITACORAS            IESS_OWNER.CRE_BITACORAS_TBL%ROWTYPE;
        R_KSCRETBITPRO      IESS_OWNER.KSCRETBITPRO%ROWTYPE;
        R_KSCRETCREDITOS      IESS_OWNER.KSCRETCREDITOS%ROWTYPE;
        
        X_SALIREJECUCION       EXCEPTION;
        
        --FECHA DE PRESTAMO, PARA VERIFICAR RESOLUCION
        K_FECPREAFI         CONSTANT VARCHAR2 (8) := '01082007';
        
    BEGIN
    
        SYS.DBMS_APPLICATION_INFO.SET_MODULE (
        MODULE_NAME   => 'CRE_EJECUTADEBITO_P',
        ACTION_NAME   => 'ORQUESTA PROCESOS PARA EJECUCION DEL DEBITO AUTOMATICO');

        
        --BIRACORA INICIO PROCESO
        L_INICIOPROCESO                := SYSDATE;
        R_KSCRETBITPRO.CODPRO         := K_CODPRO;
        R_KSCRETBITPRO.TOTREGCOM     := NULL;
        R_KSCRETBITPRO.FECPRO         := SYSDATE;
        R_KSCRETBITPRO.OBSERV         := 'INICIO CRE_EJECUTADEBITO_P';
        IESS_OWNER.HLCREKPROGEN.PROREGBITPRO(AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);


        --BITACORA REGISTROS A PROCESAR
        OPEN C_TOTALAPROCESAR;
            FETCH C_TOTALAPROCESAR BULK COLLECT INTO L_TOTALAPROCESAR; 
            
            IF L_TOTALAPROCESAR(1).APROCESAR = 0 THEN
                R_KSCRETBITPRO.OBSERV := 'NO EXISTEN REGISTROS PARA PROCESAR';
                IESS_OWNER.HLCREKPROGEN.PROREGBITPRO (AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
                RAISE X_SALIREJECUCION;
            END IF;
        CLOSE C_TOTALAPROCESAR;


        R_KSCRETBITPRO.OBSERV := 'NUMERO TOTAL DE REGISTROS A PROCESAR: ' || L_TOTALAPROCESAR(1).APROCESAR;
        IESS_OWNER.HLCREKPROGEN.PROREGBITPRO (AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        
        
        OPEN C_PQENMORA;
        
        <<FOR_LOOP_CREDITOS>>
        LOOP
            FETCH C_PQENMORA BULK COLLECT INTO L_PQENMORA LIMIT K_LIMITEBULKCOLLECT; 
            
            <<FOR_LOOP_PQENMORA>>
            FOR I IN 1 ..L_PQENMORA.COUNT LOOP
                
                BEGIN
                    --INICIALIZA BITACORAS
                    R_BITACORAS                 := NULL;
                    R_BITACORAS.ID                := G_ID;
                    R_BITACORAS.CODPROC            := G_CODPROCESOBIT;
                    R_BITACORAS.MO_MODULO        := 'CRE';
                    R_BITACORAS.TE_ID_TIPO_ERROR:= G_NIDERROR_GENDEBAUT;
                    R_BITACORAS.CODPRETIP        := L_PQENMORA(I).CODPRETIP;
                    R_BITACORAS.ORDPREAFI        := L_PQENMORA(I).ORDPREAFI;
                    R_BITACORAS.NUMPREAFI        := L_PQENMORA(I).NUMPREAFI;
                    R_BITACORAS.CODPRECLA        := L_PQENMORA(I).CODPRECLA;
                    R_BITACORAS.RUCEMP            := L_PQENMORA(I).RUCEMP;
                    R_BITACORAS.NUMAFI            := L_PQENMORA(I).NUMAFI;
    
                    --INICIALIZA CREDITO
                    R_KSCRETCREDITOS                 :=NULL;      
                    R_KSCRETCREDITOS.NUMAFI          := L_PQENMORA(I).NUMAFI;
                    R_KSCRETCREDITOS.NUMPREAFI       := L_PQENMORA(I).NUMPREAFI;      
                    R_KSCRETCREDITOS.ORDPREAFI       := L_PQENMORA(I).ORDPREAFI;     
                    R_KSCRETCREDITOS.CODPRETIP       := L_PQENMORA(I).CODPRETIP;     
                    R_KSCRETCREDITOS.CODPRECLA       := L_PQENMORA(I).CODPRECLA;     
                    R_KSCRETCREDITOS.CODDIVPOL       := L_PQENMORA(I).CODDIVPOL;     
                    R_KSCRETCREDITOS.FECPREAFI       := L_PQENMORA(I).FECPREAFI;  
                    R_KSCRETCREDITOS.CODTIPSOLSER    := L_PQENMORA(I).CODTIPSOLSER;   
                    R_KSCRETCREDITOS.NUMSOLSER       := L_PQENMORA(I).NUMSOLSER;     
                    R_KSCRETCREDITOS.CR_OPERACIONSAC := L_PQENMORA(I).CR_OPERACIONSAC;
                    R_KSCRETCREDITOS.RUCEMP          := L_PQENMORA(I).RUCEMP;
                    R_KSCRETCREDITOS.CODESTPRE       := L_PQENMORA(I).CODESTPRE;
                    
                    <<BUSCATIPODEBITO>>
                    BEGIN
                    
                        CRE_VALIDATIPODEBITO_P (
                                        AI_KSCRETCREDITOS      => R_KSCRETCREDITOS,
                                        AI_FECRESOL         => K_FECPREAFI,
                                        AO_VALIDACREDITO    => L_TIPODEBITO,
                                        AO_ERROR            => AO_ERROR,
                                        AO_MENSAJEERROR        => AO_MENSAJEERROR);
                        
                        L_TIPODEBITO := NVL(L_TIPODEBITO, 0);
                        
                    END BUSCATIPODEBITO;
                    
                    
                    --NO PUDO ENCONTRAR EL TIPO
                    IF L_TIPODEBITO = 0
                    THEN
                    
                        L_OBSERVACIONBIT     := R_KSCRETCREDITOS.CR_OPERACIONSAC || ' NO SE PUDO DETERMINAR EL TIPO DE DEBITO.';
                        L_OBSERVACIONSAC    := 'DA-17 NO SE PUDO DETERMINAR EL TIPO DE DEBITO.';
                        R_BITACORAS.BI_OBSERVACION    := SUBSTR(L_OBSERVACIONBIT, 1, 200);

                        CRE_INSERTABITACORAS_P (
                                    AI_BITACORAS     => R_BITACORAS,
                                    AO_ERROR         => AO_ERROR,
                                    AO_MENSAJEERROR => AO_MENSAJEERROR);

                        CRE_ACTUALIZADEBITOREC_P (
                                    AI_MENSAJEERROR    => L_OBSERVACIONSAC,
                                    AI_IDGAF          => R_KSCRETCREDITOS.CR_OPERACIONSAC,
                                    AI_IDREGISTRO     => L_PQENMORA(I).CD_IDREGISTRO,
                                    AO_ERROR          => AO_ERROR,
                                    AO_MENSAJEERROR => AO_MENSAJEERROR);
                    END IF;
                        

                    --100% FONDOS DE RESERVA Y MIXTOS
                    IF L_TIPODEBITO = 1 
                    THEN
                        -- 11 RESOLUCION 171
                        --  CC-RFCA-17
                        CRE_GENERADEBITOFRS_P (
                                    AI_KSCRETCREDITOS        => R_KSCRETCREDITOS,
                                    AI_IDREGISTRO           => L_PQENMORA(I).CD_IDREGISTRO,
                                    AI_OPERACIONSAC         => L_PQENMORA(I).CR_OPERACIONSAC,
                                    AI_NUT                  => L_PQENMORA(I).CD_NUT,
                                    AI_FECHASACEFEC         => L_PQENMORA(I).CD_FECHAEFECTIVASAC,
                                    AI_VALORLIQUIDACIONSAC     => L_PQENMORA(I).CD_VALORLIQUIDACIONSAC,
                                    AI_ESTADOCES            => L_PQENMORA(I).ESTADOCES,
                                    AO_VALORSALDO           => L_VALORSALDO,
                                    AO_ESTADOCREDITO        => L_ESTADOCREDITO,
                                    AO_ERROR                  => AO_ERROR,
                                    AO_MENSAJEERROR            => AO_MENSAJEERROR);
                        
                        IF NVL(L_VALORSALDO, 0) > 0 
                        THEN
                            --ESTADO DESPUS DE LA SOLICITUD DE FRS
                            R_KSCRETCREDITOS.CODESTPRE := L_ESTADOCREDITO;
                            CRE_GENERADEBITOFCE_P (
                                        AI_KSCRETCREDITOS    => R_KSCRETCREDITOS,
                                        AI_VALSOL              => L_VALORSALDO,
                                        AI_IDREGISTRO          => L_PQENMORA(I).CD_IDREGISTRO,
                                        AI_OPERACIONSAC        => L_PQENMORA(I).CR_OPERACIONSAC,
                                        AI_NUT                 => L_PQENMORA(I).CD_NUT,
                                        AI_FECHASACEFEC        => L_PQENMORA(I).CD_FECHAEFECTIVASAC,
                                        AI_VALLIQSAC        => L_PQENMORA(I).CD_VALORLIQUIDACIONSAC,
                                        AI_ESTADOCES        => L_PQENMORA(I).ESTADOCES,
                                        AO_ERROR               => AO_ERROR,
                                        AO_MENSAJEERROR     => AO_MENSAJEERROR);
                            
                        END IF;
                    
                    END IF;--L_TIPODEBITO = 1 
                    
                    
                    --100% CESANTIAS Y CD 144
                    IF L_TIPODEBITO = 2 THEN
                        --EL ESTADO ENVIADO ES VIG. ESTADO DEL CREDITO DE LA CONSULTA PRINCIPAL.
                        CRE_GENERADEBITOFCE_P (
                                    AI_KSCRETCREDITOS    => R_KSCRETCREDITOS,
                                    AI_VALSOL              => L_PQENMORA(I).CD_VALORLIQUIDACIONSAC,
                                    AI_IDREGISTRO          => L_PQENMORA(I).CD_IDREGISTRO,
                                    AI_OPERACIONSAC        => L_PQENMORA(I).CR_OPERACIONSAC,
                                    AI_NUT                 => L_PQENMORA(I).CD_NUT,
                                    AI_FECHASACEFEC        => L_PQENMORA(I).CD_FECHAEFECTIVASAC,
                                    AI_VALLIQSAC        => L_PQENMORA(I).CD_VALORLIQUIDACIONSAC,
                                    AI_ESTADOCES        => L_PQENMORA(I).ESTADOCES,
                                    AO_ERROR               => AO_ERROR,
                                    AO_MENSAJEERROR     => AO_MENSAJEERROR);
                        
                    END IF;--L_TIPODEBITO = 2
                    
                EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK;
                    
                    R_BITACORAS.BI_OBSERVACION    := SUBSTR(L_PQENMORA(I).CR_OPERACIONSAC || ' ERROR FOR_LOOP_PQENMORA ' || SQLERRM, 1, 200);

                    CRE_INSERTABITACORAS_P (
                            AI_BITACORAS     => R_BITACORAS,
                            AO_ERROR         => AO_ERROR,
                            AO_MENSAJEERROR => AO_MENSAJEERROR);

                    CRE_ACTUALIZADEBITOREC_P (
                            AI_MENSAJEERROR    => SUBSTR(L_PQENMORA(I).CR_OPERACIONSAC || ' ERROR FOR_LOOP_PQENMORA ' || SQLERRM, 1, 1024),
                            AI_IDGAF          => L_PQENMORA(I).CR_OPERACIONSAC,
                            AI_IDREGISTRO     => L_PQENMORA(I).CD_IDREGISTRO,
                            AO_ERROR          => AO_ERROR,
                            AO_MENSAJEERROR => AO_MENSAJEERROR);
                
                END;

            END LOOP FOR_LOOP_PQENMORA;
            
            
            --BITACORAS
            L_PROCESADOS := L_PROCESADOS + L_PQENMORA.COUNT;
            R_KSCRETBITPRO.OBSERV := L_PROCESADOS || ' REGISTROS PROCESADOS DE: ' || L_TOTALAPROCESAR(1).APROCESAR;
            IESS_OWNER.HLCREKPROGEN.PROREGBITPRO (AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
            
            
            --ELIMINA LOS REGISTROS DEL ARREGLO POR BLOQUES
            L_PQENMORA.DELETE;
            
            
            EXIT FOR_LOOP_CREDITOS WHEN C_PQENMORA%NOTFOUND;
                
            
        END LOOP FOR_LOOP_CREDITOS;
            
                
        CLOSE C_PQENMORA;
        
            
        --CREACION DEL ARCHIVO
        L_NOMBREARCHIVO := 'DEBITO_AUTOMATICO_PQ' || '_' || TO_CHAR (G_FECHADEBITO, 'FXDDMMYYYY') || '.TXT';
        CRE_ARCHIVODEBITO_P (
                AI_NOMBREARCHIVO    => L_NOMBREARCHIVO,
                AI_NID              => G_ID,
                AO_NUMEROLINEAS        => L_NUMEROLINEAS,
                AO_ERROR              => AO_ERROR,
                AO_MENSAJEERROR        => AO_MENSAJEERROR);
        
        IF AO_ERROR = '0' THEN
            L_OBSERVACIONBIT := 'NOTA: ERROR AL GENERAR EL ARCHIVO CON NOVEDADES EN EL PROCESO DE DEBITO AUTOMATICO';
        END IF;


        --CONSULTA REGISTROS PROCESADOS
        OPEN C_RESUMENPROCESADOS;
            FETCH C_RESUMENPROCESADOS BULK COLLECT INTO L_RESUMENPROCESADOS; 
        CLOSE C_RESUMENPROCESADOS;


        --ENVIO DE NOTIFICACION
        L_FINPROCESO := SYSDATE;
        L_DURACIONPROCESO := IESS_OWNER.GEN_PROCESOSGENERICOS_PKG.GEN_DURACIONPROCESO_FUN(AIFECHAINI => L_INICIOPROCESO, AIFECHAFIN => L_FINPROCESO);
        
        L_EMAILMENSAJE := K_ENTER || K_ENTER
                    || 'RESULTADO DE EJECUCION DE DEBITO AUTOMATICO PQ'
                    || K_ENTER || K_ENTER;

        <<RESUMENPROCESADOS>>                    
        FOR INDX IN 1 .. L_RESUMENPROCESADOS.COUNT
        LOOP
            L_EMAILMENSAJE := L_EMAILMENSAJE || L_RESUMENPROCESADOS(INDX).MENSAJE || ' '|| L_RESUMENPROCESADOS(INDX).VALOR     || K_ENTER;
        END LOOP RESUMENPROCESADOS;
        
        L_EMAILMENSAJE := L_EMAILMENSAJE || K_ENTER || K_ENTER
                    || 'TIEMPOS DE EJECUCION '
                    || K_ENTER
                    || L_DURACIONPROCESO
                    || K_ENTER
                    || K_ENTER
                    || L_OBSERVACIONBIT;

        IESS_OWNER.CRE_PROCESOSGENERICOS_PKG.CRE_ENVIOMAILS_PRC(
                    AIUSERENVMAIL        => G_REMITENTE,
                    AICSUBJECT             => 'RESULTADO EJECUCION DE DEBITO AUTOMATICO PQ ' || TO_CHAR (G_FECHADEBITO, 'FXDDMMYYYY') ,
                    AICMENERRCAB         => NULL,
                    AINCODPRO             => NULL,
                    AICNOMARC             => G_RUTADIRECTORIO || '/' || L_NOMBREARCHIVO,
                    AICMENERRCUE         => NULL,
                    AICDESCRIPCION        => L_EMAILMENSAJE,
                    AINCANTIDADOBS         => L_NUMEROLINEAS,
                    AOCMENERR             => AO_ERROR,
                    AOCRESPRO             => AO_MENSAJEERROR,
                    AITIPRES             => NULL,
                    AICTYPEMAIL         => NULL,
                    AI_DESTINATARIOS     => G_DESTINATARIOS);
                    
        IF AO_ERROR = '0' THEN
            R_KSCRETBITPRO.OBSERV := SUBSTR(AO_MENSAJEERROR,1,1000);
            IESS_OWNER.HLCREKPROGEN.PROREGBITPRO(AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        ELSE
            R_KSCRETBITPRO.OBSERV := 'PROCEDIMIENTO CRE_ENVIOMAILS_PRC EJECUTADO CORRECTAMENTE';
            IESS_OWNER.HLCREKPROGEN.PROREGBITPRO (AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        END IF;
        
        AO_ERROR := '1';
        AO_MENSAJEERROR := 'FIN PROCEDIMIENTO CRE_EJECUTADEBITO_P';
        
        R_KSCRETBITPRO.OBSERV := AO_MENSAJEERROR;
        IESS_OWNER.HLCREKPROGEN.PROREGBITPRO(AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        SYS.DBMS_APPLICATION_INFO.SET_MODULE (NULL, NULL);    
        

    EXCEPTION
    WHEN X_SALIREJECUCION THEN
        AO_ERROR := '1';
        AO_MENSAJEERROR := 'FIN PROCEDIMIENTO CRE_EJECUTADEBITO_P';
        
        R_KSCRETBITPRO.OBSERV := AO_MENSAJEERROR;
        IESS_OWNER.HLCREKPROGEN.PROREGBITPRO (AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        
        SYS.DBMS_APPLICATION_INFO.SET_MODULE (NULL, NULL);
        
    WHEN OTHERS
    THEN
        AO_ERROR := '0';
        AO_MENSAJEERROR := SUBSTR('ERROR INESPERADO (CRE_EJECUTADEBITO_P): ' || SQLERRM, 1, 1024);

        R_KSCRETBITPRO.OBSERV := SUBSTR ('ERROR CRE_EJECUTADEBITO_P: ' || SQLERRM, 1024);
        IESS_OWNER.HLCREKPROGEN.PROREGBITPRO(AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        
        SYS.DBMS_APPLICATION_INFO.SET_MODULE (NULL, NULL);
        
    END CRE_EJECUTADEBITO_P;PROCEDURE CRE_EJECUTADEBITO_P (
        AI_TIPOPROCESO         IN VARCHAR2,
        AI_FECHACARGA          IN DATE,    
        AO_ERROR               OUT VARCHAR2,
        AO_MENSAJEERROR       OUT VARCHAR2)
    IS
        CURSOR C_PQENMORA
        IS
            SELECT CRE.NUMAFI NUMAFI,
            CRE.NUMPREAFI NUMPREAFI,
            CRE.ORDPREAFI ORDPREAFI,
            CRE.CODPRETIP CODPRETIP,
            CRE.CODPRECLA CODPRECLA,
            CRE.CODDIVPOL CODDIVPOL,
            CRE.FECPREAFI FECPREAFI,
            CRE.CODTIPSOLSER CODTIPSOLSER,
            CRE.NUMSOLSER NUMSOLSER,
            SAC.CD_IDREGISTRO,
            CRE.CR_OPERACIONSAC,
            CRE.RUCEMP RUCEMP,
            SAC.CD_NUT,
            SAC.CD_FECHAEFECTIVASAC,
            SAC.CD_VALORLIQUIDACIONSAC,
            (SELECT A.APENOMAFI FROM IESS_OWNER.KSPCOTAFILIADOS A WHERE A.NUMAFI = CRE.NUMAFI) APENOMAFI,
            AC.AC_ESTADO ESTADOCES,
            CRE.CODESTPRE CODESTPRE
            FROM IESS_OWNER.KSCRETCREDITOS CRE
            INNER JOIN PQ_OWNER.CRE_CREDITOSDEBITOSAC_T SAC
            ON SAC.CD_NUMAFI = CRE.NUMAFI 
            AND SAC.CD_OPERACIONSAC = CRE.CR_OPERACIONSAC 
            INNER JOIN PQ_OWNER.CRE_ACTUALIZACESANTIAS_TBL AC
            ON AC.AC_NUMAFI = CRE.NUMAFI
            WHERE 
            SAC.CD_ESTADOAFECOPE = 'ENV'
            AND SAC.CD_ESTADOPROCESO = 'SDE'
            AND SAC.CD_FECHACARGA = AI_FECHACARGA                            ------------------------------------------------------PRUEBAS DE GASTOS ADM
            AND CRE.CODESTPRE = 'VIG'
            AND AC.AC_TIPO = 'MENSUAL' 
            --AND SAC.CD_NUMAFI = '0917863458'                            
            ORDER BY CRE.FECPREAFI;
        
        
        CURSOR C_TOTALAPROCESAR IS
            SELECT COUNT(1) APROCESAR
            FROM PQ_OWNER.CRE_CREDITOSDEBITOSAC_T SAC
            WHERE SAC.CD_ESTADOAFECOPE = 'ENV'
            AND   SAC.CD_ESTADOPROCESO = 'SDE'
            AND   SAC.CD_FECHACARGA = AI_FECHACARGA;
            
            
        CURSOR C_RESUMENPROCESADOS
        IS
            SELECT 'REGISTROS PROCESADOS: ' MENSAJE, COUNT(1) VALOR
            FROM PQ_OWNER.CRE_CREDITOSDEBITOSAC_T
            WHERE TRUNC(CD_FECHACARGA) = AI_FECHACARGA
            AND NVL(CD_ESTADOPROCESO, '-') IN ('EJE', 'PRO')
            AND NVL(CD_ESTADOAFECOPE, '-') IN ('ADA', 'CDA')
            UNION ALL
            SELECT 'REGISTROS NO PROCESADOS: ' MENSAJE, COUNT(1) VALOR
            FROM PQ_OWNER.CRE_CREDITOSDEBITOSAC_T
            WHERE TRUNC(CD_FECHACARGA) = AI_FECHACARGA
            AND NVL(CD_ESTADOPROCESO, '-') NOT IN ('EJE', 'PRO')
            AND NVL(CD_ESTADOAFECOPE, '-') NOT IN ('ADA', 'CDA')
            UNION ALL
            SELECT 'TOTAL REGISTROS: ' MENSAJE, COUNT(1) VALOR
            FROM PQ_OWNER.CRE_CREDITOSDEBITOSAC_T
            WHERE TRUNC(CD_FECHACARGA) = AI_FECHACARGA;    
        

        TYPE T_PQENMORA IS TABLE OF C_PQENMORA%ROWTYPE INDEX BY PLS_INTEGER;
        L_PQENMORA    T_PQENMORA;


        TYPE T_TOTALAPROCESAR     IS TABLE OF C_TOTALAPROCESAR%ROWTYPE INDEX BY PLS_INTEGER;
        L_TOTALAPROCESAR          T_TOTALAPROCESAR;
        
        
        TYPE T_RESUMENPROCESADOS IS TABLE OF C_RESUMENPROCESADOS%ROWTYPE INDEX BY PLS_INTEGER;
        L_RESUMENPROCESADOS      T_RESUMENPROCESADOS;
        
        L_INICIOPROCESO     DATE;
        L_FINPROCESO        DATE;
        L_DURACIONPROCESO   VARCHAR2(200);
        L_NOMBREARCHIVO        VARCHAR2(200);
        L_EMAILMENSAJE      VARCHAR2(2000);
        
        L_PROCESADOS        PLS_INTEGER := 0;
        L_TIPODEBITO        PLS_INTEGER := 0;
        L_NUMEROLINEAS        PLS_INTEGER := 0;
        
        L_ESTADOCREDITO        IESS_OWNER.KSCRETCREDITOS.CODESTPRE%TYPE;
        L_VALORSALDO        IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_VALORLIQUIDACIONSAC%TYPE;
        L_OBSERVACIONSAC       IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_OBSERVACION%TYPE;
        L_OBSERVACIONBIT    IESS_OWNER.CRE_BITACORAS_TBL.BI_OBSERVACION%TYPE;
        
        R_BITACORAS            IESS_OWNER.CRE_BITACORAS_TBL%ROWTYPE;
        R_KSCRETBITPRO      IESS_OWNER.KSCRETBITPRO%ROWTYPE;
        R_KSCRETCREDITOS      IESS_OWNER.KSCRETCREDITOS%ROWTYPE;
        
        X_SALIREJECUCION       EXCEPTION;
        
        --FECHA DE PRESTAMO, PARA VERIFICAR RESOLUCION
        K_FECPREAFI         CONSTANT VARCHAR2 (8) := '01082007';
        
    BEGIN
    
        SYS.DBMS_APPLICATION_INFO.SET_MODULE (
        MODULE_NAME   => 'CRE_EJECUTADEBITO_P',
        ACTION_NAME   => 'ORQUESTA PROCESOS PARA EJECUCION DEL DEBITO AUTOMATICO');

        
        --BIRACORA INICIO PROCESO
        L_INICIOPROCESO                := SYSDATE;
        R_KSCRETBITPRO.CODPRO         := K_CODPRO;
        R_KSCRETBITPRO.TOTREGCOM     := NULL;
        R_KSCRETBITPRO.FECPRO         := SYSDATE;
        R_KSCRETBITPRO.OBSERV         := 'INICIO CRE_EJECUTADEBITO_P';
        IESS_OWNER.HLCREKPROGEN.PROREGBITPRO(AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);


        --BITACORA REGISTROS A PROCESAR
        OPEN C_TOTALAPROCESAR;
            FETCH C_TOTALAPROCESAR BULK COLLECT INTO L_TOTALAPROCESAR; 
            
            IF L_TOTALAPROCESAR(1).APROCESAR = 0 THEN
                R_KSCRETBITPRO.OBSERV := 'NO EXISTEN REGISTROS PARA PROCESAR';
                IESS_OWNER.HLCREKPROGEN.PROREGBITPRO (AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
                RAISE X_SALIREJECUCION;
            END IF;
        CLOSE C_TOTALAPROCESAR;


        R_KSCRETBITPRO.OBSERV := 'NUMERO TOTAL DE REGISTROS A PROCESAR: ' || L_TOTALAPROCESAR(1).APROCESAR;
        IESS_OWNER.HLCREKPROGEN.PROREGBITPRO (AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        
        
        OPEN C_PQENMORA;
        
        <<FOR_LOOP_CREDITOS>>
        LOOP
            FETCH C_PQENMORA BULK COLLECT INTO L_PQENMORA LIMIT K_LIMITEBULKCOLLECT; 
            
            <<FOR_LOOP_PQENMORA>>
            FOR I IN 1 ..L_PQENMORA.COUNT LOOP
                
                BEGIN
                    --INICIALIZA BITACORAS
                    R_BITACORAS                 := NULL;
                    R_BITACORAS.ID                := G_ID;
                    R_BITACORAS.CODPROC            := G_CODPROCESOBIT;
                    R_BITACORAS.MO_MODULO        := 'CRE';
                    R_BITACORAS.TE_ID_TIPO_ERROR:= G_NIDERROR_GENDEBAUT;
                    R_BITACORAS.CODPRETIP        := L_PQENMORA(I).CODPRETIP;
                    R_BITACORAS.ORDPREAFI        := L_PQENMORA(I).ORDPREAFI;
                    R_BITACORAS.NUMPREAFI        := L_PQENMORA(I).NUMPREAFI;
                    R_BITACORAS.CODPRECLA        := L_PQENMORA(I).CODPRECLA;
                    R_BITACORAS.RUCEMP            := L_PQENMORA(I).RUCEMP;
                    R_BITACORAS.NUMAFI            := L_PQENMORA(I).NUMAFI;
    
                    --INICIALIZA CREDITO
                    R_KSCRETCREDITOS                 :=NULL;      
                    R_KSCRETCREDITOS.NUMAFI          := L_PQENMORA(I).NUMAFI;
                    R_KSCRETCREDITOS.NUMPREAFI       := L_PQENMORA(I).NUMPREAFI;      
                    R_KSCRETCREDITOS.ORDPREAFI       := L_PQENMORA(I).ORDPREAFI;     
                    R_KSCRETCREDITOS.CODPRETIP       := L_PQENMORA(I).CODPRETIP;     
                    R_KSCRETCREDITOS.CODPRECLA       := L_PQENMORA(I).CODPRECLA;     
                    R_KSCRETCREDITOS.CODDIVPOL       := L_PQENMORA(I).CODDIVPOL;     
                    R_KSCRETCREDITOS.FECPREAFI       := L_PQENMORA(I).FECPREAFI;  
                    R_KSCRETCREDITOS.CODTIPSOLSER    := L_PQENMORA(I).CODTIPSOLSER;   
                    R_KSCRETCREDITOS.NUMSOLSER       := L_PQENMORA(I).NUMSOLSER;     
                    R_KSCRETCREDITOS.CR_OPERACIONSAC := L_PQENMORA(I).CR_OPERACIONSAC;
                    R_KSCRETCREDITOS.RUCEMP          := L_PQENMORA(I).RUCEMP;
                    R_KSCRETCREDITOS.CODESTPRE       := L_PQENMORA(I).CODESTPRE;
                    
                    <<BUSCATIPODEBITO>>
                    BEGIN
                    
                        CRE_VALIDATIPODEBITO_P (
                                        AI_KSCRETCREDITOS      => R_KSCRETCREDITOS,
                                        AI_FECRESOL         => K_FECPREAFI,
                                        AO_VALIDACREDITO    => L_TIPODEBITO,
                                        AO_ERROR            => AO_ERROR,
                                        AO_MENSAJEERROR        => AO_MENSAJEERROR);
                        
                        L_TIPODEBITO := NVL(L_TIPODEBITO, 0);
                        
                    END BUSCATIPODEBITO;
                    
                    
                    --NO PUDO ENCONTRAR EL TIPO
                    IF L_TIPODEBITO = 0
                    THEN
                    
                        L_OBSERVACIONBIT     := R_KSCRETCREDITOS.CR_OPERACIONSAC || ' NO SE PUDO DETERMINAR EL TIPO DE DEBITO.';
                        L_OBSERVACIONSAC    := 'DA-17 NO SE PUDO DETERMINAR EL TIPO DE DEBITO.';
                        R_BITACORAS.BI_OBSERVACION    := SUBSTR(L_OBSERVACIONBIT, 1, 200);

                        CRE_INSERTABITACORAS_P (
                                    AI_BITACORAS     => R_BITACORAS,
                                    AO_ERROR         => AO_ERROR,
                                    AO_MENSAJEERROR => AO_MENSAJEERROR);

                        CRE_ACTUALIZADEBITOREC_P (
                                    AI_MENSAJEERROR    => L_OBSERVACIONSAC,
                                    AI_IDGAF          => R_KSCRETCREDITOS.CR_OPERACIONSAC,
                                    AI_IDREGISTRO     => L_PQENMORA(I).CD_IDREGISTRO,
                                    AO_ERROR          => AO_ERROR,
                                    AO_MENSAJEERROR => AO_MENSAJEERROR);
                    END IF;
                        

                    --100% FONDOS DE RESERVA Y MIXTOS
                    IF L_TIPODEBITO = 1 
                    THEN
                        -- 11 RESOLUCION 171
                        --  CC-RFCA-17
                        CRE_GENERADEBITOFRS_P (
                                    AI_KSCRETCREDITOS        => R_KSCRETCREDITOS,
                                    AI_IDREGISTRO           => L_PQENMORA(I).CD_IDREGISTRO,
                                    AI_OPERACIONSAC         => L_PQENMORA(I).CR_OPERACIONSAC,
                                    AI_NUT                  => L_PQENMORA(I).CD_NUT,
                                    AI_FECHASACEFEC         => L_PQENMORA(I).CD_FECHAEFECTIVASAC,
                                    AI_VALORLIQUIDACIONSAC     => L_PQENMORA(I).CD_VALORLIQUIDACIONSAC,
                                    AI_ESTADOCES            => L_PQENMORA(I).ESTADOCES,
                                    AO_VALORSALDO           => L_VALORSALDO,
                                    AO_ESTADOCREDITO        => L_ESTADOCREDITO,
                                    AO_ERROR                  => AO_ERROR,
                                    AO_MENSAJEERROR            => AO_MENSAJEERROR);
                        
                        IF NVL(L_VALORSALDO, 0) > 0 
                        THEN
                            --ESTADO DESPUS DE LA SOLICITUD DE FRS
                            R_KSCRETCREDITOS.CODESTPRE := L_ESTADOCREDITO;
                            CRE_GENERADEBITOFCE_P (
                                        AI_KSCRETCREDITOS    => R_KSCRETCREDITOS,
                                        AI_VALSOL              => L_VALORSALDO,
                                        AI_IDREGISTRO          => L_PQENMORA(I).CD_IDREGISTRO,
                                        AI_OPERACIONSAC        => L_PQENMORA(I).CR_OPERACIONSAC,
                                        AI_NUT                 => L_PQENMORA(I).CD_NUT,
                                        AI_FECHASACEFEC        => L_PQENMORA(I).CD_FECHAEFECTIVASAC,
                                        AI_VALLIQSAC        => L_PQENMORA(I).CD_VALORLIQUIDACIONSAC,
                                        AI_ESTADOCES        => L_PQENMORA(I).ESTADOCES,
                                        AO_ERROR               => AO_ERROR,
                                        AO_MENSAJEERROR     => AO_MENSAJEERROR);
                            
                        END IF;
                    
                    END IF;--L_TIPODEBITO = 1 
                    
                    
                    --100% CESANTIAS Y CD 144
                    IF L_TIPODEBITO = 2 THEN
                        --EL ESTADO ENVIADO ES VIG. ESTADO DEL CREDITO DE LA CONSULTA PRINCIPAL.
                        CRE_GENERADEBITOFCE_P (
                                    AI_KSCRETCREDITOS    => R_KSCRETCREDITOS,
                                    AI_VALSOL              => L_PQENMORA(I).CD_VALORLIQUIDACIONSAC,
                                    AI_IDREGISTRO          => L_PQENMORA(I).CD_IDREGISTRO,
                                    AI_OPERACIONSAC        => L_PQENMORA(I).CR_OPERACIONSAC,
                                    AI_NUT                 => L_PQENMORA(I).CD_NUT,
                                    AI_FECHASACEFEC        => L_PQENMORA(I).CD_FECHAEFECTIVASAC,
                                    AI_VALLIQSAC        => L_PQENMORA(I).CD_VALORLIQUIDACIONSAC,
                                    AI_ESTADOCES        => L_PQENMORA(I).ESTADOCES,
                                    AO_ERROR               => AO_ERROR,
                                    AO_MENSAJEERROR     => AO_MENSAJEERROR);
                        
                    END IF;--L_TIPODEBITO = 2
                    
                EXCEPTION
                WHEN OTHERS
                THEN
                    ROLLBACK;
                    
                    R_BITACORAS.BI_OBSERVACION    := SUBSTR(L_PQENMORA(I).CR_OPERACIONSAC || ' ERROR FOR_LOOP_PQENMORA ' || SQLERRM, 1, 200);

                    CRE_INSERTABITACORAS_P (
                            AI_BITACORAS     => R_BITACORAS,
                            AO_ERROR         => AO_ERROR,
                            AO_MENSAJEERROR => AO_MENSAJEERROR);

                    CRE_ACTUALIZADEBITOREC_P (
                            AI_MENSAJEERROR    => SUBSTR(L_PQENMORA(I).CR_OPERACIONSAC || ' ERROR FOR_LOOP_PQENMORA ' || SQLERRM, 1, 1024),
                            AI_IDGAF          => L_PQENMORA(I).CR_OPERACIONSAC,
                            AI_IDREGISTRO     => L_PQENMORA(I).CD_IDREGISTRO,
                            AO_ERROR          => AO_ERROR,
                            AO_MENSAJEERROR => AO_MENSAJEERROR);
                
                END;

            END LOOP FOR_LOOP_PQENMORA;
            
            
            --BITACORAS
            L_PROCESADOS := L_PROCESADOS + L_PQENMORA.COUNT;
            R_KSCRETBITPRO.OBSERV := L_PROCESADOS || ' REGISTROS PROCESADOS DE: ' || L_TOTALAPROCESAR(1).APROCESAR;
            IESS_OWNER.HLCREKPROGEN.PROREGBITPRO (AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
            
            
            --ELIMINA LOS REGISTROS DEL ARREGLO POR BLOQUES
            L_PQENMORA.DELETE;
            
            
            EXIT FOR_LOOP_CREDITOS WHEN C_PQENMORA%NOTFOUND;
                
            
        END LOOP FOR_LOOP_CREDITOS;
            
                
        CLOSE C_PQENMORA;
        
            
        --CREACION DEL ARCHIVO
        L_NOMBREARCHIVO := 'DEBITO_AUTOMATICO_PQ' || '_' || TO_CHAR (G_FECHADEBITO, 'FXDDMMYYYY') || '.TXT';
        CRE_ARCHIVODEBITO_P (
                AI_NOMBREARCHIVO    => L_NOMBREARCHIVO,
                AI_NID              => G_ID,
                AO_NUMEROLINEAS        => L_NUMEROLINEAS,
                AO_ERROR              => AO_ERROR,
                AO_MENSAJEERROR        => AO_MENSAJEERROR);
        
        IF AO_ERROR = '0' THEN
            L_OBSERVACIONBIT := 'NOTA: ERROR AL GENERAR EL ARCHIVO CON NOVEDADES EN EL PROCESO DE DEBITO AUTOMATICO';
        END IF;


        --CONSULTA REGISTROS PROCESADOS
        OPEN C_RESUMENPROCESADOS;
            FETCH C_RESUMENPROCESADOS BULK COLLECT INTO L_RESUMENPROCESADOS; 
        CLOSE C_RESUMENPROCESADOS;


        --ENVIO DE NOTIFICACION
        L_FINPROCESO := SYSDATE;
        L_DURACIONPROCESO := IESS_OWNER.GEN_PROCESOSGENERICOS_PKG.GEN_DURACIONPROCESO_FUN(AIFECHAINI => L_INICIOPROCESO, AIFECHAFIN => L_FINPROCESO);
        
        L_EMAILMENSAJE := K_ENTER || K_ENTER
                    || 'RESULTADO DE EJECUCION DE DEBITO AUTOMATICO PQ'
                    || K_ENTER || K_ENTER;

        <<RESUMENPROCESADOS>>                    
        FOR INDX IN 1 .. L_RESUMENPROCESADOS.COUNT
        LOOP
            L_EMAILMENSAJE := L_EMAILMENSAJE || L_RESUMENPROCESADOS(INDX).MENSAJE || ' '|| L_RESUMENPROCESADOS(INDX).VALOR     || K_ENTER;
        END LOOP RESUMENPROCESADOS;
        
        L_EMAILMENSAJE := L_EMAILMENSAJE || K_ENTER || K_ENTER
                    || 'TIEMPOS DE EJECUCION '
                    || K_ENTER
                    || L_DURACIONPROCESO
                    || K_ENTER
                    || K_ENTER
                    || L_OBSERVACIONBIT;

        IESS_OWNER.CRE_PROCESOSGENERICOS_PKG.CRE_ENVIOMAILS_PRC(
                    AIUSERENVMAIL        => G_REMITENTE,
                    AICSUBJECT             => 'RESULTADO EJECUCION DE DEBITO AUTOMATICO PQ ' || TO_CHAR (G_FECHADEBITO, 'FXDDMMYYYY') ,
                    AICMENERRCAB         => NULL,
                    AINCODPRO             => NULL,
                    AICNOMARC             => G_RUTADIRECTORIO || '/' || L_NOMBREARCHIVO,
                    AICMENERRCUE         => NULL,
                    AICDESCRIPCION        => L_EMAILMENSAJE,
                    AINCANTIDADOBS         => L_NUMEROLINEAS,
                    AOCMENERR             => AO_ERROR,
                    AOCRESPRO             => AO_MENSAJEERROR,
                    AITIPRES             => NULL,
                    AICTYPEMAIL         => NULL,
                    AI_DESTINATARIOS     => G_DESTINATARIOS);
                    
        IF AO_ERROR = '0' THEN
            R_KSCRETBITPRO.OBSERV := SUBSTR(AO_MENSAJEERROR,1,1000);
            IESS_OWNER.HLCREKPROGEN.PROREGBITPRO(AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        ELSE
            R_KSCRETBITPRO.OBSERV := 'PROCEDIMIENTO CRE_ENVIOMAILS_PRC EJECUTADO CORRECTAMENTE';
            IESS_OWNER.HLCREKPROGEN.PROREGBITPRO (AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        END IF;
        
        AO_ERROR := '1';
        AO_MENSAJEERROR := 'FIN PROCEDIMIENTO CRE_EJECUTADEBITO_P';
        
        R_KSCRETBITPRO.OBSERV := AO_MENSAJEERROR;
        IESS_OWNER.HLCREKPROGEN.PROREGBITPRO(AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        SYS.DBMS_APPLICATION_INFO.SET_MODULE (NULL, NULL);    
        

    EXCEPTION
    WHEN X_SALIREJECUCION THEN
        AO_ERROR := '1';
        AO_MENSAJEERROR := 'FIN PROCEDIMIENTO CRE_EJECUTADEBITO_P';
        
        R_KSCRETBITPRO.OBSERV := AO_MENSAJEERROR;
        IESS_OWNER.HLCREKPROGEN.PROREGBITPRO (AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        
        SYS.DBMS_APPLICATION_INFO.SET_MODULE (NULL, NULL);
        
    WHEN OTHERS
    THEN
        AO_ERROR := '0';
        AO_MENSAJEERROR := SUBSTR('ERROR INESPERADO (CRE_EJECUTADEBITO_P): ' || SQLERRM, 1, 1024);

        R_KSCRETBITPRO.OBSERV := SUBSTR ('ERROR CRE_EJECUTADEBITO_P: ' || SQLERRM, 1024);
        IESS_OWNER.HLCREKPROGEN.PROREGBITPRO(AICCODPRO => R_KSCRETBITPRO.CODPRO, AICOBSERV => R_KSCRETBITPRO.OBSERV);
        
        SYS.DBMS_APPLICATION_INFO.SET_MODULE (NULL, NULL);
        
    END CRE_EJECUTADEBITO_P;