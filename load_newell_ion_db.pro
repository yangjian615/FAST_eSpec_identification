;2016/06/07
PRO LOAD_NEWELL_ION_DB,ion, $
                       ;; FAILCODES=failCodes, $
                       NEWELLDBDIR=NewellDBDir, $
                       NEWELLDBFILE=NewellDBFile, $
                       FORCE_LOAD_DB=force_load_db, $
                       DONT_LOAD_IN_MEMORY=nonMem, $
                       ;;   LOAD_DELTA_T=load_delta_t, $
                       ;;   COORDINATE_SYSTEM=coordinate_system, $
                       ;;   USE_AACGM_COORDS=use_aacgm, $
                       ;;   USE_GEO_COORDS=use_geo, $
                       ;;   USE_MAG_COORDS=use_mag, $
                       ;; LOAD_DELTA_ILAT_FOR_WIDTH_TIME=load_dILAT, $
                       ;; LOAD_DELTA_ANGLE_FOR_WIDTH_TIME=load_dAngle, $
                       ;; LOAD_DELTA_X_FOR_WIDTH_TIME=load_dx, $
                       JUST_TIMES=just_times, $
                       OUT_TIMES=out_times, $
                       ;; OUT_CLEANED_I=cleaned_i, $
                       LUN=lun

  COMPILE_OPT idl2

  ;;This common block is defined ONLY here and in GET_ESPEC_ION_DB_IND, I believe
  ;; IF ~KEYWORD_SET(nonMem) THEN BEGIN
  @common__newell_ion_db.pro
  ;; ENDIF
  
  defNewellDBDir         = '/SPENCEdata/Research/database/FAST/dartdb/electron_Newell_db/fully_parsed/'
  defNewellDBFile        = 'iSpec_20160607_db--PARSED--Orbs_500-16361.sav'

  defNewellDBCleanInds   = 'iSpec_20160607_db--PARSED--Orbs_500-16361--indices_w_no_NaNs_INFs.sav'

  IF N_ELEMENTS(lun) EQ 0 THEN BEGIN
     lun                 = -1
  ENDIF

  ;; IF ~KEYWORD_SET(nonMem) THEN BEGIN
     IF N_ELEMENTS(NEWELL_I__ion) NE 0 AND ~KEYWORD_SET(force_load_db) THEN BEGIN
        CASE 1 OF
           KEYWORD_SET(just_times): BEGIN
              PRINT,"Just giving eSpec times ..."
              out_times     = ion.x
           END
           ELSE: BEGIN
              PRINT,'Restoring ion DB already in memory...'
              ion           = NEWELL_I__ion
              NewellDBDir   = NEWELL_I__dbDir
              NewellDBFile  = NEWELL_I__dbFile
           END
        ENDCASE
        RETURN
     ENDIF
  ;; ENDIF

  IF N_ELEMENTS(NewellDBDir) EQ 0 THEN BEGIN
     NewellDBDir            = defNewellDBDir
  ENDIF
  ;; IF ~KEYWORD_SET(nonMem) THEN BEGIN
     NEWELL_I__dbDir        = NewellDBDir
  ;; ENDIF

  IF N_ELEMENTS(NewellDBFile) EQ 0 THEN BEGIN
     NewellDBFile           = defNewellDBFile
  ENDIF
  ;; IF ~KEYWORD_SET(nonMem) THEN BEGIN
     NEWELL_I__dbFile       = NewellDBFile
  ;; ENDIF

  IF N_ELEMENTS(ion) EQ 0 OR KEYWORD_SET(force_load_db) THEN BEGIN
     IF KEYWORD_SET(force_load_db) THEN BEGIN
        PRINTF,lun,"Forced loading of ion database ..."
     ENDIF
     PRINTF,lun,'Loading ion DB: ' + NewellDBFile + '...'
     RESTORE,NewellDBDir+NewellDBFile

     ;;Correct fluxes
     PRINT,"Correcting ionDB fluxes..."
     ion.ji[WHERE(ion.ilat GT 0)]  = (-1.)*(ion.ji[WHERE(ion.ilat GT 0)])
     ion.jei[WHERE(ion.ilat GT 0)] = (-1.)*(ion.jei[WHERE(ion.ilat GT 0)])

     ;; IF FILE_TEST(NewellDBDir+defNewellDBCleanInds) THEN BEGIN
     ;;    RESTORE,NewellDBDir+defNewellDBCleanInds
     ;; ENDIF ELSE BEGIN        
     ;;    cleaned_i = BASIC_ESPEC_ION_DB_CLEANER(ion,/CLEAN_NANS_AND_INFINITIES)
     ;;    PRINT,'Saving NaN- and INF-less ion DB inds to ' + defNewellDBCleanInds + '...'
     ;;    SAVE,cleaned_i,FILENAME=NewellDBDir+defNewellDBCleanInds
     ;; ENDELSE

     ;; IF ~KEYWORD_SET(nonMem) THEN BEGIN
     ;;    NEWELL_I__cleaned_i = cleaned_i
     ;; ENDIF

  ENDIF ELSE BEGIN
     PRINTF,lun,'ion DB already loaded! Not restoring ' + NewellDBFile + '...'
  ENDELSE
  IF ~KEYWORD_SET(nonMem) THEN BEGIN
     NEWELL_I__ion          = ion
  ENDIF

  ;; IF KEYWORD_SET(just_times) THEN BEGIN
  ;;    out_times              = TEMPORARY(ion.x)
  ;; ENDIF

  IF KEYWORD_SET(nonMem) THEN BEGIN
     CLEAR_ION_DB_VARS
  ENDIF

  RETURN

END