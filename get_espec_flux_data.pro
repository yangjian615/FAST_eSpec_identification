;2016/06/07
PRO GET_ESPEC_FLUX_DATA, $
   plot_i, $ 
   FOR_STORMS=for_storms, $
   FOR_IMF_SCREENING=for_IMF_screening, $
   ESPEC__JUNK_ALFVEN_CANDIDATES=eSpec__junk_alfven_candidates, $
   ESPEC__ALL_FLUXES=eSpec__all_fluxes, $
   ESPEC__NEWELL_2009_INTERP=eSpec__Newell_2009_interp, $
   ESPEC__USE_2000KM_FILE=eSpec__use_2000km_file, $
   ESPEC__REMOVE_OUTLIERS=eSpec__remove_outliers, $
   ESPEC__NEWELLPLOT_PROBOCCURRENCE=eSpec__newellPlot_probOccurrence, $
   DESPUN_ALF_DB=despun_alf_db, $
   USE_AACGM=use_AACGM, $
   USE_MAG_COORDS=use_MAG, $
   T1_ARR=t1_arr,T2_ARR=t2_arr, $
   DO_TIMEAVG_FLUXQUANTITIES=do_timeAvg_fluxQuantities, $
   ESPEC_DELTA_T=eSpec_delta_t, $
   ION_DELTA_T=ion_delta_t, $
   OUT_EFLUX_DATA=eFlux_data, $
   OUT_ENUMFLUX_DATA=eNumFlux_data, $
   OUT_IFLUX_DATA=iFlux_data, $
   OUT_INUMFLUX_DATA=iNumFlux_data, $
   INDICES__ESPEC=eSpec_i, $
   INDICES__ION=ion_i, $
   ESPEC__MLTS=eSpec__mlts, $
   ESPEC__ILATS=eSpec__ilats, $
   ESPEC__INFO=eSpec_info, $
   ION__MLTS=ion__mlts, $
   ION__ILATS=ion__ilats, $
   ION__INFO=ion_info, $
   ORBRANGE=orbRange, $
   ALTITUDERANGE=altitudeRange, $
   CHARERANGE=charERange, $
   CHARIERANGE=charIERange, $
   CHARE__NEWELL_THE_CUSP=charE__Newell_the_cusp, $
   SAMPLE_T_RESTRICTION=sample_t_restriction, $
   INCLUDE_32HZ=include_32Hz, $
   DISREGARD_SAMPLE_T=disregard_sample_t, $
   BOTH_HEMIS=both_hemis, $
   NORTH=north, $
   SOUTH=south, $
   HEMI=hemi, $
   HWMAUROVAL=HwMAurOval, $
   HWMKPIND=HwMKpInd, $
   MINMLT=minM, $
   MAXMLT=maxM, $
   BINM=binM, $
   MINILAT=minI, $
   MAXILAT=maxI, $
   BINILAT=binI, $
   EQUAL_AREA_BINNING=equal_area_binning, $
   DAYSIDE=dayside, $
   NIGHTSIDE=nightside, $
   MIMC_STRUCT=MIMC_struct, $
   ALFDB_PLOT_STRUCT=alfDB_plot_struct, $
   IMF_STRUCT=IMF_struct, $
   RESET_OMNI_INDS=reset_omni_inds, $
   RESTRICT_WITH_THESE_ESPEC_I=restrict_with_these_eSpec_i, $
   RESTRICT_WITH_THESE_ION_I=restrict_with_these_ion_i, $
   ;; GET_ESPEC_I_NOT_ION_I=get_eSpec_i, $
   RESET_GOOD_INDS=reset_good_inds, $
   DO_NOT_SET_DEFAULTS=do_not_set_defaults, $
   DONT_LOAD_IN_MEMORY=nonMem

  COMPILE_OPT idl2

  @common__newell_espec.pro
  @common__newell_ion_db.pro

  IF SIZE(plot_i,/TYPE) EQ 11 THEN BEGIN
     PRINT,'plot_i is a list!'
     plot_i_is_list = 1
  ENDIF ELSE BEGIN
     plot_i_is_list = 0
  ENDELSE

  IF KEYWORD_SET(alfDB_plot_struct.eNumFlPlots)                   OR $
     KEYWORD_SET(alfDB_plot_struct.ePlots)                        OR $ 
     KEYWORD_SET(alfDB_plot_struct.eSpec__newellPlot_probOccurrence) $
  THEN BEGIN

     LOAD_NEWELL_ESPEC_DB, $
        ;; eSpec, $
        ;; /DONT_LOAD_IN_MEMORY, $
        DONT_CONVERT_TO_STRICT_NEWELL=~KEYWORD_SET(alfDB_plot_struct.eSpec__Newell_2009_interp), $
        USE_2000KM_FILE=alfDB_plot_struct.eSpec__use_2000km_file ;, $
        ;; /DONT_PERFORM_CORRECTION

     eSpec_info = NEWELL__eSpec.info

     IF KEYWORD_SET(alfDB_plot_struct.do_timeAvg_fluxQuantities) THEN BEGIN
        eSpec_delta_t = GET_ESPEC_ION_DELTA_T(NEWELL__eSpec, $
                                              DBNAME='eSpec')

     ENDIF

     IF ~KEYWORD_SET(for_IMF_screening) THEN BEGIN ;If doing IMF stuff, GET_RESTRICTED_AND_INTERPED_DB_INDICES will handle this
        good_eSpec_i = GET_ESPEC_ION_DB_IND(NEWELL__eSpec,satellite,lun, $
                                            ;; DBFILE=dbfile, $
                                            ;; DBDIR=dbDir, $
                                            ORBRANGE=orbRange, $
                                            ALTITUDERANGE=altitudeRange, $
                                            CHARERANGE=charERange, $
                                            CHARE__NEWELL_THE_CUSP=charE__Newell_the_cusp, $
                                            ;; CHARIERANGE=charIERange, $
                                            BOTH_HEMIS=both_hemis, $
                                            NORTH=north, $
                                            SOUTH=south, $
                                            HEMI=hemi, $
                                            HWMAUROVAL=HwMAurOval, $
                                            HWMKPIND=HwMKpInd, $
                                            MINMLT=minM, $
                                            MAXMLT=maxM, $
                                            BINM=binM, $
                                            MINILAT=minI, $
                                            MAXILAT=maxI, $
                                            BINILAT=binI, $
                                            EQUAL_AREA_BINNING=equal_area_binning, $
                                            ;; DO_LSHELL=do_lshell, $
                                            ;; MINLSHELL=minL, $
                                            ;; MAXLSHELL=maxL, $
                                            ;; BINLSHELL=binL, $
                                            DAYSIDE=dayside, $
                                            NIGHTSIDE=nightside, $
                                            /GET_ESPEC_I_NOT_ION_I, $
                                            ;; GET_ION_I=get_ion_i, $
                                            RESET_GOOD_INDS=reset_good_inds, $
                                            DO_NOT_SET_DEFAULTS=do_not_set_defaults, $
                                            ;; /DONT_LOAD_IN_MEMORY, $
                                            DONT_LOAD_IN_MEMORY=nonMem, $
                                            ESPEC__NEWELL_2009_INTERP=alfDB_plot_struct.eSpec__Newell_2009_interp, $
                                            ESPEC__USE_2000KM_FILE=alfDB_plot_struct.eSpec__use_2000km_file, $
                                            ESPEC__REMOVE_OUTLIERS=alfDB_plot_struct.eSpec__remove_outliers);, $
                                            ;; PRINT_PARAM_SUMMARY)

        nBef_eSpec           = N_ELEMENTS(good_eSpec_i)
     ENDIF
  ENDIF

  IF KEYWORD_SET(alfDB_plot_struct.ionPlots) THEN BEGIN
     LOAD_NEWELL_ION_DB ;,ion,/DONT_LOAD_IN_MEMORY;,OUT_GOOD_I=basicClean_ion_i
     ion_info = NEWELL__ion.info ;;For later

     IF KEYWORD_SET(do_timeAvg_fluxQuantities) THEN BEGIN
        ion_delta_t = GET_ESPEC_ION_DELTA_T(NEWELL__ion, $
                                            DBNAME='ion')

        ;; ion_delta_t            = [FLOAT(ion.x[1:-1]-ion.x[0:-2]),1.0]

        ;; worst                  = WHERE(ion_delta_t LT 0,nWorst)
        ;; IF nWorst GT 0 THEN BEGIN
        ;;    PRINT,'The worst!'
        ;;    ;; STOP
        ;; ENDIF

        ;; fixme                  = WHERE(ion_delta_t GT 2,nFix)
        ;; IF nFix GT 0 THEN BEGIN
        ;;    ion_delta_t[fixme]  = 2.0
        ;; ENDIF
     ENDIF

     IF ~KEYWORD_SET(for_IMF_screening) THEN BEGIN ;If doing IMF stuff, GET_RESTRICTED_AND_INTERPED_DB_INDICES will handle this
        good_ion_i = GET_ESPEC_ION_DB_IND(ion,satellite,lun, $
                                          DBFILE=dbfile, $
                                          DBDIR=dbDir, $
                                          ORBRANGE=orbRange, $
                                          ALTITUDERANGE=altitudeRange, $
                                          ;; CHARERANGE=charERange, $
                                          CHARE__NEWELL_THE_CUSP=charE__Newell_the_cusp, $
                                          CHARIERANGE=charERange, $
                                          HEMI=hemi, $
                                          HWMAUROVAL=HwMAurOval, $
                                          HWMKPIND=HwMKpInd, $
                                          MINMLT=minM, $
                                          MAXMLT=maxM, $
                                          BINM=binM, $
                                          MINILAT=minI, $
                                          MAXILAT=maxI, $
                                          BINILAT=binI, $
                                          EQUAL_AREA_BINNING=equal_area_binning, $
                                          ;; DO_LSHELL=do_lshell, $
                                          ;; MINLSHELL=minL, $
                                          ;; MAXLSHELL=maxL, $
                                          ;; BINLSHELL=binL, $
                                          DAYSIDE=dayside, $
                                          NIGHTSIDE=nightside, $
                                          ;; GET_ESPEC_I_NOT_ION_I=get_eSpec_i, $
                                          /GET_ION_I, $
                                          RESET_GOOD_INDS=reset_good_inds, $
                                          DO_NOT_SET_DEFAULTS=do_not_set_defaults, $
                                          ;; /DONT_LOAD_IN_MEMORY, $
                                          DONT_LOAD_IN_MEMORY=nonMem);, $
                                          ;; /PRINT_PARAM_SUMMARY)

        nBef_ion             = N_ELEMENTS(good_ion_i)
     ENDIF
  ENDIF

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;Doing storm stuff?? Doing IMF stuff??
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  CASE 1 OF
     KEYWORD_SET(for_storms): BEGIN

        ;;Electrons?
        IF KEYWORD_SET(alfDB_plot_struct.eNumFlPlots) OR $
           KEYWORD_SET(alfDB_plot_struct.ePlots)         $
        THEN BEGIN
           todaysEspecFile   = TODAYS_NONSTORM_MAINPHASE_AND_RECOVERYPHASE_ESPEC_INDICES( $
                               SUFFIX=indFileSuff, $
                               DSTCUTOFF=dstCutoff, $
                               /MOST_RECENT)
           PRINT,'Getting ' + STRUPCASE(for_storms) + ' nonAlfven electron data ...'
           RESTORE,todaysEspecFile
           CASE 1 OF
              STRLOWCASE(for_storms) EQ 'nonstorm': BEGIN
                 eSpec_i     = CGSETINTERSECTION(good_eSpec_i,ns_i,COUNT=nAft_eSpec)
              END
              STRLOWCASE(for_storms) EQ 'mainphase': BEGIN
                 eSpec_i     = CGSETINTERSECTION(good_eSpec_i,mp_i,COUNT=nAft_eSpec)
              END
              STRLOWCASE(for_storms) EQ 'recoveryphase': BEGIN
                 eSpec_i     = CGSETINTERSECTION(good_eSpec_i,rp_i,COUNT=nAft_eSpec)
              END
           ENDCASE

           ;; PRINT,"Dropped " + STRCOMPRESS(nBef_eSpec-nAft_eSpec,/REMOVE_ALL) + " NaN- and INF-type Alfvén ion events..."
           PRINT,"Dropped " + STRCOMPRESS(nBef_eSpec-nAft_eSpec,/REMOVE_ALL) + " Alfvén eSpec events not associated with " + for_storms + " times ..."
           PRINT,FORMAT='(I0," remaining ...")',nAft_eSpec
        ENDIF

        ;;Now ions
        IF KEYWORD_SET(alfDB_plot_struct.ionPlots) THEN BEGIN
           todaysIonFile     = TODAYS_NONSTORM_MAINPHASE_AND_RECOVERYPHASE_ION_INDICES(SUFFIX=indFileSuff, $
                                                                                       DSTCUTOFF=dstCutoff, $
                                                                                       /MOST_RECENT)
           PRINT,'Getting ' + STRUPCASE(for_storms) + ' nonAlfven ion data ...'
           RESTORE,todaysIonFile
           CASE 1 OF
              STRLOWCASE(for_storms) EQ 'nonstorm': BEGIN
                 ion_i       = CGSETINTERSECTION(good_ion_i,ns_i,COUNT=nAft_ion)
              END
              STRLOWCASE(for_storms) EQ 'mainphase': BEGIN
                 ion_i       = CGSETINTERSECTION(good_ion_i,mp_i,COUNT=nAft_ion)
              END
              STRLOWCASE(for_storms) EQ 'recoveryphase': BEGIN
                 ion_i       = CGSETINTERSECTION(good_ion_i,rp_i,COUNT=nAft_ion)
              END
           ENDCASE

           ;; PRINT,"Dropped " + STRCOMPRESS(nBef_ion-nAft_ion,/REMOVE_ALL) + " NaN- and INF-type Alfvén ion events..."
           PRINT,"Dropped " + STRCOMPRESS(nBef_ion-nAft_ion,/REMOVE_ALL) + " Alfvén ion events not associated with " + for_storms + " times ..."
           PRINT,FORMAT='(I0," remaining ...")',nAft_ion

        ENDIF
     END
     KEYWORD_SET(for_IMF_screening): BEGIN
        ;;In this case, we're going to grab all the IMF-type inds a bit later
        IF KEYWORD_SET(alfDB_plot_struct.eNumFlPlots) OR KEYWORD_SET(alfDB_plot_struct.ePlots) $
        OR KEYWORD_SET(alfDB_plot_struct.eSpec__newellPlot_probOccurrence) THEN BEGIN
           eSpec_i_list      = GET_RESTRICTED_AND_INTERPED_DB_INDICES( $
                               NEWELL__eSpec,satellite,delay,LUN=lun, $
                               ;; DBTIMES=cdbTime, $
                               DBFILE=dbfile, $
                               HEMI=hemi, $
                               ORBRANGE=orbRange, $
                               ALTITUDERANGE=altitudeRange, $
                               CHARERANGE=charERange, $
                               ;; CHARIERANGE=charIERange, $ ;Only for non-Alfvén ions
                               CHARE__NEWELL_THE_CUSP=charE__Newell_the_cusp, $
                               SAMPLE_T_RESTRICTION=sample_t_restriction, $
                               INCLUDE_32HZ=include_32Hz, $
                               DISREGARD_SAMPLE_T=disregard_sample_t, $
                               MINMLT=minM, $
                               MAXMLT=maxM, $
                               BINM=binM, $
                               SHIFTM=shiftM, $
                               MINILAT=minI, $
                               MAXILAT=maxI, $
                               BINI=binI, $
                               EQUAL_AREA_BINNING=equal_area_binning, $
                               DO_LSHELL=do_lshell, $
                               MINLSHELL=minL, $
                               MAXLSHELL=maxL, $
                               BINL=binL, $
                               MIMC_STRUCT=MIMC_struct, $
                               ALFDB_PLOT_STRUCT=alfDB_plot_struct, $
                               IMF_STRUCT=IMF_struct, $
                               RESET_OMNI_INDS=reset_omni_inds, $
                               DO_NOT_SET_DEFAULTS=do_not_set_defaults, $
                               HWMAUROVAL=HwMAurOval, $
                               HWMKPIND=HwMKpInd, $
                               /FOR_ESPEC_OR_ION_DB, $
                               ESPEC__NEWELL_2009_INTERP=alfDB_plot_struct.eSpec__Newell_2009_interp, $
                               ESPEC__USE_2000KM_FILE=alfDB_plot_struct.eSpec__use_2000km_file, $
                               ESPEC__REMOVE_OUTLIERS=alfDB_plot_struct.eSpec__remove_outliers, $
                               RESTRICT_WITH_THESE_I=restrict_with_these_eSpec_i, $
                               RESET_GOOD_INDS=reset_good_inds, $
                               DONT_LOAD_IN_MEMORY=nonMem) ;; , $
           ;; NO_BURSTDATA=no_burstData)


        ENDIF
        IF KEYWORD_SET(alfDB_plot_struct.ionPlots) THEN BEGIN
           ion_i_list = GET_RESTRICTED_AND_INTERPED_DB_INDICES( $
                        NEWELL__ion,satellite,delay,LUN=lun, $
                        ;; DBTIMES=cdbTime, $
                        DBFILE=dbfile, $
                        HEMI=hemi, $
                        ORBRANGE=orbRange, $
                        ALTITUDERANGE=altitudeRange, $
                        ;; CHARERANGE=charERange, $
                        CHARIERANGE=charIERange, $ ;Only for non-Alfvén ions
                        CHARE__NEWELL_THE_CUSP=charE__Newell_the_cusp, $
                        SAMPLE_T_RESTRICTION=sample_t_restriction, $
                        INCLUDE_32HZ=include_32Hz, $
                        DISREGARD_SAMPLE_T=disregard_sample_t, $
                        MINMLT=minM, $
                        MAXMLT=maxM, $
                        BINM=binM, $
                        SHIFTM=shiftM, $
                        MINILAT=minI, $
                        MAXILAT=maxI, $
                        BINI=binI, $
                        EQUAL_AREA_BINNING=equal_area_binning, $
                        DO_LSHELL=do_lshell, $
                        MINLSHELL=minL, $
                        MAXLSHELL=maxL, $
                        BINL=binL, $
                        MIMC_STRUCT=MIMC_struct, $
                        ALFDB_PLOT_STRUCT=alfDB_plot_struct, $
                        IMF_STRUCT=IMF_struct, $
                        RESET_OMNI_INDS=reset_omni_inds, $
                        DO_NOT_SET_DEFAULTS=do_not_set_defaults, $
                        HWMAUROVAL=HwMAurOval, $
                        HWMKPIND=HwMKpInd, $
                        /FOR_ESPEC_OR_ION_DB, $
                        RESTRICT_WITH_THESE_I=restrict_with_these_ion_i, $
                        RESET_GOOD_INDS=reset_good_inds, $
                        DONT_LOAD_IN_MEMORY=nonMem) ;; , $



        ENDIF
     END
     ELSE: BEGIN

        ;;Electrons?
        IF KEYWORD_SET(alfDB_plot_struct.eNumFlPlots)                   OR $
           KEYWORD_SET(alfDB_plot_struct.ePlots)                        OR $
           KEYWORD_SET(alfDB_plot_struct.eSpec__newellPlot_probOccurrence) $
        THEN BEGIN
           GET_DATA_AVAILABILITY_FOR_ARRAY_OF_UTC_RANGES, $
              T1_ARR=t1_Arr, $
              T2_ARR=t2_Arr, $
              DBSTRUCT=NEWELL__eSpec, $
              DBTIMES=dbTimes, $
              /FOR_ESPEC_DB, $
              /DO_NOT_MAKE_ORB_INFO, $
              RESTRICT_W_THESEINDS=restrict, $
              OUT_INDS_LIST=eSpec_i, $
              UNIQ_ORBS_LIST=uniq_orbs_list,UNIQ_ORB_INDS_LIST=uniq_orb_inds_list, $
              INDS_ORBS_LIST=inds_orbs_list,TRANGES_ORBS_LIST=tranges_orbs_list,TSPANS_ORBS_LIST=tspans_orbs_list, $
              PRINT_DATA_AVAILABILITY=0, $
              GIVE_TIMESPLIT_INFO=give_timeSplit_info, $
              VERBOSE=verbose, $
              /LIST_TO_ARR, $
              LUN=logLun
        ENDIF

        ;;Now ions
        IF KEYWORD_SET(alfDB_plot_struct.ionPlots) THEN BEGIN
           GET_DATA_AVAILABILITY_FOR_ARRAY_OF_UTC_RANGES, $
              T1_ARR=t1_Arr, $
              T2_ARR=t2_Arr, $
              DBSTRUCT=ion, $
              DBTIMES=dbTimes, $
              /FOR_ESPEC_DB, $
              /DO_NOT_MAKE_ORB_INFO, $
              RESTRICT_W_THESEINDS=restrict, $
              OUT_INDS_LIST=ion_i, $
              UNIQ_ORBS_LIST=uniq_orbs_list,UNIQ_ORB_INDS_LIST=uniq_orb_inds_list, $
              INDS_ORBS_LIST=inds_orbs_list,TRANGES_ORBS_LIST=tranges_orbs_list,TSPANS_ORBS_LIST=tspans_orbs_list, $
              PRINT_DATA_AVAILABILITY=0, $
              GIVE_TIMESPLIT_INFO=give_timeSplit_info, $
              VERBOSE=verbose, $
              /LIST_TO_ARR, $
              LUN=logLun

        ENDIF
     END
  ENDCASE

  ;;Electrons
  IF ~KEYWORD_SET(alfDB_plot_struct.eSpec__all_fluxes) THEN BEGIN

     IF KEYWORD_SET(alfDB_plot_struct.eNumFlPlots) OR $
        KEYWORD_SET(alfDB_plot_struct.ePlots)      OR $
        KEYWORD_SET(alfDB_plot_struct.eSpec__newellPlot_probOccurrence) $
     THEN BEGIN
        LOAD_ALF_NEWELL_ESPEC_DB,!NULL,good_alf_eSpec_i,good_eSpec_assoc_w_alf_i, $
                                 DESPUN_ALF_DB=despun_alf_db, $
                                 /DONT_LOAD_IN_MEMORY

        IF KEYWORD_SET(for_IMF_screening) THEN BEGIN
           IF ~plot_i_is_list THEN BEGIN
              PRINT,"Wait! Why isn't plot_i a list as well?!?"
              STOP
           ENDIF

           FOR jj=0,N_ELEMENTS(eSpec_i_list)-1 DO BEGIN
              eSpec_i              = eSpec_i_list[jj]
              tmp_plot_i           = plot_i[jj]

              nBef_eSpec           = N_ELEMENTS(eSpec_i)

              IF KEYWORD_SET(alfDB_plot_struct.eSpec__junk_alfven_candidates) THEN BEGIN
                 PRINT,"Even junking electron measurements associated with Alfvén wave CANDIDATES!"
                 eSpec_i           = CGSETDIFFERENCE(eSpec_i,good_eSpec_assoc_w_alf_i,COUNT=nAft_eSpec)
              ENDIF ELSE BEGIN
                 tmp_alf_eSpec_i   = CGSETINTERSECTION(tmp_plot_i,good_alf_eSpec_i,INDICES_B=eSpec_deleteable_ii)
                 eSpec_i           = CGSETDIFFERENCE(eSpec_i,good_eSpec_assoc_w_alf_i[eSpec_deleteable_ii],COUNT=nAft_eSpec)
              ENDELSE

              PRINT,"Dropped " + STRCOMPRESS(nBef_eSpec-nAft_eSpec,/REMOVE_ALL) + " Alfvén electron events..."
              PRINT,FORMAT='(I0," remaining ...")',nAft_eSpec

              eSpec_i_list[jj]     = eSpec_i
           ENDFOR
        ENDIF ELSE BEGIN

           nBef_eSpec           = N_ELEMENTS(eSpec_i)

           IF KEYWORD_SET(alfDB_plot_struct.eSpec__junk_alfven_candidates) THEN BEGIN
              PRINT,"Even junking electron measurements associated with Alfvén wave CANDIDATES!"
              eSpec_i           = CGSETDIFFERENCE(eSpec_i,good_eSpec_assoc_w_alf_i,COUNT=nAft_eSpec)
           ENDIF ELSE BEGIN
              tmp_alf_eSpec_i   = CGSETINTERSECTION(plot_i,good_alf_eSpec_i,INDICES_B=eSpec_deleteable_ii)
              eSpec_i           = CGSETDIFFERENCE(eSpec_i,good_eSpec_assoc_w_alf_i[eSpec_deleteable_ii],COUNT=nAft_eSpec)
           ENDELSE

           PRINT,"Dropped " + STRCOMPRESS(nBef_eSpec-nAft_eSpec,/REMOVE_ALL) + " Alfvén electron events..."
           PRINT,FORMAT='(I0," remaining ...")',nAft_eSpec

        ENDELSE
     ENDIF

     IF KEYWORD_SET(alfDB_plot_struct.ionPlots) THEN BEGIN
        LOAD_ALF_NEWELL_ION_DB,good_alf_ion_i,good_iSpec_assoc_w_alf_i, $
                               DESPUN_ALF_DB=despun_alf_db, $
                               /DONT_LOAD_IN_MEMORY

        nBef_ion             = N_ELEMENTS(ion_i)

        IF KEYWORD_SET(for_IMF_screening) THEN BEGIN
           IF ~plot_i_is_list THEN BEGIN
              PRINT,"Wait! Why isn't plot_i a list as well?!?"
              STOP
           ENDIF

           FOR jj=0,N_ELEMENTS(ion_i_list)-1 DO BEGIN
              ion_i              = ion_i_list[jj]
              tmp_plot_i           = plot_i[jj]

              nBef_ion           = N_ELEMENTS(ion_i)

              IF KEYWORD_SET(alfDB_plot_struct.eSpec__junk_alfven_candidates) THEN BEGIN
                 PRINT,"Even junking electron measurements associated with Alfvén wave CANDIDATES!"
                 ion_i           = CGSETDIFFERENCE(ion_i,good_iSpec_assoc_w_alf_i,COUNT=nAft_ion)
              ENDIF ELSE BEGIN
                 tmp_alf_ion_i   = CGSETINTERSECTION(tmp_plot_i,good_alf_ion_i,INDICES_B=ion_deleteable_ii)
                 ion_i           = CGSETDIFFERENCE(ion_i,good_iSpec_assoc_w_alf_i[ion_deleteable_ii],COUNT=nAft_ion)
              ENDELSE

              PRINT,"Dropped " + STRCOMPRESS(nBef_ion-nAft_ion,/REMOVE_ALL) + " Alfvén electron events..."
              PRINT,FORMAT='(I0," remaining ...")',nAft_ion

              ion_i_list[jj]     = ion_i
           ENDFOR
        ENDIF ELSE BEGIN

        IF KEYWORD_SET(alfDB_plot_struct.eSpec__junk_alfven_candidates) THEN BEGIN
           PRINT,"Even junking ion measurements associated with Alfvén wave CANDIDATES!"
           ion_i             = CGSETDIFFERENCE(ion_i,good_iSpec_assoc_w_alf_i,COUNT=nAft_ion)
        ENDIF ELSE BEGIN
           tmp_alf_ion_i     = CGSETINTERSECTION(plot_i,good_alf_ion_i,INDICES_B=ion_deleteable_ii)
           ion_i             = CGSETDIFFERENCE(ion_i,good_iSpec_assoc_w_alf_i[ion_deleteable_ii],COUNT=nAft_ion)
        ENDELSE

        PRINT,"Dropped " + STRCOMPRESS(nBef_ion-nAft_ion,/REMOVE_ALL) + " Alfvén ion events..."
        PRINT,FORMAT='(I0," remaining ...")',nAft_ion
     ENDELSE

     ENDIF
  ENDIF

  ;;Now get the data
  IF KEYWORD_SET(alfDB_plot_struct.ePlots) OR KEYWORD_SET(alfDB_plot_struct.eSpec__newellPlot_probOccurrence) THEN BEGIN
     eFlux_data              = 1
  ENDIF

  IF KEYWORD_SET(alfDB_plot_struct.eNumFlPlots) THEN BEGIN
     eNumFlux_data           = 1
  ENDIF

  IF KEYWORD_SET(alfDB_plot_struct.ionPlots) THEN BEGIN
     CASE 1 OF
        STRUPCASE(alfDB_plot_struct.iFluxPlotType) EQ 'ENERGY': BEGIN
           iFlux_data        = 1
        END
        ELSE: BEGIN
           iNumFlux_data     = 1
        END
     ENDCASE
  ENDIF

  ;;Last, get the MLTs and ILATs
  ;;Electrons
  IF KEYWORD_SET(alfDB_plot_struct.eNumFlPlots)                   OR $
     KEYWORD_SET(alfDB_plot_struct.ePlots)                        OR $
     KEYWORD_SET(alfDB_plot_struct.eSpec__newellPlot_probOccurrence) $
  THEN BEGIN
     eSpec__mlts             = 1
     eSpec__ilats            = 1
  ENDIF

  ;;Ions
  IF KEYWORD_SET(alfDB_plot_struct.ionPlots) THEN BEGIN
     ion__mlts               = 1
     ion__ilats              = 1
  ENDIF

  IF KEYWORD_SET(for_IMF_screening) THEN BEGIN
     IF KEYWORD_SET(espec_i_list) THEN BEGIN
        eSpec_i              = TEMPORARY(eSpec_i_list)
     ENDIF
     IF KEYWORD_SET(ion_i_list) THEN BEGIN
        ion_i                = TEMPORARY(ion_i_list)
     ENDIF
  ENDIF

END