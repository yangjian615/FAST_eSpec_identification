PRO JOURNAL__20160613__BARPLOTS_FROM_20160607_ESPEC_DB

  inDir    = '/SPENCEdata/Research/database/FAST/dartdb/electron_Newell_db/fully_parsed/'
  ;;The file with failcodes
  inFile   = 'eSpec_20160607_db--PARSED--Orbs_500-16361.sav' ;;This file does not need to be cleaned

  RESTORE,inDir+inFile
  CONVERT_ESPEC_TO_STRICT_NEWELL_INTERPRETATION,eSpec,eSpec,/HUGE_STRUCTURE

  SET_PLOT_DIR,/FOR_ESPECDB,/ADD_TODAY

  ;;By altitude
  bpSaveName      = GET_TODAY_STRING(/DO_YYYYMMDD_FMT)+'--barplot_eSpec_types_vs_altitude--20160607_eSpec_DB.png'
  plots           = BARPLOT_ESPEC_TYPES_VS_ALT(eSpec, $
                                               PLOTDIR=plotDir, $
                                               /SAVEPLOT, $
                                               SPNAME=bpSaveName)

  bpSaveName      = GET_TODAY_STRING(/DO_YYYYMMDD_FMT)+'--barplot_eSpec_types_vs_MLT--20160607_eSpec_DB.png'
  plots           = BARPLOT_ESPEC_TYPES_VS_MLT(eSpec, $
                                               PLOTDIR=plotDir, $
                                               /SAVEPLOT, $
                                               SPNAME=bpSaveName)

END