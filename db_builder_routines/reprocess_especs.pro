;;06/04/16
PRO REPROCESS_ESPECS

  COMPILE_OPT IDL2

  ;;Running options
  loud                      = 1

  firstOrb                  = 1500
  lastOrb                   = 16361


  newFileDateStr            = GET_TODAY_STRING(/DO_YYYYMMDD_FMT)

  Newell_DB_dir             = '/SPENCEdata/software/sdt/batch_jobs/Alfven_study/20160520--get_Newell_identification_for_Alfven_events--NOT_despun/Newell_batch_output/'
  Newell_filePref           = 'Newell_et_al_identification_of_electron_spectra--ions_included--Orbit_'

  outDir                    = '/SPENCEdata/Research/database/FAST/dartdb/electron_Newell_db/'

  orbChunk_save_interval    = 250
  chunkNum                  = 4

  chunkDir                  = outDir+'fully_parsed/'
  chunk_saveFile_pref       = STRING(FORMAT='("eSpec_",A0,"_db--PARSED--Orbs_",I0,"-",I0)', $
                                     newFileDateStr, $
                                     firstOrb, $
                                     lastOrb)

  ;;String together a chunk of orbits, reanalyze, and save
  PRINT,FORMAT='("Start orb",T12,"Stop orb",T24,"N Predicted",T36,"N Actual",T48,"NT Predicted",T60,"NT Actual",T72,"N Orbs this chunk")'
  orbCount                  = 0
  nPredicted                = 0
  nActual                   = 0
  nTotPredicted             = 0
  nTotActual                = 0
  TIC
  FOR curOrb=firstOrb,lastOrb DO BEGIN


     chunkStartOrb   = curOrb
     chunkEndOrb     = (curOrb + orbChunk_save_interval-1) < lastOrb
     clock           = TIC(STRING(FORMAT='("reprocess_especs--Orbs_",I0,"-",I0)',chunkStartOrb,chunkEndOrb))
     WHILE curOrb LE chunkEndOrb DO BEGIN
        ;;Get events in this orb
        doneski                           = 0
        curInterval                       = 0
        tempFile                          = STRING(FORMAT='(A0,A0,I0,"_",I0,".sav")',Newell_DB_dir,Newell_filePref,curOrb,curInterval)

        IF ~FILE_TEST(tempFile) THEN BEGIN

           doneski                        = 1
           curOrb++
           IF KEYWORD_SET(loud) THEN PRINT,"No data for orbit " + STRCOMPRESS(curOrb,/REMOVE_ALL)
           CONTINUE
        ENDIF
        WHILE ~doneski DO BEGIN

           RESET_ESPEC_RESTOREFILE_VARS,especs_parsed, $
                                        ispec_up, $
                                        jei_up, $
                                        ji_up, $
                                        out_sc_min_energy_ind, $
                                        out_sc_min_energy_ind_i, $
                                        out_sc_pot, $
                                        out_sc_pot_i, $
                                        out_sc_time, $
                                        out_sc_time_i, $
                                        tmpespec_lc, $
                                        tmpjee_lc, $
                                        tmpje_lc
           alt             = !NULL

           RESTORE,tempFile

           GET_ALT_MLT_ILAT_FROM_FAST_EPHEM,curOrb,eSpecs_parsed.x, $
                                            OUT_TSORTED_I=tSort_i, $
                                            OUT_ALT=alt, $
                                            OUT_MLT=mlt, $
                                            OUT_ILAT=ilat, $
                                            LOGLUN=logLun

           eSpecs_parsed   = !NULL
           eSpecs_temp     = !NULL
           failCodes_temp  = !NULL

           nEvents         = N_ELEMENTS(tmpeSpec_lc.x)
           IDENTIFY_DIFF_EFLUXES_AND_CREATE_STRUCT,tmpeSpec_lc,tmpjee_lc,tmpJe_lc,mlt,ilat,alt,MAKE_ARRAY(nEvents,VALUE=curOrb), $
                                                   eSpecs_temp, $
                                                   /QUIET, $
                                                   /HAS_ALT_AND_ORBIT, $
                                                   SC_POT=out_sc_pot, $
                                                   /PRODUCE_FAILCODE_OUTPUT, $
                                                   OUT_FAILCODES=failCodes_temp, $
                                                   /GIVE_TIMESPLIT_INFO, $
                                                   /BATCH_MODE
           ;; ADD_EVENT_TO_SPECTRAL_STRUCT__WITH_ALT,eSpecs,eSpecs_parsed,alt,MAKE_ARRAY(nEvents,VALUE=curOrb)
           ADD_EVENT_TO_SPECTRAL_STRUCT,eSpecs,eSpecs_temp,/HAS_ALT_AND_ORBIT
           ADD_ESPEC_FAILCODES_TO_FAILCODE_STRUCT,failCodes,failCodes_temp

           nPredicted     += nEvents

           ;;Check for next interval
           curInterval++
           tempFile = STRING(FORMAT='(A0,A0,I0,"_",I0,".sav")',Newell_DB_dir,Newell_filePref,curOrb,curInterval)
           IF ~FILE_TEST(tempFile) THEN doneski  = 1
        ENDWHILE

        orbCount++
        curOrb++
     ENDWHILE
     curOrb-- ;Fix the damage--trust me
     TOC,clock

     chunkTempFName  = STRING(FORMAT='(A0,"--CHUNK_",I02,"--eSpecs_failCodes_for_orbs_",I0,"-",I0,".sav")', $
                              chunk_saveFile_pref, $
                              chunkNum++, $
                              chunkStartOrb, $
                              chunkEndOrb)

     PRINT,"Saving " + chunkTempFName + '...'
     SAVE,eSpecs,failCodes,FILENAME=chunkDir+chunkTempFName

     ;;Check: did we hose it?
     nActual         = N_ELEMENTS(eSpecs.x)
     nTotActual     += nActual
     nTotPredicted  += nPredicted

     ;;Some output
     PRINT,FORMAT='(I0,T12,I0,T24,I0,T36,I0,T48,I0,T60,I0,T72,I0)',chunkStartOrb,chunkEndOrb,nPredicted,nActual,nTotPredicted,nTotActual,orbCount

     ;;Now reset loop vars
     eSpecs          = !NULL
     failCodes       = !NULL

     nPredicted      = 0
     nActual         = 0

     orbCount        = 0

  ENDFOR

  PRINT,'N total predicted: ' + STRCOMPRESS(nTotPredicted,/REMOVE_ALL)
  PRINT,'N total actual   : ' + STRCOMPRESS(nTotActual,/REMOVE_ALL)

  TOC

END

PRO RESET_ESPEC_RESTOREFILE_VARS,especs_parsed, $
                                 ispec_up, $
                                 jei_up, $
                                 ji_up, $
                                 out_sc_min_energy_ind, $
                                 out_sc_min_energy_ind_i, $
                                 out_sc_pot, $
                                 out_sc_pot_i, $
                                 out_sc_time, $
                                 out_sc_time_i, $
                                 tmpespec_lc, $
                                 tmpjee_lc, $
                                 tmpje_lc

        especs_parsed                  = !NULL
        ispec_up                       = !NULL
        jei_up                         = !NULL
        ji_up                          = !NULL
        out_sc_min_energy_ind          = !NULL
        out_sc_min_energy_ind_i        = !NULL
        out_sc_pot                     = !NULL
        out_sc_pot_i                   = !NULL
        out_sc_time                    = !NULL
        out_sc_time_i                  = !NULL
        tmpespec_lc                    = !NULL
        tmpjee_lc                      = !NULL
        tmpje_lc                       = !NULL

END