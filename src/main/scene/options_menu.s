include "hardware.inc"
include "enums.inc"
include "macros.inc"

include "metasprites.inc"
include "dimensionopt.inc"


DEF CURSOR_TOP_Y_POS EQU 56
DEF CURSOR_BOTTOM_Y_POS EQU 96
DEF CURSOR_MOVE_Y EQU CURSOR_BOTTOM_Y_POS - CURSOR_TOP_Y_POS
DEF SIZE_STR_INDEX = $C2
DEF SIZE_STR_LEN = 6
DEF DIFF_STR_INDEX = $162
DEF DIFF_STR_LEN = 6


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

SECTION "OptionsStrings", ROM0

    StringData: INCBIN "strings.2bpp"
    StringDataEnd:

ENDSECTION

/*******************************************************
* TITLE METASPRITES
* Sprite structs
********************************************************/
SECTION "OptionsSpriteData", ROM0

    SpriteSheet: INCBIN "options_cursor.2bpp"
    SpriteSheetEnd:

SECTION "OptionsSpriteMap", ROM0

    CursorSheetA: INCBIN "options_cursor.tilemap" ; 10x3 tiles

SECTION "OptionsMetasprites", WRAM0

    Cursor: STRUCT_METASPRITE

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

    ld de, SpriteSheet
    ld hl, $8000
    ld bc, SpriteSheetEnd - SpriteSheet
    call VRAMCopy               ; load spritesheet

    ld hl, Cursor               ; sprite
    ld bc, ShadowOAM            ; place to shadow at
    ld d, 10                    ; width
    ld e, 3                     ; height
    call InitMSprite            ; initialise sprite

    ld hl, Cursor               ; sprite
    ld bc, CursorSheetA         ; spritesheet
    call ColourMSprite          ; set the spritesheet
    
    ld hl, Cursor               ; sprite
    ld b, 16                    ; x
    ld c, 56                    ; y
    call PositionMSprite
 

    ;; Background ;;

    ld de, OptionsData          ; load tile data into VRAM
    ld hl, $9000
    ld bc, OptionsDataEnd - OptionsData
    call VRAMCopy

    ld de, StringData           ; load second half of tiles into VRAM
    ld hl, $8800
    ld bc, StringDataEnd - StringData
    call VRAMCopy

    ld de, OptionsTilemap       ; load tile map into VRAM
    ld hl, TILEMAP0
    ld bc, OptionsTilemapEnd - OptionsTilemap 
    call VRAMCopy


    ;; Animations ;;

    call InitAnimator
    call InitCursorAnimation

    ld bc, AnimateCursor
    call AddAnimation


    ;; LCD ;;

    xor a
    ld [rSCY], a

    xor a
    ld a, LCDC_ON | LCDC_BG_ON | LCDC_BLOCK21 | LCDC_OBJ_8 | LCDC_OBJ_ON
    ld [rLCDC], a               ; setup LCD

    ld hl, RenderLoop
    call SetVBlankHandler       ; set background animations

    call FadeIn                 ; fade back in after loading everything


    ;; Game Setup ;;

    call InitOptions            ; initialize options variables

    call GetDimDefault          ; de = pointer to descriptor
    ld b, SIZE_STR_LEN
    ld hl, $9800 + SIZE_STR_INDEX
    call VRAMCopyFast           ; copy options descriptor into VRAM to display

    call GetDiffDefault          ; de = pointer to descriptor
    ld b, DIFF_STR_LEN
    ld hl, $9800 + DIFF_STR_INDEX
    call VRAMCopyFast           ; copy options descriptor into VRAM to display

    jp OptionsMain

ENDSECTION


/*******************************************************
* OPTIONS LOOP
* Computes input here
********************************************************/
SECTION "OptionsMain", ROM0

; Moves the cursor up and down along the options menu
; If it is at the top, it goes down
; If it is at the bottom, it goes up
MoveCursor:
    ld hl, Cursor
    ld d, 0
    ld e, META_Y
    add hl, de
    ld a, [hl]                  ; get Y position of cursor
    cp CURSOR_TOP_Y_POS
    jr nz, .ElseMoveToTop

.IfMoveToBottom:
    ld hl, Cursor
    ld b, 0
    ld c, CURSOR_MOVE_Y
    call MoveMSprite            ; move cursor down
    jr .EndIf

.ElseMoveToTop:
    ld hl, Cursor
    ld b, 0
    ld c, -CURSOR_MOVE_Y
    call MoveMSprite            ; move cursor up

.EndIf:
    ret

; Cycles to next setting depending on which setting the cursor is selecting
CycleNextSetting:
    ld hl, Cursor
    ld d, 0
    ld e, META_Y
    add hl, de
    ld a, [hl]                  ; get Y position of cursor
    cp CURSOR_TOP_Y_POS
    jr nz, .Else

.IfBoardSizeSelected:
    call DimOptionNext
    ld b, SIZE_STR_LEN
    ld d, h
    ld e, l
    ld hl, $9800 + SIZE_STR_INDEX
    call VRAMCopyFast
    jr .EndIf

.Else:
    call DiffOptionNext
    ld b, DIFF_STR_LEN
    ld d, h
    ld e, l
    ld hl, $9800 + DIFF_STR_INDEX
    call VRAMCopyFast

.EndIf:
    ret

; Cycles to previous setting depending on which setting the cursor is selecting
CyclePrevSetting:
    ld hl, Cursor
    ld d, 0
    ld e, META_Y
    add hl, de
    ld a, [hl]                  ; get Y position of cursor
    cp CURSOR_TOP_Y_POS
    jr nz, .Else

.IfBoardSizeSelected:
    call DimOptionPrev
    ld b, SIZE_STR_LEN
    ld d, h
    ld e, l
    ld hl, $9800 + SIZE_STR_INDEX
    call VRAMCopyFast
    jr .EndIf

.Else:
    call DiffOptionPrev
    ld b, DIFF_STR_LEN
    ld d, h
    ld e, l
    ld hl, $9800 + DIFF_STR_INDEX
    call VRAMCopyFast

.EndIf:
    ret

; Main Options loop that waits for input and then calls subroutines after
OptionsMain:
    halt                        ; run this loop at 60fps (more is waste of battery)

    call GetNewKeys             ; return current keypress in register a

    ld b, a
    and a, JOYP_A               ; check if buttons pressed
    jr nz, .IfAPressed
    ld a, b
    and a, JOYP_B
    jr nz, .IfAPressed
    ld a, b
    and a, JOYP_SELECT
    jr nz, .IfAPressed
    ld a, b
    and a, JOYP_UP << 4
    jr nz, .IfUpPressed
    ld a, b
    and a, JOYP_DOWN << 4
    jr nz, .IfDownPressed
    ld a, b
    and a, JOYP_START
    jr nz, .IfStartPressed
    jr .EndIf

.IfAPressed:
    call MoveCursor
    jr .EndIf

.IfUpPressed:
    call CyclePrevSetting
    jr .EndIf

.IfDownPressed:
    call CycleNextSetting
    jr .EndIf

.IfStartPressed:
    jr .EndIf

.EndIf:
    jr OptionsMain

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
    call Animate
    ret

ENDSECTION

