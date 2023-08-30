CREATE OR REPLACE PACKAGE PQ_OWNER.CRE_DEBITOAUTOMATICOPQ_PKG IS
  --<BR><B>VERSION:</B> 1.0.0
  --<B>DESCRIPCION:</B> PROCESOS DE DEBITO AUTOMATICO
  --<BR><B>AUTOR:</B> SANDRA GUAITA
  --<BR><B>FECHA:</B> 01/08/2023
    TYPE T_CRE_CREDITOSDEBITOSAC_T IS TABLE OF PQ_OWNER.CRE_CREDITOSDEBITOSAC_T%ROWTYPE INDEX BY PLS_INTEGER;
    TYPE T_ACTUALIZACESANTIAS     IS TABLE OF PQ_OWNER.CRE_ACTUALIZACESANTIAS_TBL%ROWTYPE INDEX BY PLS_INTEGER;

  --<B>DESCRIPCION:</B> CONSULTA DE CATALOGOS
  --<BR><B>AUTOR:</B> SANDRA GUAITA  <BR>
  --<BR><B> PARAMETROS ENTRADA:</B>
  --<BR>      AI_CODCATALOGO    : CODIGO DEL CATALOGO</P>
  --<BR>      AI_CODDETCATALOGO    : CODIGO DEL DETALLE DEL CATALOGO</P>
  --<BR><B> PARAMETROS ENTRADA Y SALIDA:</B>
  --<BR>      AO_VALNUMDETCATALOGO    : VALOR TIPO NUMERO</P>A
  --<BR>      AO_VALCARDETCATALOGO    : VALOR TIPO CARACTER</P>
  --<BR>      AO_VALFECDETCATALOGO    : VALOR TIPO FECHA</P>
  --<BR><B> PARAMETROS SALIDA:</B>
  --<BR>      AOCRESPRO: CODIGO DE ERRROR (0 ERROR, 1 OK)
  --<BR>      AOCMENERR: MENSAJE DE ERROR</P>
  --<BR><B>HISTORIAL DE CAMBIOS</B>
  --<HR>
  --FECHA                AUTOR                 DESCRIPCION
  --<HR>
  --01/08/2023        SANDRA GUAITA      CREACION DEL PROCEDIMIENTO
    PROCEDURE CRE_CONSULTACATALOGO_P (
        AI_CODCATALOGO             IN  PQ_OWNER.CRE_CATALOGOPQ_TBL.CP_CODCATALOGO%TYPE,        
        AI_CODDETCATALOGO         IN  PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_CODDETCATALOGO%TYPE, 
        AO_VALNUMDETCATALOGO    IN OUT PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_VALNUMDETCATALOGO%TYPE, 
        AO_VALCARDETCATALOGO    IN OUT PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_VALCARDETCATALOGO%TYPE, 
        AO_VALFECDETCATALOGO    IN OUT PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_VALFECDETCATALOGO%TYPE, 
        AO_ERROR                  IN OUT VARCHAR2,
        AO_MENSAJEERROR            IN OUT VARCHAR2);


    PROCEDURE CRE_ACTUALIZACATALOGO_P (
        AI_VALNUMDETCATALOGO IN  PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_VALNUMDETCATALOGO%TYPE,
        AI_VALCARDETCATALOGO IN  PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_VALCARDETCATALOGO%TYPE,
        AI_VALFECDETCATALOGO IN  PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_VALFECDETCATALOGO%TYPE,
        AI_CODDETCATALOGO      IN  PQ_OWNER.CRE_DETCATALOGOPQ_TBL.DP_CODDETCATALOGO%TYPE, 
        AO_ERROR               IN OUT VARCHAR2,
        AO_MENSAJEERROR         IN OUT VARCHAR2);

        
    PROCEDURE CRE_ACTUALIZADEBIOSSAC_P (
        AI_CRE_CREDITOSDEBITOSAC_T  IN T_CRE_CREDITOSDEBITOSAC_T,
        AO_ERROR          IN OUT VARCHAR2,
        AO_MENSAJEERROR    IN OUT VARCHAR2);


    PROCEDURE CRE_EXCLUSIONESDEB_P(
        AI_FECHACARGA      IN DATE,
        AO_ERROR          OUT VARCHAR2,
        AO_MENSAJEERROR OUT VARCHAR2); 


    PROCEDURE CRE_EXCLUSIONESCES_P(
        AI_FECHACARGA      IN DATE,
        AO_ERROR              OUT VARCHAR2,
        AO_MENSAJEERROR      OUT VARCHAR2);


    PROCEDURE CRE_VALIDAEXCLUSIONESCES_P (
        AO_ERROR          IN OUT VARCHAR2,
        AO_MENSAJEERROR    IN OUT VARCHAR2);


    PROCEDURE CRE_VALIDAEXCLUSIONESDEB_P (
        AO_ERROR          IN OUT VARCHAR2,
        AO_MENSAJEERROR    IN OUT VARCHAR2);


    PROCEDURE CRE_ARCHIVOCESANTIA_P (
        AI_NOMBREARCHIVO    IN  VARCHAR2,
        AO_NUMEROLINEAS        OUT PLS_INTEGER,
        AO_ERROR            OUT VARCHAR2,
        AO_MENSAJEERROR       OUT VARCHAR2);


    PROCEDURE CRE_GENERAACTUALIZA_P (
        AI_ACTUALIZACESANTIAS      IN T_ACTUALIZACESANTIAS,
        AI_FECHACARGA            IN DATE,
        AO_ERROR                  IN OUT VARCHAR2,
        AO_MENSAJEERROR            IN OUT VARCHAR2);


    PROCEDURE CRE_ACTUALIZACUENTACESANTIAS_P(
            AI_FECHACARGA          IN DATE,
            AO_ERROR             IN OUT VARCHAR2,
            AO_MENSAJEERROR      IN OUT VARCHAR2);


    PROCEDURE CRE_EJECUTAACTUALIZACION_P(
            AI_FECHACARGA      IN DATE,
            AO_ERROR        OUT VARCHAR2,
            AO_MENSAJEERROR    OUT VARCHAR2);


    PROCEDURE CRE_VALIDAEJECUTACES_P (
        AI_FECHACARGA          IN DATE,
        AO_ERROR              IN OUT VARCHAR2,
        AO_MENSAJEERROR        IN OUT VARCHAR2);
        
        
    PROCEDURE CRE_ACTUALIZACESANTIAS_P (
        AI_NUMAFI              IN    IESS_OWNER.KSAFITCESANTIAS.CEDULA%TYPE,
        AI_DISPONIBLECTAIND    IN     IESS_OWNER.KSAFITCESANTIAS.CESHISLAB%TYPE,
        AO_ERROR             OUT VARCHAR2,
        AO_MENSAJEERROR       OUT VARCHAR2);        
        
        
    PROCEDURE CRE_GENERACODIGOPROCESO_P (
        AI_CODPRO          IN     IESS_OWNER.HLPROTTIPOPE.CODPRO%TYPE,
        AI_CODESTPRO       IN     IESS_OWNER.HLPROTBITOPE.CODESTPRO%TYPE,
        AI_EXTARC          IN     IESS_OWNER.HLPROTBITOPE.EXTARC%TYPE,
        AI_NOMARC       IN     IESS_OWNER.HLPROTBITOPE.NOMARC%TYPE,
        AI_TIPOPE       IN     VARCHAR2,
        AI_NID             IN OUT IESS_OWNER.HLPROTBITOPE.ID%TYPE,
        AO_ERROR          IN OUT VARCHAR2,
        AO_MENSAJEERROR IN OUT VARCHAR2);


    PROCEDURE CRE_NETEOCUENTAINDIVIDUAL_P (
        AI_NUMPREAFI      IN     IESS_OWNER.KSCRETCREDITOS.NUMPREAFI%TYPE,
        AI_ORDPREAFI      IN     IESS_OWNER.KSCRETCREDITOS.ORDPREAFI%TYPE,
        AI_CODPRETIP      IN     IESS_OWNER.KSCRETCREDITOS.CODPRETIP%TYPE,
        AI_CODPRECLA      IN     IESS_OWNER.KSCRETCREDITOS.CODPRECLA%TYPE,
        AI_NUMAFI         IN     FRO.FRSAFITSOLAFI.NUMAFI%TYPE,
        AI_CODSOLAFI      IN     FRO.FRSAFITSOLAFI.CODSOLAFI%TYPE,
        AI_CODTIPSOLAFI   IN     FRO.FRSAFITSOLAFI.CODTIPSOLAFI%TYPE,
        AI_VALORLIQUIDA   IN     FRO.FRSAFITSOLAFI.VALSOLAFI%TYPE,
        AI_OBSERVACION    IN     FRO.FRSAFITCRURESCTAIND.OBSERVACION%TYPE,
        AI_FECSOLAFI      IN     FRO.FRSAFITSOLAFI.FECPAGSOL%TYPE,
        AI_IMPOSICIONES   IN     VARCHAR2,
        AO_NETEO             OUT NUMBER,
        AO_ERROR            OUT VARCHAR2,
        AO_MENSAJEERROR     OUT VARCHAR2);


    PROCEDURE CRE_ARCHIVODEBITO_P (
        AI_NOMBREARCHIVO    IN    VARCHAR2,
        AI_NID              IN  IESS_OWNER.CRE_BITACORAS_TBL.ID%TYPE,
        AO_NUMEROLINEAS        OUT NUMBER,
        AO_ERROR              IN OUT VARCHAR2,
        AO_MENSAJEERROR        IN OUT VARCHAR2);


    PROCEDURE CRE_ACTUALIZAESTADOCRE_P (
        AI_NUMPREAFI       IN    IESS_OWNER.KSCRETCREDITOS.NUMPREAFI%TYPE,
        AI_ORDPREAFI       IN  IESS_OWNER.KSCRETCREDITOS.ORDPREAFI%TYPE,
        AI_CODPRETIP       IN  IESS_OWNER.KSCRETCREDITOS.CODPRETIP%TYPE,
        AI_CODPRECLA       IN  IESS_OWNER.KSCRETCREDITOS.CODPRECLA%TYPE,
        AI_ESTADOANTES    IN  IESS_OWNER.KSCRETCREDITOS.CODESTPRE%TYPE,
        AI_ESTADONUEVO    IN  IESS_OWNER.KSCRETCREDITOS.CODESTPRE%TYPE,
        AO_ERROR          IN OUT VARCHAR2,
        AO_MENSAJEERROR    IN OUT VARCHAR2);
        
        
    PROCEDURE CRE_LIBERATOTALFRS_P (
        AI_NUMPREAFI       IN  IESS_OWNER.KSCRETCREDITOS.NUMPREAFI%TYPE,
        AI_ORDPREAFI       IN  IESS_OWNER.KSCRETCREDITOS.ORDPREAFI%TYPE,
        AI_CODPRETIP       IN  IESS_OWNER.KSCRETCREDITOS.CODPRETIP%TYPE,
        AI_CODPRECLA       IN  IESS_OWNER.KSCRETCREDITOS.CODPRECLA%TYPE,
        AI_NUMAFI          IN  IESS_OWNER.KSCRETCREDITOS.NUMAFI%TYPE,
        AI_OPERACIONSAC    IN  IESS_OWNER.KSCRETCREDITOS.CR_OPERACIONSAC%TYPE,
        AI_ESTCTAIND    IN    IESS_OWNER.FRSAFITCRURESCTAIND.ESTPROCTAIND%TYPE,
        AO_ERROR           IN OUT VARCHAR2,
        AO_MENSAJEERROR IN OUT VARCHAR2);        
        
        
    PROCEDURE CRE_LIBERADESBLOQUEATOTAL_P ( 
        AI_NUMPREAFI      IN  IESS_OWNER.KSCRETCREDITOS.NUMPREAFI%TYPE,
        AI_ORDPREAFI    IN  IESS_OWNER.KSCRETCREDITOS.ORDPREAFI%TYPE,
        AI_CODPRETIP    IN  IESS_OWNER.KSCRETCREDITOS.CODPRETIP%TYPE,
        AI_CODPRECLA    IN  IESS_OWNER.KSCRETCREDITOS.CODPRECLA%TYPE,
        AI_TIPOFONDO      IN  VARCHAR2,
        AI_NUMAFI       IN  IESS_OWNER.KSCRETCREDITOS.NUMAFI%TYPE,
        AI_OPERACIONSAC IN     IESS_OWNER.KSCRETCREDITOS.CR_OPERACIONSAC%TYPE,
        AO_ERROR         IN OUT VARCHAR2,
        AO_MENSAJEERROR IN OUT VARCHAR2);
        
        
    PROCEDURE CRE_GENERATRANSACCION_P (
        AI_TIPOFONDO          IN  VARCHAR2,
        AI_NUMAFI            IN     IESS_OWNER.KSCRETCREDITOS.NUMAFI%TYPE,
        AI_OPERACIONSAC     IN  IESS_OWNER.KSCRETCREDITOS.CR_OPERACIONSAC%TYPE,
        AI_CODTIPSOLSER     IN  IESS_OWNER.KSCRETCREDITOS.CODTIPSOLSER%TYPE,
        AI_NUMSOLSER        IN  IESS_OWNER.KSCRETCREDITOS.NUMSOLSER%TYPE,
        AI_VALORCOBRAR      IN  IESS_OWNER.REC_TRANSACCION_TBL.TR_VALORCOBRAR%TYPE,
        AI_TIPORETIRO          IN  VARCHAR2,
        AI_IDREGISTRO       IN  IESS_OWNER.REC_TRANSACCION_TBL.TR_REFERENCIACANCELACION%TYPE,
        AI_NUT                IN  IESS_OWNER.REC_TRANSACCION_TBL.TR_NUT%TYPE,
        AI_FECHASACEFEC        IN  IESS_OWNER.REC_TRANSACCION_TBL.TR_FECHACANCELACION%TYPE,
        AO_TIPOTRANSACCION  IN OUT IESS_OWNER.REC_TRANSACCION_TBL.TR_IDTIPOTRANSACCION%TYPE,
        AO_ERROR              IN OUT VARCHAR2,
        AO_MENSAJEERROR     IN OUT VARCHAR2);
        
        
    PROCEDURE CRE_INSERTABITACORAS_P (
        AI_BITACORAS     IN IESS_OWNER.CRE_BITACORAS_TBL%ROWTYPE,
        AO_ERROR         IN OUT VARCHAR2,
        AO_MENSAJEERROR IN OUT VARCHAR2);        
        
        
    PROCEDURE CRE_ACTUALIZADEBITOREC_P (
        AI_MENSAJEERROR    IN    VARCHAR2,
        AI_IDGAF          IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_OPERACIONSAC%TYPE,
        AI_IDREGISTRO     IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_IDREGISTRO%TYPE,
        AO_ERROR          IN OUT VARCHAR2,
        AO_MENSAJEERROR IN OUT VARCHAR2);
        
        
    PROCEDURE CRE_ACTUALIZADEBITOCAN_P (
        AI_IDGAF          IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_OPERACIONSAC%TYPE,
        AI_VALDEB       IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_VALORAPLICADOFONRES%TYPE,
        AI_CODSOLI      IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_NUMTRANSACCIONBIESS%TYPE,
        AI_TIPODEBITO   IN VARCHAR2,
        AI_IDTRANSAC    IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_IDTRANSACCIONSAC%TYPE,
        AI_IDREGISTRO   IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_IDREGISTRO%TYPE,
        AO_ERROR         IN OUT VARCHAR2,
        AO_MENSAJEERROR IN OUT VARCHAR2);


    PROCEDURE CRE_ACTUALIZADEBITOOBS_P (
        AI_MENSAJEERROR       IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_OBSERVACION%TYPE,
        AI_IDGAF               IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_OPERACIONSAC%TYPE,
        AI_IDREGISTRO       IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_IDREGISTRO%TYPE,
        AO_ERROR             IN OUT VARCHAR2,
        AO_MENSAJEERROR      IN OUT VARCHAR2);


    PROCEDURE CRE_VALORAPROXIMADOFRS_P (
        AI_KSCRETCREDITOS           IN IESS_OWNER.KSCRETCREDITOS%ROWTYPE,
        AO_VALORTOTALAPROXIMADOFR     IN OUT IESS_OWNER.APORTES_PFR2.VALORCOMPROMETIDOFRCAPITAL%TYPE,
        AO_ERROR          IN OUT VARCHAR2,
        AO_MENSAJEERROR IN OUT VARCHAR2);


    PROCEDURE CRE_VALIDAVALORESDEBITO_P (
        AI_IDGAF        IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_OPERACIONSAC%TYPE,
        AI_IDREGISTRO   IN IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_IDREGISTRO%TYPE,
        AI_CODSOLAFI     IN IESS_OWNER.FRSAFITSOLAFI.CODSOLAFI%TYPE,
        AI_CODTIPSOLAFI IN IESS_OWNER.FRSAFITSOLAFI.CODTIPSOLAFI%TYPE,
        AO_ERROR          IN OUT VARCHAR2,
        AO_MENSAJEERROR IN OUT VARCHAR2);
        
        
    PROCEDURE CRE_AFECTACUENTAFRS_P (
        AI_NUMPREAFI           IN         IESS_OWNER.KSCRETCREDITOS.NUMPREAFI%TYPE,
        AI_ORDPREAFI           IN         IESS_OWNER.KSCRETCREDITOS.ORDPREAFI%TYPE,
        AI_CODPRETIP           IN         IESS_OWNER.KSCRETCREDITOS.CODPRETIP%TYPE,
        AI_CODPRECLA           IN         IESS_OWNER.KSCRETCREDITOS.CODPRECLA%TYPE,
        AI_NUMAFI              IN         IESS_OWNER.KSCRETCREDITOS.NUMAFI%TYPE,
        AI_CODTIPSOLSER        IN         IESS_OWNER.KSCRETCREDITOS.CODTIPSOLSER%TYPE,
        AI_NUMSOLSER           IN         IESS_OWNER.KSCRETCREDITOS.NUMSOLSER%TYPE,
        AI_VALORLIQUIDACION IN         IESS_OWNER.FRSAFITSOLAFI.VALSOLAFI%TYPE,    --VALOR LIQUIDACION ENVIADO POR GAF
        AI_CODSOLIAFI          IN         IESS_OWNER.FRSAFITSOLAFI.CODSOLAFI%TYPE,
        AI_CODTIPSOLIAFI       IN         IESS_OWNER.FRSAFITSOLAFI.CODTIPSOLAFI%TYPE,
        AI_CODDIVPOL           IN         IESS_OWNER.KSPCOTDIVPOL.CODDIVPOL%TYPE,
        AI_IDREGISTRO          IN        IESS_OWNER.REC_TRANSACCION_TBL.TR_REFERENCIACANCELACION%TYPE,
        AI_FECSOLAFI        IN        IESS_OWNER.FRSAFITCRURESCTAIND.FECREGSOL%TYPE,
        AI_OPERACIONSAC        IN         IESS_OWNER.KSCRETCREDITOS.CR_OPERACIONSAC%TYPE,
        AI_NUT              IN         IESS_OWNER.KSCRETSOLICITUDES.NUT%TYPE,
        AI_FECHASACEFEC        IN         IESS_OWNER.REC_TRANSACCION_TBL.TR_FECHACANCELACION%TYPE,
        AO_LIQUIPQ           OUT     IESS_OWNER.FRSAFITSOLAFI.VALSOLAFI%TYPE,
        AO_ERROR            OUT     VARCHAR2,
        AO_MENSAJEERROR        OUT     VARCHAR2);


    PROCEDURE CRE_EJECUTADEBITOFCE_P (
        AI_NUMAFI       IN    IESS_OWNER.KSCRETCREDITOS.NUMAFI%TYPE,
        AI_NUMPREAFI    IN  IESS_OWNER.KSCRETCREDITOS.NUMPREAFI%TYPE,
        AI_ORDPREAFI    IN  IESS_OWNER.KSCRETCREDITOS.ORDPREAFI%TYPE,
        AI_CODPRETIP    IN  IESS_OWNER.KSCRETCREDITOS.CODPRETIP%TYPE,
        AI_CODPRECLA    IN  IESS_OWNER.KSCRETCREDITOS.CODPRECLA%TYPE,
        AI_CODTIPSOLSER IN  IESS_OWNER.KSCRETCREDITOS.CODTIPSOLSER%TYPE,
        AI_NUMSOLSER    IN  IESS_OWNER.KSCRETCREDITOS.NUMSOLSER%TYPE,
        AI_CODESTPRE    IN  IESS_OWNER.KSCRETCREDITOS.CODESTPRE%TYPE,
        AI_CODIVPOL     IN  IESS_OWNER.KSCRETCREDITOS.CODDIVPOL%TYPE,
        AI_VALORSOL     IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_VALORLIQUIDACIONSAC%TYPE,
        AI_IDREGISTRO   IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_IDREGISTRO%TYPE,
        AI_OPERACIONSAC IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_OPERACIONSAC%TYPE,
        AI_NUT          IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_NUT%TYPE,
        AI_FECHASACEFEC IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_FECEJECUCION%TYPE,
        AI_VALLIQSAC    IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_VALORLIQUIDACIONSAC%TYPE,
        AO_ERROR        IN OUT VARCHAR2,
        AO_MENSAJEERROR IN OUT VARCHAR2);        


    PROCEDURE CRE_GENERADEBITOFCE_P (
        AI_KSCRETCREDITOS   IN  IESS_OWNER.KSCRETCREDITOS%ROWTYPE,
        AI_VALSOL              IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_VALORLIQUIDACIONSAC%TYPE,
        AI_IDREGISTRO          IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_IDREGISTRO%TYPE,
        AI_OPERACIONSAC        IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_OPERACIONSAC%TYPE,
        AI_NUT                 IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_NUT%TYPE,
        AI_FECHASACEFEC        IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_FECEJECUCION%TYPE,
        AI_VALLIQSAC        IN     IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_VALORLIQUIDACIONSAC%TYPE,
        AI_ESTADOCES        IN     IESS_OWNER.CRE_ACTUALIZACESANTIAS_TBL.AC_ESTADO%TYPE,
        AO_ERROR               IN OUT VARCHAR2,
        AO_MENSAJEERROR     IN OUT VARCHAR2);


    PROCEDURE CRE_GENERADEBITOFRS_P (
        AI_KSCRETCREDITOS        IN  IESS_OWNER.KSCRETCREDITOS%ROWTYPE,
        AI_IDREGISTRO           IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_IDREGISTRO%TYPE,
        AI_OPERACIONSAC         IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_OPERACIONSAC%TYPE,
        AI_NUT                  IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_NUT%TYPE,
        AI_FECHASACEFEC         IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_FECEJECUCION%TYPE,
        AI_VALORLIQUIDACIONSAC     IN  IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_VALORLIQUIDACIONSAC%TYPE,
        AI_ESTADOCES            IN  IESS_OWNER.CRE_ACTUALIZACESANTIAS_TBL.AC_ESTADO%TYPE,
        AO_VALORSALDO               OUT IESS_OWNER.CRE_CREDITOSDEBITOSAC_T.CD_VALORLIQUIDACIONSAC%TYPE,
        AO_ESTADOCREDITO        OUT IESS_OWNER.KSCRETCREDITOS.CODESTPRE%TYPE,
        AO_ERROR                  OUT    VARCHAR2,
        AO_MENSAJEERROR            OUT VARCHAR2);


    PROCEDURE CRE_VALIDATIPODEBITO_P (
        AI_KSCRETCREDITOS   IN IESS_OWNER.KSCRETCREDITOS%ROWTYPE,
        AI_FECRESOL         IN VARCHAR2,
        AO_VALIDACREDITO    OUT PLS_INTEGER,
        AO_ERROR               OUT VARCHAR2,
        AO_MENSAJEERROR      OUT VARCHAR2);


    PROCEDURE CRE_EJECUTADEBITO_P (
        AI_TIPOPROCESO         IN VARCHAR2,
        AI_FECHACARGA          IN DATE,    
        AO_ERROR               OUT VARCHAR2,
        AO_MENSAJEERROR       OUT VARCHAR2);
        
        
    PROCEDURE CRE_VALIDAEJECUTADEB_P (
        AI_TIPOPROCESO         IN VARCHAR2,
        AI_FECHACARGA          IN DATE,
        AO_ERROR              IN OUT VARCHAR2,
        AO_MENSAJEERROR        IN OUT VARCHAR2);        
        
        
    PROCEDURE CRE_ACTUALIZAPARAMETROS_P (
        AO_ERROR               OUT VARCHAR2,
        AO_MENSAJEERROR      OUT VARCHAR2);
        
        
    PROCEDURE CRE_PARAMETRIZACIONES_P (
        AO_ERROR          IN OUT VARCHAR2,
        AO_MENSAJEERROR    IN OUT VARCHAR2);        
    
    
    PROCEDURE CRE_DEBITOAUTOMATICO_P (
        AO_ERROR          IN OUT VARCHAR2,
        AO_MENSAJEERROR    IN OUT VARCHAR2);



        
END CRE_DEBITOAUTOMATICOPQ_PKG;
/