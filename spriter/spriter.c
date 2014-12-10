/* spriter.c: transforms a sprite GIF into ready-to-use assembler code
 * 
 * Author:  Eli Wenig
 * Date:    12-09-2014
 * Version: 0.1
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <gif_lib.h>

void usage();

int main (int argc, char** argv) {
	 // inverse flag
	int rflag = 0, ch;
	while ((ch = getopt(argc, argv, "r")) != -1) {
		switch (ch) {
		case 'r':
			rflag = 1;
			break;
		default:
			// print error and exit
			usage();
			break;
		}
	}

	// adjust args array post-getopt
	argc -= optind;
	argv += optind;

	if (argv[0] == NULL) {
		// print error and exit
		fputs("File name missing\n", stderr);
		usage();
	}

	char *fname = argv[0];

	// open the GIF file
	GifFileType *SpriteGif;
	SpriteGif = DGifOpenFileName(fname);

	// check for error
	if (SpriteGif == NULL) {
		// print error and exit
		PrintGifError();
		exit(1);
	}

	int rc = DGifSlurp(SpriteGif);
	if (rc == GIF_ERROR) {
		// print error and exit
		PrintGifError();
		exit(1);
	}

	// make sure we have the correct number of pixels
	if (SpriteGif->SWidth != 24 && SpriteGif->SHeight != 21) {
		fputs("Error: Dimensions of image must be 24 by 21 pixels",stderr);
	}

	// iterate over the raster bits
	unsigned char *raster = SpriteGif->SavedImages->RasterBits;

	int i,j,row=0; // iterators
	for (i=0;i<504;i+=24) {
		printf("\t; row %x\n", row++);
		fputs("\t.byte %", stdout);
		for (j=0;j<8;j++) {
			fputs((raster[i+j] == 0) ? (rflag ? "1" : "0") : (rflag ? "0" : "1"), stdout);
		}
		fputs("\n\t.byte %", stdout);
		for (j=8;j<16;j++) {
			fputs((raster[i+j] == 0) ? (rflag ? "1" : "0") : (rflag ? "0" : "1"), stdout);
		}
		fputs("\n\t.byte %", stdout);
		for (j=16;j<24;j++) {
			fputs((raster[i+j] == 0) ? (rflag ? "1" : "0") : (rflag ? "0" : "1"), stdout);
		}
		puts("");
	}

	return 0;
}

void usage() {
	// print usage message
	fputs("Usage: ./spriter [-r] [filename]\n", stderr);
	exit(1);
}
