INCLUDE "hardware.inc"

/*******************************************************
* STAT INTERRUPT
* Called depending on variables conditions in the STAT register.
* Typically used for when the PPU is rendering a certain
* part of the screen.
********************************************************/
SECTION "StatInterrupt", ROM0[$0048]

; Called when the interrupts are enabled, and conditions in rSTAT
; cause the interrupt to fire.
Interrupt:
    push af                     ; store the states of all the registers
    push bc
    push de
    push hl
    jp HandlerSelector          ; start handler code

ENDSECTION


/*******************************************************
* STAT HANDLER
* Calls a function pointer on every STAT interrupt
* Retains register states
********************************************************/
SECTION "StatHandlerVars", WRAM0

    wStatHandlerPtr: dw       ; function pointer to handler
    
SECTION "StatHandler", ROM0

; Call the Handler function pointer
HandlerSelector:
    ld a, [wStatHandlerPtr]
    ld l, a
    ld a, [wStatHandlerPtr + 1]
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

; Called by the STAT Interrupt
; Doesn't do anything except implicitly wake up the CPU from the halt instr
DefaultHandler:
    ret

; Should be called at startup to initialise member variables
; @uses hl
initStatHandling::
    ld a, LOW(DefaultHandler)
    ld [wStatHandlerPtr], a
    ld a, HIGH(DefaultHandler)
    ld [wStatHandlerPtr + 1], a ; load the default handler

    xor a
    ld [rSTAT], a               ; clear STAT register
    ret

ENDSECTION


/*******************************************************
* STAT SETTERS
* Setters to turn on/off the interrupt and interact with it
********************************************************/
SECTION "StatSetters", ROM0

; Sets the StatHandler
; @param hl: address of a StatHandler function
SetStatHandler::
    di
    ld a, l
    ld [wStatHandlerPtr], a
    ld a, h
    ld [wStatHandlerPtr + 1], a
    xor a
    ld [rIF], a                 ; clear pending interrupt requests (may be outdated)
    reti

; Enables the stat interrupt to trigger on a given scanline
; @param a: nth scanline to trigger at
ReqStatOnScanline::
    ld [rLYC], a                ; set scanline to trigger at
    ld a, STAT_LYC
    ld [rSTAT], a               ; set that we want to trigger when LYC == LY
    ret

; Enables the STAT interrupt
SetStatInterrupt::
    ld a, [rIE]
    or a, IE_STAT               ; sets the STAT bit
    ld [rIE], a                 ; enables the STAT interrupt flag
    ret

; Disable the STAT bit on the interrupt register
UnsetStatInterrupt::
    ld a, [rIE]
    and a, !IE_STAT             ; unsets the STAT bit
    ldh [rIE], a                ; disables the STAT interrupt flag
    ret

ENDSECTION

