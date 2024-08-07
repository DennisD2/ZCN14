/*
 * This is an OpenSSL-compatible implementation of the RSA Data Security, Inc.
 * MD5 Message-Digest Algorithm (RFC 1321).
 *
 * Homepage:
 * http://openwall.info/wiki/people/solar/software/public-domain-source-code/md5
 *
 * Author:
 * Alexander Peslyak, better known as Solar Designer <solar at openwall.com>
 *
 * This software was written by Alexander Peslyak in 2001.  No copyright is
 * claimed, and the software is hereby placed in the public domain.
 * In case this attempt to disclaim copyright and place the software in the
 * public domain is deemed null and void, then the software is
 * Copyright (c) 2001 Alexander Peslyak and it is hereby released to the
 * general public under the following terms:
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted.
 *
 * There's ABSOLUTELY NO WARRANTY, express or implied.
 *
 * (This is a heavily cut-down "BSD license".)
 *
 * This differs from Colin Plumb's older public domain implementation in that
 * no exactly 32-bit integer data type is required (any 32-bit or wider
 * unsigned integer data type will do), there's no compile-time endianness
 * configuration, and the function prototypes match OpenSSL's.  No code from
 * Colin Plumb's implementation has been reused; this comment merely compares
 * the properties of the two independent implementations.
 *
 * The primary goals of this implementation are portability and ease of use.
 * It is meant to be fast, but not as fast as possible.  Some known
 * optimizations are not included to reduce source code size and avoid
 * compile-time configuration.
 */

/* Added "L" suffix to all 32-bit hex constants, for CP/M -rjm */

#ifndef HAVE_OPENSSL

#include <string.h>

#include "md5.h"

/* A highly sophisticated memset() implementation :-) to replace
 * Hitech C's apparently very broken one. This is only used by
 * MD5_Final(), so the relative crapitude hardly matters. -rjm
 */
void xmemset(void *vp,int c,int n)
{
unsigned char *ptr=vp;
int f;

for(f=0;f<n;f++)
  *ptr++=c;
}

#define memset xmemset

/*
 * The basic MD5 functions.
 *
 * F and G are optimized compared to their RFC 1321 definitions for
 * architectures that lack an AND-NOT instruction, just like in Colin Plumb's
 * implementation.
 */
#define F(x, y, z)			((z) ^ ((x) & ((y) ^ (z))))
#define G(x, y, z)			((y) ^ ((z) & ((x) ^ (y))))
#define H(x, y, z)			(((x) ^ (y)) ^ (z))
#define H2(x, y, z)			((x) ^ ((y) ^ (z)))
#define I(x, y, z)			((y) ^ ((x) | ~(z)))

/*
 * The MD5 transformation for all four rounds.
 */
#define STEP(f, a, b, c, d, x, t, s) \
	(a) += f((b), (c), (d)) + (x) + (t); \
	(a) = (((a) << (s)) | (((a) & 0xffffffffL) >> (32 - (s)))); \
	(a) += (b);

/*
 * SET reads 4 input bytes in little-endian byte order and stores them in a
 * properly aligned word in host byte order.
 *
 * The check for little-endian architectures that tolerate unaligned memory
 * accesses is just an optimization.  Nothing will break if it fails to detect
 * a suitable architecture.
 *
 * Unfortunately, this optimization may be a C strict aliasing rules violation
 * if the caller's data buffer has effective type that cannot be aliased by
 * MD5_u32plus.  In practice, this problem may occur if these MD5 routines are
 * inlined into a calling function, or with future and dangerously advanced
 * link-time optimizations.  For the time being, keeping these MD5 routines in
 * their own translation unit avoids the problem.
 */
#if defined(__i386__) || defined(__x86_64__) || defined(__vax__)
#define SET(n) \
	(*(MD5_u32plus *)&ptr[(n) * 4])
#define GET(n) \
	SET(n)
#else
/* Hitech C workaround, (unsigned) casts below apparently required -rjm */
#define SET(n) \
	(ctx->block[(n)] = \
         (MD5_u32plus)(unsigned)ptr[(n) * 4] | \
         ((MD5_u32plus)(unsigned)ptr[(n) * 4 + 1] << 8) |       \
         ((MD5_u32plus)(unsigned)ptr[(n) * 4 + 2] << 16) |      \
         ((MD5_u32plus)(unsigned)ptr[(n) * 4 + 3] << 24))
#define GET(n) \
	(ctx->block[(n)])
#endif

/*
 * This processes one or more 64-byte data blocks, but does NOT update the bit
 * counters.  There are no alignment requirements.
 */
static const void *body(MD5_CTX *ctx, const void *data, unsigned long size)
{
	const unsigned char *ptr;
	MD5_u32plus a, b, c, d;
	MD5_u32plus saved_a, saved_b, saved_c, saved_d;

	ptr = (const unsigned char *)data;

	a = ctx->a;
	b = ctx->b;
	c = ctx->c;
	d = ctx->d;

	do {
		saved_a = a;
		saved_b = b;
		saved_c = c;
		saved_d = d;

/* Round 1 */
		STEP(F, a, b, c, d, SET(0), 0xd76aa478L, 7)
		STEP(F, d, a, b, c, SET(1), 0xe8c7b756L, 12)
		STEP(F, c, d, a, b, SET(2), 0x242070dbL, 17)
		STEP(F, b, c, d, a, SET(3), 0xc1bdceeeL, 22)
		STEP(F, a, b, c, d, SET(4), 0xf57c0fafL, 7)
		STEP(F, d, a, b, c, SET(5), 0x4787c62aL, 12)
		STEP(F, c, d, a, b, SET(6), 0xa8304613L, 17)
		STEP(F, b, c, d, a, SET(7), 0xfd469501L, 22)
		STEP(F, a, b, c, d, SET(8), 0x698098d8L, 7)
		STEP(F, d, a, b, c, SET(9), 0x8b44f7afL, 12)
		STEP(F, c, d, a, b, SET(10), 0xffff5bb1L, 17)
		STEP(F, b, c, d, a, SET(11), 0x895cd7beL, 22)
		STEP(F, a, b, c, d, SET(12), 0x6b901122L, 7)
		STEP(F, d, a, b, c, SET(13), 0xfd987193L, 12)
		STEP(F, c, d, a, b, SET(14), 0xa679438eL, 17)
		STEP(F, b, c, d, a, SET(15), 0x49b40821L, 22)

/* Round 2 */
		STEP(G, a, b, c, d, GET(1), 0xf61e2562L, 5)
		STEP(G, d, a, b, c, GET(6), 0xc040b340L, 9)
		STEP(G, c, d, a, b, GET(11), 0x265e5a51L, 14)
		STEP(G, b, c, d, a, GET(0), 0xe9b6c7aaL, 20)
		STEP(G, a, b, c, d, GET(5), 0xd62f105dL, 5)
		STEP(G, d, a, b, c, GET(10), 0x02441453L, 9)
		STEP(G, c, d, a, b, GET(15), 0xd8a1e681L, 14)
		STEP(G, b, c, d, a, GET(4), 0xe7d3fbc8L, 20)
		STEP(G, a, b, c, d, GET(9), 0x21e1cde6L, 5)
		STEP(G, d, a, b, c, GET(14), 0xc33707d6L, 9)
		STEP(G, c, d, a, b, GET(3), 0xf4d50d87L, 14)
		STEP(G, b, c, d, a, GET(8), 0x455a14edL, 20)
		STEP(G, a, b, c, d, GET(13), 0xa9e3e905L, 5)
		STEP(G, d, a, b, c, GET(2), 0xfcefa3f8L, 9)
		STEP(G, c, d, a, b, GET(7), 0x676f02d9L, 14)
		STEP(G, b, c, d, a, GET(12), 0x8d2a4c8aL, 20)

/* Round 3 */
		STEP(H, a, b, c, d, GET(5), 0xfffa3942L, 4)
		STEP(H2, d, a, b, c, GET(8), 0x8771f681L, 11)
		STEP(H, c, d, a, b, GET(11), 0x6d9d6122L, 16)
		STEP(H2, b, c, d, a, GET(14), 0xfde5380cL, 23)
		STEP(H, a, b, c, d, GET(1), 0xa4beea44L, 4)
		STEP(H2, d, a, b, c, GET(4), 0x4bdecfa9L, 11)
		STEP(H, c, d, a, b, GET(7), 0xf6bb4b60L, 16)
		STEP(H2, b, c, d, a, GET(10), 0xbebfbc70L, 23)
		STEP(H, a, b, c, d, GET(13), 0x289b7ec6L, 4)
		STEP(H2, d, a, b, c, GET(0), 0xeaa127faL, 11)
		STEP(H, c, d, a, b, GET(3), 0xd4ef3085L, 16)
		STEP(H2, b, c, d, a, GET(6), 0x04881d05L, 23)
		STEP(H, a, b, c, d, GET(9), 0xd9d4d039L, 4)
		STEP(H2, d, a, b, c, GET(12), 0xe6db99e5L, 11)
		STEP(H, c, d, a, b, GET(15), 0x1fa27cf8L, 16)
		STEP(H2, b, c, d, a, GET(2), 0xc4ac5665L, 23)

/* Round 4 */
		STEP(I, a, b, c, d, GET(0), 0xf4292244L, 6)
		STEP(I, d, a, b, c, GET(7), 0x432aff97L, 10)
		STEP(I, c, d, a, b, GET(14), 0xab9423a7L, 15)
		STEP(I, b, c, d, a, GET(5), 0xfc93a039L, 21)
		STEP(I, a, b, c, d, GET(12), 0x655b59c3L, 6)
		STEP(I, d, a, b, c, GET(3), 0x8f0ccc92L, 10)
		STEP(I, c, d, a, b, GET(10), 0xffeff47dL, 15)
		STEP(I, b, c, d, a, GET(1), 0x85845dd1L, 21)
		STEP(I, a, b, c, d, GET(8), 0x6fa87e4fL, 6)
		STEP(I, d, a, b, c, GET(15), 0xfe2ce6e0L, 10)
		STEP(I, c, d, a, b, GET(6), 0xa3014314L, 15)
		STEP(I, b, c, d, a, GET(13), 0x4e0811a1L, 21)
		STEP(I, a, b, c, d, GET(4), 0xf7537e82L, 6)
		STEP(I, d, a, b, c, GET(11), 0xbd3af235L, 10)
		STEP(I, c, d, a, b, GET(2), 0x2ad7d2bbL, 15)
		STEP(I, b, c, d, a, GET(9), 0xeb86d391L, 21)

		a += saved_a;
		b += saved_b;
		c += saved_c;
		d += saved_d;

		ptr += 64;
	} while (size -= 64);

	ctx->a = a;
	ctx->b = b;
	ctx->c = c;
	ctx->d = d;

	return ptr;
}

void MD5_Init(MD5_CTX *ctx)
{
	ctx->a = 0x67452301L;
	ctx->b = 0xefcdab89L;
	ctx->c = 0x98badcfeL;
	ctx->d = 0x10325476L;

	ctx->lo = 0L;
	ctx->hi = 0L;
}

void MD5_Update(MD5_CTX *ctx, const void *data, unsigned long size)
{
	MD5_u32plus saved_lo;
	unsigned long used, available;

	saved_lo = ctx->lo;
	if ((ctx->lo = (saved_lo + size) & 0x1fffffffL) < saved_lo)
		ctx->hi++;
	ctx->hi += size >> 29;

	used = saved_lo & 0x3fL;

	if (used) {
		available = 64 - used;

		if (size < available) {
			memcpy(&ctx->buffer[used], data, size);
			return;
		}

		memcpy(&ctx->buffer[used], data, available);
		data = (const unsigned char *)data + available;
		size -= available;
		body(ctx, ctx->buffer, 64);
	}

	if (size >= 64) {
		data = body(ctx, data, size & ~(unsigned long)0x3fL);
		size &= 0x3fL;
	}

	memcpy(ctx->buffer, data, size);
}

#define OUT(dst, src) \
	(dst)[0] = (unsigned char)(src); \
	(dst)[1] = (unsigned char)((src) >> 8); \
	(dst)[2] = (unsigned char)((src) >> 16); \
	(dst)[3] = (unsigned char)((src) >> 24);

void MD5_Final(unsigned char *result, MD5_CTX *ctx)
{
	unsigned int used, available;	/* 16-bit is good enough -rjm */

	used = ctx->lo & 0x3fL;

	ctx->buffer[used++] = 0x80;

	available = 64 - used;

	if (available < 8) {
		memset(&ctx->buffer[used], 0, available);
		body(ctx, ctx->buffer, 64);
		used = 0;
		available = 64;
	}

	memset(&ctx->buffer[used], 0, available - 8);

	ctx->lo <<= 3;
	OUT(&ctx->buffer[56], ctx->lo)
	OUT(&ctx->buffer[60], ctx->hi)

	body(ctx, ctx->buffer, 64);

	OUT(&result[0], ctx->a)
	OUT(&result[4], ctx->b)
	OUT(&result[8], ctx->c)
	OUT(&result[12], ctx->d)

	memset(ctx, 0, sizeof(*ctx));
}

#endif
