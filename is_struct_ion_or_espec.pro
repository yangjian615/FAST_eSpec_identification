PRO IS_STRUCT_ION_OR_ESPEC,dbStruct,is_ion,LUN=lun

  COMPILE_OPT idl2

  IF N_ELEMENTS(lun) EQ 0 THEN lun = -1   ;stdout

  IF TAG_EXIST(dbStruct,'ji') THEN BEGIN
     PRINTF,lun,"This is a FAST ion database..."
     is_ion = 1
  ENDIF ELSE BEGIN
     PRINTF,lun,"This is a FAST eSpec database..."
     is_ion = 0
  ENDELSE

END