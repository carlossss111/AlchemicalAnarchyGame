include "hardware.inc"
include "enums.inc"
include "macros.inc"


/*******************************************************
* TITLE DATA
* Tilemap and tiles
********************************************************/
SECTION "TitleTileData", ROM0

    SplashData: INCBIN "splash.2bpp"
    SplashDataEnd:


SECTION "TitleTileMap", ROM0

    SplashTilemap: INCBIN "splash.tilemap"
    SplashTilemapEnd:

ENDSECTION


/*******************************************************
* TITLE ENTRYPOINT
* Initialises the title scene 
********************************************************/
SECTION "TitleEntrypoint", ROM0

; Entrypoint for the title screen, initialises the screen
; @uses all registers
TitleEntrypoint::
    call SetVBlankInterruptOnly ; set the VBlank interrupt
    ei

    xor a
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_BLOCK01
    ld [rLCDC], a               ; setup LCD

    call FadeOut                ; fade to black

    ld de, SplashData           ; load all tiles into VRAM
    ld hl, $8000
    ld bc, SplashDataEnd - SplashData
    call VRAMCopy

    ld de, SplashTilemap        ; load all tilemaps into VRAM
    ld hl, TILEMAP0
    ld bc, SplashTilemapEnd - SplashTilemap
    call VRAMCopy

    call FadeIn                 ; fade back in after loading everything

    call InitAllTitleAnimations
    ld hl, RenderLoop
    call SetVBlankHandler       ; set animations

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
    halt                        ; run this loop at 60fps (more is waste of battery)
    
    call GetCurrentKeys         ; return current keypress in register a
    and a, JOYP_START           ; check if start
    jp z, TitleLoop             ; if button not pressed, loop again

.exit:
    ld bc, GAME_SCENE           ; set next scene
    di                          ; disable interrupts
    ret                         ; return to main loop

ENDSECTION


/*******************************************************
* RENDER LOOP
* Performs any rendering that requires a VBlank
********************************************************/
SECTION "TitleRenderer", ROM0

; Render animations into VRAM using the render-queue
RenderLoop:
    call AnimateWavingFlag
    ret

ENDSECTION

