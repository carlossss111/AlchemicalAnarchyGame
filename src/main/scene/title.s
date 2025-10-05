include "hardware.inc"
include "enums.inc"

/*******************************************************
* TITLE ENTRYPOINT
* Initialises the title scene 
********************************************************/
SECTION "TitleEntrypoint", ROM0

; Entrypoint for the title screen, initialises things
; @uses all registers
TitleEntrypoint::
    ld hl, Render
    call SetVBlankHandler       ; set the VBlank handler function to point to
    call SetVBlankInterruptOnly ; set the VBlank interrupt
    ei                          ; enable interrupts
    jp TitleLoop

ENDSECTION


/*******************************************************
* TITLE LOOP
* Computes input here
********************************************************/
SECTION "TitleMain", ROM0

; Loop until the player presses start
; @uses all registers
TitleLoop:
    halt                        ; jump to Render label on VBlank
    jp TitleLoop

    ld bc, TITLE_SCENE          ; set next scene
    di                          ; disable interrupts
    ret                         ; return to main loop

ENDSECTION


/*******************************************************
* RENDER LOOP
* Performs any rendering that requires a VBlank
********************************************************/
SECTION "TitleRenderer", ROM0

; Render the title screen into VRAM
Render:
    ret

ENDSECTION

