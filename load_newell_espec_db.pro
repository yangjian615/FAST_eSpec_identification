;2016/06/04
;;NOTE: We do not clean the current database. It's clean as a whistle.
PRO LOAD_NEWELL_ESPEC_DB,eSpec,eSpec__times,eSpec__delta_t, $
                         FAILCODES=failCode, $
                         USE_UNSORTED_FILE=use_unsorted_file, $
                         NEWELLDBDIR=NewellDBDir, $
                         NEWELLDBFILE=NewellDBFile, $
                         FORCE_LOAD_DB=force_load_db, $
                         DONT_LOAD_IN_MEMORY=nonMem, $
                         DONT_PERFORM_CORRECTION=dont_perform_SH_correction, $
                         DONT_CONVERT_TO_STRICT_NEWELL=dont_convert_to_strict_newell, $
                         DONT_MAP_TO_100KM=no_mapping, $
                         DO_NOT_MAP_FLUXES=do_not_map_fluxes, $
                         DO_NOT_MAP_DELTA_T=do_not_map_delta_t, $
                         LOAD_DELTA_T=load_delta_t, $
                         COORDINATE_SYSTEM=coordinate_system, $
                         USE_AACGM_COORDS=use_aacgm, $
                         USE_GEO_COORDS=use_geo, $
                         USE_MAG_COORDS=use_mag, $
                         ;; JUST_TIMES=just_times, $
                         ;; OUT_TIMES=out_times, $
                         ;; OUT_GOOD_I=good_i, $
                         LOAD_DELTA_ILAT_FOR_WIDTH_TIME=load_dILAT, $
                         LOAD_DELTA_ANGLE_FOR_WIDTH_TIME=load_dAngle, $
                         LOAD_DELTA_X_FOR_WIDTH_TIME=load_dx, $
                         USE_2000KM_FILE=use_2000km_file, $
                         CLEAR_MEMORY=clear_memory, $
                         NO_MEMORY_LOAD=noMem, $
                         REDUCED_DB=reduce_dbSize, $
                         LUN=lun, $
                         QUIET=quiet

  COMPILE_OPT idl2

  ;;DONT_LOAD_IN_MEMORY is kept so that other routines don't make a mistake,
  ;;but I've included the keyword NO_MEMORY_LOAD from LOAD_MAXIMUS and LOAD_FASTLOC for the sake of my poor memory
  IF N_ELEMENTS(noMem) NE 0 THEN BEGIN
     IF N_ELEMENTS(nonMem) EQ 0 THEN BEGIN
        nonMem = noMem
     ENDIF ELSE BEGIN
        IF nonMem NE noMem THEN BEGIN
           PRINT,"Ludicrosity. Tell me to do one thing and then the other."
           STOP
        ENDIF
     ENDELSE
  ENDIF

  IF KEYWORD_SET(clear_memory) THEN BEGIN
     CLEAR_ESPEC_DB_VARS,QUIET=quiet
     RETURN
  ENDIF

  @common__newell_espec.pro
  
  defNewellDBDir         = '/SPENCEdata/Research/database/FAST/dartdb/electron_Newell_db/fully_parsed/'
  defNewellDBDir         = '/SPENCEdata/Research/database/FAST/dartdb/electron_Newell_db/fully_parsed/'

  ;;The file with failcodes
  defNewellDBFile        = 'eSpec_failCodes_20160609_db--PARSED--Orbs_500-16361.sav' ;;This file does not need to be cleaned
  DB_date                = '20160609'
  DB_version             = 'v0.0'
  DB_extras              = 'failcodes'

  ;;The file without failcodes
  defNewellDBFile        = 'eSpec_20160607_db--PARSED--with_mapping_factors--Orbs_500-16361.sav' ;;This file does not need to be cleaned
  DB_date                = '20160607'
  DB_version             = 'v0.0'
  DB_extras              = 'with_mapping_factors'

  defSortNewellDBFile    =  "sorted--" + defNewellDBFile

  ;;the 2000 km file
  IF KEYWORD_SET(use_2000km_file) THEN BEGIN
     PRINT,'Using 2000 km eSpec DB ...'
     defNewellDBFile     = 'eSpec_20160607_db--orbs_500-16361--BELOW_2000km--with_alternate_coords__mapping_factors__strict_Newell_interp.sav'
     defSortNewellDBFile =  defNewellDBFile
     DB_date             = '20160607'
     DB_version          = 'v0.0'
     DB_extras           = 'Below_2000km/with_alternate_coords/with_mapping_factors/strict_Newell_interp'
  ENDIF

  ;; defNewellDBCleanInds   = 'iSpec_20160607_db--PARSED--Orbs_500-16361--indices_w_no_NaNs_INFs.sav'


  defCoordDir            = '/SPENCEdata/Research/database/FAST/dartdb/electron_Newell_db/alternate_coords/'
  ;; AACGM_file           = 'Dartdb_20151222--500-16361_inc_lower_lats--maximus--AACGM_coords.sav'

  ;; GEO_file             = 'Dartdb_20151222--500-16361_inc_lower_lats--maximus--GEO_coords.sav'
  ;; MAG_file             = 'Dartdb_20151222--500-16361_inc_lower_lats--maximus--MAG_coords.sav'


  IF N_ELEMENTS(quiet) EQ 0 THEN quiet = 0

  IF N_ELEMENTS(lun) EQ 0 THEN BEGIN
     lun                 = -1
  ENDIF

  IF N_ELEMENTS(NEWELL__eSpec) NE 0 AND ~KEYWORD_SET(force_load_db) THEN BEGIN
     CASE 1 OF
        KEYWORD_SET(just_times): BEGIN
           IF ~quiet THEN PRINT,"Just giving eSpec times ..."
           out_times     = NEWELL__eSpec.x

           RETURN
        END
        KEYWORD_SET(nonMem): BEGIN
           PRINT,"Moving eSpec structure/data in mem to outputted variables ..."
           eSpec            = TEMPORARY(NEWELL__eSpec     )
           ;; fastLoc_times    = TEMPORARY(FASTLOC__times)
           NewellDBFile     = TEMPORARY(NEWELL__dbFile    )
           NewellDBDir      = TEMPORARY(NEWELL__dbDir     )
           failCodes        = N_ELEMENTS(NEWELL__failCodes) GT 0 ? TEMPORARY(NEWELL__failCodes) : !NULL
           eSpec__delta_t   = N_ELEMENTS(NEWELL__delta_t  ) GT 0 ? TEMPORARY(NEWELL__delta_t  ) : !NULL 
        END
        ELSE: BEGIN
           ;; IF ~quiet THEN PRINT,'Restoring eSpec DB already in memory...'
           ;; eSpec         = NEWELL__eSpec
           ;; IF N_ELEMENTS(NEWELL__failCodes) GT 0 THEN BEGIN
           ;;    failCodes  = NEWELL__failCodes
           ;; ENDIF
           ;; NewellDBDir   = NEWELL__dbDir
           ;; NewellDBFile  = NEWELL__dbFile
           PRINT,"There is already an eSpec DB in memory! If you want it to come out, set /NO_MEMORY_LOAD"
        END
     ENDCASE
     RETURN
  ENDIF
  ;; ENDIF

  IF N_ELEMENTS(NewellDBDir) EQ 0 THEN BEGIN
     NewellDBDir      = defNewellDBDir
  ENDIF

  IF N_ELEMENTS(NewellDBFile) EQ 0 THEN BEGIN
     CASE KEYWORD_SET(use_unsorted_file) OF
        1: BEGIN
           specType      = 'UNSORTED'
           NewellDBFile  = defNewellDBFile
        END
        ELSE: BEGIN
           specType      = 'SORTED'
           NewellDBFile  = defSortNewellDBFile
        END
     ENDCASE
  ENDIF

  ;;If just getting times, at this point we've populated other variables
  ;;that might be of interest to user, so JET
  IF KEYWORD_SET(just_times) AND N_ELEMENTS(out_times) GT 0 THEN RETURN

  IF N_ELEMENTS(specType) EQ 0 THEN specType = ''
  IF N_ELEMENTS(eSpec) EQ 0 OR KEYWORD_SET(force_load_db) THEN BEGIN
     IF KEYWORD_SET(force_load_db) THEN BEGIN
        IF ~quiet THEN PRINTF,lun,"Forced loading of " + specType + " eSpec database ..."
     ENDIF
     IF ~quiet THEN PRINTF,lun,'Loading ' + specType + ' eSpec DB: ' + NewellDBFile + '...'
     RESTORE,NewellDBDir+NewellDBFile

     IF KEYWORD_SET(use_2000km_file) THEN BEGIN
        eSpec    = {x          : eSpec.x                , $
                    orbit      : eSpec.orbit            , $
                    ;; mlt     : eSpec.coords.aacgm.mlt , $
                    ;; ilat    : eSpec.coords.aacgm.lat , $
                    ;; alt     : eSpec.coords.aacgm.alt , $
                    mlt        : eSpec.coords.SDT.mlt   , $
                    ilat       : eSpec.coords.SDT.ilat  , $
                    alt        : eSpec.coords.SDT.alt   , $
                    je         : eSpec.je               , $
                    jee        : eSpec.jee              , $
                    mapFactor  : eSpec.mapFactor        , $
                    mono       : eSpec.mono             , $
                    broad      : eSpec.broad            , $
                    diffuse    : eSpec.diffuse          , $
                    info       : eSpec.info}
     ENDIF

     NEWELL_ESPEC__ADD_INFO_STRUCT,eSpec, $
                                  DB_DATE=DB_date, $
                                  DB_VERSION=DB_version, $
                                  DB_EXTRAS=DB_extras, $
                                  REDUCE_DBSIZE=reduce_dbSize

     ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     ;;What type of delta do you want?
     delta_stuff = KEYWORD_SET(load_delta_t) + KEYWORD_SET(load_dILAT) + KEYWORD_SET(load_dx) + KEYWORD_SET(load_dAngle)
     CASE delta_stuff OF
        0:
        1: BEGIN
           IF ~KEYWORD_SET(load_delta_t) THEN BEGIN
              dILAT_file         = GET_FAST_DB_STRING(eSpec,/FOR_ESPEC_DB) + '-delta_ilats.sav'
              RESTORE,NewellDBDir+dILAT_file
           ENDIF
        END
        ELSE: BEGIN
           PRINT,"Can't have it all."
           STOP
        END
     ENDCASE

     IF KEYWORD_SET(load_delta_t) THEN BEGIN
        PRINT,"Loading eSpec delta_ts ..."
        eSpec__delta_t = GET_ESPEC_ION_DELTA_T(eSpec, $
                                               DBNAME='eSpec')
     ENDIF

     IF KEYWORD_SET(load_dILAT) THEN BEGIN
        PRINT,"Loading dILAT in place of eSpec delta_t, and not mapping ..."
        
        ;; no_mapping              = 1
        do_not_map_delta_t      = 1

        eSpec__delta_t          = TEMPORARY(ABS(FLOAT(width_ILAT)))
        eSpec.info.dILAT_not_dt = 1B
     ENDIF

     IF KEYWORD_SET(load_dAngle) THEN BEGIN
        PRINT,"Loading dAngle in place of eSpec delta_t, and not mapping ..."
        
        ;; no_mapping               = 1
        do_not_map_delta_t       = 1

        eSpec__delta_t           = TEMPORARY(ABS(FLOAT(width_angle)))
        eSpec.info.dAngle_not_dt = 1B
     ENDIF

     IF KEYWORD_SET(load_dx) THEN BEGIN
        PRINT,"Loading dx in place of eSpec delta_t, and not mapping ..."
        
        ;; no_mapping              = 1
        do_not_map_delta_t      = 1

        eSpec__delta_t          = TEMPORARY(ABS(FLOAT(width_x)))
        eSpec.info.dx_not_dt    = 1B
     ENDIF

     IF KEYWORD_SET(no_mapping) OR KEYWORD_SET(do_not_map_fluxes) THEN BEGIN
        PRINT,"Not mapping to 100 km ..."
     ENDIF ELSE BEGIN
        PRINT,"Mapping eSpec observations to 100 km ..."
        eSpec.je  *= eSpec.mapFactor
        eSpec.jee *= eSpec.mapFactor

        eSpec.info.is_mapped = 1B
     ENDELSE

     IF ~(KEYWORD_SET(do_not_map_delta_t) OR KEYWORD_SET(no_mapping)) $
        AND (N_ELEMENTS(eSpec__delta_t) GT 0) $
     THEN BEGIN
        eSpec__delta_t         /= SQRT(eSpec.mapFactor)
        eSpec.info.dt_is_mapped = 1B
     ENDIF


     ;; STR_ELEMENT,eSpec,'mapFactor',/DELETE

     IF KEYWORD_SET(reduce_dbSize) THEN BEGIN
        PRINT,"Reducing eSpec DB size, tossing out possibly extraneous members ..."

        IF MAX(eSpec.orbit) GT 65534 THEN BEGIN
           PRINT,"You're about to descend into confusion if you shrink tag member ORBIT for this database."
           STOP                 ;Because the tag ORBIT is type UINT
        ENDIF

        eSpec   = {x           : eSpec.x           , $
                   orbit       : UINT(eSpec.orbit) , $
                   mlt         : FLOAT(eSpec.mlt)  , $
                   ilat        : FLOAT(eSpec.ilat) , $
                   alt         : FLOAT(eSpec.alt)  , $
                   mono        : eSpec.mono        , $
                   broad       : eSpec.broad       , $
                   diffuse     : eSpec.diffuse     , $
                   je          : eSpec.je          , $
                   jee         : eSpec.jee         , $
                   info        : eSpec.info        }
     ENDIF

     ;;Correct fluxes
     IF ~(KEYWORD_SET(dont_perform_SH_correction) OR (KEYWORD_SET(just_times) AND KEYWORD_SET(dont_perform_SH_correction))) THEN BEGIN
        IF ~quiet THEN PRINT,"Correcting eSpec fluxes so that earthward is positive in SH..."
        
        ;;The following line says that if there are a lot of jee values in the Southern Hemi that are negative, we need to perform a conversion
        ;;to make earthward positive in the SH
        IF FLOAT(N_ELEMENTS(WHERE(eSpec.jee LT 0 AND eSpec.ilat LT 0)))/N_ELEMENTS(WHERE(eSpec.ilat LT 0)) GT 0.1 THEN BEGIN
           eSpec.je [WHERE(eSpec.ilat LT 0)] = (-1.)*(eSpec.je [WHERE(eSpec.ilat LT 0)])
           eSpec.jee[WHERE(eSpec.ilat LT 0)] = (-1.)*(eSpec.jee[WHERE(eSpec.ilat LT 0)])
        ENDIF
        
        ;;Book keeping
        eSpec.info.correctedFluxes = 1B

        ;;Convert to strict Newell interpretation        
        IF ~KEYWORD_SET(dont_convert_to_strict_newell) THEN BEGIN
           IF ~quiet THEN PRINT,"Converting eSpec DB to strict Newell interpretation ..."
           CONVERT_ESPEC_TO_STRICT_NEWELL_INTERPRETATION,eSpec,eSpec,/HUGE_STRUCTURE,/VERBOSE
        ENDIF ELSE BEGIN
           IF ~quiet THEN PRINT,'Not converting eSpec to strict Newell interp ...'
        ENDELSE
     ENDIF ELSE BEGIN
        IF ~quiet THEN PRINT,"Not correcting sign in each hemisphere, and not converting to strict Newell interp ..."
     ENDELSE

  ENDIF ELSE BEGIN
     IF ~quiet THEN PRINTF,lun,'eSpec DB already loaded! Not restoring ' + NewellDBFile + '...'
  ENDELSE

  IF KEYWORD_SET(coordinate_system) THEN BEGIN
     CASE STRUPCASE(coordinate_system) OF
        'AACGM': BEGIN
           use_aacgm = 1
           use_geo   = 0
           use_mag   = 0
        END
        'GEO'  : BEGIN
           use_aacgm = 0
           use_geo   = 1
           use_mag   = 0
        END
        'MAG'  : BEGIN
           use_aacgm = 0
           use_geo   = 0
           use_mag   = 1
        END
     ENDCASE
  ENDIF

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  PRINT,"UNDER CONSTRUCTION"
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  IF KEYWORD_SET(use_aacgm) THEN BEGIN
     PRINT,"I know. I already did."

     ;; PRINT,'Using AACGM lat, MLT, and alt ...'

     ;; RESTORE,defCoordDir+AACGM_file

     ;; ALFDB_SWITCH_COORDS,MAXIMUS__maximus,max_AACGM,'AACGM'

  ENDIF

  ;; IF KEYWORD_SET(use_geo) THEN BEGIN
  ;;    PRINT,'Using GEO lat and alt ...'

  ;;    RESTORE,defCoordDir+GEO_file

  ;;    ALFDB_SWITCH_COORDS,MAXIMUS__maximus,max_GEO,'GEO'

  ;; ENDIF

  ;; IF KEYWORD_SET(use_mag) THEN BEGIN
  ;;    PRINT,'Using MAG lat and alt ...'

  ;;    RESTORE,defCoordDir+MAG_file

  ;;    ALFDB_SWITCH_COORDS,MAXIMUS__maximus,max_MAG,'MAG'

  ;; ENDIF

  IF ~KEYWORD_SET(nonMem) THEN BEGIN
     NEWELL__eSpec          = TEMPORARY(eSpec)

     IF KEYWORD_SET(delta_stuff) THEN BEGIN
        NEWELL__delta_t     = TEMPORARY(eSpec__delta_t)
     ENDIF

     NEWELL__dbFile         = TEMPORARY(NewellDBFile)
     NEWELL__dbDir          = TEMPORARY(NewellDBDir )

     IF N_ELEMENTS(failCode) NE 0 THEN BEGIN
        NEWELL__failCodes   = TEMPORARY(failCode)
     ENDIF ELSE BEGIN
        NEWELL__failCodes   = !NULL
        IF ~quiet THEN PRINT,'This Newell DB file doesn''t have fail codes!'
     ENDELSE

  ENDIF

  RETURN
END