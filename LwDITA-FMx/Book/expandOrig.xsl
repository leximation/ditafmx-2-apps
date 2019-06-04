<?xml version="1.0" encoding="UTF-8"?>

<!-- 
      Updates:
      2017-03-28: update for LwDITA
      
      2.0.00 - 2013-12-23: support mapref, and glossref, update DTD
      1.1.18 - 2013-12-19: support for amendments, changed draftinfo to draftintro
      2012-09-28 - added tests to check for @print='no' and @format='html'
      
-->

<!-- ***********************************************************************    -->
<!-- XSLT to pre-process a ditamap and create an intermediate XML file that -->
<!-- is based on the ditabook.dtd and can be imported into FrameMaker as    -->
<!-- a book. The XSLT expands all references.				         -->
<!-- ***********************************************************************    -->

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:xml="http://www.w3.org/XML/1998/namespace" 
		xmlns:xalan="http://xml.apache.org/xalan" 
		xmlns:exsl="http://exslt.org/common"
		xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/" 
		version="1.0" 
		extension-element-prefixes="xalan exsl" exclude-result-prefixes="ditaarch">

  <xsl:output method="xml" version="1.0" 
  		encoding="UTF-8" 
  		doctype-public="-//FMX//DTD XDITA FMxBook//EN" 
  		doctype-system="fmx-book.dtd"/>

 
  
  <!-- ***********************************************************************    -->
  <!-- USE THESE TEMPLATES TO READ THE ENTIRE FILE INTO A VARIABLE                -->
  <!-- ***********************************************************************    -->
  
  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>
     
  <xsl:template match="topicref|chapter|appendix|abbrevlist|bibliolist|booklist|
  			figurelist|glossarylist|indexlist|tablelist|toc|trademarklist|
  			bookabstract|colophon|dedication|amendments|draftintro|notices|
  			preface|mapref|glossref">
    <xsl:if test="not(@print='no') and not(@format='html') and not(@processing-role='resource-only')">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
        <xsl:apply-templates select="document(@href)/*"/>
        <xsl:apply-templates/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
    
  <xsl:template match="part">
    <xsl:if test="not(@print='no') and not(@format='html') and not(@processing-role='resource-only')">
      <xsl:copy>
        <xsl:apply-templates select="@*"/>
       	<xsl:apply-templates select="document(@href)/*"/>
       	<xsl:apply-templates/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
   </xsl:template>

</xsl:transform>