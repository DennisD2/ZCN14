/* optdir-c - "optdir"-like for full 1024k ZCN card image
 *
 * usage: optdir-c <in.card >out.card
 *
 * Modifies card image, operating as a filter.
 *
 * (This also removes the sub-record file length field that cpmtools
 * bizarrely writes.)
 *
 * Must have A:/B:/C:/D:, all formatted in ZCN format.
 * All drives must have exactly two directory blocks.
 * Any drives can be bootable or not.
 *
 * Public domain by Russell Marks, 2022-08-05
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>


/* just like nodecmp in optdir.z - but slightly shorter :-) */
int nodecmp(const void *v1,const void *v2)
{
const unsigned char *ent1=v1,*ent2=v2;
int diff;

/* ";if one of them is erased, that one comes later, no matter what" */
if(*ent1==0xe5)
  return(1);

if(*ent2==0xe5)
  return(-1);

/* ";otherwise, we test the 'length of extent' byte." */
if((diff=ent2[15]-ent1[15])!=0)
  return(diff);

/* ";if the extent-length matches, sort alphabetically." */

/* no attributes in ZCN, so pure ASCII, direct comparison is fine */
return(memcmp(ent1+1,ent2+1,8+3));
}



int main(void)
{
/* maybe it's not pretty, but 1MB is just nothing at this point */
static unsigned char cardimg[1024*1024];
unsigned char *driveptr;
int d,f,sysblks;

if(isatty(fileno(stdout)))
  fprintf(stderr,"optdir-c: not writing to tty\n"),exit(1);

/* read input card */
if(fread(cardimg,1,sizeof(cardimg),stdin)!=sizeof(cardimg))
  fprintf(stderr,"optdir-c: need 1024k card as input\n"),exit(1);

/* drives A: to D: */
for(d=0;d<4;d++)
  {
  driveptr=cardimg+d*256*1024;
  
  if(memcmp(driveptr+2,"ZCN1",4)!=0)
    fprintf(stderr,"optdir-c: drive %c not formatted\n",'A'+d),exit(1);
  
  if((sysblks=driveptr[8])>15)
    fprintf(stderr,"optdir-c: must be no more than 15 system blocks\n"),
      exit(1);

  if(driveptr[9]!=2)
    fprintf(stderr,"optdir-c: must be 2 dir blocks per drive\n"),exit(1);

  qsort(driveptr+1024*(1+sysblks),64,32,nodecmp);

  /* while we're here, also remove the sub-record file length data
   * cpmtools seems to non-optionally write for some crazy reason.
   *
   * It isn't a problem for ZCN itself, but if ZCN modifies something
   * it won't update this, so if you then use cpmtools to read the
   * data out it might be the wrong length.
   */
  for(f=0;f<64;f++)
    if(driveptr[1024*(1+sysblks)+f*32]!=0xe5)
      driveptr[1024*(1+sysblks)+f*32+13]=0;
  }

if(fwrite(cardimg,1,sizeof(cardimg),stdout)!=sizeof(cardimg))
  fprintf(stderr,"optdir-c: write error\n"),exit(1);

exit(0);
}
