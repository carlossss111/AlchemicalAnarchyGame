include "macros.inc"
include "hardware.inc"


SECTION "TitleAnimatorVars", WRAM0

    DEF FRAMES_PER_ANIM EQU 8   ; must be divisble by rightshifts!
    DEF BITSHIFTS_PER_ANIM EQU 3; bits before the divisor

    wNextWavingFlagFrame: db

SECTION "TitleAnimations", ROM0

    DEF FLAG_TOP_LEFT  EQU $9800 + $10c
    DEF FLAG_TOP_RIGHT EQU $9800 + $10d
    DEF FLAG_BOTTOM_LEFT  EQU $9800 + $12c
    DEF FLAG_BOTTOM_RIGHT EQU $9800 + $12d

; Frame 1
WavingFlagF1:
    ld a, $6c
    ld [FLAG_TOP_LEFT], a 
    ld a, $6d
    ld [FLAG_TOP_RIGHT], a
    ld a, $7b
    ld [FLAG_BOTTOM_LEFT], a
    ld a, $7c
    ld [FLAG_BOTTOM_RIGHT], a
    ret

; Frame 2
WavingFlagF2:
    ld a, $6c
    ld [FLAG_TOP_LEFT], a 
    ld a, $6d
    ld [FLAG_TOP_RIGHT], a
    ld a, $e2
    ld [FLAG_BOTTOM_LEFT], a
    ld a, $e3
    ld [FLAG_BOTTOM_RIGHT], a
    ret

; Frame 3
WavingFlagF3:
    ld a, $ec
    ld [FLAG_TOP_LEFT], a 
    ld a, $ed
    ld [FLAG_TOP_RIGHT], a
    ld a, $f8
    ld [FLAG_BOTTOM_LEFT], a
    ld a, $f9
    ld [FLAG_BOTTOM_RIGHT], a
    ret


SECTION "TitleAnimator", ROM0

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
    call InitWavingFlag
    ret

; Sets the waving flag static varibales to 0
InitWavingFlag::
    xor a
    ld [wNextWavingFlagFrame], a
    ret

; Checks if we are on an animation frame, if we are, animate!
AnimateWavingFlag::
    ld a, [hFrameCounter]
    ld b, BITSHIFTS_PER_ANIM
    call IsAnimationFrame
    cp TRUE
    jp z, .AnimationFrame       ; confirm it is an animation frame,
    ret                         ; otherwise return early

.AnimationFrame:
    ld a, [wNextWavingFlagFrame]
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
    call WavingFlagF1           ; 3 bytes
    ld hl, wNextWavingFlagFrame ; 3 bytes
    inc [hl]                    ; 1 byte
    jr .SwitchEnd               ; 2 bytes
    FOR V, 7
        nop                     ; 7 bytes padding
    ENDR

    call WavingFlagF2
    ld hl, wNextWavingFlagFrame
    inc [hl]
    jr .SwitchEnd
    FOR V, 7
        nop
    ENDR

    call WavingFlagF3
    ld hl, wNextWavingFlagFrame
    ld [hl], 0
    jr .SwitchEnd
    FOR V, 7
        nop     
    ENDR
    ld a, [wNextWavingFlagFrame]
    inc a      
    ld [wNextWavingFlagFrame], a
    jr .SwitchEnd

.SwitchEnd
    ret

ENDSECTION
    
