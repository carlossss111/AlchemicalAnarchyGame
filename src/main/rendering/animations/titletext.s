include "macros.inc"
include "hardware.inc"

DEF LINES_TO_RAISE_BY EQU 2
DEF TOP_SCANLINE_TO_RAISE EQU 10
DEF BOTTOM_SCANLINE_TO_RAISE EQU 70

/*******************************************************
* FRAMES
* Subroutines to be called on a given frame
********************************************************/
SECTION "TitleTextFrames", ROM0

; Frame 1
TitleTextF1:
    ld a, LINES_TO_RAISE_BY
    ld [wTitleYPosition], a
    ret

; Frame 2
TitleTextF2:
    xor a
    ld [wTitleYPosition], a
    ret

; Raises screen up a bit, called as a STAT interrupt handler
; Sets the place for the next STAT handler
ScreenYRaise:
    ldh a, [rSTAT]
    and %00000011
    or STAT_HBLANK
    jr nz, ScreenYRaise         ; wait for HBlank

    ld a, [wTitleYPosition]
    ld [rSCY], a                ; raise screen Y

    ld a, BOTTOM_SCANLINE_TO_RAISE
    call ReqStatOnScanline      ; set scanline for next STAT interrupt

    ld hl, ScreenYLower
    call SetStatHandler         ; set handler for next STAT interrupt

    ret

; Lowers screen down, called as a STAT interrupt handler
; Sets the place for the next STAT handler
ScreenYLower:
    ldh a, [rSTAT]
    and %00000011
    or STAT_HBLANK
    jr nz, ScreenYLower         ; wait for HBlank

    xor a
    ld [rSCY], a                ; lower screen Y

    ld a, TOP_SCANLINE_TO_RAISE
    call ReqStatOnScanline      ; set scanline for next STAT interrupt

    ld hl, ScreenYRaise
    call SetStatHandler         ; set handler for next STAT interrupt

    ret

ENDSECTION

/*******************************************************
* ANIMATION HANDLER
* Keeps track of which frame is next, calls frame subroutines 
* depending on that.
********************************************************/
SECTION "TitleTextAnimationVars", WRAM0

    wNextFrame: db
    wTitleYPosition: db

SECTION "TitleTextAnimation", ROM0

; Reinitialises the animation 
InitTitleTextAnimation::
    xor a
    ld [wNextFrame], a
    ld [wTitleYPosition], a
    
    ld hl, ScreenYRaise
    call SetStatHandler

    ld a, TOP_SCANLINE_TO_RAISE
    call ReqStatOnScanline

    ret

; Advances to the next frame of the animation
AnimateTitleText::
    ld a, [wNextFrame]
    ld hl, .Switch
    rla
    rla
    rla
    rla                         ; a * 16
    ld c, a
    ld b, 0
    add hl, bc                  ; calculate switch address
    jp hl
    
.Switch
    call TitleTextF1            ; 3 bytes
    ld hl, wNextFrame           ; 3 bytes
    inc [hl]                    ; 1 byte
    jr .SwitchEnd               ; 2 bytes
    FOR V, 7
        nop                     ; 7 bytes padding
    ENDR

    call TitleTextF2
    ld hl, wNextFrame
    ld [hl], 0
    jr .SwitchEnd
    FOR V, 7
        nop     
    ENDR
    ld a, [wNextFrame]
    inc a      
    ld [wNextFrame], a
    jr .SwitchEnd

.SwitchEnd
    ret

ENDSECTION

