/* makecimg - make a bootable 1024k card image for ZCN
 *
 * usage: makecimg <zcn.bin >out.card
 *
 * zcn.bin must not exceed 12288 bytes (12*1024).
 * boot.z as used must have assembled to exactly 66 bytes.
 * (This program checks for the "jp (hl)" from boot.z in zcn.bin.)
 *
 * The card output is roughly the same as after doing the following in
 * ZCN:
 *
 * format a:
 * format b:
 * format c:
 * format d:
 * sys a:
 *
 * (It's not a perfect match, as ZCN dumps the copy currently running
 * in memory when you do "sys", so the contents of the system blocks
 * would inevitably vary etc.)
 *
 * Public domain by Russell Marks, 2022-08-05
 */

/* This makes awfully large assumptions about boot.z and cardboot.z
 * essentially not changing at all - but to be fair, at the time of
 * writing they haven't changed since 1995, and it does do some very
 * basic sanity checks at least.
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define ZCNMAX		(12*1024)

#define BOOTZ_LEN	66

#define CBOOT_LEN	45
#define CBOOT2_LEN	40

#define CF1BOOT		128
#define CF1FNX		512


/* start of first block on bootable drive, 16 chars */
static unsigned char zcnbthed[]=
  "\x18\x7eZCN1\x00\x04\x0c\x02\x00\x00\x00\x00\x00\x00";

/* start of first block on non-bootable drive, 16 chars */
static unsigned char zcnnbhed[]=
  "\xc9\x7eZCN1\x00\x04\x00\x02\x00\x00\x00\x00\x00\x00";

#define ZCNHEDBIT_LEN	16


void write_err(void)
{
fprintf(stderr,"makecimg: write error\n");
}


int main(void)
{
/* 1k larger than ZCNMAX to allow for file size check, simplify the
 * zero padding, and simplify finding bits in zcn.bin.
 */
static unsigned char zcnbuf[ZCNMAX+1024];
static unsigned char bootbuf[1024];
static unsigned char zerobuf[1024];
static unsigned char e5buf[1024];
int f,d,siz;
int cbootst,count;

if(isatty(fileno(stdout)))
  fprintf(stderr,"makecimg: not writing to tty\n"),exit(1);

/* not really needed I suppose, but nicer to do it */
memset(zcnbuf,0,sizeof(zcnbuf));
memset(zerobuf,0,sizeof(zerobuf));

/* definitely needed :-) */
memset(e5buf,0xe5,sizeof(e5buf));


/* read zcn.bin and write drive A: */

if((siz=fread(zcnbuf,1,sizeof(zcnbuf),stdin))>ZCNMAX)
  fprintf(stderr,"makecimg: zcn.bin too big\n"),exit(1);

if(zcnbuf[BOOTZ_LEN-1]!=0xe9)
  fprintf(stderr,"makecimg: boot.bin part must be %d bytes\n",
    BOOTZ_LEN),exit(1);

/* go digging for cbootst (from cardboot.z).
 * The "di" and "ld sp,08000h" at the start should be unique.
 */
cbootst=count=0;
for(f=0;f<ZCNMAX;f++)
  if(memcmp(zcnbuf+BOOTZ_LEN+f,"\xf3\x31\x00\x80",4)==0)
    cbootst=BOOTZ_LEN+f,count++;

/* must find the above instructions exactly once, and must
 * have NC100PRG signature at cbootst+CBOOT_LEN.
 */
if(count!=1 || memcmp(zcnbuf+cbootst+CBOOT_LEN,"NC100PRG",8)!=0)
  fprintf(stderr,"makecimg: cardboot part not uniquely found, aborting\n"),
    exit(1);

/* make bootable boot block for A: */
memset(bootbuf,0,sizeof(bootbuf));
memcpy(bootbuf,zcnbthed,ZCNHEDBIT_LEN);
memcpy(bootbuf+CF1BOOT,zcnbuf+cbootst,CBOOT_LEN);
memcpy(bootbuf+CF1FNX,zcnbuf+cbootst+CBOOT_LEN,CBOOT2_LEN);

/* write it */
if(fwrite(bootbuf,1,sizeof(bootbuf),stdout)!=sizeof(bootbuf))
  write_err(),exit(1);

/* zcn.bin, minus boot.z and padded to 12k at end with zeroes */
if(fwrite(zcnbuf+BOOTZ_LEN,1,ZCNMAX,stdout)!=ZCNMAX)
  write_err(),exit(1);

/* empty dir/data blocks */
for(f=0;f<256-1-12;f++)
  if(fwrite(e5buf,1,sizeof(e5buf),stdout)!=sizeof(e5buf))
    write_err(),exit(1);


/* zero out boot block for the non-bootable drives */
memset(bootbuf,0,sizeof(bootbuf));

/* copy, uh, non-boot boot block :-) */
memcpy(bootbuf,zcnnbhed,ZCNHEDBIT_LEN);

/* write drives B:/C:/D: as blank */
for(d=1;d<4;d++)
  {
  if(fwrite(bootbuf,1,sizeof(bootbuf),stdout)!=sizeof(bootbuf))
    write_err(),exit(1);

  for(f=1;f<=2;f++)
    if(fwrite(e5buf,1,sizeof(e5buf),stdout)!=sizeof(e5buf))
      write_err(),exit(1);
  
  for(;f<256;f++)
    if(fwrite(zerobuf,1,sizeof(zerobuf),stdout)!=sizeof(zerobuf))
      write_err(),exit(1);
  }

exit(0);
}
