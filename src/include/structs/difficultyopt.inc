
MACRO STRUCT_DIFFICULTY
    db                          ; difficulty modifier 
    ds 6                        ; descriptor
ENDM

MACRO STRUCT_DIFFICULTY_DEF
    db \1
    db \2
ENDM

DEF DIFF_MODIFIER EQU 0
DEF DIFF_DESCRIPTOR EQU 1
DEF DIFF_STRUCT_SIZE EQU 7

