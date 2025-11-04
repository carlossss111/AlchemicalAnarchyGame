include "macros.inc"
include "hardware.inc"


/*******************************************************
* TITLE FRAMES
* Frames that an index into a x,y coordinate on screen
********************************************************/
SECTION "TitleBackgroundFrames", ROM0

; Frame 1
BottleF1:
    LOAD_ANIM $90, 14, 11
    LOAD_ANIM $91, 15, 11
    LOAD_ANIM $92, 16, 11
    LOAD_ANIM $93, 17, 11
    LOAD_ANIM $94, 1, 12
    LOAD_ANIM $95, 2, 12
    LOAD_ANIM $96, 4, 12
    LOAD_ANIM $97, 5, 12
    LOAD_ANIM $98, 6, 12
    LOAD_ANIM $99, 13, 12
    LOAD_ANIM $9a, 14, 12
    LOAD_ANIM $9b, 15, 12
    LOAD_ANIM $9c, 16, 12
    LOAD_ANIM $9f, 1, 13
    LOAD_ANIM $a0, 2, 13
    LOAD_ANIM $a1, 3, 13
    LOAD_ANIM $a2, 4, 13
    LOAD_ANIM $a3, 5, 13
    LOAD_ANIM $a4, 6, 13
    LOAD_ANIM $aa, 1, 14
    LOAD_ANIM $ab, 2, 14
    LOAD_ANIM $ac, 3, 14
    LOAD_ANIM $ad, 4, 14
    ret

; Frame 2
BottleF2:
    LOAD_ANIM $06, 4, 12
    LOAD_ANIM $06, 5, 12
    LOAD_ANIM $c8, 1, 12
    LOAD_ANIM $c9, 2, 12
    LOAD_ANIM $ca, 1, 13
    LOAD_ANIM $cb, 2, 13
    LOAD_ANIM $cc, 3, 13
    LOAD_ANIM $cd, 4, 13
    LOAD_ANIM $ce, 5, 13
    LOAD_ANIM $cf, 6, 13
    LOAD_ANIM $d0, 4, 14
    LOAD_ANIM $d1, 15, 11
    LOAD_ANIM $d2, 16, 11
    LOAD_ANIM $d3, 17, 11
    LOAD_ANIM $d4, 14, 12
    LOAD_ANIM $d5, 15, 12
    LOAD_ANIM $d6, 16, 12
    LOAD_ANIM $e1, 6, 12
    ret

; Frame 3
BottleF3:
    LOAD_ANIM $29, 4, 14
    LOAD_ANIM $d7, 3, 13
    LOAD_ANIM $d8, 4, 13
    LOAD_ANIM $d9, 5, 13
    LOAD_ANIM $da, 6, 13
    LOAD_ANIM $db, 14, 11
    LOAD_ANIM $dc, 15, 11
    LOAD_ANIM $dd, 16, 11
    LOAD_ANIM $de, 14, 12
    LOAD_ANIM $df, 15, 12
    LOAD_ANIM $e0, 16, 12
    LOAD_ANIM $e1, 6, 12
    LOAD_ANIM $e2, 5, 12
    ret

ENDSECTION


SECTION "TitleSpriteFrames", ROM0

; Frame 1
; @param hl: pointer to sparkle metasprite
SparkleF1:
    ld b, 0
    ld c, 2
    call MoveMSprite
    ret
    
; Frame 2
; @param hl: pointer to sparkle metasprite
SparkleF2:
    ld b, 0
    ld c, -2
    call MoveMSprite
    ret

ENDSECTION


/*******************************************************
* ANIMATOR
* The animator should ideally be called on every vblank.
* It first check if the current frame is an animation frame,
* e.g. once every N frames, and if it is it activates
* the next frame
********************************************************/
SECTION "TitleAnimatorVars", WRAM0

    DEF FRAMES_PER_ANIM EQU 16   ; must be divisble by rightshifts!
    DEF BITSHIFTS_PER_ANIM EQU 4 ; bits before the divisor

    wNextBottleFrame: db
    wNextSparkleFrame: db

SECTION "TitleBackgroundAnimator", ROM0

; Returns 1 if the frame is divisible by FRAMES_PER_ANIM
; Returns 0 otherwise
; @param a: current frame number
; @param b: bitshifts per animation
; @returns a: true or false
IsAnimationFrame:
.DivisibleLoop:
    rra                         ; right shift frame counter
    jp nc, .Continue            ; if we have a carry, the number is not divisible
    xor a
    ret
.Continue:
    dec b                       ; decrement bitshifts per animation
    jp nz, .DivisibleLoop       ; and loop if there are more shifts to do
    ld a, TRUE
    ret

; Initialises all title animations
InitAllTitleAnimations::
    xor a
    ld [wNextBottleFrame], a
    ld [wNextSparkleFrame], a
    ret

; Checks if we are on an animation frame, if we are, animate!
AnimateBottle::
    ld a, [hFrameCounter]
    ld b, BITSHIFTS_PER_ANIM
    call IsAnimationFrame
    cp TRUE
    jp z, .AnimationFrame       ; confirm it is an animation frame,
    ret                         ; otherwise return early

.AnimationFrame:
    ld a, [wNextBottleFrame]
    ld hl, .Switch
    rla
    rla
    rla
    rla                         ; a * 16
    ld c, a
    xor b
    add hl, bc                  ; calculate switch address
    jp hl
    
.Switch
    call BottleF1               ; 3 bytes
    ld hl, wNextBottleFrame     ; 3 bytes
    inc [hl]                    ; 1 byte
    jr .SwitchEnd               ; 2 bytes
    FOR V, 7
        nop                     ; 7 bytes padding
    ENDR

    call BottleF2
    ld hl, wNextBottleFrame
    inc [hl]
    jr .SwitchEnd
    FOR V, 7
        nop
    ENDR

    call BottleF3
    ld hl, wNextBottleFrame
    ld [hl], 0
    jr .SwitchEnd
    FOR V, 7
        nop     
    ENDR
    ld a, [wNextBottleFrame]
    inc a      
    ld [wNextBottleFrame], a
    jr .SwitchEnd

.SwitchEnd
    ret

SECTION "TitleSpriteAnimator", ROM0

; Checks if we are on an animation frame, if we are, animate!
; @param hl: sparkle metasprite
AnimateSparkle::
    push hl

    ld a, [hFrameCounter]
    ld b, BITSHIFTS_PER_ANIM
    call IsAnimationFrame
    cp TRUE
    jp z, .AnimationFrame       ; confirm it is an animation frame,
    ret                         ; otherwise return early

.AnimationFrame:
    ld a, [wNextSparkleFrame]
    ld hl, .Switch
    rla
    rla
    rla
    rla                         ; a * 16
    ld c, a
    xor b
    add hl, bc                  ; calculate switch address
    jp hl
    
.Switch
    pop hl                      ; 1 byte
    call SparkleF1              ; 3 bytes
    ld hl, wNextSparkleFrame           ; 3 bytes
    inc [hl]                    ; 1 byte
    jr .SwitchEnd               ; 2 bytes
    FOR V, 6
        nop                     ; 6 bytes padding
    ENDR

    pop hl
    call SparkleF2 
    ld hl, wNextSparkleFrame
    ld [hl], 0
    jr .SwitchEnd
    FOR V, 6
        nop
    ENDR

    ld a, [wNextSparkleFrame]
    inc a      
    ld [wNextSparkleFrame], a
    jr .SwitchEnd

.SwitchEnd
    ret

ENDSECTION
    
