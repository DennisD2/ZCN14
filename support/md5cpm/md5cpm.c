/* md5cpm - minimal md5sum program, intended for use on CP/M
 *
 * Public domain by Russell Marks, 2022.
 *
 * Uses Solar Designer's md5.c/md5.h.
 *
 *
 * Compile with Hitech C 3.09, using e.g. "zxcc c md5cpm.c md5.c"
 */

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#ifdef CPM
#include <sys.h>
#endif

#include "md5.h"


void putlowname(FILE *fp,char *ptr)
{
int c;

for(;*ptr;ptr++)
  {
  /* Hitech C's tolower() is broken, requires isupper() check */
  c=*ptr;
  if(isupper(c)) c=tolower(c);
  fputc(c,fp);
  }
}


int main(int argc,char *argv[])
{
static char *bin2hex="0123456789abcdef";
static unsigned char buf[1024],result[16];
static MD5_CTX ctxbuf;
MD5_CTX *ctx=&ctxbuf;
FILE *in;
char *ptr;
int f,g,size;

#ifdef CPM
/* allow wildcards and redirection. Which should work with just
 * "-R" compiler option, but didn't seem to. Doing this makes
 * the .com file over 2k bigger, but still worth having. -rjm
 */
ptr=(char *)0x80;  /* CP/M command tail, length-then-data */
size=*ptr++;
if(size<0 || size>126) size=126;
ptr[size]=0;
_getargs(ptr,"");
#endif

if(argc==1)
  fprintf(stderr,"usage: md5cpm [files]\n"),exit(1);

for(f=1;f<argc;f++)
  {
  if((in=fopen(argv[f],"rb"))==NULL)
    {
    fprintf(stderr,"md5cpm: failed to open ");
    putlowname(stderr,argv[f]);
    fprintf(stderr,"\n");
    }
  else
    {
    MD5_Init(ctx);
    while((size=fread(buf,1,sizeof(buf),in))>0)
      MD5_Update(ctx,buf,size);
    MD5_Final(result,ctx);
    fclose(in);
    
    for(g=0;g<16;g++)
      {
      /* Hitech C has a weird %x in printf(), so... */
      putchar(bin2hex[(result[g]>>4)&15]);
      putchar(bin2hex[result[g]&15]);
      }
    
    putchar(32);
    putchar(32);
    putlowname(stdout,argv[f]);
    putchar('\n');
    }
  }

exit(0);
}
