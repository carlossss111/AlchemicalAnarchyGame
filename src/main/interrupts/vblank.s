INCLUDE "hardware.inc"

SECTION "FillerBefore", ROM0[$0000]
    ds $40
ENDSECTION

SECTION "FillerAfter", ROM0[$0047]
    ds $100 - $47
ENDSECTION


/*******************************************************
* VBLANK INTERRUPT
* Called when rendering a VBlank (so LCY = 144)
********************************************************/
SECTION "VBlankInterrupt", ROM0[$0040]

; Called when the interrupts are enabled, the rIE register is set and 
; and a VBlank has started
Interrupt:
    push af                     ; store the states of all the registers
    push bc
    push de
    push hl
    jp HandlerSelector          ; start handler code

ENDSECTION


/*******************************************************
* VBLANK HANDLER
* Calls a function pointer every VBlank
* Increments a frame counter
* Retains register states
********************************************************/
SECTION "FrameCounter", HRAM

    hFrameCounter:: db          ; updated every VBlank (60fps)

SECTION "VBlankHandlerVars", WRAM0

    wVBlankHandlerPtr: dw       ; function pointer to handler
    
SECTION "VBlankHandler", ROM0

; Call the Handler function pointer
HandlerSelector:
    ld hl, hFrameCounter
    inc [hl]                    ; update frame counter

    ld a, [wVBlankHandlerPtr]
    ld l, a
    ld a, [wVBlankHandlerPtr + 1]
    ld h, a
    ld bc, .ret
    push bc
    jp hl                       ; call handler function pointer
.ret
    pop hl                      ; restore all register states
    pop de
    pop bc
    pop af
    reti                        ; interrupt return

; Called by the VBlank Interrupt
; Doesn't do anything except implicitly wake up the CPU from the halt instr
DefaultHandler::
    ret

; Should be called at startup to initialise member variables
; @uses hl
initVBlankHandling::
    ld a, LOW(DefaultHandler)
    ld [wVBlankHandlerPtr], a
    ld a, HIGH(DefaultHandler)
    ld [wVBlankHandlerPtr + 1], a   ; load the default handler

    ld a, 0
    ld [hFrameCounter], a           ; init frame counter
    ret

ENDSECTION


/*******************************************************
* VBLANK SETTERS
* Setters to turn on/off the interrupt and interact with it
********************************************************/
SECTION "VBlankSetters", ROM0

; Sets the VBlankHandler
; @param hl: address of a VBlankHandler function
SetVBlankHandler::
    di
    ld a, l
    ld [wVBlankHandlerPtr], a
    ld a, h
    ld [wVBlankHandlerPtr + 1], a
    xor a
    ld [rIF], a                 ; clear pending VBlank interrupt requests (may be outdated)
    reti

; Enable the VBlank bit on the interrupt register
SetVBlankInterrupt::
    ld a, [rIE]
    or a, IE_VBLANK             ; sets the VBlank bit
    ld [rIE], a                 ; enables the VBlank interrupt flag
    ret

; Enables the VBlank bit on the interrupt register and disables all others
SetVBlankInterruptOnly::
    xor a                       ; clear all bits
    or a, IE_VBLANK             ; sets the VBlank bit only
    ld [rIE], a                 ; enables the VBlank interrupt flag, disable others
    ret
    
; Disable the VBlank bit on the interrupt register
UnsetVBlankInterrupt::
    ld a, [rIE]
    and a, !IE_VBLANK           ; unsets the VBlank bit
    ldh [rIE], a                ; disables the VBlank interrupt flag
    ret

ENDSECTION

