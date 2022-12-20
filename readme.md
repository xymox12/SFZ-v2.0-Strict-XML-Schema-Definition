# SFZ v2.0 Strict XML Schema

SFZ overview: https://en.wikipedia.org/wiki/SFZ_(file_format)

This project was an attempt to create a 'Strict' XSD schema for version 2.0 of the SFZ sample format, based on the the mapping of the SFZ format at the [SFZ Format website](https://sfzformat.com/). 

## Why...

Why did I create this schema? 2 reasons. The first was a wish to understand the format better. The second is a little more opinionated, and I imagine some may disagree: in the early 2000s the SFZ developers decided not to base SFZ on XML, and created the bespoke SFZ format. Fair enough - XML, and access to tools to develop with it, wasn't quite as ubiquitous as it is now; JSON even less so. However, that decision may have prevented the format becoming more popular (but this my purely subjective take on things). Creating the Schema, and XML-to-SFZ stylesheet, is an attempt to make the SFZ format more accessible to developers of software, and to instrument creators who prefer to use the same development workflows they use for other formats.

## What's included...

The project includes a functional stylesheet to convert from the XML to the SFZ native format. 

I have left in a purely experimental, not quite functioning, and not supported stylesheet to convert from SFZ to XML - just in case anyone likes a challenge and wants to complete it. It was only built to reverse the outputs from the XML to SFZ stylesheet above, but even that was beyond my patience to complete. It wasn't what XSLT was meant to do, and there are better ways to do it.


## Project structure

* schema folder: this is the location of the schema
* stylesheets: the location of the main stylesheet, xml2sfz_stylesheet.xsl, to convert the XML created using the Schema above to SFZ format.
* sfz.xml: an example file to help people start developing for SFZ using the schema.
* diagrams: contains diagrams of the schema in SVG format (created directly from the schema using XSD Diagram), and sfz-v2.mm (created manually while working out the structure using FreePlane).

## Future

An obvious future development would be to create a v2.x 'Transitional' schema and include the ARIA extensions.  Unfortunately, my life got a lot busier recently and I am unlikely going to have the time. The project is provided under the MIT licence, so feel free to fork etc.


## Useful tools:

* [XSD Diagram is a free xml schema definition diagram viewer](http://regis.cosnier.free.fr)
* [FreePlane](https://sourceforge.net/projects/freeplane/)
