;2016/06/11
FUNCTION BARPLOT_ESPEC_TYPES_VS_ALT,eSpec, $
                                    BINSIZE=binSize, $
                                    MINALT=minLoc, $
                                    MAXALT=maxLoc, $
                                    YLOG=yLog, $
                                    YRANGE=yRange, $
                                    TITLE=title, $
                                    ;; ONLY_NEWELL=only_newell, $
                                    ;; NEWELL_ESPEC_INTERPRETED=eSpec_interpreted, $
                                    CURRENT=window, $
                                    SAVEPLOT=savePlot, $
                                    SPNAME=sPName, $
                                    PLOTDIR=plotDir, $
                                    CLOSE_WINDOW_AFTER_SAVE=close_window_after_save
  
  COMPILE_OPT idl2


  IF N_ELEMENTS(binSize) EQ 0 THEN binSize      = 65  ;km
  IF N_ELEMENTS(minLoc)  EQ 0 THEN minLoc       = 341  ;km
  IF N_ELEMENTS(maxLoc)  EQ 0 THEN maxLoc       = 4176 ;km

  broad    = WHERE(eSpec.broad EQ 1 OR eSpec.broad EQ 2,nB)
  mono     = WHERE(eSpec.mono EQ 1 OR eSpec.mono EQ 2,nM)
  diffuse  = WHERE(eSpec.diffuse EQ 1,nD)

  broadAltHist    = HISTOGRAM(eSpec.alt[broad]   ,BINSIZE=binsize,MIN=minLoc,MAX=maxLoc,/L64,LOCATIONS=bLoc)
  monoAltHist     = HISTOGRAM(eSpec.alt[mono]    ,BINSIZE=binsize,MIN=minLoc,MAX=maxLoc,/L64,LOCATIONS=mLoc)
  diffuseAltHist  = HISTOGRAM(eSpec.alt[diffuse] ,BINSIZE=binsize,MIN=minLoc,MAX=maxLoc,/L64,LOCATIONS=dLoc)

  denomHist       = broadAltHist + monoAltHist + diffuseAltHist
  goodLoc         = WHERE(denomHist GT 0,nGood,COMPLEMENT=badLoc)
  denomHist[WHERE(denomHist EQ 0)] = 1
  goodLoc         = LINDGEN(N_ELEMENTS(denomHist))
  denomHist       = DOUBLE(denomHist)

  IF ~ARRAY_EQUAL(bLoc,mLoc) OR ~ARRAY_EQUAL(bLoc,dLoc) OR ~ARRAY_EQUAL(mLoc,dLoc) THEN BEGIN
     PRINT,"Histos are unequal; you're about to have bogusness."
     STOP
  ENDIF

  ;; histList        = LIST(broadAltHist[goodLoc],monoAltHist[goodLoc],diffuseAltHist[goodLoc],denomHist)
  histList        = LIST(diffuseAltHist[goodLoc]/denomHist[goodLoc], $
                         broadAltHist[goodLoc]/denomHist[goodLoc], $
                         monoAltHist[goodLoc]/denomHist[goodLoc])

  ;;Now plots
  ;;Window?
  IF ~ISA(window) THEN BEGIN
     window          = WINDOW(DIMENSIONS=[800,600])
  ENDIF
  
  nPlots             = 3
  plotArr         = MAKE_ARRAY(3,/OBJ)
  plotMargin      = [0.15, 0.25, 0.15, 0.15]

  ;; plotNames       = ['Broadband','Monoenergetic','Diffuse']
  plotNames       = ['Diffuse','Broadband','Monoenergetic']
  colorArr        = ['Green','Red','Blue']
  lsArr           = ['-','-','-']

  xRange          = [000,4500]
  yRange          = KEYWORD_SET(yRange) ? yRange : [0.7,1.03]

  xTickValues     = [500,1000,1500,2000,2500,3000,3500,4000,4500]
  xTickName       = STRCOMPRESS(xTickValues,/REMOVE_ALL)

  x_values        = bLoc[goodLoc]

  FOR iPlot=0,nPlots-1 DO BEGIN
     CASE iPlot OF
        0: BEGIN
           y_values      = (histList[0])
           bottom_values = !NULL
        END
        1: BEGIN
           y_values      = (histList[1]+histList[0])
           bottom_values = (histList[0])
        END
        2: BEGIN
           y_values      = (histList[2]+histList[1]+histList[0])
           bottom_values = (histList[0] + histList[1])
        END
     ENDCASE

     ;; PRINT,'Doing' + plotNames[i] + '...'

     plotArr[iPlot]      = BARPLOT(x_values, $
                                   y_values, $
                                   XRANGE=xRange, $
                                   YRANGE=yRange, $
                                   BOTTOM_VALUES=bottom_values, $
                                   NAME=plotNames[iPlot], $
                                   ;; XMAJOR=5, $
                                   XMINOR=0, $
                                   XTICKVALUES=xTickValues, $
                                   XTICKNAME=xTickName, $
                                   ;; INDEX=indexArr[0], $
                                   ;; NBARS=nBars, $
                                   FILL_COLOR=colorArr[iPlot], $
                                   ;; BOTTOM_COLOR=bottom_color, $
                                   /OVERPLOT, $
                                   CURRENT=window)
     
     
  ENDFOR

  legend          = LEGEND(TARGET=plotArr[*], $
                           /NORMAL, $
                           POSITION=[0.8,0.4])


  ;; Add a title.
  plotArr[0].TITLE = "Mono, broad, and diffuse e!U-!N statistics for eSpec events" + (KEYWORD_SET(title) ? "!C" + title : '')
  
  IF KEYWORD_SET(savePlot) THEN BEGIN

     IF KEYWORD_SET(spName) THEN outName = spName ELSE BEGIN
        outName = GET_TODAY_STRING() + '--Newell-based_stats_vs_alt.png'
     ENDELSE
     IF N_ELEMENTS(plotDir) GT 0 THEN BEGIN
        pDir = plotDir
     ENDIF ELSE BEGIN
        SET_PLOT_DIR,pDir,/ADD_TODAY,/FOR_ALFVENDB
     ENDELSE

     PRINT,'Saving to ' + spName + '...'
     window.save,pDir+spName

     IF KEYWORD_SET(close_window_after_save) THEN BEGIN
        window.close
        window      = !NULL
     ENDIF

  ENDIF


  RETURN,plotArr

END