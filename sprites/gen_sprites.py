#!/usr/bin/python2
import os
from PIL import Image

ROOT = os.path.dirname(os.path.abspath(__file__))
from spritesticker import *

setImageFolder('images')
setPngOptimizer('pngcrush -rem alla -brute -reduce %s %s > /dev/null')

def bw(sheet_image):
    img = sheet_image.image.copy()
    if img.mode != 'RGBA':
        img = img.convert('RGBA')
    w, h = img.size
    pix = img.load()
    for x in range(w):
        for y in range(h):
            r,g,b,a = pix[x,y]
            avg = (r+g+b) / 3
            pix[x,y] = (avg,avg,avg,a)
    return SheetImage(image=img, usedInCss=' '.join(map(lambda prop: prop.selector+'.bw', sheet_image.cssProp)))

normalImages = [SheetImage(filename='clients/'+x, usedInCss='.clients .'+x.split('-')[0]) for x in os.listdir(os.path.join(ROOT, 'images/clients'))]
bwImages = map(bw, normalImages)

noRepeat = SpriteSheet('../../images/sprites', BoxLayout(
    normalImages + bwImages +
    [SheetImage(filename='techs/'+x, usedInCss='.techs .'+x.split('-')[0]) for x in os.listdir(os.path.join(ROOT, 'images/techs'))] +
    [SheetImage(filename='misc/github_32.png', usedInCss='.github')]
))

noRepeat.write()

class MyWriter(CssWriter):
    def write(self, filename, pathPrefix='', imgClass=None):
        self.pathPrefix = pathPrefix
        self.fout = file(filename, 'w')
        self.maxwidth  = 0
        self.maxheight = 0
        for selector, value in self.selectorToImage.items():
            image, pos = value
            self._writeImageCss(selector, image, pos)
        if imgClass:
            #self.fout.write('%s { width: %dpx; height: %dpx; }\n' % (imgClass, self.maxwidth, self.maxheight))
            self.fout.write('%s { height: %dpx !important; }\n' % (imgClass, self.maxheight))
        self.fout.close()
    def _writeImageCss(self, selector, image, pos):
        imagePath = self.pathPrefix + os.path.split(image.filename)[1]
        repeat = image.repeat
        color = image.color or ''
        pos = '%dpx %dpx' % pos
        sizes = image.getOuterRect().size
        if sizes[0] > self.maxwidth: self.maxwidth = sizes[0]
        if sizes[1] > self.maxheight: self.maxheight = sizes[1]
        sizesstr = 'width: %dpx; height: %dpx' % sizes
        self.fout.write('%(selector)s { background: %(color)s url(%(imagePath)s) %(repeat)s %(pos)s; %(sizesstr)s; }\n' % locals())
        """
        self.fout.write('%s.centering { position: absolute; top: 50%%; margin-top: %dpx; left: 50%%; margin-left: %dpx; }\n' %  (
            selector, -sizes[1]/2, -sizes[0]/2
        ));
        """

cssWriter = MyWriter()
cssWriter.register(noRepeat)
cssWriter.write(r'../css/sprites.css', pathPrefix='/images/', imgClass='.sprite_img')
