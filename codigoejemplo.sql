  K_LIMITEBULKCOLLECT CONSTANT PLS_INTEGER:= 3000;
    K_ENTER                CONSTANT VARCHAR2 (50) := CHR (13) || CHR (10);
    
   
    PROCEDURE CRE_CONSULTACATALOGO_P (
        AI_CODCATALOGO             IN  PQ_OWNER.CRE_CATALOGOPQ_TBL.CP_CODCATALOGO%TYPE,        
        AI_CODDETCATALOGO         IN  PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_CODDETCATALOGO%TYPE, 
        AO_VALNUMDETCATALOGO    IN OUT PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_VALNUMDETCATALOGO%TYPE, 
        AO_VALCARDETCATALOGO    IN OUT PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_VALCARDETCATALOGO%TYPE, 
        AO_VALFECDETCATALOGO    IN OUT PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_VALFECDETCATALOGO%TYPE, 
        AO_ERROR                  IN OUT VARCHAR2,
        AO_MENSAJEERROR            IN OUT VARCHAR2)
    IS
    BEGIN

        SYS.DBMS_APPLICATION_INFO.SET_MODULE (
        MODULE_NAME   => 'cre_consultacatalogo_p',
        ACTION_NAME   => 'Obtiene datos parametrizados que se usan en el proceso');

       <<BUSCACATALOGO>>
        BEGIN
            SELECT D.DP_VALNUMDETCATALOGO, D.DP_VALCARDETCATALOGO, D.DP_VALFECDETCATALOGO
            INTO AO_VALNUMDETCATALOGO, AO_VALCARDETCATALOGO, AO_VALFECDETCATALOGO
            FROM PQ_OWNER.CRE_CATALOGOPQ_TBL AS C
            INNER JOIN PQ_OWNER.CRE_DETCATALOGOPQ_TBL2 D
            ON (C.CP_ID_CATALOGO = D.CP_ID_CATALOGO)
            WHERE     
            C.CP_CODCATALOGO = AI_CODCATALOGO
            AND D.DP_CODDETCATALOGO = AI_CODDETCATALOGO
            AND C.CP_ESTADOCATALOGO = K_VALCA
            AND D.DP_ESTADODETCATALOGO = K_VALDA
            AND D.DP_TIPVALDETCATALOGO = K_VALDV;
        EXCEPTION

           SELECT PL.RUCEMP,
                   PL.CODSUC,
                   PL.ANIPER,
                   PL.MESPER,
                   V_DESCONSULTA2,
                   P.CODTIPPLA,
                   PL.TIPPER,
                   PL.SECPLA,
                   PL.ESTTIPPLA,
                   PL.PAGBANCEN,
                   P.NUMAFI,
                   P.CODTIPNOVHISLAB,
                   D.FECININOV,
                   D.ESTNOVDET
              FROM KSEMPTNOVHISLABDET , KSRECTPLADET , KSRECTPLANILLAS 
             WHERE     D.RUCEMP = P.RUCEMP
                   AND D.CODSUC = P.CODSUC
                   AND D.NUMAFI = P.NUMAFI
                   AND D.CODTIPNOVHISLAB = P.CODTIPNOVHISLAB
                   AND PL.RUCEMP = P.RUCEMP
                   AND PL.CODSUC = P.CODSUC
                   AND PL.CODTIPPLA = P.CODTIPPLA
                   AND PL.TIPPER = P.TIPPER
                   AND PL.ANIPER = P.ANIPER
                   AND PL.MESPER = P.MESPER
                   AND PL.SECPLA = P.SECPLA
                   AND PL.ESTTIPPLA <> 'ANU'
                   AND P.CODTIPNOVHISLAB = 'SAL'
                   AND P.ANIPER = AI_ANIPER
                   AND P.MESPER = AI_MESPER
                   AND P.CODTIPPLA = 'AA'
                   AND P.TIPPER = AI_TIPPER
                   AND D.FECININOV BETWEEN R_REGPER.FECINIPER
                                       AND R_REGPER.FECFINPER
                   AND D.ESTNOVDET = '1'
                   AND EXISTS
                          (SELECT A.RUCEMP, A.CODSUC
                             FROM KSPCOTSUCURSALES ,
                                  KSPCOTEMPLEADORES ,
                                  KSPCOTEMPTIP AS C
                            WHERE     A.CODESTEMP NOT IN
                                         ('INA', 'INC', 'PLI')
                                  AND A.RUCEMP = B.RUCEMP
                                  AND B.CODTIPEMP = C.CODTIPEMP
                                  AND B.CODSEGSOC = C.CODSEGSOC
                                  AND PL.RUCEMP = A.RUCEMP
                                  AND PL.CODSUC = A.CODSUC
                                  AND C.CODSEC NOT IN ('V', 'S'));
                                  
        <<BUSCACATALOGO>>
        UPDATE PEPITO
        SET A = BACKU;
        
        DELETE FROM JUAITO;
        
        BEGIN
            SELECT D.DP_VALNUMDETCATALOGO, D.DP_VALCARDETCATALOGO, D.DP_VALFECDETCATALOGO
            INTO AO_VALNUMDETCATALOGO, AO_VALCARDETCATALOGO, AO_VALFECDETCATALOGO
            FROM PQ_OWNER.CRE_CATALOGOPQ_TBL AS C
            INNER JOIN PQ_OWNER.CRE_DETCATALOGOPQ_TBL D
            ON (C.CP_ID_CATALOGO = D.CP_ID_CATALOGO)
            WHERE     
            C.CP_CODCATALOGO = AI_CODCATALOGO
            AND D.DP_CODDETCATALOGO = AI_CODDETCATALOGO
            AND C.CP_ESTADOCATALOGO = K_VALCA
            AND D.DP_ESTADODETCATALOGO = K_VALDA
            AND D.DP_TIPVALDETCATALOGO = K_VALDV;
        EXCEPTION