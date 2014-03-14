; docformat = 'rst'
;
; NAME:
;       TEST_WIDGET_TREE
;
; PURPOSE:
;+
;       The purpose of this program is to test different features of the tree widget::
;           a) If the widget tree structure can be generated by a utility program outside
;              of the program that realizes the widget.
;           b) How to change the tree structure after the widget is already realized.
;
;       Answers::
;           a) Yes, it can.
;           b) Destroy the widgets that are no longer wanted and fill in the tree
;              like normal.
;
; :Categories:
;
;       Test Program
;
; :Author:
;   Matthew Argall::
;       University of New Hampshire
;       Morse Hall, Room 113
;       8 College Rd.
;       Durham, NH, 03824
;       matthew.argall@wildcats.unh.edu
;       
; :History:
;   Modification History::
;       03/05/2013  -   Written by Matthew Argall
;-
;*****************************************************************************************

;+
; The purpose of this program is to handle events not handled by other specific event
; handling routines.
;
; :Private:
;-
pro test_widget_tree_event, event
    compile_opt idl2
    on_error, 2

    ;Do nothing so far
end


;+
; The purpose of this program is to handle events generated by the OK button.
;
; :Private:
;-
pro test_widget_tree_ok, event
    compile_opt idl2, hidden
    
    ;destroy the widget.
    widget_control, event.top, /destroy
end


;+
; The purpose of this program is to handle events created by the CANCEL button.
;
; :Private:
;-
pro test_widget_tree_cancel, event
    compile_opt idl2, hidden
    on_error, 2
    
    ;destroy the widget.
    widget_control, event.top, /destroy
end


;+
; The purpose of this program is to clean up after the widget is destroyed.
;
; :Private:
;-
pro test_widget_tree_cleanup, event
    compile_opt idl2, hidden
    
    ;Catch any errors when cleaning up
    catch, the_error
    if the_error ne 0 then begin
        catch, /CANCEL
        void = cgErrorMsg()
        return
    endif
    
    ;free the state variable pointer
    widget_control, event.top, GET_UVALUE=pstate
    ptr_free, (*pstate).ids, (*pstate).parents, (*pstate).unames
    ptr_free, pstate
end

;+
; The purpose of this program is to update the widget tree when the "Update" button
; is pushed.
;
; :Private:
;-
pro test_widget_tree_update, event
    compile_opt idl2, hidden
    
    ;Get the state variable
    widget_control, event.top, GET_UVALUE=pstate
    
    ;add more leaves if the update button was pushed
    if event.select eq 0 then nleaves=3 else nleaves=4
    
;---------------------------------------------------------------------
;Delete the Previous Tree Structure //////////////////////////////////
;--------------------------------------------------------------------- 
    ;Find all of the widget ids whos parent is the treeRoot.
    rootID = widget_info(event.top, FIND_BY_UNAME='treeRoot')
    primaries = where(*(*pstate).parents eq rootID, count)
    if count ne 0 then begin
        ;destroy them
        for i = 0, n_elements(primaries)-1 $
            do widget_control, (*(*pstate).ids)[primaries[i]], /destroy
    endif
    
;---------------------------------------------------------------------
;Create the New Tree Structure ///////////////////////////////////////
;--------------------------------------------------------------------- 
    
    ;Allocate memory for the ID arrays
    ids = lonarr(nleaves+1)
    parents = lonarr(nleaves+1)
    ids[0] = rootID
    parents[0] = event.top
    count = 1

    ;Step through all of the leaves.
    for i = 0, nleaves-1 do begin
        ;If i=2...
        if i eq 2 then begin
            ;Create a new branch
            ids[count] = widget_tree(rootID, VALUE='branch 1-0', /FOLDER, /EXPANDED)
            parents[count] = rootID
            count += 1
            
            ;Expand the IDs and PARENTS arrays
            ids = [ids, lonarr(nleaves)]
            parents = [parents, lonarr(nleaves)]
            
            ;Create leaves on the new branch
            for j = 0, nleaves-1 do begin
                ids[count] = widget_tree(ids[count-1-j], VALUE='leaf 1-' + string(j, format='(i0)'))
                parents[count] = ids[count-1-j]
                count += 1
            endfor

        ;Otherwise,...
        endif else begin
            ;Create a leaf on the trunk
            ids[count] = widget_tree(rootID, VALUE='leaf 0-' + string(i, format='(i0)'))
            parents[count] = rootID
            count += 1
        endelse
    endfor
    
    ;Update the state variable
    *(*pstate).ids = ids
    *(*pstate).parents = parents
end


pro test_widget_tree
    compile_opt idl2

;---------------------------------------------------------------------
;Make the Top Level Base /////////////////////////////////////////////
;---------------------------------------------------------------------
    no_block = 1
    tlb = widget_base(TITLE='Test Widget Tree', /COLUMN, XOFFSET=200, YOFFSET=100, $
                      UNAME='tlb', /BASE_ALIGN_CENTER)

;---------------------------------------------------------------------
;Create Tree Root ////////////////////////////////////////////////////
;---------------------------------------------------------------------
    ;Create base to hold each of the buttons. Make each button individually. CW_BGROUP() is
    ;not used because I want an event handler for each button.
    treeBase = widget_base(tlb, COL=2)
    treeRoot = widget_tree(treeBase, /FOLDER, /EXPANDED, /MULTIPLE, VALUE='Root', $
                           XSIZE=varwidth, UNAME='treeRoot')

    ;Set the user value for the top level base.
    state = {ids: ptr_new([tlb, treeBase, treeRoot]), $
             parents: ptr_new([tlb])}
    widget_control, tlb, SET_UVALUE=ptr_new(state, /no_copy)
    
    ;Simulate a push-button event to generate the tree structure for the first time.
    test_widget_tree_update, {widget_button, ID:tlb, TOP:tlb, HANDLER: 0L, SELECT: 0}
    
    ;Create a button to update the widget tree.
    updateBase = widget_base(treeBase, /NONEXCLUSIVE, /COL)
    updateButton = widget_button(updateBase, VALUE='Update', UNAME='update', $
                                 EVENT_PRO='test_widget_tree_update')

;---------------------------------------------------------------------
;Create OK and Cancel Buttons ////////////////////////////////////////
;---------------------------------------------------------------------
    okBase = widget_base(tlb, /ROW)
    okButton = widget_button(okBase, /ALIGN_CENTER, UNAME='ok', VALUE='OK', $
                             EVENT_PRO='test_widget_tree_ok')
    cancelButton = widget_button(okBase, /ALIGN_CENTER, UNAME='cancel', VALUE='Cancel', $
                                 EVENT_PRO='test_widget_tree_cancel')
    
;---------------------------------------------------------------------
;Create the State Variable, Realize, and Start Event Handling ////////
;---------------------------------------------------------------------

	;Realize the top-level base
	widget_control, tlb, /REALIZE
	
	;Call XMANAGER
	xmanager, 'test_widget_tree_gui', tlb, cleanup='test_widget_tree_cleanup', $
	          event_handler='test_widget_tree_event', NO_BLOCK=no_block
end