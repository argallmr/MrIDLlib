; docformat = 'rst'
;
; NAME:
;       TYPE_TO_FORMAT_CODE
;
;*****************************************************************************************
;   Copyright (c) 2013, Matthew Argall                                                   ;
;   All rights reserved.                                                                 ;
;                                                                                        ;
;   Redistribution and use in source and binary forms, with or without modification,     ;
;   are permitted provided that the following conditions are met:                        ;
;                                                                                        ;
;       * Redistributions of source code must retain the above copyright notice,         ;
;         this list of conditions and the following disclaimer.                          ;
;       * Redistributions in binary form must reproduce the above copyright notice,      ;
;         this list of conditions and the following disclaimer in the documentation      ;
;         and/or other materials provided with the distribution.                         ;
;       * Neither the name of the <ORGANIZATION> nor the names of its contributors may   ;
;         be used to endorse or promote products derived from this software without      ;
;         specific prior written permission.                                             ;
;                                                                                        ;
;   THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY  ;
;   EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES ;
;   OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT  ;
;   SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,       ;
;   INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED ;
;   TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR   ;
;   BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN     ;
;   CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN   ;
;   ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH  ;
;   DAMAGE.                                                                              ;
;*****************************************************************************************
;
; PURPOSE:
;+
;       The purpose of this program is to convert an IDL type code (as returned by the
;       `SIZE` function) and convert it to the corresponding format code character.
;
; :Categories:
;
;       Type Conversion
;
; :Examples:
;
;       See the example program at the end of this file::
;
;           IDL> .r type_to_format_code
;
; :Params:
;
;       TYPE_CODE:              in, required, type=int
;                               The IDL type code of a variable, returned by
;                                   `SIZE(x, /TYPE)`
;
; :Returns:
;
;       FORMAT_CODE:            The string format code corresponding to `TYPE_CODE`
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
;       03/01/2013  -   Written by Matthew Argall
;-
function type_to_format_code, type_code
    compile_opt idl2
    on_error, 2
    
    ;Convert the type code to a format code character.
    case type_code of
        0: message, 'Type code is undefined.'
        1: data_type = 'i'      ;byte
        2: data_type = 'i'      ;integer
        3: data_type = 'i'      ;long
        4: data_type = 'f'      ;float
        5: data_type = 'd'      ;double
        6: data_type = 'f'      ;complex
        7: data_type = 'a'      ;character
        9: data_type = 'd'      ;double complex
        12: data_type = 'i'     ;uint
        13: data_type = 'i'     ;ulong
        14: data_type = 'i'     ;long64
        15: data_type = 'i'     ;ulong64
        else: message, 'Type code ' + strtrim(string(type_code), 2) + $
                       ' does not have a corresponding format code.'
    endcase
    
    return, data_type
end


;-----------------------------------------------------
;Main Level Example Program \\\\\\\\\\\\\\\\\\\\\\\\\\
;-----------------------------------------------------
;Create variables of different types
int = 5
str = 'string'
dbl = 1D

;Get their type codes
int_type = size(int, /TYPE)
str_type = size(str, /TYPE)
dbl_type = size(dbl, /TYPE)

;Convert to format codes
int_frmt = type_to_format_code(int_type)
str_frmt = type_to_format_code(str_type)
dbl_frmt = type_to_format_code(dbl_type)

;Print the results
print, format='(%"Type code: %i      Format code: %s")', int_type, int_frmt
print, format='(%"Type code: %i      Format code: %s")', str_type, str_frmt
print, format='(%"Type code: %i      Format code: %s")', dbl_type, dbl_frmt

end