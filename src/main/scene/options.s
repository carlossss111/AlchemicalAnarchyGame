include "hardware.inc"
include "enums.inc"
include "macros.inc"
include "metasprites.inc"


/*******************************************************
* OPTIONS DATA
* Tilemap and tiles
********************************************************/
SECTION "OptionsTileData", ROM0

    OptionsData: INCBIN "options.2bpp"
    OptionsDataEnd:


SECTION "OptionsTileMap", ROM0

    OptionsTilemap: INCBIN "options.tilemap"
    OptionsTilemapEnd:

ENDSECTION


/*******************************************************
* OPTIONS ENTRYPOINT
* Initialises the options scene 
********************************************************/
SECTION "OptionsEntrypoint", ROM0

OptionsEntrypoint:: 
    call UnsetStatInterrupt
    call SetVBlankInterrupt
    call initVBlankHandling
    ei

    call FadeOut                ; fade to black


    ;; Sprites ;;

    call ClearShadowOAM         ; initialise shadow OAM

    ld a, DEFAULT_PALETTE
    ld [rOBP0], a               ; set sprite palette


    ;; Background ;;

    ld de, OptionsData          ; load tile data into VRAM
    ld hl, $9000
    ld bc, OptionsDataEnd - OptionsData
    call VRAMCopy

    ld de, OptionsTilemap       ; load tile map into VRAM
    ld hl, TILEMAP0
    ld bc, OptionsTilemapEnd - OptionsTilemap 
    call VRAMCopy


    ;; Animations ;;

    call InitAnimator


    ;; LCD ;;
    xor a
    ld [rSCY], a

    xor a
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD

    ld hl, RenderLoop
    call SetVBlankHandler       ; set background animations

    call FadeIn                 ; fade back in after loading everything

    jp OptionsMain

ENDSECTION


/*******************************************************
* OPTIONS LOOP
* Computes input here
********************************************************/
SECTION "OptionsMain", ROM0

OptionsMain:
    halt                        ; run this loop at 60fps (more is waste of battery)

    jp OptionsMain
    ret

ENDSECTION


/*******************************************************
* RENDER LOOP
* Performs any rendering that requires a VBlank
********************************************************/
SECTION "OptionsRenderer", ROM0

; Render animations into VRAM using the render-queue
RenderLoop:
    call RenderToOAM
    ret

ENDSECTION

