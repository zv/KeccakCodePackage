/*
Implementation by the Keccak, Keyak and Ketje Teams, namely, Guido Bertoni,
Joan Daemen, Michaël Peeters, Gilles Van Assche and Ronny Van Keer, hereby
denoted as "the implementer".

For more information, feedback or questions, please refer to our websites:
http://keccak.noekeon.org/
http://keyak.noekeon.org/
http://ketje.noekeon.org/

To the extent possible under law, the implementer has waived all copyright
and related or neighboring rights to the source code in this file.
http://creativecommons.org/publicdomain/zero/1.0/
*/

#ifndef _KeccakP400Interface_h_
#define _KeccakP400Interface_h_

#include "KeccakF-400-interface.h"

#undef KeccakF_400
#define KeccakP_400

/** Function to apply Keccak-p[400,nr] on the state.
  * @param  state   Pointer to the state.
  * @param  nr      Number of rounds.
  */
void KeccakP400_StatePermute(void *state, unsigned int nr);

#endif
