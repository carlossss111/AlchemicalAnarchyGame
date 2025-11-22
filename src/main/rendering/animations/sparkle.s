include "macros.inc"
include "hardware.inc"
include "metasprites.inc"

DEF PIXELS_TO_MOVE_BY EQU 2

/*******************************************************
* FRAMES
* Subroutines to be called on a given frame
********************************************************/
SECTION "SparkleFrames", ROM0

; Frame 1
SparkleF1:
    xor a
    ld d, a                     ; element index
    ld e, a                     ; byte index
.Loop:
    ld a, [wMetaspriteArraySize]
    cp d
    jr z, .EndLoop
    
    ld a, [wMetaspriteArray]
    ld h, a
    ld a, [wMetaspriteArray + 1]
    ld l, a
    push de

    ld d, 0
    add hl, de

    ld b, 0
    ld c, -PIXELS_TO_MOVE_BY
    call MoveMSprite

    pop de
    inc d
    ld a, e
    add a, META_SIZE
    ld e, a
    jr .Loop
.EndLoop:
    ret

; Frame 2
SparkleF2:
    xor a
    ld d, a                     ; element index
    ld e, a                     ; byte index
.Loop:
    ld a, [wMetaspriteArraySize]
    cp d
    jr z, .EndLoop
    
    ld a, [wMetaspriteArray]
    ld h, a
    ld a, [wMetaspriteArray + 1]
    ld l, a
    push de

    ld d, 0
    add hl, de

    ld b, 0
    ld c, PIXELS_TO_MOVE_BY
    call MoveMSprite

    pop de
    inc d
    ld a, e
    add a, META_SIZE
    ld e, a
    jr .Loop
.EndLoop:
    ret

/*******************************************************
* ANIMATION HANDLER
* Keeps track of which frame is next, calls frame subroutines 
* depending on that.
********************************************************/
SECTION "SparkleAnimationVars", WRAM0

    wNextFrame: db
    wMetaspriteArray: dw
    wMetaspriteArraySize: db

SECTION "SparkleAnimation", ROM0

; Reinitialises the animation and loads in an array of metasprites
; @param hl: pointer to start of sparkle metasprite array
; @param b: number of metasprites
InitSparkleAnimation::
    xor a
    ld [wNextFrame], a

    ld a, h
    ld [wMetaspriteArray], a
    ld a, l
    ld [wMetaspriteArray + 1], a
    ld a, b
    ld [wMetaspriteArraySize], a
    ret

; Advances to the next frame of the animation
AnimateSparkle::
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
    call SparkleF1              ; 3 bytes
    ld hl, wNextFrame           ; 3 bytes
    inc [hl]                    ; 1 byte
    jr .SwitchEnd               ; 2 bytes
    FOR V, 7
        nop                     ; 7 bytes padding
    ENDR

    call SparkleF2 
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

