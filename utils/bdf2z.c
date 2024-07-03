/* bdf2z.c - convert BDF font file to .z file, based on bdf2h from vmanpg.
 * Copyright (C) 1998-2022 Russell Marks. See `zcn.txt' for license details.
 */

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>


int bitbox,bitsleft;
int bytes=0;


void bit_init()
{
bitbox=0; bitsleft=8;
bytes=0;
}


void bit_output(int bit)
{
bitsleft--;
bitbox|=(bit<<bitsleft);
if(!bitsleft)
  {
  printf("defb %d\n",bitbox);
  bytes++;
  bitbox=0;
  bitsleft=8;
  }
}


int bit_flush()
{
/* there are never 0 bits left outside of bit_output, but
 * if 8 bits are left here there's nothing to flush, so
 * only do it if bitsleft!=8.
 */
if(bitsleft!=8)
  {
  bitsleft=1;
  bit_output(0);	/* yes, really. This will always work. */
  }
return(bytes);
}


int main(int argc,char *argv[])
{
FILE *in=stdin;
char buf[128];
int f,g;
int c=0,w=0,i,mask;
int fw,fh,fox,foy,width,height,x,y,wcount;
int maxy=-999;
int ofs=0;
int ofstbl[128];
char *fontdesc="unnamed";

if(argc==2) fontdesc=argv[1];

printf(";automatically generated (edits will be lost!)\n\n");

printf("font%sdat:\n\n",fontdesc);

printf(";data for each char is ox oy w h dwidth, then data\n\n");

while(fgets(buf,sizeof(buf),in)!=NULL)
  {
  if(strncmp(buf,"FONTBOUNDINGBOX ",16)==0)
    sscanf(buf+16,"%d %d %d %d",&fw,&fh,&fox,&foy);
  else if(strncmp(buf,"ENCODING ",9)==0)
    c=atoi(buf+9);
  else if(strncmp(buf,"DWIDTH ",7)==0)
    w=atoi(buf+7);
  else if(strncmp(buf,"BBX ",4)==0)
    {
    sscanf(buf+4,"%d %d %d %d",&width,&height,&x,&y);
    }
  else if(strcmp(buf,"BITMAP\n")==0)
    {
    if(c<32 || c>127) continue;
    ofstbl[c]=ofs;
    printf(";`%c'\n",c);
    printf("defb %d,%d,%d,%d,%d\n",x,y,width,height,w);
    ofs+=5;
    if(y+height-foy>maxy) maxy=y+height-foy;
    bit_init();
    while(fgets(buf,sizeof(buf),in)!=NULL && strcmp(buf,"ENDCHAR\n")!=0)
      {
      i=0;
      wcount=width;
      
      for(f=0;f<strlen(buf)-1;f++)
        {
        c=toupper(buf[f])-48; if(c>9) c-=7;
        if(c<0 || c>15)
          fprintf(stderr,"error in font - bad hex!\n"),exit(1);
        else
          {
          i=i*16+c;
          if(f&1)
            {
            for(g=0,mask=128;g<8 && wcount--;g++,mask>>=1)
              bit_output((i&mask)?1:0);
            i=0;
            }
          }
        }
      if(f&1)
        {
        for(g=0,mask=128;g<8 && wcount--;g++,mask>>=1)
          bit_output((i&mask)?1:0);
        }
      }
    ofs+=bit_flush();
    putchar('\n');
    }
  }

printf("\n\n");

/* lookup table for each char (32..126) */
printf("font%stbl:",fontdesc);
for(f=32;f<127;f++)
  {
  static char sep=' ';
  if((f&3)==0) printf("\ndefw"),sep=' ';
  printf("%cfont%sdat+%d",sep,fontdesc,ofstbl[f]);
  sep=',';
  }
printf("\n\n");

printf(";main table with addrs etc.\n");
printf("font%saddr:\n",fontdesc);
printf("defw font%sdat,font%stbl\n",fontdesc,fontdesc);
printf("defb %d\t;yofs\n",fh-maxy);
printf("defb %d\t;fh\n",fh);
printf("defb %d\t;oy\n\n\n",foy);

exit(0);
}
