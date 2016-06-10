;2016/06/04
;;NOTE: We do not clean the current database. It's clean as a whistle.
PRO LOAD_NEWELL_ESPEC_DB,eSpec, $
                         FAILCODES=failCode, $
                         NEWELLDBDIR=NewellDBDir, $
                         NEWELLDBFILE=NewellDBFile, $
                         FORCE_LOAD_DB=force_load_db, $
                         DONT_LOAD_IN_MEMORY=nonMem, $
                         JUST_TIMES=just_times, $
                         OUT_TIMES=out_times, $
                         ;; OUT_GOOD_I=good_i, $
                         LUN=lun

  COMPILE_OPT idl2

  ;;This common block is defined ONLY here and in GET_ESPEC_ION_DB_IND
  IF ~KEYWORD_SET(nonMem) THEN BEGIN
     COMMON NEWELL,NEWELL__eSpec,NEWELL__HAVE_GOOD_I, $
        NEWELL__failCode, $
        NEWELL__good_i, $
        NEWELL__charERange, $
        ;; NEWELL__cleaned_i, $
        NEWELL__dbFile,NEWELL__dbDir, $
        NEWELL__RECALCULATE
  ENDIF
  
  defNewellDBDir         = '/SPENCEdata/Research/database/FAST/dartdb/electron_Newell_db/fully_parsed/'
  defNewellDBFile        = 'eSpec_failCodes_20160609_db--PARSED--Orbs_500-16361.sav' ;;This file does not need to be cleaned

  ;; defNewellDBCleanInds   = 'iSpec_20160607_db--PARSED--Orbs_500-16361--indices_w_no_NaNs_INFs.sav'

  IF N_ELEMENTS(lun) EQ 0 THEN BEGIN
     lun                 = -1
  ENDIF

  IF ~KEYWORD_SET(nonMem) THEN BEGIN
     IF N_ELEMENTS(NEWELL__eSpec) NE 0 AND ~KEYWORD_SET(force_load_db) THEN BEGIN
        CASE 1 OF
           KEYWORD_SET(just_times): BEGIN
              PRINT,"Just giving eSpec times ..."
              out_times     = eSpec.x
           END
           ELSE: BEGIN
              PRINT,'Restoring eSpec DB already in memory...'
              eSpec         = NEWELL__eSpec
              failCodes     = NEWELL__failCodes
              NewellDBDir   = NEWELL__dbDir
              NewellDBFile  = NEWELL__dbFile
           END
        ENDCASE
        RETURN
     ENDIF
  ENDIF

  IF N_ELEMENTS(NewellDBDir) EQ 0 THEN BEGIN
     NewellDBDir      = defNewellDBDir
  ENDIF
  IF ~KEYWORD_SET(nonMem) THEN BEGIN
     NEWELL__dbDir          = NewellDBDir
  ENDIF

  IF N_ELEMENTS(NewellDBFile) EQ 0 THEN BEGIN
     NewellDBFile     = defNewellDBFile
  ENDIF
  IF ~KEYWORD_SET(nonMem) THEN BEGIN
     NEWELL__dbFile         = NewellDBFile
  ENDIF

  IF N_ELEMENTS(eSpec) EQ 0 OR KEYWORD_SET(force_load_db) THEN BEGIN
     IF KEYWORD_SET(force_load_db) THEN BEGIN
        PRINTF,lun,"Forced loading of eSpec database ..."
     ENDIF
     PRINTF,lun,'Loading eSpec DB: ' + NewellDBFile + '...'
     RESTORE,NewellDBDir+NewellDBFile

     ;;Correct fluxes
     PRINT,"Correcting eSpec fluxes..."
     eSpec.je[WHERE(eSpec.ilat LT 0)]  = (-1.)*(eSpec.je[WHERE(eSpec.ilat LT 0)])
     eSpec.jee[WHERE(eSpec.ilat LT 0)] = (-1.)*(eSpec.jee[WHERE(eSpec.ilat LT 0)])

     ;;Convert to strict Newell interpretation
     CONVERT_ESPEC_TO_STRICT_NEWELL_INTERPRETATION,eSpec,eSpec,/HUGE_STRUCTURE,/VERBOSE

     ;;The following lines aren't necessary for this little beaut

     ;; IF FILE_TEST(NewellDBDir+defNewellDBCleanInds) THEN BEGIN
     ;;    RESTORE,NewellDBDir+defNewellDBCleanInds
     ;; ENDIF ELSE BEGIN        
     ;;    good_i = BASIC_ESPEC_ION_DB_CLEANER(eSpec,/CLEAN_NANS_AND_INFINITIES)
     ;;    PRINT,'Saving NaN- and INF-less eSpec DB inds to ' + defNewellDBCleanInds + '...'
     ;;    SAVE,good_i,FILENAME=NewellDBDir+defNewellDBCleanInds
     ;; ENDELSE
     
  ENDIF ELSE BEGIN
     PRINTF,lun,'eSpec DB already loaded! Not restoring ' + NewellDBFile + '...'
  ENDELSE

  IF ~KEYWORD_SET(nonMem) THEN BEGIN
     NEWELL__eSpec          = eSpec

     IF N_ELEMENTS(failCode) NE 0 THEN BEGIN
        NEWELL__failCodes   = failCode
     ENDIF ELSE BEGIN
        NEWELL__failCodes   = !NULL
        PRINT,'This Newell DB file doesn''t have fail codes!'
     ENDELSE

  ENDIF

  IF KEYWORD_SET(just_times) THEN BEGIN
     out_times              = TEMPORARY(eSpec)
  ENDIF

  RETURN

END