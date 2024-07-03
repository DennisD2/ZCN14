/* ramdfix - fix makecimg output to make NC200 ramdisk on B:
 *
 * usage: ramdfix tmp.card
 *
 * Public domain by Russell Marks, 2022-08-18
 */

#include <stdio.h>
#include <stdlib.h>


int main(int argc,char *argv[])
{
FILE *cimg;

if(argc!=2)
  printf("usage: ramdfix tmp.card\n"),exit(1);

if((cimg=fopen(argv[1],"r+"))==NULL)
  fprintf(stderr,"ramdfix: couldn't open file.\n"),exit(1);

if(fseek(cimg,256*1024+6,SEEK_SET)==-1)
  fprintf(stderr,"ramdfix: couldn't seek.\n"),exit(1);

if(fputc(48,cimg)==EOF || fputc(0,cimg)==EOF)
  fprintf(stderr,"ramdfix: couldn't write.\n"),exit(1);

fclose(cimg);

exit(0);
}
