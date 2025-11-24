
MACRO STRUCT_SPRITE
    db                          ; y position
    db                          ; x position
    db                          ; tile index
    db                          ; flags
ENDM

DEF SPR_X EQU 1
DEF SPR_Y EQU 0
DEF SPR_IND EQU 2
DEF SPR_FLAGS EQU 3

MACRO STRUCT_METASPRITE
    db                          ; x position
    db                          ; y posiiton
    db                          ; sprite width
    db                          ; sprite height
    dw                          ; ptr to sprite array
ENDM

DEF META_X EQU 0
DEF META_Y EQU 1
DEF META_WIDTH EQU 2
DEF META_HEIGHT EQU 3
DEF META_SPRITE_PTR EQU 4
DEF META_SIZE EQU 6

