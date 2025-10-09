include "hardware.inc"
include "enums.inc"
include "macros.inc"


/*******************************************************
* TITLE DATA
* Tilemap and tiles
********************************************************/
SECTION "TitleTileData", ROM0

    TitleTileData: INCBIN "title_screen.2bpp"
    FlagData: INCBIN "animation_test.2bpp"
    TitleTileDataEnd:


SECTION "TitleTileMap", ROM0

    TitleTilemap: INCBIN "title_screen.tilemap"
    TitleTilemapEnd:

ENDSECTION


/*******************************************************
* TITLE ENTRYPOINT
* Initialises the title scene 
********************************************************/
SECTION "TitleEntrypoint", ROM0

; Entrypoint for the title screen, initialises the screen
; @uses all registers
TitleEntrypoint::
    ; Draw the screen once with vblank handler
    call SetVBlankInterruptOnly ; set the VBlank interrupt
    ld hl, RenderFirst
    call SetVBlankHandler       ; set the init VBlank handler to draw the entire screen once
    ei                          ; enable interrupts
    halt                        ; wait until a VBlank then call the init handler

    ; Set reoccuring Vblank handler
    call InitRenderQueue        ; init the renderer queue
    ld hl, RenderLoop
    call SetVBlankHandler       ; set the VBlank looping handler 

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

    ; PLACEHOLDER OBVIOUSLY
    ld b, 1
    ld c, 1
    ld d, $25
    call EnqueueTilemap

    halt                        ; jump to Render label on VBlank
    halt
    halt
    halt
    halt

    ld b, 1
    ld c, 1
    ld d, $26
    call EnqueueTilemap

    halt                        ; jump to Render label on VBlank
    halt
    halt
    halt
    halt

    ld b, 1
    ld c, 1
    ld d, $27
    call EnqueueTilemap

    halt                        ; jump to Render label on VBlank
    halt
    halt
    halt
    halt

    ld b, 1
    ld c, 1
    ld d, $26
    call EnqueueTilemap

    halt                        ; jump to Render label on VBlank
    halt
    halt
    halt
    halt

    ld b, 1
    ld c, 1
    ld d, $25
    call EnqueueTilemap

    halt                        ; jump to Render label on VBlank
    halt
    halt
    halt
    halt

    ld b, 1
    ld c, 1
    ld d, $28
    call EnqueueTilemap

    halt                        ; jump to Render label on VBlank
    halt
    halt
    halt
    halt

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

; Load all tile and tilemap data into VRAM
; Should only be used to initialise and only called once
RenderFirst:
    xor a                 
    ld [rLCDC], a               ; turn off the LCD since we are going to take a long time

    ld de, TitleTileData        ; load all tiles into VRAM
    ld hl, $9000
    ld bc, TitleTileDataEnd - TitleTileData
    call Memcpy

    ld de, TitleTilemap         ; load all tilemaps into VRAM
    ld hl, TILEMAP0
    ld bc, TitleTilemapEnd - TitleTilemap
    call Memcpy

    ld a, LCDC_ON | LCDC_BG_ON | LCDC_OBJ_OFF
    ld [rLCDC], a               ; turn on LCD
    ld a, COLOUR_PALETTE
    ld [rBGP], a                ; initialize background palette
    ret

; Render animations into VRAM using the render-queue
RenderLoop:
    call DequeueTilemapsToVRAM  ; transfer tilemap changes to VRAM 
    ret

ENDSECTION

