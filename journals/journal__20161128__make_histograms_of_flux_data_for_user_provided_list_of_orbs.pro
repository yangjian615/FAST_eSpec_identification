;;11/25/16
PRO JOURNAL__20161128__MAKE_HISTOGRAMS_OF_FLUX_DATA_FOR_USER_PROVIDED_LIST_OF_ORBS,orbs

  COMPILE_OPT IDL2

  @common__newell_espec.pro

  ;;eSpec DB options
  use_2000km_file = 0
  force_load_DB   = 0

  ;;Plot options
  output_fa_crossing  = 1
  skip_histos         = 1

  ;;txt output
  output_txtFile      = 0

  ;;Histo plot options (if ~skip_histos)
  eFlux               = 1
  eNumFlux            = 0
  charE               = 0

  log_plots           = 1
  log_stats           = 1
  zoomed_histoXRange  = 1
  zoomed_histoYRange  = 1

  save_plots          = 1

  suff__plotDir         = '/orbs_with_userness'

  ;; show_plots          = 0 ;Not really practical for our purposes here

  ;;gjør det en del 
  IF N_ELEMENTS(NEWELL__eSpec) EQ 0 OR KEYWORD_SET(force_load_DB) THEN BEGIN
     LOAD_NEWELL_ESPEC_DB, $
        !NULL, $
        NEWELLDBDIR=NewellDBDir, $
        USE_2000KM_FILE=use_2000km_file, $
        FORCE_LOAD_DB=force_load_DB
  ENDIF

  plotSuff        = STRING(FORMAT='(A0,"--",A0,"_user-provided_",A0)', $
                    GET_NEWELL_DB_STRING(NEWELL__eSpec),GET_TODAY_STRING(/DO_YYYYMMDD_FMT))

  SET_PLOT_DIR,plotDir, $
               /FOR_ESPEC_DB, $
               /ADD_TODAY, $
               ADD_SUFF=suff__plotDir

  IF KEYWORD_SET(output_txtFile) THEN BEGIN
     PRINT,"Making txtFile: " + plotSuff + '--orb_list.txt'
     SET_TXTOUTPUT_DIR,txtOutputDir, $
                  /FOR_ESPEC_DB, $
                  /ADD_TODAY, $
                  ADD_SUFF=suff__plotDir
     
  ENDIF
  ;;How many unique orbits here?
  ;; uniq_ii = UNIQ(NEWELL__eSpec.orbit[wild_inds],SORT(NEWELL__eSpec.orbit[wild_inds]))
  ;; orbs    = NEWELL__eSpec.orbit[wild_inds[uniq_ii]]

  PRINT,"Got a list of " + STRCOMPRESS(N_ELEMENTS(orbs),/REMOVE_ALL) + $
        " orbs from user ..."

  ;;NOW PLOTSSSSSSS
  FOR k=0,N_ELEMENTS(orbs)-1 DO BEGIN
     curOrb = orbs[k]
     orbStr = STRCOMPRESS(curOrb,/REMOVE_ALL)

     opener = "ORB " + orbStr + ": "

     IF ~KEYWORD_SET(skip_histos) THEN BEGIN
        user_inds = WHERE(NEWELL__eSpec.orbit EQ curOrb,nOrb)
        
        IF nOrb EQ 0 THEN BEGIN
           PRINT,opener + "No inds!! Skipping ..."
           CONTINUE
        ENDIF

        PRINT,opener + STRCOMPRESS(nOrb,/REMOVE_ALL) + ' inds'
        
        user_plotSuff = plotSuff + '--orb_' + orbStr


        JOURNAL__20161122__SO_HOW_DO_WE_CLEAN_YOU_ESPEC_DB, $
           ENUMFLUX=je, $
           EFLUX=eFlux, $
           CHARE=charE, $
           POS_ONLY=pos_only, $
           NEG_ONLY=neg_only, $
           LOG_PLOTS=log_plots, $
           LOG_STATS=log_stats, $
           SHOW_PLOTS=show_plots, $
           WINDOW_INDEX=safeWinInd, $
           SAVE_PLOTS=save_plots, $
           ZOOMED_HISTOXRANGE=zoomed_histoXRange, $
           ZOOMED_HISTOYRANGE=zoomed_histoYRange, $
           ;; NORMALIZE_YRANGE=normalize_yRange, $
           OUT_ESTATS=eStats, $
           USER_INDS=user_inds, $
           USER_PLOTSUFF=user_plotSuff, $
           PLOTDIR=plotDir, $
           SUFF__PLOTDIR=suff__plotDir, $
           CUSTOM_TITLE='Orbit ' + orbStr
     ENDIF

     IF KEYWORD_SET(output_fa_crossing) THEN BEGIN
        PLOT_FA_CROSSING,ORBIT=curOrb, $
                         /MAGPOLE, $
                         /SSCZONE, $
                         POST=plotDir + 'FA_crossing--orb_' + orbStr
        
        EPS2PDF,plotDir + 'FA_crossing--orb_' + orbStr,/PS
     ENDIF

     IF KEYWORD_SET(output_txtFile) THEN BEGIN
        SPAWN,'echo ' + orbStr + ' >> ' + txtOutputDir + plotSuff + '--orb_list.txt'
     ENDIF

  ENDFOR
END

