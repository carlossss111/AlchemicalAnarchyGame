include "charmap.inc"

include "dimensionopt.inc"
include "difficultyopt.inc"

SECTION "BoardSettings", HRAM

    hWidth: db
    hHeight: db
    hDifficultyModifier: db

ENDSECTION


SECTION "OptionsConsts", ROM0

    ; 8 byte struct, 1) width, 2) height, 3) desc
    DimensionsArr:
    STRUCT_DIMENSIONS_DEF 4, 6,   "tiny  "
    STRUCT_DIMENSIONS_DEF 6, 8,   "small "
    STRUCT_DIMENSIONS_DEF 8, 12,  "medium"
    STRUCT_DIMENSIONS_DEF 12, 14, "large "
    STRUCT_DIMENSIONS_DEF 16, 16, "huge  "
    DimensionsArrEnd:

    ; 7 byte struct, 1) modifier, 2) desc
    DifficultyArr:
    STRUCT_DIFFICULTY_DEF 1, "easy  "
    STRUCT_DIFFICULTY_DEF 3, "normal"
    STRUCT_DIFFICULTY_DEF 5, "hard  "
    DifficultyArrEnd:

SECTION "OptionsVars", WRAM0

    wDimPtr: dw
    wDiffPtr: dw

SECTION "Options", ROM0

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
    ld [hWidth], a
    ld a, [DimensionsArr + DIM_HEIGHT]
    ld [hHeight], a
    ld a, [DifficultyArr + DIFF_MODIFIER] 
    ld [hDifficultyModifier], a
    ret
    



ENDSECTION

