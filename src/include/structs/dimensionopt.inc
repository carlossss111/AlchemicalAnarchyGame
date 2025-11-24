
MACRO STRUCT_DIMENSIONS
    db                          ; board width
    db                          ; board height
    ds 6                        ; descriptor
ENDM

MACRO STRUCT_DIMENSIONS_DEF
    db \1
    db \2
    db \3
ENDM

DEF DIM_WIDTH EQU 0
DEF DIM_HEIGHT EQU 1
DEF DIM_DESCRIPTOR EQU 2
DEF DIM_STRUCT_SIZE EQU 8

