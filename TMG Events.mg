https://community.sap.com/t5/application-development-blog-posts/table-maintenance-generator-events-create-update-and-delete/ba-p/13506337
link for delete as above

TABLE NAME : ZCHANGE_LOCK
IN ATHER SANDBOX.

UPDATE : 01
CREATE : 05.

FORM create .
  
 IF zeb_events-matnr IS NOT INITIAL.
  
  SELECT SINGLE
    Maktx
    FROM makt
    INTO @zeb_events-maktx
    WHERE matnr EQ @zeb_events-matnr
    AND spras EQ 'E'.
    
 ENDIF.
 
ENDFORM.



FORM update.
** -- Data Declarations
DATA: lv_timestamp TYPE tzonref-tstamps.
*-- Time stamp conversion
CALL FUNCTION 'ABI_TIMESTAMP_CONVERT_INTO'
EXPORTING
iv_date = sy-datum
iv_time = sy-uzeit
IMPORTING
ev_timestamp = lv_timestamp
EXCEPTIONS
conversion_error = 1
OTHERS = 2.
FIELD-SYMBOLS: <fs_field> TYPE any .
LOOP AT total.
CHECK <action> EQ aendern.
** -- Updated By
ASSIGN COMPONENT 'UPDTD_BY' OF STRUCTURE <vim_total_struc> TO <fs_field>.
IF sy-subrc EQ 0.
<fs_field> = sy-uname.
ENDIF.
** -- Updated On
ASSIGN COMPONENT 'UPDTD_ON' OF STRUCTURE <vim_total_struc> TO <fs_field>.
IF sy-subrc EQ 0.
<fs_field> = lv_timestamp.
ENDIF.
READ TABLE extract WITH KEY <vim_xtotal_key>.
IF sy-subrc EQ 0.
extract = total.
MODIFY extract INDEX sy-tabix.
ENDIF.
IF total IS NOT INITIAL.
MODIFY total.
ENDIF.
ENDLOOP.
ENDFORM.


FORM create.
** -- Data Declarations
DATA: lv_timestamp TYPE tzonref-tstamps.
*-- Time stamp conversion
CALL FUNCTION 'ABI_TIMESTAMP_CONVERT_INTO'
EXPORTING
iv_date = sy-datum
iv_time = sy-uzeit
IMPORTING
ev_timestamp = lv_timestamp
EXCEPTIONS
conversion_error = 1
OTHERS = 2.
** -- Created On & Created By
ztemp_dtls-crtd_by = sy-uname.
ztemp_dtls-crtd_on = lv_timestamp.
ENDFORM.

FORM delete .

  DATA:  lt_delete TYPE  TABLE OF zdeleted_data ,
        ls_delete TYPE zdeleted_data.


    SELECT *
    FROM zchange_lock
    INTO TABLE @DATA(lt_event) .
    SORT lt_event BY emp_id.
loop at  lt_event INTO DATA(ls_data) . "INDEX index.

ls_delete-emp_id = ls_data-emp_id.
ls_delete-emp_name = ls_data-emp_name.
ls_delete-emp_contact = ls_data-emp_contact.
ls_delete-deleted_by = sy-uname.
ls_delete-deleted_on = sy-datum.
APPEND ls_delete TO lt_delete.
CLEar: ls_delete.
ENDLOOP.
INSERT zdeleted_data FROM TABLE lt_delete ACCEPTING DUPLICATE KEYS.

ENDFORM.
