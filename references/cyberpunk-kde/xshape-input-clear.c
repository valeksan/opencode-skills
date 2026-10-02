/* xshape-input-clear <window-id> — set an EMPTY input shape => click-through. */
#include <X11/Xlib.h>
#include <X11/extensions/shape.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s <window-id>\n", argv[0]);
        return 2;
    }
    Display *d = XOpenDisplay(NULL);
    if (!d) { fprintf(stderr, "cannot open display\n"); return 1; }
    Window w = strtoul(argv[1], NULL, 0);
    int ev, err, evmaj, evmin;
    if (!XShapeQueryExtension(d, &ev, &err)) {
        fprintf(stderr, "SHAPE extension not available\n");
        return 1;
    }
    XShapeQueryVersion(d, &evmaj, &evmin);
    /* empty input region -> pointer events pass through */
    XShapeCombineRectangles(d, w, ShapeInput, 0, 0, NULL, 0, ShapeSet, Unsorted);
    XSync(d, False);
    printf("input shape cleared for window %s (SHAPE %d.%d)\n", argv[1], evmaj, evmin);
    XCloseDisplay(d);
    return 0;
}
