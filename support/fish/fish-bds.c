/* hack of BSD 'fish' */
/* 2002 Sep 21 - modified for BDS C v1.6 */

/* 2022 Sep  3 - adopted the 1999 removal of BSD advertising clause */

/*-
 * Copyright (c) 1990 The Regents of the University of California.
 * All rights reserved.
 *
 * This code is derived from software contributed to Berkeley by
 * Muffy Barkocy.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the University nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE REGENTS AND CONTRIBUTORS ``AS IS'' AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

char *copyright;

/*static char sccsid[] = "@(#)fish.c	5.4 (Berkeley) 1/18/91";*/

#include <stdio.h>

#define	RANKS		13
#define	HANDSIZE	7
#define	CARDS		4

#define	USER		1
#define	COMPUTER	0
#define	OTHER(a)	(1 - (a))

char *cards[14];

#define	PRC(card)	printf(" %s", cards[card])

int promode;
int asked[RANKS], comphand[RANKS], deck[RANKS];
int userasked[RANKS], userhand[RANKS];

int lmove;

#define random nrand(1)


/* I only bother doing an equality test, as that's all 'fish' uses it
 * for.
 */
int strcasecmp(s1,s2)
char *s1,*s2;
{
while(tolower(*s1)==tolower(*s2)) {
	if(*s1==0) return(0);	/* equal */
	s1++; s2++;
}

return(1);	/* different */
}


main(argc, argv)
	int argc;
	char **argv;
{
	char *ptr;
	int ch, move, r;

        ptr=
"@(#) Copyright (c) 1990 The Regents of the University of California.\n\
 All rights reserved.\n";
        
	cards[ 0]="A"; cards[ 1]="2";
	cards[ 2]="3"; cards[ 3]="4";
	cards[ 4]="5"; cards[ 5]="6";
	cards[ 6]="7"; cards[ 7]="8";
	cards[ 8]="9"; cards[ 9]="10";
	cards[10]="J"; cards[11]="Q";
	cards[12]="K"; cards[13]=NULL;
        lmove=0;
        
	if(argc==2 && strcmp(argv[1],"-p")==0)
		promode = 1;

        /* set seed from R */
        ptr=0xf0;
        *ptr++=0xed; *ptr++=0x5f;	/* ld a,r */
        *ptr=0xc9;			/* ret */
        r=calla(0xf0,0,0,0,0);
        r=256*r+r;
        nrand(-1,r,r,r);
        
	init();

	if (nrandom(2) == 1) {
		printplayer(COMPUTER);
		printf("get to start.\n");
		goto istart;
	}
	printplayer(USER);
	printf("get to start.\n");
	
	for (;;) {
		move = usermove();
		if (!comphand[move]) {
			if (gofish(move, USER, userhand))
				continue;
		} else {
			goodmove(USER, move, userhand, comphand);
			continue;
		}

istart:		for (;;) {
			move = compmove();
			if (!userhand[move]) {
				if (!gofish(move, COMPUTER, comphand))
					break;
			} else
				goodmove(COMPUTER, move, comphand, userhand);
		}
	}
	/* NOTREACHED */
}

usermove()
{
	register int n;
	register char **p;
	char buf[256];

	printf("\nYour hand is:");
	printhand(userhand);

	for (;;) {
		printf("You ask me for: ");
		fflush(stdout);
		if (fgets(buf, 256, stdin) == NULL)
			exit(0);
		if (buf[0] == '\0')
			continue;
		if (buf[0] == '\n') {
			printf("%d cards in my hand, %d in the pool.\n",
			    countcards(comphand), countcards(deck));
			printf("My books:");
			countbooks(comphand);
			continue;
		}
		buf[strlen(buf) - 1] = '\0';
		if (!strcasecmp(buf, "p") && !promode) {
			promode = 1;
			printf("Entering pro mode.\n");
			continue;
		}
		if (!strcasecmp(buf, "quit"))
			exit(0);
		for (p = cards; *p; ++p)
			if (!strcasecmp(*p, buf))
				break;
		if (!*p) {
			printf("I don't understand!\n");
			continue;
		}
		n = p - cards;
		if (userhand[n]) {
			userasked[n] = 1;
			return(n);
		}
		if (nrandom(3) == 1)
			printf("You don't have any of those!\n");
		else
			printf("You don't have any %s's!\n", cards[n]);
		if (nrandom(4) == 1)
			printf("No cheating!\n");
		printf("Guess again.\n");
	}
	/* NOTREACHED */
}

compmove()
{
/*	static int lmove;*/

	if (promode)
		lmove = promove();
	else {
		do {
			lmove = (lmove + 1) % RANKS;
		} while (!comphand[lmove] || comphand[lmove] == CARDS);
	}
	asked[lmove] = 1;

	printf("I ask you for: %s.  ", cards[lmove]);
	return(lmove);
}

promove()
{
	register int i, max;

	for (i = 0; i < RANKS; ++i)
		if (userasked[i] &&
		    comphand[i] > 0 && comphand[i] < CARDS) {
			userasked[i] = 0;
			return(i);
		}
	if (nrandom(3) == 1) {
		for (i = 0;; ++i)
			if (comphand[i] && comphand[i] != CARDS) {
				max = i;
				break;
			}
		while (++i < RANKS) 
			if (comphand[i] != CARDS &&
			    comphand[i] > comphand[max])
				max = i;
		return(max);
	} 
	if (nrandom(1024) == 0723) {
		for (i = 0; i < RANKS; ++i)
			if (userhand[i] && comphand[i])
				return(i);
	}
	for (;;) {
		for (i = 0; i < RANKS; ++i)
			if (comphand[i] && comphand[i] != CARDS &&
			    !asked[i])
				return(i);
		for (i = 0; i < RANKS; ++i)
			asked[i] = 0;
	}
	/* NOTREACHED */
}

drawcard(player, hand)
	int player;
	int *hand;
{
	int card;

	while (deck[card = nrandom(RANKS)] == 0);
	++hand[card];
	--deck[card];
	if (player == USER || hand[card] == CARDS) {
		printplayer(player);
		printf("drew %s", cards[card]);
		if (hand[card] == CARDS) {
			printf(" and made a book of %s's!\n",
			     cards[card]);
			chkwinner(player, hand);
		} else
			printf(".  ");
	}
	return(card);
}

gofish(askedfor, player, hand)
	int askedfor, player;
	int *hand;
{
	printplayer(OTHER(player));
	printf("say \"GO FISH!\"\n");
	if (askedfor == drawcard(player, hand)) {
		printplayer(player);
		printf("drew the guess!  ");
		printplayer(player);
		printf("get to ask again!\n");
		return(1);
	}
	return(0);
}

goodmove(player, move, hand, opphand)
	int player, move;
	int *hand, *opphand;
{
	printplayer(OTHER(player));
	printf("have %d %s%s.  ",
	    opphand[move], cards[move], opphand[move] == 1 ? "": "'s");

	hand[move] += opphand[move];
	opphand[move] = 0;

	if (hand[move] == CARDS) {
		printplayer(player);
		printf("made a book of %s's!\n", cards[move]);
		chkwinner(player, hand);
	}

	chkwinner(OTHER(player), opphand);

	printplayer(player);
	printf("get another guess!\n");
}

chkwinner(player, hand)
	int player;
	register int *hand;
{
	register int cb, i, ub;

	for (i = 0; i < RANKS; ++i)
		if (hand[i] > 0 && hand[i] < CARDS)
			return;
	printplayer(player);
	printf("don't have any more cards!\n");
	printf("My books:");
	cb = countbooks(comphand);
	printf("Your books:");
	ub = countbooks(userhand);
	printf("\nI have %d, you have %d.\n", cb, ub);
	if (ub > cb) {
		printf("\nYou win!!!\n");
		if (nrandom(1024) == 0723)
			printf("Cheater, cheater, pumpkin eater!\n");
	} else if (cb > ub) {
		printf("\nI win!!!\n");
		if (nrandom(1024) == 0723)
			printf("Hah!  Stupid peasant!\n");
	} else
		printf("\nTie!\n");
	exit(0);
}

printplayer(player)
	int player;
{
	switch (player) {
	case COMPUTER:
		printf("I ");
		break;
	case USER:
		printf("You ");
		break;
	}
}

printhand(hand)
	int *hand;
{
	register int book, i, j;

	for (book = i = 0; i < RANKS; i++)
		if (hand[i] < CARDS)
			for (j = hand[i]; --j >= 0;) 
				PRC(i);
		else
			++book;
	if (book) {
		printf(" + Book%s of", book > 1 ? "s" : "");
		for (i = 0; i < RANKS; i++)
			if (hand[i] == CARDS)
				PRC(i);
	}
	putchar('\n');
}

countcards(hand)
	register int *hand;
{
	register int i, count;

	for (count = i = 0; i < RANKS; i++)
		count += *hand++;
	return(count);
}

countbooks(hand)
	int *hand;
{
	int i, count;

	for (count = i = 0; i < RANKS; i++)
		if (hand[i] == CARDS) {
			++count;
			PRC(i);
		}
	if (!count)
		printf(" none");
	putchar('\n');
	return(count);
}

init()
{
	register int i, rank;

	for (i = 0; i < RANKS; ++i)
		deck[i] = CARDS;
	for (i = 0; i < HANDSIZE; ++i) {
		while (!deck[rank = nrandom(RANKS)]);
		++userhand[rank];
		--deck[rank];
	}
	for (i = 0; i < HANDSIZE; ++i) {
		while (!deck[rank = nrandom(RANKS)]);
		++comphand[rank];
		--deck[rank];
	}
}

nrandom(n)
	int n;
{
	int rand();

	return(rand() % n);
}

usage()
{
	printf("usage: fish [-p]\n");
	exit(1);
}
