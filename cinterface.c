#include "system.h"
#include "io.h"
#include "altera_avalon_pio_regs.h"
#include <sys/alt_alarm.h>
#include <stdio.h>
#include <string.h>

#include "cinterface.h"
#include "sha256.h"


unsigned currenttarget;
unsigned currentcount;
unsigned char     currentsearchstring[64];
unsigned hascollision;

void setsearchstring(char *v) {
   memset(currentsearchstring, 0, 48);
   strncpy(currentsearchstring, v, 48);
}

void settarget(int n) {
   currenttarget = (n > 0) ? n : 1;
}

int collisionfound() {
   return hascollision;
}

int shacomputed() {
    return ALT_CI_SHA_0(101,10);
}

/* this function evaluates if a digest meets the collision target */
int testdigest(unsigned char digest1[32]) {
	unsigned bitstogo = currenttarget;
	unsigned idx = 0;
	int mask = -256;
	
	while (bitstogo > 7) {
	  if (digest1[idx] == 0) {
	     bitstogo -= 8;
		 idx++;
	  } else return 0;
    }
	
    if (bitstogo == 0) return 1; 	
    mask = mask >> bitstogo;
    if ((digest1[idx] & mask & 0xff) == 0)
	   return 1;
	   
	return 0;
}


int searchcollision() {
   currentcount     = 0;
   hascollision     = 0;
    unsigned char digest[32]; 
   unsigned int sendm[16];
	unsigned int digesti[8];
   int i,j;
   unsigned int result1;
   unsigned int cmp1,cmp2,target,target1;
   
   
   
 //  sha256_context ctx;
   

	//padding
	currentsearchstring[48] = 0x80;
	for(i = 49; i <= 61; i++)
		currentsearchstring[i] = 0x0;
	currentsearchstring[62] = 0x1;
	currentsearchstring[63] = 0x80;
   
   for(i = 0; i < 16; i++){
	for(j = 0; j < 4; j++ ) {
    sendm[i] = sendm[i] << 8;  
    sendm[i] += currentsearchstring[4*i + j];
}
}
for(i = 1; i <= 15; i++){
		
		ALT_CI_SHA_0((i),sendm[i]);
	
	}
   ALT_CI_SHA_0(0,0);
   ALT_CI_SHA_0(16,currenttarget);
   
   
   
  /* while (currentcount < ((unsigned)-1)) {
  
 	
		ALT_CI_SHA_0(0,currentcount);

	result1 = ALT_CI_SHA_0(16,currenttarget);
 
	 if (result1 != 100) 
	  return currentcount + result1;
	currentcount = currentcount + 2;
  }*/
	
	while(ALT_CI_SHA_0(100,10) != 1);
	return ALT_CI_SHA_0(102,10);
 
 
}
