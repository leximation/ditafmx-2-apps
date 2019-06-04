
LwDITA-FMx .. ***BETA***
=====================================================
2017-06-02

These structured applications were developed from the LwDITA DTDs available on 
2017-06-02 from this URL ..

https://github.com/oasis-open/dita-lightweight/tree/master/org.oasis.xdita/dtd

>>> The LwDITA DTDs are NOT complete or final. <<<

These apps were developed specifically for use with DITA-FMx, but will "work" 
with default FM-DITA. The main problem being that the default DITA plugin adds
attributes to some elements that are not valid in LwDITA. Modifications have been
made to DITA-FMx (as of v.2.0.06i), that fix these problems.

If you're using these apps with default FM-DITA, you should ignore the "Book" 
app since that's a special model for use with the DITA-FMx book-build process.
Also, you may want to edit the EDDs to remove the <fm-data-marker> and <fm-var>
elements since those won't work with default FM.

To "install" these apps, copy the LwDITA-FMx folder to your $FMHOME\Structure\xml 
folder, then insert the "stub" file to your structure application definitions 
file as described here ..

http://docs.leximation.com/dita-fmx/2.0/?ditafmx_installing_apps_manual.html

Note that if you're using this with default FM-DITA, you'll need to modify the 
structure app definition to change the APIClient from "ditafmx_app" to "ditafm_app".

Additional notes and observations are included in the EDD files.

Check back for updates.

----
These files are provided on an as-is basis, with no warranty of fittness or 
functionality implied oroffered. Use at your own risk.

That said, please do let me know if you run into any problems, especially if you're
using it with DITA-FMx.

<tools@leximation.com>
----

