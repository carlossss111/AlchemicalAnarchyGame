
/*******************************************************
* STACK
* A debugging watchpoint should be set at the top ($d060)
* This section doesn't do anything technically, it is for
* logical organisation.
********************************************************/
SECTION "Stack", WRAM0[$E000 - 4000]

    StackAllowance:: ds 4000    ; 4000 bytes to the top
    StackStart::                ; bottom of the stack, sp should start here

ENDSECTION

