/* zx0full - all source files for zx0 smushed together.
 *
 * Five files for not much code just seemed silly. -rjm
 */

/*
 * (c) Copyright 2021 by Einar Saukas. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *     * Redistributions of source code must retain the above copyright
 *       notice, this list of conditions and the following disclaimer.
 *     * Redistributions in binary form must reproduce the above copyright
 *       notice, this list of conditions and the following disclaimer in the
 *       documentation and/or other materials provided with the distribution.
 *     * The name of its author may not be used to endorse or promote products
 *       derived from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
 * DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 * (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define INITIAL_OFFSET 1

#define FALSE 0
#define TRUE 1

#define QTY_BLOCKS 10000

#define MAX_SCALE 50

#define MAX_OFFSET_ZX0    32640
#define MAX_OFFSET_ZX7     2176

typedef struct block_t {
    struct block_t *chain;
    struct block_t *ghost_chain;
    int bits;
    int index;
    int offset;
    int references;
} BLOCK;

unsigned char* output_data;
int output_index;
int input_index;
int bit_index;
int bit_mask;
int diff;
int backtrack;

BLOCK *ghost_root = NULL;
BLOCK *dead_array = NULL;
int dead_array_size = 0;

void read_bytes(int n, int *delta) {
    input_index += n;
    diff += n;
    if (*delta < diff)
        *delta = diff;
}

void write_byte(int value) {
    output_data[output_index++] = value;
    diff--;
}

void write_bit(int value) {
    if (backtrack) {
        if (value)
            output_data[output_index-1] |= 1;
        backtrack = FALSE;
    } else {
        if (!bit_mask) {
            bit_mask = 128;
            bit_index = output_index;
            write_byte(0);
        }
        if (value)
            output_data[bit_index] |= bit_mask;
        bit_mask >>= 1;
    }
}

void write_interlaced_elias_gamma(int value, int backwards_mode, int invert_mode) {
    int i;

    for (i = 2; i <= value; i <<= 1)
        ;
    i >>= 1;
    while (i >>= 1) {
        write_bit(backwards_mode);
        write_bit(invert_mode ? !(value & i) : (value & i));
    }
    write_bit(!backwards_mode);
}

unsigned char *compress(BLOCK *optimal, unsigned char *input_data, int input_size, int skip, int backwards_mode, int invert_mode, int *output_size, int *delta) {
    BLOCK *prev;
    BLOCK *next;
    int last_offset = INITIAL_OFFSET;
    int length;
    int i;

    /* calculate and allocate output buffer */
    *output_size = (optimal->bits+25)/8;
    output_data = (unsigned char *)malloc(*output_size);
    if (!output_data) {
         fprintf(stderr, "Error: Insufficient memory\n");
         exit(1);
    }

    /* un-reverse optimal sequence */
    prev = NULL;
    while (optimal) {
        next = optimal->chain;
        optimal->chain = prev;
        prev = optimal;
        optimal = next;
    }

    /* initialize data */
    diff = *output_size-input_size+skip;
    *delta = 0;
    input_index = skip;
    output_index = 0;
    bit_mask = 0;
    backtrack = TRUE;

    /* generate output */
    for (optimal = prev->chain; optimal; prev=optimal, optimal = optimal->chain) {
        length = optimal->index-prev->index;

        if (!optimal->offset) {
            /* copy literals indicator */
            write_bit(0);

            /* copy literals length */
            write_interlaced_elias_gamma(length, backwards_mode, FALSE);

            /* copy literals values */
            for (i = 0; i < length; i++) {
                write_byte(input_data[input_index]);
                read_bytes(1, delta);
            }
        } else if (optimal->offset == last_offset) {
            /* copy from last offset indicator */
            write_bit(0);

            /* copy from last offset length */
            write_interlaced_elias_gamma(length, backwards_mode, FALSE);
            read_bytes(length, delta);
        } else {
            /* copy from new offset indicator */
            write_bit(1);

            /* copy from new offset MSB */
            write_interlaced_elias_gamma((optimal->offset-1)/128+1, backwards_mode, invert_mode);

            /* copy from new offset LSB */
            if (backwards_mode)
                write_byte(((optimal->offset-1)%128)<<1);
            else
                write_byte((127-(optimal->offset-1)%128)<<1);

            /* copy from new offset length */
            backtrack = TRUE;
            write_interlaced_elias_gamma(length-1, backwards_mode, FALSE);
            read_bytes(length, delta);

            last_offset = optimal->offset;
        }
    }

    /* end marker */
    write_bit(1);
    write_interlaced_elias_gamma(256, backwards_mode, invert_mode);

    /* done! */
    return output_data;
}


BLOCK *allocate(int bits, int index, int offset, BLOCK *chain) {
    BLOCK *ptr;

    if (ghost_root) {
        ptr = ghost_root;
        ghost_root = ptr->ghost_chain;
        if (ptr->chain && !--ptr->chain->references) {
            ptr->chain->ghost_chain = ghost_root;
            ghost_root = ptr->chain;
        }
    } else {
        if (!dead_array_size) {
            dead_array = (BLOCK *)malloc(QTY_BLOCKS*sizeof(BLOCK));
            if (!dead_array) {
                fprintf(stderr, "Error: Insufficient memory\n");
                exit(1);
            }
            dead_array_size = QTY_BLOCKS;
        }
        ptr = &dead_array[--dead_array_size];
    }
    ptr->bits = bits;
    ptr->index = index;
    ptr->offset = offset;
    if (chain)
        chain->references++;
    ptr->chain = chain;
    ptr->references = 0;
    return ptr;
}

void assign(BLOCK **ptr, BLOCK *chain) {
    chain->references++;
    if (*ptr && !--(*ptr)->references) {
        (*ptr)->ghost_chain = ghost_root;
        ghost_root = *ptr;
    }
    *ptr = chain;
}


int offset_ceiling(int index, int offset_limit) {
    return index > offset_limit ? offset_limit : index < INITIAL_OFFSET ? INITIAL_OFFSET : index;
}

int elias_gamma_bits(int value) {
    int bits = 1;
    while (value >>= 1)
        bits += 2;
    return bits;
}

BLOCK* optimize(unsigned char *input_data, int input_size, int skip, int offset_limit) {
    BLOCK **last_literal;
    BLOCK **last_match;
    BLOCK **optimal;
    int* match_length;
    int* best_length;
    int best_length_size;
    int bits;
    int index;
    int offset;
    int length;
    int bits2;
    int dots = 2;
    int max_offset = offset_ceiling(input_size-1, offset_limit);

    /* allocate all main data structures at once */
    last_literal = (BLOCK **)calloc(max_offset+1, sizeof(BLOCK *));
    last_match = (BLOCK **)calloc(max_offset+1, sizeof(BLOCK *));
    optimal = (BLOCK **)calloc(input_size, sizeof(BLOCK *));
    match_length = (int *)calloc(max_offset+1, sizeof(int));
    best_length = (int *)malloc(input_size*sizeof(int));
    if (!last_literal || !last_match || !optimal || !match_length || !best_length) {
        fprintf(stderr, "Error: Insufficient memory\n");
        exit(1);
    }
    if (input_size > 2)
        best_length[2] = 2;

    /* start with fake block */
    assign(&last_match[INITIAL_OFFSET], allocate(-1, skip-1, INITIAL_OFFSET, NULL));

    printf("[");

    /* process remaining bytes */
    for (index = skip; index < input_size; index++) {
        best_length_size = 2;
        max_offset = offset_ceiling(index, offset_limit);
        for (offset = 1; offset <= max_offset; offset++) {
            if (index != skip && index >= offset && input_data[index] == input_data[index-offset]) {
                /* copy from last offset */
                if (last_literal[offset]) {
                    length = index-last_literal[offset]->index;
                    bits = last_literal[offset]->bits + 1 + elias_gamma_bits(length);
                    assign(&last_match[offset], allocate(bits, index, offset, last_literal[offset]));
                    if (!optimal[index] || optimal[index]->bits > bits)
                        assign(&optimal[index], last_match[offset]);
                }
                /* copy from new offset */
                if (++match_length[offset] > 1) {
                    if (best_length_size < match_length[offset]) {
                        bits = optimal[index-best_length[best_length_size]]->bits + elias_gamma_bits(best_length[best_length_size]-1);
                        do {
                            best_length_size++;
                            bits2 = optimal[index-best_length_size]->bits + elias_gamma_bits(best_length_size-1);
                            if (bits2 <= bits) {
                                best_length[best_length_size] = best_length_size;
                                bits = bits2;
                            } else {
                                best_length[best_length_size] = best_length[best_length_size-1];
                            }
                        } while(best_length_size < match_length[offset]);
                    }
                    length = best_length[match_length[offset]];
                    bits = optimal[index-length]->bits + 8 + elias_gamma_bits((offset-1)/128+1) + elias_gamma_bits(length-1);
                    if (!last_match[offset] || last_match[offset]->index != index || last_match[offset]->bits > bits) {
                        assign(&last_match[offset], allocate(bits, index, offset, optimal[index-length]));
                        if (!optimal[index] || optimal[index]->bits > bits)
                            assign(&optimal[index], last_match[offset]);
                    }
                }
            } else {
                /* copy literals */
                match_length[offset] = 0;
                if (last_match[offset]) {
                    length = index-last_match[offset]->index;
                    bits = last_match[offset]->bits + 1 + elias_gamma_bits(length) + length*8;
                    assign(&last_literal[offset], allocate(bits, index, 0, last_match[offset]));
                    if (!optimal[index] || optimal[index]->bits > bits)
                        assign(&optimal[index], last_literal[offset]);
                }
            }
        }

        /* indicate progress */
        if (index*MAX_SCALE/input_size > dots) {
            printf(".");
            fflush(stdout);
            dots++;
        }
    }

    printf("]\n");

    return optimal[input_size-1];
}


void reverse(unsigned char *first, unsigned char *last) {
    unsigned char c;

    while (first < last) {
        c = *first;
        *first++ = *last;
        *last-- = c;
    }
}

int main(int argc, char *argv[]) {
    int skip = 0;
    int forced_mode = FALSE;
    int quick_mode = FALSE;
    int backwards_mode = FALSE;
    int classic_mode = FALSE;
    char *output_name;
    unsigned char *input_data;
    unsigned char *output_data;
    FILE *ifp;
    FILE *ofp;
    int input_size;
    int output_size;
    int partial_counter;
    int total_counter;
    int delta;
    int i;

    printf("ZX0 v2.2: Optimal data compressor by Einar Saukas\n");

    /* process optional parameters */
    for (i = 1; i < argc && (*argv[i] == '-' || *argv[i] == '+'); i++) {
        if (!strcmp(argv[i], "-f")) {
            forced_mode = TRUE;
        } else if (!strcmp(argv[i], "-c")) {
            classic_mode = TRUE;
        } else if (!strcmp(argv[i], "-b")) {
            backwards_mode = TRUE;
        } else if (!strcmp(argv[i], "-q")) {
            quick_mode = TRUE;
        } else if ((skip = atoi(argv[i])) <= 0) {
            fprintf(stderr, "Error: Invalid parameter %s\n", argv[i]);
            exit(1);
        }
    }

    /* determine output filename */
    if (argc == i+1) {
        output_name = (char *)malloc(strlen(argv[i])+5);
        strcpy(output_name, argv[i]);
        strcat(output_name, ".zx0");
    } else if (argc == i+2) {
        output_name = argv[i+1];
    } else {
        fprintf(stderr, "Usage: %s [-f] [-c] [-b] [-q] input [output.zx0]\n"
                        "  -f      Force overwrite of output file\n"
                        "  -c      Classic file format (v1.*)\n"
                        "  -b      Compress backwards\n"
                        "  -q      Quick non-optimal compression\n", argv[0]);
        exit(1);
    }

    /* open input file */
    ifp = fopen(argv[i], "rb");
    if (!ifp) {
        fprintf(stderr, "Error: Cannot access input file %s\n", argv[i]);
        exit(1);
    }
    /* determine input size */
    fseek(ifp, 0L, SEEK_END);
    input_size = ftell(ifp);
    fseek(ifp, 0L, SEEK_SET);
    if (!input_size) {
        fprintf(stderr, "Error: Empty input file %s\n", argv[i]);
        exit(1);
    }

    /* validate skip against input size */
    if (skip >= input_size) {
        fprintf(stderr, "Error: Skipping entire input file %s\n", argv[i]);
        exit(1);
    }

    /* allocate input buffer */
    input_data = (unsigned char *)malloc(input_size);
    if (!input_data) {
        fprintf(stderr, "Error: Insufficient memory\n");
        exit(1);
    }

    /* read input file */
    total_counter = 0;
    do {
        partial_counter = fread(input_data+total_counter, sizeof(char), input_size-total_counter, ifp);
        total_counter += partial_counter;
    } while (partial_counter > 0);

    if (total_counter != input_size) {
        fprintf(stderr, "Error: Cannot read input file %s\n", argv[i]);
        exit(1);
    }

    /* close input file */
    fclose(ifp);

    /* check output file */
    if (!forced_mode && fopen(output_name, "rb") != NULL) {
        fprintf(stderr, "Error: Already existing output file %s\n", output_name);
        exit(1);
    }

    /* create output file */
    ofp = fopen(output_name, "wb");
    if (!ofp) {
        fprintf(stderr, "Error: Cannot create output file %s\n", output_name);
        exit(1);
    }

    /* conditionally reverse input file */
    if (backwards_mode)
        reverse(input_data, input_data+input_size-1);

    /* generate output file */
    output_data = compress(optimize(input_data, input_size, skip, quick_mode ? MAX_OFFSET_ZX7 : MAX_OFFSET_ZX0), input_data, input_size, skip, backwards_mode, !classic_mode && !backwards_mode, &output_size, &delta);

    /* conditionally reverse output file */
    if (backwards_mode)
        reverse(output_data, output_data+output_size-1);

    /* write output file */
    if (fwrite(output_data, sizeof(char), output_size, ofp) != output_size) {
        fprintf(stderr, "Error: Cannot write output file %s\n", output_name);
        exit(1);
    }

    /* close output file */
    fclose(ofp);

    /* done! */
    printf("File%s compressed%s from %d to %d bytes! (delta %d)\n", (skip ? " partially" : ""), (backwards_mode ? " backwards" : ""), input_size-skip, output_size, delta);

    return 0;
}
