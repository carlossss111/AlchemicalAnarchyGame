include "charmap.inc"

include "dimensionopt.inc"
include "difficultyopt.inc"

/*******************************************************
* GLOBAL BOARD SETTINGS
* Global options for setting up the board.
********************************************************/
SECTION "BoardSettings", HRAM

    hWidth:: db
    hHeight:: db
    hDifficultyModifier:: db

ENDSECTION


/*******************************************************
* OPTIONS MECHANICS
* Allows cycling through a dimensions and difficulty array
* to determine the respective settings.
* On each cycle, a descriptor is returned to display to 
* the user and the current settings are written to HRAM.
********************************************************/
SECTION "OptionsConsts", ROM0

    ; 8 byte struct, 1) width, 2) height, 3) desc
    DimensionsArr:     STRUCT_DIMENSIONS_DEF 4, 6,   "tiny  "
                       STRUCT_DIMENSIONS_DEF 6, 8,   "small "
                       STRUCT_DIMENSIONS_DEF 8, 12,  "medium"
                       STRUCT_DIMENSIONS_DEF 12, 14, "large "
    DimensionsArrLast: STRUCT_DIMENSIONS_DEF 16, 16, "huge  "

    ; 7 byte struct, 1) modifier, 2) desc
    DifficultyArr:     STRUCT_DIFFICULTY_DEF 1, "easy  "
                       STRUCT_DIFFICULTY_DEF 3, "normal"
    DifficultyArrLast: STRUCT_DIFFICULTY_DEF 5, "hard  "

SECTION "OptionsVars", WRAM0

    wDimPtr: dw
    wDiffPtr: dw

SECTION "Options", ROM0

; Initialises pointers to the two cyclical arrays
InitOptions::
    ld a, LOW(DimensionsArr)          ; init dimensions array ptr
    ld [wDimPtr], a
    ld a, HIGH(DimensionsArr)
    ld [wDimPtr + 1], a

    ld a, LOW(DifficultyArr)          ; init difficulty array ptr
    ld [wDiffPtr], a
    ld a, HIGH(DifficultyArr)
    ld [wDiffPtr + 1], a

    ld a, [DimensionsArr + DIM_WIDTH] ; set defaults in WRAM
    ldh [hWidth], a
    ld a, [DimensionsArr + DIM_HEIGHT]
    ldh [hHeight], a
    ld a, [DifficultyArr + DIFF_MODIFIER] 
    ldh [hDifficultyModifier], a
    ret

; Gets the default descriptor for dimensions
; @returns de: pointer to descriptor string
GetDimDefault::
    ld a, LOW(DimensionsArr + DIM_DESCRIPTOR)
    ld e, a
    ld a, HIGH(DimensionsArr + DIM_DESCRIPTOR)
    ld d, a
    ret

; Gets the default descriptor for difficulty
; @returns de: pointer to descriptor string
GetDiffDefault::
    ld a, LOW(DifficultyArr + DIFF_DESCRIPTOR)
    ld e, a
    ld a, HIGH(DifficultyArr + DIFF_DESCRIPTOR)
    ld d, a
    ret

; Cycles to the previous size setting and returns the descriptor string
; @returns hl: pointer to descriptor string
DimOptionPrev::
    ld a, [wDimPtr + 1]
    ld h, a
    ld a, [wDimPtr]
    ld l, a

    cp LOW(DimensionsArr)
    jr nz, .Else
    ld a, h
    cp HIGH(DimensionsArr)
    jr nz, .Else                ; check whether we are the first elem

.IfAtFirstElem:
    ld hl, DimensionsArrLast    ; looparound to last elem
    jr .EndIf
.Else:
    ld de, -DIM_STRUCT_SIZE
    add hl, de                  ; go to previous elem
.EndIf:

    ld a, l
    ld [wDimPtr], a
    ld a, h
    ld [wDimPtr + 1], a         ; update new elem

    ld a, [hl+]
    ldh [hWidth], a
    ld a, [hl+]
    ldh [hHeight], a            ; update HRAM
    
    ret                         ; hl should now point to the descriptor string

; Cycles to the next size setting and returns the descriptor string
; @returns hl: pointer to descriptor string
DimOptionNext::
    ld a, [wDimPtr + 1]
    ld h, a
    ld a, [wDimPtr]
    ld l, a
    cp LOW(DimensionsArrLast)
    jr nz, .Else
    ld a, h
    cp HIGH(DimensionsArrLast)
    jr nz, .Else                ; check whether we are the last elem

.IfAtLastElem:
    ld hl, DimensionsArr        ; looparound to last elem
    jr .EndIf
.Else:
    ld de, DIM_STRUCT_SIZE
    add hl, de                  ; go to next elem
.EndIf:

    ld a, l
    ld [wDimPtr], a
    ld a, h
    ld [wDimPtr + 1], a         ; update new elem

    ld a, [hl+]
    ldh [hWidth], a
    ld a, [hl+]
    ldh [hHeight], a             ; update HRAM
    
    ret                         ; hl should now point to the descriptor string

; Cycles to the prev difficulty setting and returns the descriptor string
; @returns hl: pointer to descriptor string
DiffOptionPrev::
    ld a, [wDiffPtr + 1]
    ld h, a
    ld a, [wDiffPtr]
    ld l, a

    cp LOW(DifficultyArr)
    jr nz, .Else
    ld a, h
    cp HIGH(DifficultyArr)
    jr nz, .Else                ; check whether we are the first elem

.IfAtFirstElem:
    ld hl, DifficultyArrLast    ; looparound to last elem
    jr .EndIf
.Else:
    ld de, -DIFF_STRUCT_SIZE
    add hl, de                  ; go to previous elem
.EndIf:

    ld a, l
    ld [wDiffPtr], a
    ld a, h
    ld [wDiffPtr + 1], a         ; update new elem

    ld a, [hl+]
    ldh [hDifficultyModifier], a
    
    ret                         ; hl should now point to the descriptor string

; Cycles to the next difficulty setting and returns the descriptor string
; @returns hl: pointer to descriptor string
DiffOptionNext::
    ld a, [wDiffPtr + 1]
    ld h, a
    ld a, [wDiffPtr]
    ld l, a
    cp LOW(DifficultyArrLast)
    jr nz, .Else
    ld a, h
    cp HIGH(DifficultyArrLast)
    jr nz, .Else                ; check whether we are the last elem

.IfAtLastElem:
    ld hl, DifficultyArr        ; looparound to last elem
    jr .EndIf
.Else:
    ld de, DIFF_STRUCT_SIZE
    add hl, de                  ; go to next elem
.EndIf:

    ld a, l
    ld [wDiffPtr], a
    ld a, h
    ld [wDiffPtr + 1], a         ; update new elem

    ld a, [hl+]
    ldh [hDifficultyModifier], a
    
    ret                         ; hl should now point to the descriptor string



ENDSECTION

