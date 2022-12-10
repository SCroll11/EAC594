#!/usr/bin/python
# -*- coding:utf-8 -*-

import sys
import os
picdir = "/home/pi/hwd101/pic/"
libdir = "/home/pi/hwd101/lib/"

if os.path.exists(libdir):
    sys.path.append(libdir)

import logging
from waveshare_epd import epd2in7
import time
from datetime import date
from PIL import Image,ImageDraw,ImageFont
import traceback
from yahoo_fin.stock_info import *
from gpiozero import Button
import csv
import RPi.GPIO as GPIO

#GPIO mapping for buttons
logging.basicConfig(level=logging.DEBUG)
GPIO.setmode(GPIO.BCM)

key1 = 5
key2 = 6
key3 = 13
key4 = 19

GPIO.setup(key1, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(key2, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(key3, GPIO.IN, pull_up_down=GPIO.PUD_UP)
GPIO.setup(key4, GPIO.IN, pull_up_down=GPIO.PUD_UP)

today = str(date.today())

#Intial units per ETF
xawunits = 100
vcnunits = 100
zagunits = 100

try:
    
    #Clearing/Initializing screen
    epd = epd2in7.EPD()
    logging.info("init and Clear")
    epd.init()
    epd.Clear(0xFF)
    
    # Drawing on the image
    logging.info("Drawing")
    blackimage = Image.new('1', (epd.width, epd.height), 255)
    font30 = ImageFont.truetype(os.path.join(picdir, 'Font.ttc'), 30)
    font24 = ImageFont.truetype(os.path.join(picdir, 'Font.ttc'), 24)
    font18 = ImageFont.truetype(os.path.join(picdir, 'Font.ttc'), 18) 

    # Draw on screen to signal ready for input
    HBlackimage2 = Image.new('1', (epd.height, epd.width), 255)
    drawblack2 = ImageDraw.Draw(HBlackimage2)
    drawblack2.text((170, 0), today, font = font18, fill = 0)
    drawblack2.text((5, 0), 'Ready for input', font= font18, fill = 0)
    epd.display(epd.getbuffer(HBlackimage2))
    logging.info("Ready for input")
    
    def portfolio():
        HBlackimage = Image.new('1', (epd.height, epd.width), 255)
        
        #Get buy in and current price
        xawprice = round(get_live_price('XAW.TO'),2)
        vcnprice = round(get_live_price('VCN.TO'),2)
        zagprice = round(get_live_price('ZAG.TO'),2)
        xawinitprice = 28.12
        #xawinitprice = 1.00
        vcninitprice = 34.48
        zaginitprice = 15.90
        
        #Calculate intial and current of ETFs
        xawvalue = round((xawprice * xawunits),2)
        xawinitvalue = round((xawinitprice * xawunits),2)
        vcnvalue = round((vcnprice * vcnunits),2)
        vcninitvalue = round((vcninitprice * vcnunits),2)
        zagvalue = round((zagprice * zagunits),2)
        zaginitvalue = round((zaginitprice * zagunits),2)
        
        #Calculate intial and current values of all ETFs
        totalval = (xawvalue + vcnvalue + zagvalue)
        totalinitval = (xawinitvalue + vcninitvalue + zaginitvalue)
        
        #Calculate percetage gain/loss
        overallval = (totalval - totalinitval)
        overallpercentstr = '(' + str(round((((totalval - totalinitval) / totalinitval) * 100),2)) + '%)'

        #Draw info
        drawblack = ImageDraw.Draw(HBlackimage)
        drawblack.text((5, 0), 'Overall Portfolio:', font = font18, fill = 0)
        drawblack.text((170, 0), today, font = font18, fill = 0)
        drawblack.text((60, 40), str(overallval), font = font24, fill = 0)
        drawblack.text((140, 40), overallpercentstr, font = font24, fill = 0)
        drawblack.text((5, 80), 'Total Assets:', font = font18, fill = 0)
        drawblack.text((110, 80), str(totalval), font = font18, fill = 0)
        drawblack.text((5, 100), 'XAW.TO:', font = font18, fill = 0)
        drawblack.text((77, 100), str(xawvalue), font = font18, fill = 0)
        drawblack.text((5, 120), 'VCN.TO:', font = font18, fill = 0)
        drawblack.text((77, 120), str(vcnvalue), font = font18, fill = 0)
        drawblack.text((5, 140), 'ZAG.TO:', font = font18, fill = 0)
        drawblack.text((77, 140), str(zagvalue), font = font18, fill = 0)
        #epd.display(epd.getbuffer(HBlackimage))
        
        #Show UP/DOWN arrow image depending on whether intial value is greater or lower than current
        if (overallval < 0):
            bmp = Image.open(os.path.join(picdir, 'downarrow.bmp'))
        else:
            bmp = Image.open(os.path.join(picdir, 'uparrow.bmp'))
        HBlackimage.paste(bmp, (5,30))
        epd.display(epd.getbuffer(HBlackimage))
        
        return
    
    def getdata( ETF ):
        #Dump quote table data into data.csv
        HBlackimage = Image.new('1', (epd.height, epd.width), 255)
        rawdata = get_quote_table(ETF)
        print (rawdata, file=open('/home/pi/hwd101/data.csv', 'w'))
        f = open('/home/pi/hwd101/data.csv')
        csv_f = csv.reader(f)
    
        #Extract required info from data.csv
        for row in csv_f:
            previousclose = row[12]
            dayrange = row[5]
            yearrange = row[0]  
        f.close()
    
        previousclose = previousclose[1:]
        dayrange = dayrange[1:]
        yearrange = yearrange[1:]
        currentprice = str(round(get_live_price(ETF),2))

        #Draw info on screen
        drawblack = ImageDraw.Draw(HBlackimage)
        drawblack.text((5, 0), ETF, font = font30, fill = 0)
        drawblack.text((5, 30), currentprice, font = font30, fill = 0)
        drawblack.text((5, 80), previousclose, font = font18, fill = 0)
        drawblack.text((5, 100), dayrange, font = font18, fill = 0)
        drawblack.text((5, 120), yearrange, font = font18, fill = 0)
        drawblack.text((170, 0), today, font = font18, fill = 0)
        epd.display(epd.getbuffer(HBlackimage))
        #time.sleep(1)
        #epd.Clear(0xFF)
        return
    
    def main():

        #Continuously run to monitor key press
        while True:
            key1state = GPIO.input(key1)
            key2state = GPIO.input(key2)
            key3state = GPIO.input(key3)
            key4state = GPIO.input(key4)

            if key1state == False:
                print('Key1 Pressed')
                portfolio()
                time.sleep(0.2)
            if key2state == False:
                print('Key2 Pressed')
                getdata('XAW.TO')
                time.sleep(0.2)
            if key3state == False:
                print('Key3 Pressed')
                getdata('VCN.TO')
                time.sleep(0.2)
            if key4state == False:
                print('Key4 Pressed')
                getdata('ZAG.TO')
                time.sleep(0.2)

    #if __name__ == '__main__':
    main()
     
except IOError as e:
    logging.info(e)
    
except KeyboardInterrupt:    
    logging.info("ctrl + c:")
    epd2in7.epdconfig.module_exit()
    exit()
