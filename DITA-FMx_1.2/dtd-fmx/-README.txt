
DITA 1.2 DTDs for DITA-FMx
============================================================

These DTDs have been "normalized" from the DITA 1.2 DTDs that shipped with 
FrameMaker 11. They were initially created by exporting a DTD from the EDD 
in order to create a single DTD rather than using the complex set of DTDs 
provided with DITA 1.2. After exporting the "uber" DTD, some manual tweaking
was required to remove the "fm-*" elements and to modify some of the 
general rules.

The single DTD significantly increases load time in FrameMaker (especially 
for FM8).

If you prefer to use the default DITA DTDs, you should be able to do so 
by changing the reference in the structure application definition.


