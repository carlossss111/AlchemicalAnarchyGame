include "hardware.inc"

/*******************************************************
* RENDER QUEUE
* A cyclical queue of MAX_BYTES length. Once initialized,
* the queue can be added to with positions and tilemaps
* during at ANY time.
*
* These tilemaps can then be transferred to VRAM from the
* queue during a VBlank.
********************************************************/
SECTION "RenderQueueVars", WRAM0

    def MAX_BYTES equ (255) * 4 ; max bytes of cyclical queue (/4 = max no. of tiles per frame)

    wSpHolder: dw               ; holders the original stack pointer addr when in use
    wVramBank: dw               ; which VRAM bank to target ($9800 or $9C00)
    wHead: dw                   ; head of the queue
    wTail: dw                   ; tail of the queue
    wQueueBuffer: ds MAX_BYTES  ; max len = 255 (1 byte)

SECTION "RenderQueue", ROM0

; Initialise the render queue
InitRenderQueue::
    ld a, LOW(TILEMAP0)
    ld [wVramBank], a
    ld a, HIGH(TILEMAP0)
    ld [wVramBank + 1], a       ; store VRAM bank as TILEMAP0 by default
    
    ld a, LOW(wQueueBuffer)
    ld [wHead], a
    ld [wTail], a
    ld a, HIGH(wQueueBuffer)
    ld [wHead + 1], a
    ld [wTail + 1], a           ; init pointers to the start of the buffer
    ret

; Enqueue a tilemap and a screen position to be rendered later
; @param b: tilemap x position
; @param c: tilemap y position 
; @param d: new tile index 
EnqueueTilemap::
    ; find head 
    di                          ; disable interrupts
    ld a, [wHead]
    ld l, a
    ld a, [wHead + 1]
    ld h, a                     ; load head address
    
    push de                     ; store new tile index
    ld d, 0
    ld e, b

    ; some absolute fucking cracked 8-bit wizardry I cooked up
    xor a
    sla c                       ; y * 2
    sla c                       ; y * 4
    sla c                       ; y * 8

    sla c                       ; y * 16 (lowest 8 bits)
    adc a, 0                    ; a = 0 + carry
    ld b, a                     ; b = 0 + carry
    xor a
    sla c                       ; y * 32 (lowest 8 bits)
    adc a, 0                    ; a = 0 + carry2 
    sla b                       ; b = 0 + carry1 leftshifted
    or a, b                     ; a = OR of both carries in bit position 0 and 1
    ld b, a                     ; y * 32 (highest 8 bits)

    ld hl, TILEMAP0             ; hl = TILEMAP
    add hl, bc                  ; hl = TILEMAP + (y * 32)
    add hl, de                  ; hl = TILEMAP + (y * 32) + x
    ld b, h
    ld c, l

    ld a, [wHead]
    ld l, a
    ld a, [wHead + 1]
    ld h, a                     ; load head address
    
    ; save the tilemap address
    ld [hl], c                  ; load tilemap address !!
    inc hl
    ld [hl], b                  ; load tilemap address !!
    inc hl

    ; save the tile index
    pop de                      ; restore tile index
    ld [hl], d                  ; enqueue tile index
    inc hl
    ld [hl], 0                  ; align to 2 bytes each
    inc hl

    ; check if we need to wrap the head back around to the start of the buffer
    ld bc, ($FFFF - wQueueBuffer - MAX_BYTES + 1)
    ld d, h
    ld e, l
    add hl, bc                  ; add head and starting location
    jr nc, .NoOverflow          ; continue IF we are at the end of the queue
    ld a, LOW(wQueueBuffer)
    ld [wHead], a
    ld a, HIGH(wQueueBuffer)
    ld [wHead + 1], a           ; if we are, set the head to the beginning
    jr .Ret
.NoOverflow

    ; store new head position
    ld a, e
    ld [wHead], a
    ld a, d
    ld [wHead + 1], a
.Ret
    reti                        ; reenable interrupts

; Dequeue all tilemap values and move them into VRAM
; This method should ONLY be called during a VBlank
; (Ab)uses the stack pointer for speed
; @uses hl, de
DequeueTilemapsToVRAM::
    ld [wSpHolder], sp          ; save the stack pointer

    ; find tail
    ld a, [wTail]
    ld l, a
    ld a, [wTail + 1]
    ld h, a
    ld sp, hl                   ; point sp to the tail

    ; while &head != &tail
.DequeueLoopConditions:
    ld hl, sp + 0
    ld a, [wHead]
    cp a, l                     ; if HIGH(sp) == HIGH(head)
    jr nz, .DequeueLoop
    ld a, [wHead + 1]
    cp a, h                     ; && LOW(sp) == LOW(head)
    jr z, .EndLoop              ; then exit the loop

.DequeueLoop:
    ; break if LY == 152 (vblank about to end)
    ldh a, [rLY]
    cp a, 152
    jr z, .EndLoop

    ; load index into VRAM
    pop hl                      ; dequeue tilemap address
    pop de                      ; dequeue tilemap value, e=index
    ld [hl], e                  ; load the tile index into the tilemap position !!

    ; check if we need to wrap the tail to the start of the buffer
    ld hl, ($FFFF - wQueueBuffer - MAX_BYTES + 1)
    add hl, sp                  ; add head and start addr
    jr nc, .NoOverflow          ; if we are at the end
    ld sp, wQueueBuffer         ; loop sp to the beginning
.NoOverflow
    jr .DequeueLoopConditions

.EndLoop
    ; store the tail position
    ld [wTail], sp              ; update the tail
    
    ; restore the stack pointer to it's original position
    ld a, [wSpHolder]
    ld l, a
    ld a, [wSpHolder + 1]
    ld h, a
    ld sp, hl                   ; restore stack pointer
    ret
    
ENDSECTION

