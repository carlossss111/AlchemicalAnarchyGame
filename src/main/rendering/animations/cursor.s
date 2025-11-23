include "macros.inc"
include "hardware.inc"

/*******************************************************
* CURSOR ANIMATION
* Super simple animation that flips the objects on/off.
********************************************************/
SECTION "CursorAnimation", ROM0

; Reinitialises the animation 
InitCursorAnimation::
    ret

; Advances to the next frame of the animation
AnimateCursor::
    ld a, [rLCDC]
    ld b, LCDC_OBJS
    xor b                       ; XOR to flip on/off
    ld [rLCDC], a
    ret

ENDSECTION

