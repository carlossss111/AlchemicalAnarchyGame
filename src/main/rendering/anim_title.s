include "macros.inc"


SECTION "TitleAnimatorVars", WRAM0

    wNextWavingFlagFrame: db

    DEF FRAMES_PER_ANIM EQU 4   ; must be divisble by rightshifts!
    DEF BITSHIFTS_PER_ANIM EQU 2; bits before the divisor
    DEF DIVISIBLE_CHECK EQU %11111100 ; all bits >= dec 4

SECTION "TitleAnimations", ROM0

WavingFlagF1:
    ret

WavingFlagF2:
    ret

WavingFlagF3:
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
    
