  create or replace PACKAGE AUDIMED_OWNER.SAL_REPLICAAUDIMED_K IS
   --<b>Version:</b> 1.0.0
   --<br><b>Descripcion:</b>  Replica la informacion de tramites, expedientes, servicios y trazabilidad de auditorias medicas.
   --<br><b>Autor:</b>  Manuel Vera <br>
   --<br><b>Fecha:</b> 21/07/2023
   --<br><b>Historial de Cambios</b>
   --<hr>
   --Fecha          Autor            Version      Descripcion
   --<hr>
   --21/07/2023     Manuel Vera      1.0.0          Creacion.
PROCEDURE sal_replicaaudimed_orq_p;
PROCEDURE sal_replicaaudimed_p(
 ao_mensajesalida OUT VARCHAR2,
 ao_registros OUT NUMBER
   INSERT INTO aud_visor_log_usuarios_t@dbk_audimed_dbreplica (id_log_usuario, accion,resultado,detalle,usu_creacion,fec_creacion,ip_equipo,tabla)
   VALUES(AUD_VISOR_LOG_USUARIOS_S.nextval@dbk_audimed_dbreplica, 'REPLICA', 'exito', 'INICIO DEL PROCESO', 'system', SYSDATE, l_ip,null );

   /*
    TRAMITES
   */
   INSERT INTO AUD_TRAMITES_T@dbk_audimed_dbreplica /*+ append */
                                     nologging (id_tramite,

  K_LIMITEBULKCOLLECT CONSTANT PLS_INTEGER:= 3000;
    K_ENTER                CONSTANT VARCHAR2 (50) := CHR (13) || CHR (10);
    
      cod_coordinacion) 
      SELECT /*+ parallel(b,9) */
            t.id_tramite,
    codi_tramite,
    coordinacion_provincial,--variable
    val_solicitado, 
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
        ACTION_NAME   => 'Obtiene datos parametrizados que se usan en el proceso');--eemplo
--eemplo
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

            AND D.DP_TIPVALDETCATALOGO = K_VALDV;
        EXCEPTION

           SELECT PL.RUCEMP,
                   D.FECININOV,
                   D.ESTNOVDET
              FROM KSEMPTNOVHISLABDET , KSRECTPLADET , KSRECTPLANILLAS 
             WHERE     D.RUCEMP = P.RUCEMP
                   AND D.CODSUC = P.CODSUC
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
                                  AND C.CODSEC NOT IN ('V', 'S'));
                                  
        <<BUSCACATALOGO>>
        UPDATE PEPITO
        SET A = BACKU;
        
        DELETE FROM JUAITO;
        
		  SELECT A FROM B;
        BEGIN
            FOR N IN ( SELECT D.DP_VALNUMDETCATALOGO, D.DP_VALCARDETCATALOGO, D.DP_VALFECDETCATALOGO
            INTO AO_VALNUMDETCATALOGO, AO_VALCARDETCATALOGO, AO_VALFECDETCATALOGO
            FROM PQ_OWNER.CRE_CATALOGOPQ_TBL AS C
            INNER JOIN PQ_OWNER.CRE_DETCATALOGOPQ_TBL D
            ON (C.CP_ID_CATALOGO = D.CP_ID_CATALOGO)
            WHERE     
            C.CP_CODCATALOGO = AI_CODCATALOGO
            AND D.DP_CODDETCATALOGO = AI_CODDETCATALOGO ) LOOP
				
SELECT A, (SELECT B FROM Y WHERE A=B) FROM D WHERE D= A;

SELECT      PL.ESTTIPPLA, PL.PAGBANCEN, CAMPO2, CAMPO3, CAMPO4
FROM TABLA1, TABLA2, TABLA3, KSEMPTNOVHISLABDET , KSRECTPLADET , KSRECTPLANILLAS 
WHERE     D.RUCEMP = P.RUCEMP
                   AND D.CODSUC = P.CODSUC
AND EXISTS
                          (SELECT A.RUCEMP, A.CODSUC
                             FROM KSPCOTSUCURSALES ,
                                  KSPCOTEMPLEADORES ,
                                  KSPCOTEMPTIP AS C
                            WHERE     A.CODESTEMP NOT IN
                                         ('INA', 'INC', 'PLI')
                                  AND A.RUCEMP = B.RUCEMP
                                  AND C.CODSEC NOT IN ('V', 'S'));        