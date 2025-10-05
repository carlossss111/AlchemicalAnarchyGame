INCLUDE "hardware.inc"
INCLUDE "enums.inc"

/*******************************************************
* CARTRIDGE HEADER
* Populated by the rgbfix tool
********************************************************/
SECTION "Header", ROM0[$0100]

	jp EntryPoint

	ds $150 - @, 0

ENDSECTION

/*******************************************************
* INITIALISATION
* Copies memory to where it needs to be
********************************************************/
SECTION "Init", ROM0

; Global entrypoint for the program
; @uses all registers
EntryPoint:
    ld sp, StackStart           ; set stack pointer

    xor a
	ld [rNR52], a               ; turn off audio

    di                          ; disable interrupts for the main loop
    call initVBlankHandling     ; init interrupt handling vars for later

    ld bc, TITLE_SCENE          ; first scene to load on program startup
    jp Main                     ; jump to the main loop

ENDSECTION


/*******************************************************
* MAIN LOOP
* The main event loop for the program
********************************************************/
SECTION "MainLoop", ROM0

; Main loop that each game state returns to upon finishing
; @param bc: scene to load
; @uses all registers
Main:
    ld a, c
    cp a, SWITCH_SIZE + 1       ; compare if bc is within the right range
    jr nc, .SwitchEnd           ; if bc > switch size then we skip the switch
    
    ld hl, .Switch
    xor b
    add hl, bc                  ; hl = scene enum value + switch starting location
    jp hl                       ; jump to the correct scene via the offset

.Switch:
    call TitleEntrypoint        ; enter title loop. return new state as bc 
    jr .SwitchEnd
    call OptionsEntrypoint      ; enter options loop. return new state as bc 
    jr .SwitchEnd
    call GameEntrypoint         ; enter game loop. return new state as bc 
    jr .SwitchEnd

.SwitchEnd
    jp Main                     ; while True


OptionsEntrypoint:
    ret                         ; unimplemented
GameEntrypoint:
    ret                         ; unimplemented

ENDSECTION

