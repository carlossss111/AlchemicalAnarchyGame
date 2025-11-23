include "hardware.inc"
include "enums.inc"
include "macros.inc"
include "metasprites.inc"


/*******************************************************
* TITLE DATA
* Tilemap and tiles
********************************************************/
SECTION "TitleTileData", ROM0

    SplashData: INCBIN "alchemical_anarchy.2bpp"
    SplashDataEnd:


SECTION "TitleTileMap", ROM0

    SplashTilemap: INCBIN "alchemical_anarchy.tilemap"
    SplashTilemapEnd:

ENDSECTION

/*******************************************************
* TITLE METASPRITES
* Sprite structs
********************************************************/
SECTION "TitleSpriteData", ROM0

    SpriteSheet: INCBIN "sparkles.2bpp"
    SpriteSheetEnd:

SECTION "TitleSpriteMap", ROM0

    ; large sparkle
    SparkleSheetA: db $00, $01, $06, $07, $0a, $0b
    ; tiny sparkle
    SparkleSheetB: db $03
    ; tall sparkle
    SparkleSheetC: db $02, $08
    ; medium sparkle
    SparkleSheetD: db $04, $09

SECTION "TitleMetasprites", WRAM0
    
    DEF SPARKLES_ARR_LEN EQU 6
    SparklesArr:
    Sparkles1: STRUCT_METASPRITE
    Sparkles2: STRUCT_METASPRITE
    Sparkles3: STRUCT_METASPRITE
    Sparkles4: STRUCT_METASPRITE
    Sparkles5: STRUCT_METASPRITE
    Sparkles6: STRUCT_METASPRITE

ENDSECTION

/*******************************************************
* TITLE ENTRYPOINT
* Initialises the title scene 
********************************************************/
SECTION "TitleEntrypoint", ROM0

; Entrypoint for the title screen, initialises the screen
; @uses all registers
TitleEntrypoint::
    call SetVBlankInterrupt
    call SetStatInterrupt
    ei

    call FadeOut                ; fade to black


    ;; Sprites ;;

    call ClearShadowOAM         ; initialise shadow OAM

    ld a, DEFAULT_PALETTE
    ld [rOBP0], a               ; set sprite palette

    ld de, SpriteSheet
    ld hl, $8000
    ld bc, SpriteSheetEnd - SpriteSheet
    call VRAMCopy               ; load spritesheet

    ld hl, Sparkles1            ; sprite
    ld bc, ShadowOAM            ; place to shadow at
    ld d, 2                     ; width
    ld e, 3                     ; height
    call InitMSprite            ; initialise a sparkle sprite

    ld hl, Sparkles1            ; sprite
    ld bc, SparkleSheetA        ; spritesheet
    call ColourMSprite          ; set the sparkle's spritesheet
    
    ld hl, Sparkles1            ; sprite
    ld b, 12                    ; x
    ld c, 84                    ; y
    call PositionMSprite

    ;;

    ld hl, Sparkles2            ; sprite
    ld bc, ShadowOAM + 24       ; place to shadow at
    ld d, 2                     ; width
    ld e, 3                     ; height
    call InitMSprite            ; initialise a sparkle sprite

    ld hl, Sparkles2            ; sprite
    ld bc, SparkleSheetA        ; spritesheet
    call ColourMSprite          ; set the sparkle's spritesheet
    
    ld hl, Sparkles2            ; sprite
    ld b, 144                   ; x
    ld c, 86                    ; y
    call PositionMSprite

    ;;

    ld hl, Sparkles3            ; sprite
    ld bc, ShadowOAM + 48       ; place to shadow at
    ld d, 1                     ; width
    ld e, 1                     ; height
    call InitMSprite            ; initialise a sparkle sprite

    ld hl, Sparkles3            ; sprite
    ld bc, SparkleSheetB        ; spritesheet
    call ColourMSprite          ; set the sparkle's spritesheet
    
    ld hl, Sparkles3            ; sprite
    ld b, 102                   ; x
    ld c, 94                    ; y
    call PositionMSprite
    
    ;;

    ld hl, Sparkles4            ; sprite
    ld bc, ShadowOAM + 72       ; place to shadow at
    ld d, 1                     ; width
    ld e, 1                     ; height
    call InitMSprite            ; initialise a sparkle sprite

    ld hl, Sparkles4            ; sprite
    ld bc, SparkleSheetB        ; spritesheet
    call ColourMSprite          ; set the sparkle's spritesheet
    
    ld hl, Sparkles4            ; sprite
    ld b, 112                   ; x
    ld c, 122                   ; y
    call PositionMSprite
    
    ;;

    ld hl, Sparkles5            ; sprite
    ld bc, ShadowOAM + 96       ; place to shadow at
    ld d, 1                     ; width
    ld e, 2                     ; height
    call InitMSprite            ; initialise a sparkle sprite

    ld hl, Sparkles5            ; sprite
    ld bc, SparkleSheetC        ; spritesheet
    call ColourMSprite          ; set the sparkle's spritesheet
    
    ld hl, Sparkles5            ; sprite
    ld b, 64                    ; x
    ld c, 120                   ; y
    call PositionMSprite

    ;;

    ld hl, Sparkles6            ; sprite
    ld bc, ShadowOAM + 120      ; place to shadow at
    ld d, 1                     ; width
    ld e, 2                     ; height
    call InitMSprite            ; initialise a sparkle sprite

    ld hl, Sparkles6            ; sprite
    ld bc, SparkleSheetD        ; spritesheet
    call ColourMSprite          ; set the sparkle's spritesheet
    
    ld hl, Sparkles6            ; sprite
    ld b, 20                    ; x
    ld c, 140                   ; y
    call PositionMSprite


    ;; Background ;;

    ld de, SplashData              ; load first half of tiles into VRAM
    ld hl, $9000
    ld bc, 16 * 128
    call VRAMCopy

    ld de, SplashData + (16 * 128) ; load second half of tiles into VRAM
    ld hl, $8800
    ld bc, SplashDataEnd - (SplashData + 16 * 128)
    call VRAMCopy

    ld de, SplashTilemap           ; load all tilemaps into VRAM
    ld hl, TILEMAP0
    ld bc, SplashTilemapEnd - SplashTilemap
    call VRAMCopy


    ;; Animations ;;

    call InitAnimator
    call InitTitleTextAnimation
    call InitBottleAnimation
    ld hl, SparklesArr          ; sprites to animate
    ld b, SPARKLES_ARR_LEN      ; length of sprite array
    call InitSparkleAnimation

    ld bc, AnimateBottle
    call AddAnimation
    ld bc, AnimateTitleText
    call AddAnimation
    ld bc, AnimateSparkle
    call AddAnimation


    ;; LCD ;;

    xor a
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD


    call FadeIn                 ; fade back in after loading everything

    ld hl, RenderLoop
    call SetVBlankHandler       ; set background animations


    jp TitleLoop

ENDSECTION


/*******************************************************
* TITLE LOOP
* Computes input here
********************************************************/
SECTION "TitleMain", ROM0

; Loop until the player presses start
TitleLoop:
    halt                        ; run this loop at 60fps (more is waste of battery)

    call GetCurrentKeys         ; return current keypress in register a
    and a, JOYP_START           ; check if start
    jp z, TitleLoop             ; if button not pressed, loop again

.EndLoop:
    ld bc, OPTION_SCENE         ; set next scene
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
    ei                          ; bit of a warcrime but we still need stat interrupts
    call RenderToOAM
    call Animate
    ret

ENDSECTION

