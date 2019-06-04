<?xml version="1.0" encoding="UTF-8"?>

<!-- **************************************************************************	-->
<!-- For use with SAXON (default in FM13 and later) 				-->
<!-- **************************************************************************	-->

<!-- **************************************************************************	-->
<!-- HISTORY:									-->
<!--  2.0.06 - 22jun2017							-->
<!--   + removed dependency on exsl:node-set() to work with saxon               -->
<!--  28mar2017 - update for LwDITA     					-->
<!--  11mar2016 - added limited support for topichead (just unwraps)		-->
<!--  04sep2015 - added fm-ditabook variables			 		-->
<!--  08jun2015 - added support for author-defined conditions    		-->
<!--            - changed 'node' to 'nodename'                   		-->
<!--            - deleted 'fmtext' variable definition           		-->
<!--  02mar2015 - added fm-ditabook variables			 		-->
<!--  2.0.00 - 20mar2014							-->
<!--   + Update DTD                                                             -->
<!--   + Added support for mapref, glossref, and keydef                         -->
<!--   + Added support for @props                                               -->
<!--  1.1.18 - 19dec2013							-->
<!--   + Added support for notices, dedication, colophon, and amendments that   -->
<!--     reference a ditamap.                                                   -->
<!--  6jul2012 - strip hash fragment from hrefs (see use of "path-nofrag")      -->
<!--  6jul2012 - added support for additional book-level variables              -->
<!--  8may2012 - added "preface" handling                                       -->
<!--  v2.2, 2011-03-20								-->
<!-- 	add exclude-result-prefixes to dita to remove parser warning		-->
<!--	create getMapElemType template and use it				-->
<!--	modify test conditions for creating a new book component and PI		-->
<!-- ************************************************************************** -->


<!-- ************************************************************************** -->
<!-- XSLT to pre-process a ditamap and create an intermediate XML file that 	-->
<!-- is based on the ditabook.dtd and can be imported into FrameMaker as    	-->
<!-- a book. The XSLT creates appropriate processsing instructions that FM  	-->
<!-- can interpret and create a Frame book and book components.         	-->
<!-- ************************************************************************** -->

<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xalan="http://xml.apache.org/xalan" 
  xmlns:exsl="http://exslt.org/common"
  xmlns:ditaarch="http://dita.oasis-open.org/architecture/2005/" 
  version="1.0"
  extension-element-prefixes="xalan exsl" 
  exclude-result-prefixes="ditaarch">

  <!-- Import original stylesheet -->
  <xsl:import href="expandOrig.xsl"/>

  <xsl:output method="xml" 
    version="1.0" 
    encoding="UTF-8"
    doctype-public="-//FMX//DTD XDITA FMxBook//EN" 
    doctype-system="fmx-book.dtd"/>

  <!-- ***********************************************************************  -->
  <!-- START VARIABLES                                                		-->
  <!-- ***********************************************************************  -->
  
  <!-- General Utility variables -->
  <xsl:variable name="newline">
    <xsl:text>
</xsl:text>
  </xsl:variable>
  
  <!-- General Content variables to access metadata information for maps and bookmaps -->

  <xsl:variable name="pubinfo-org">
    <xsl:value-of select="translate(//publisherinformation/organization[1],'&#10;',' ')"/>
  </xsl:variable>

  <xsl:variable name="pubinfo-completedyear">
    <xsl:value-of select="translate(//publisherinformation/published/completed/year[1],'&#10;',' ')"/>
  </xsl:variable>

  <xsl:variable name="pubinfo-completedmonth">
    <xsl:value-of select="translate(//publisherinformation/published/completed/month[1],'&#10;',' ')"/>
  </xsl:variable>

  <xsl:variable name="pubinfo-completedday">
    <xsl:value-of select="translate(//publisherinformation/published/completed/day[1],'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="permissions-view">
    <xsl:value-of select="translate(//permissions[1]/@view, '&#10;', ' ')"/>
  </xsl:variable>

  <xsl:variable name="category">
    <xsl:value-of select="translate(//category[1],'&#10;',' ')"/>
  </xsl:variable>

  <xsl:variable name="created">
    <xsl:value-of select="translate(//critdates/created[1]/@date, '&#10;', ' ')"/>
  </xsl:variable>
  
  <xsl:variable name="revised">
    <xsl:value-of select="translate(//critdates/revised[position() = last()]/@modified,'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="bookpartno">
    <xsl:value-of select="translate(//bookmeta/bookid/bookpartno[1],'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="edition">
    <xsl:value-of select="translate(//bookmeta/bookid/edition[1],'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="isbn">
    <xsl:value-of select="translate(//bookmeta/bookid/isbn[1],'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="booknumber">
    <xsl:value-of select="translate(//bookmeta/bookid/booknumber[1],'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="volume">
    <xsl:value-of select="translate(//bookmeta/bookid/volume[1],'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="maintainer-person">
    <xsl:value-of select="translate(//bookmeta/bookid/maintainer/person[1],'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="maintainer-org">
    <xsl:value-of select="translate(//bookmeta/bookid/maintainer/organization[1],'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="copyrfirst">
    <xsl:choose>
      <xsl:when test="/bookmap">
        <xsl:value-of select="translate(//bookrights/copyrfirst/year,'&#10;',' ')"/>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate(//copyright/copyryear[1]/year,'&#10;',' ')"/>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="copyrlast">
    <xsl:choose>
      <xsl:when test="/bookmap">
        <xsl:value-of select="translate(//bookrights/copyrlast/year,'&#10;',' ')"/>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate(//copyright/copyryear[position() = last()]/year,'&#10;',' ')"/>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="copyrholder">
    <xsl:choose>
      <xsl:when test="/bookmap">
        <xsl:value-of select="translate(//bookrights/bookowner/organization[1],'&#10;',' ')"/>        
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate(//copyright/copyrholder,'&#10;',' ')"/>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <xsl:variable name="bookowner-org">
    <xsl:value-of select="translate(//bookrights/bookowner/organization[1],'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="bookowner-person">
    <xsl:value-of select="translate(//bookrights/bookowner/person[1],'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="bookrestriction">
    <xsl:value-of select="translate(//bookrights/bookrestriction/@value,'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="prodname">
    <xsl:value-of select="translate(//prodinfo/prodname,'&#10;',' ')"/>
  </xsl:variable>
  
  <xsl:variable name="version">
    <xsl:value-of
      select="translate(//prodinfo/vrmlist/vrm[position() = last()]/@version,'&#10;',' ')"/>
  </xsl:variable>

  <xsl:variable name="release">
    <xsl:value-of
      select="translate(//prodinfo/vrmlist/vrm[position() = last()]/@release,'&#10;',' ')"/>
  </xsl:variable>

  <xsl:variable name="modification">
    <xsl:value-of
      select="translate(//prodinfo/vrmlist/vrm[position() = last()]/@modification,'&#10;',' ')"/>
  </xsl:variable>

  <xsl:variable name="authorname">
    <xsl:choose>
      <xsl:when test="//authorinformation/personinfo/namedetails/personname">
        <xsl:value-of
          select="translate(//authorinformation/personinfo/namedetails/personname[1]/firstname[1],'&#10;',' ')"/>
        <xsl:text> </xsl:text>
        <xsl:value-of
          select="translate(//authorinformation/personinfo/namedetails/personname[1]/lastname[1],'&#10;',' ')"
        />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="translate(//author,'&#10;',' ')"/>        
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  
  <!-- gather up 'author-condition' values from map to add to generated files 
       - must include these conditions in component template to define formatting
       - this allows document-defined conditions to "exist" in generated files.
  -->
  <xsl:variable name="conditions" select="//othermeta[@name='author-condition']"/>


  <!-- ***********************************************************************  -->
  <!-- PATH UTILS                                              			-->
  <!-- ***********************************************************************  -->
  
  <!-- Returns the directory part of a path.  Equivalent to Unix 'dirname'.
	Examples:
	'' -> ''
	'foo/index.html' -> 'foo/'
	-->
  <xsl:template name="dirname">
    <xsl:param name="path"/>
    <xsl:if test="contains($path, '/')">
      <xsl:value-of select="concat(substring-before($path, '/'), '/')"/>
      <xsl:call-template name="dirname">
        <xsl:with-param name="path" select="substring-after($path, '/')"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>
  
  <!-- Normalized (..'s eliminated) version of 'dirname' -->
  <xsl:template name="dirname-nz">
    <xsl:param name="path"/>
    <xsl:call-template name="normalize">
      <xsl:with-param name="path">
        <xsl:call-template name="dirname">
          <xsl:with-param name="path" select="$path"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Returns the filename part of a path.  Equivalent to Unix 'basename'
		Examples:
		'index.html'  ->  'index.html' 
		'foo/bar/'  ->  '' 
		'foo/bar/index.html'  ->  'index.html' 
	-->
  <xsl:template name="filename">
    <xsl:param name="path"/>
    <xsl:choose>
      <xsl:when test="contains($path, '/')">
        <xsl:call-template name="filename">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$path"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Returns the last extension of a filename in a path.
	Examples:
	'index.html'  ->  '.html' 
	'index.dtdx.html'  ->  '.html' 
	'foo/bar/'  ->  '' 
	'foo/bar/index.html'  ->  '.html' 
	'foo/bar/index'  ->  '' 
	-->
  <xsl:template name="ext">
    <xsl:param name="path"/>
    <xsl:param name="subflag"/>
    <!-- Outermost call? -->
    <xsl:choose>
      <xsl:when test="contains($path, '.')">
        <xsl:call-template name="ext">
          <xsl:with-param name="path" select="substring-after($path, '.')"/>
          <xsl:with-param name="subflag" select="'sub'"/>
        </xsl:call-template>
      </xsl:when>
      <!-- Handle extension-less filenames by returning '' -->
      <xsl:when test="not($subflag) and not(contains($path, '.'))">
        <xsl:text/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="concat('.', $path)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Returns a filename of a path stripped of its last extension.
	Examples:
	'foo/bar/index.dtdx.html' -> 'index.dtdx'
	-->
  <xsl:template name="filename-noext">
    <xsl:param name="path"/>
    <xsl:variable name="filename">
      <xsl:call-template name="filename">
        <xsl:with-param name="path" select="$path"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="ext">
      <xsl:call-template name="ext">
        <xsl:with-param name="path" select="$filename"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="substring($filename, 1, string-length($filename) - string-length($ext))"/>
  </xsl:template>
  
  <!-- Returns a path with the filename stripped of its last extension.
	Examples:
	'foo/bar/index.dtdx.html' -> 'foo/bar/index.dtdx'
	-->
  <xsl:template name="path-noext">
    <xsl:param name="path"/>
    <xsl:variable name="ext">
      <xsl:call-template name="ext">
        <xsl:with-param name="path" select="$path"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:value-of select="substring($path, 1, string-length($path) - string-length($ext))"/>
  </xsl:template>
  
  <!-- Normalized (..'s eliminated) version of 'path-noext' -->
  <xsl:template name="path-noext-nz">
    <xsl:param name="path"/>
    <xsl:call-template name="normalize">
      <xsl:with-param name="path">
        <xsl:call-template name="path-noext">
          <xsl:with-param name="path" select="$path"/>
        </xsl:call-template>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>
  
  <!-- Returns a path with any fragment identifier ('#...') stripped off
	Examples:
	'foo/bar/index.dtdx.html#blah' -> 'foo/bar/index.dtdx.html'
	-->
  <xsl:template name="path-nofrag">
    <xsl:param name="path"/>
    <xsl:if test="not(contains($path, '#'))">
      <xsl:value-of select="$path"/>
    </xsl:if>
    <xsl:if test="contains($path, '#')">
      <xsl:value-of select="substring-before($path, '#')"/>
    </xsl:if>
  </xsl:template>
  
  <!-- Normalizes a path, converting '/' to '\' and eliminating ..'s
	Examples:
	'foo/bar/../baz/index.html' -> foo/baz/index.html'
	-->
  <xsl:template name="normalize">
    <xsl:param name="path"/>
    <xsl:variable name="path-" select="translate($path, '\', '/')"/>
    <xsl:choose>
      <xsl:when test="contains($path-, '/../')">
        <xsl:variable name="pa" select="substring-before($path-, '/../')"/>
        <xsl:variable name="th" select="substring-after($path-, '/../')"/>
        <xsl:variable name="pa-">
          <xsl:call-template name="dirname">
            <xsl:with-param name="path" select="$pa"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="pa-th" select="concat($pa-, $th)"/>
        <xsl:call-template name="normalize">
          <xsl:with-param name="path" select="$pa-th"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$path-"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ***********************************************************************  -->
  <!-- START TEMPLATES                                                		-->
  <!-- ***********************************************************************  -->
  
  <xsl:template name="get-base">
    <xsl:param name="p"/>
    <xsl:choose>
      <xsl:when test="not(contains($p,'/'))">
        <xsl:value-of select="$p"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="get-base">
          <xsl:with-param name="p" select="substring-after($p,'/')"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="is-relative-path">
    <xsl:param name="p"/>
    <xsl:choose>
      <xsl:when test="starts-with($p,'file:/') or starts-with($p, '/') or starts-with($p,'\')">
        <xsl:text>0</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>1</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="string.subst">
    <xsl:param name="string"/>
    <xsl:param name="target"/>
    <xsl:param name="replacement"/>
    <xsl:choose>
      <xsl:when test="contains($string, $target)">
        <xsl:variable name="rest">
          <xsl:call-template name="string.subst">
            <xsl:with-param name="string" select="substring-after($string, $target)"/>
            <xsl:with-param name="target" select="$target"/>
            <xsl:with-param name="replacement" select="$replacement"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of  select="concat(substring-before($string, $target), $replacement, $rest)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$string"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- returns the name of the appropriate map element that will be assigned to the mapelemtype
       attribute of the fm-ditafile element
       These are the elements: 
       topicref|chapter|appendix|preface|part|bookabstract|colophon|dedication|draftintro|notices
       NOTE: the order of execution below is important
   -->
  <xsl:template name="getMapElemType">
    <xsl:param name="nodename"/>
    <xsl:choose>
      <xsl:when test="$nodename/self::bookabstract">
        <xsl:text>bookabstract</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/self::colophon">
        <xsl:text>colophon</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/self::dedication">
        <xsl:text>dedication</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/self::amendments">
        <xsl:text>amendments</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/self::draftintro">
        <xsl:text>draftintro</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/self::notices">
        <xsl:text>notices</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/self::chapter">
        <xsl:text>chapter</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/self::appendix">
        <xsl:text>appendix</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/self::preface">
        <xsl:text>preface</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/self::part">
        <xsl:text>part</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/ancestor::bookabstract">
        <xsl:text>bookabstract</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/ancestor::colophon">
        <xsl:text>colophon</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/ancestor::dedication">
        <xsl:text>dedication</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/ancestor::amendments">
        <xsl:text>amendments</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/ancestor::draftintro">
        <xsl:text>draftintro</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/ancestor::notices">
        <xsl:text>notices</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/ancestor::chapter">
        <xsl:text>chapter</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/ancestor::appendix">
        <xsl:text>appendix</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/ancestor::preface">
        <xsl:text>preface</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/self::topicref">
        <xsl:text>topicref</xsl:text>
      </xsl:when>
      <xsl:when test="$nodename/ancestor::topicref">
        <xsl:text>topicref</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="name($nodename)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ***********************************************************************    -->
  <!-- END TEMPLATES                              				  -->
  <!-- ***********************************************************************    -->


  <!-- ***********************************************************************    -->
  <!-- process the tree								  -->
  <!-- ***********************************************************************    -->
  
  <xsl:template match="/">
    <!-- Grab result of original stylesheet -->
    <xsl:variable name="content">
      <xsl:apply-imports/>
    </xsl:variable>
       <!-- <xsl:apply-templates select="exsl:node-set($content)" mode="expanded"/> -->
    <!-- Pass grabbed content to postprocessing templates -->
     <xsl:apply-templates select="exsl:node-set($content)" mode="final"/>
  </xsl:template>

  <!-- ***********************************************************************    -->
  <!-- process map. If the map doesn't have any ancestor, start a new             -->
  <!-- Framemaker book. Otherwise, import into the current book component         -->
  <!-- ***********************************************************************    -->
  
  <xsl:template mode="final" match="map">
    <xsl:choose>
      <xsl:when test="not(parent::*[@format='ditamap'])">
        <xsl:value-of select="$newline"/>
        <xsl:processing-instruction name="FM">Book</xsl:processing-instruction>
        <xsl:value-of select="$newline"/>
        <xsl:variable name="title_text">
          <xsl:choose>
            <xsl:when test="title">
              <xsl:value-of select="translate(title,'&#10;',' ')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="translate(@title,'&#10;',' ')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <fm-ditabook xsl:exclude-result-prefixes="ditaarch">
          <xsl:attribute name="format">
            <xsl:value-of select="translate(@format,'&#10;',' ')"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="translate($title_text,'&#10;',' ')"/>
          </xsl:attribute>
          <xsl:if test="@xml:lang">
            <xsl:attribute name="xml:lang">
              <xsl:value-of select="@xml:lang"/>
            </xsl:attribute>
          </xsl:if>
          
          <!-- custom topicmeta/bookmeta data passed to fm-ditabook attributes -->
          <!-- any new values added here must be added to the fmxbook.dtd file -->
          <!-- as well as the Book application EDD -->
          
          <xsl:attribute name="created">
            <xsl:value-of select="$created"/> 
          </xsl:attribute>
          <xsl:attribute name="revised">
            <xsl:value-of select="$revised"/> 
          </xsl:attribute>
          <xsl:attribute name="prodname">
            <xsl:value-of select="$prodname"/>
          </xsl:attribute>
          <xsl:attribute name="version">
            <xsl:value-of select="$version"/>
          </xsl:attribute>
          <xsl:attribute name="release">
            <xsl:value-of select="$release"/>
          </xsl:attribute>
          <xsl:attribute name="modification">
            <xsl:value-of select="$modification"/>
          </xsl:attribute>
          <xsl:attribute name="authorname">
            <xsl:value-of select="$authorname"/> 
          </xsl:attribute>
          <xsl:attribute name="copyrfirst">
            <xsl:value-of select="$copyrfirst"/> 
          </xsl:attribute>
          <xsl:attribute name="copyrlast">
            <xsl:value-of select="$copyrlast"/> 
          </xsl:attribute>
          <xsl:attribute name="copyrholder">
            <xsl:value-of select="$copyrholder"/> 
          </xsl:attribute>
          
          <xsl:apply-templates mode="final"/>
          <xsl:value-of select="$newline"/>
        </fm-ditabook>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="final"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template mode="final" match="bookmap">
    <xsl:variable name="title_text">
      <xsl:choose>
        <xsl:when test="title">
          <xsl:value-of select="translate(title,'&#10;',' ')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate(./*/mainbooktitle,'&#10;',' ')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not(parent::*[@format='ditamap'])">
        <xsl:value-of select="$newline"/>
        <xsl:processing-instruction name="FM">Book</xsl:processing-instruction>
        <xsl:value-of select="$newline"/>
        <fm-ditabook xsl:exclude-result-prefixes="ditaarch">
          <xsl:attribute name="format">
            <xsl:value-of select="translate(@format,'&#10;',' ')"/>
          </xsl:attribute>
          <xsl:attribute name="title">
            <xsl:value-of select="translate($title_text,'&#10;',' ')"/>
          </xsl:attribute>
          <xsl:if test="@xml:lang">
            <xsl:attribute name="xml:lang">
              <xsl:value-of select="@xml:lang"/>
            </xsl:attribute>
          </xsl:if>
          
          <!-- custom topicmeta/bookmeta data passed to fm-ditabook attributes -->
          <!-- any new values added here must be added to the fmxbook.dtd file -->
          <!-- as well as the Book application EDD -->

          <xsl:attribute name="pubinfo-org">
            <xsl:value-of select="$pubinfo-org"/> 
          </xsl:attribute>
          <xsl:attribute name="pubinfo-completedyear">
            <xsl:value-of select="$pubinfo-completedyear"/> 
          </xsl:attribute>
          <xsl:attribute name="pubinfo-completedmonth">
            <xsl:value-of select="$pubinfo-completedmonth"/> 
          </xsl:attribute>
          <xsl:attribute name="pubinfo-completedday">
            <xsl:value-of select="$pubinfo-completedday"/> 
          </xsl:attribute>
          <xsl:attribute name="permissions-view">
            <xsl:value-of select="$permissions-view"/> 
          </xsl:attribute>
          <xsl:attribute name="category">
            <xsl:value-of select="$category"/> 
          </xsl:attribute>
          
          <xsl:attribute name="created">
            <xsl:value-of select="$created"/> 
          </xsl:attribute>
          <xsl:attribute name="revised">
            <xsl:value-of select="$revised"/>
          </xsl:attribute>
          <xsl:attribute name="bookpartno">
            <xsl:value-of select="$bookpartno"/> 
          </xsl:attribute>
          <xsl:attribute name="edition">
            <xsl:value-of select="$edition"/> 
          </xsl:attribute>
          <xsl:attribute name="isbn">
            <xsl:value-of select="$isbn"/> 
          </xsl:attribute>
          <xsl:attribute name="booknumber">
            <xsl:value-of select="$booknumber"/> 
          </xsl:attribute>
          <xsl:attribute name="volume">
            <xsl:value-of select="$volume"/> 
          </xsl:attribute>
          <xsl:attribute name="maintainer-person">
            <xsl:value-of select="$maintainer-person"/> 
          </xsl:attribute>
          <xsl:attribute name="maintainer-org">
            <xsl:value-of select="$maintainer-org"/> 
          </xsl:attribute>
          <xsl:attribute name="authorname">
            <xsl:value-of select="$authorname"/> 
          </xsl:attribute>
          <xsl:attribute name="copyrfirst">
            <xsl:value-of select="$copyrfirst"/> 
          </xsl:attribute>
          <xsl:attribute name="copyrlast">
            <xsl:value-of select="$copyrlast"/> 
          </xsl:attribute>
          <xsl:attribute name="copyrholder">
            <xsl:value-of select="$copyrholder"/> 
          </xsl:attribute>
          <xsl:attribute name="bookowner-org">
            <xsl:value-of select="$bookowner-org"/> 
          </xsl:attribute>
          <xsl:attribute name="bookowner-person">
            <xsl:value-of select="$bookowner-person"/> 
          </xsl:attribute>
          <xsl:attribute name="bookrestriction">
            <xsl:value-of select="$bookrestriction"/>
          </xsl:attribute>
          <xsl:attribute name="prodname">
            <xsl:value-of select="$prodname"/>
          </xsl:attribute>
          <xsl:attribute name="version">
            <xsl:value-of select="$version"/>
          </xsl:attribute>
          <xsl:attribute name="release">
            <xsl:value-of select="$release"/>
          </xsl:attribute>
          <xsl:attribute name="modification">
            <xsl:value-of select="$modification"/>
          </xsl:attribute>
          
          <xsl:apply-templates mode="final"/>
          <xsl:value-of select="$newline"/>
          
        </fm-ditabook>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="final"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="make_href">
    <xsl:param name="node" select="."/>
    <xsl:variable name="aggregated_href">
      <xsl:for-each select="$node/ancestor::*[@format='ditamap']">
        <xsl:call-template name="dirname">
          <xsl:with-param name="path" select="@href"/>
        </xsl:call-template>
      </xsl:for-each>
      <xsl:value-of select="$node/@href"/>
    </xsl:variable>
    <!-- added to strip hash from href (1.1.15) -->
    <xsl:variable name="x_aggregated_href">
      <xsl:call-template name="path-nofrag">
        <xsl:with-param name="path" select="$aggregated_href"/>
      </xsl:call-template>
    </xsl:variable>    
    <xsl:value-of select="$x_aggregated_href"/>
  </xsl:template>
  
  <xsl:template name="process-expanded-ref-with-attrs">
    <xsl:param name="nodes"/>
    <xsl:param name="platform"/>
    <xsl:param name="props"/>
    <xsl:param name="product"/>
    <xsl:param name="audience"/>
    <xsl:param name="otherprops"/>
    <xsl:param name="baseref"/>
    <!-- convert any spaces to %20 -->
    <xsl:variable name="href">
      <!-- wrapped in fullhref variable to strip hash from href (1.1.15) -->
      <xsl:variable name="fullhref">
        <xsl:call-template name="string.subst">
          <xsl:with-param name="string" select="@href"/>
          <xsl:with-param name="target" select="' '"/>
          <xsl:with-param name="replacement" select="'%20'"/>
        </xsl:call-template>
      </xsl:variable>
      <!-- added to strip hash from href (1.1.15) -->
      <xsl:call-template name="path-nofrag">
        <xsl:with-param name="path" select="$fullhref"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="href_value">
      <xsl:call-template name="make_href">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="current">
      <xsl:value-of select="."/>
    </xsl:variable>
    <xsl:variable name="name">
      <xsl:value-of select="local-name()"/>
    </xsl:variable>
    <xsl:variable name="vplatform">
      <xsl:choose>
        <xsl:when test="@platform != ''">
          <xsl:value-of select="@platform"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$platform"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vprops">
      <xsl:choose>
        <xsl:when test="@props != ''">
          <xsl:value-of select="@props"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$props"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vproduct">
      <xsl:choose>
        <xsl:when test="@product != ''">
          <xsl:value-of select="@product"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$product"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vaudience">
      <xsl:choose>
        <xsl:when test="@audience != ''">
          <xsl:value-of select="@audience"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$audience"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="votherprops">
      <xsl:choose>
        <xsl:when test="@otherprops != ''">
          <xsl:value-of select="@otherprops"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$otherprops"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- the directory name of the href attribute -->
    <xsl:variable name="dirname">
      <xsl:call-template name="dirname">
        <xsl:with-param name="path" select="@href"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- the filename from the href attribute -->
    <xsl:variable name="vfilename">
      <xsl:call-template name="filename">
        <xsl:with-param name="path" select="@href"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- combine the old base with the current directory name -->
    <xsl:variable name="vbaseref">
      <xsl:choose>
        <xsl:when test="$baseref != $dirname">
          <xsl:value-of select="concat($baseref, $dirname)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$baseref"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
  
    <xsl:choose>
    
      <!-- if this reference element has a parent and it is a map
           just process its content 
        -->
      <xsl:when test="parent::* and @format = 'ditamap'">
        <xsl:apply-templates mode="final"/>
      </xsl:when>
      
      <!-- if this reference element signals the beginning of a book component
      	   output the book component PI, create a new fm-ditafile element with
      	   appropriate attributes and process its content 
      	-->
      <!-- OLD CODE-->
      <!-- <xsl:when test="(parent::map and ancestor::part) or 
      			(parent::map and ancestor::bookmap) or
      			parent::bookmap or
      			parent::part or
      			parent::map or
      			parent::backmatter or
      			parent::frontmatter"> -->
      	<!-- ********************************************************** -->
      	<!-- CASES WHERE WE CREATE A NEW BOOK COMPONENT 		-->
      	<!-- EACH DESCRIPTION HERE MATCHES ONE OF THE OR TEST BELOW: 	-->
      	<!-- o) first child of the root map element			-->
      	<!-- o) submap within a chapter|appendix which is a map itself	-->
      	<!-- o) child of a topicgroup or topichead in a map		-->
      	<!-- o) first child of a rootmap element			-->
      	<!-- o) first child of part element				-->
      	<!-- o) first child of a nested map in a part			-->
      	<!-- o) child of backmatter					-->
      	<!-- o) child of frontmatter					-->
      	<!-- ********************************************************** -->
      	
      	<!-- NOTE: frontmatter and backmatter get unwrapped, so may not match here -->
      	
      		<!-- (parent::map and not(ancestor::map)) or -->
      		<!--  or -->
      <xsl:when
        test="
        		(parent::map and count(ancestor::*)=1) or
        		(parent::map and (
        			ancestor::chapter[@format='ditamap'] or
        			ancestor::appendix[@format='ditamap'] or
        			ancestor::preface[@format='ditamap'] or
        			ancestor::notices[@format='ditamap'] or
        			ancestor::dedication[@format='ditamap'] or
        			ancestor::colophon[@format='ditamap'] or
        			ancestor::amendments[@format='ditamap'] or
        			ancestor::mapref
        			)) or
        		(parent::map and (ancestor::topicref[@format='ditamap']) and not (ancestor::chapter)) or
        		(ancestor::map and (parent::topicgroup or parent::topichead)) or
        		parent::bookmap or
        		parent::part or
        		(parent::map and ancestor::part) or
        		parent::backmatter or
        		parent::frontmatter">
        <!-- replace any backslashes, dots or # in the filename with underscores -->
        <xsl:variable name="fmfile">
                <xsl:value-of select="translate($href, '\:/#.', '_____')"/>
        </xsl:variable>
        <!-- write the PI so that FM knows to start a new book component -->
        <xsl:value-of select="$newline"/>
        <xsl:processing-instruction name="FM">Document <xsl:value-of select="$fmfile"/>.fm</xsl:processing-instruction>
        <xsl:value-of select="$newline"/>
        
        <fm-ditafile xsl:exclude-result-prefixes="ditaarch">
          <xsl:attribute name="platform">
            <xsl:value-of select="$vplatform"/>
          </xsl:attribute>
          <xsl:attribute name="product">
            <xsl:value-of select="$vproduct"/>
          </xsl:attribute>
          <xsl:attribute name="audience">
            <xsl:value-of select="$vaudience"/>
          </xsl:attribute>
          <xsl:attribute name="props">
            <xsl:value-of select="$vprops"/>
          </xsl:attribute>
          <xsl:attribute name="otherprops">
            <xsl:value-of select="$votherprops"/>
          </xsl:attribute>
          <xsl:attribute name="href">
            <xsl:value-of select="$href_value"/>
          </xsl:attribute>
          <xsl:attribute name="format">
            <xsl:value-of select="@format"/>
          </xsl:attribute>
          
<!-- 
     Set the maptype element by going up the document tree (Including self) and 
     finding the first part|chapter|topicref) element that contains the current 
     node. The order we select the ancestor is important.
  -->
          <xsl:attribute name="mapelemtype">          
            <xsl:call-template name="getMapElemType">
              <xsl:with-param name="nodename" select="."/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="outputclass">
            <xsl:value-of select="@outputclass"/>
          </xsl:attribute>

          <xsl:for-each select="$conditions">
            <xsl:value-of select="$newline"/>
            <xsl:processing-instruction name="FM">Condition <xsl:value-of select="@content"/> Black NO_OVERRIDE show AsIs</xsl:processing-instruction>
          </xsl:for-each>

          <xsl:value-of select="$newline"/>
          <xsl:apply-templates mode="final"/>
          <xsl:value-of select="$newline"/>
        </fm-ditafile>
      </xsl:when>
      
      <!-- otherwise this reference element is already in a book component
           so just process it as an fm-ditafile but do not write a 
           book component PI
       -->
      <xsl:otherwise>
        <fm-ditafile xsl:exclude-result-prefixes="ditaarch">
          <xsl:attribute name="platform">
            <xsl:value-of select="$vplatform"/>
          </xsl:attribute>
          <xsl:attribute name="product">
            <xsl:value-of select="$vproduct"/>
          </xsl:attribute>
          <xsl:attribute name="audience">
            <xsl:value-of select="$vaudience"/>
          </xsl:attribute>
          <xsl:attribute name="props">
            <xsl:value-of select="$vprops"/>
          </xsl:attribute>
          <xsl:attribute name="otherprops">
            <xsl:value-of select="$votherprops"/>
          </xsl:attribute>
          <xsl:attribute name="href">
            <xsl:value-of select="$href_value"/>
          </xsl:attribute>
          <xsl:attribute name="format">
            <xsl:value-of select="@format"/>
          </xsl:attribute>
          <xsl:attribute name="mapelemtype">
            <xsl:call-template name="getMapElemType">
	      <xsl:with-param name="nodename" select="."/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:attribute name="outputclass">
            <xsl:value-of select="@outputclass"/>
          </xsl:attribute>
          <xsl:apply-templates mode="final"/>
          <xsl:value-of select="$newline"/>
        </fm-ditafile>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  
  <!-- ************************************************************************ -->
  <!-- Process a reference element						-->
  <!-- ************************************************************************ -->

  <xsl:template mode="final"
    match="topicref|chapter|appendix|preface|bookabstract|
  				colophon|dedication|amendments|draftintro|notices|
  				mapref|glossref">
    <xsl:variable name="href">
      <xsl:call-template name="string.subst">
        <xsl:with-param name="string" select="@href"/>
        <xsl:with-param name="target" select="' '"/>
        <xsl:with-param name="replacement" select="'%20'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <!-- do not process any part when href is empty -->
      <xsl:when test="$href=''">
        <xsl:message terminate="no">The href attribute has no value and the topicref will not be
          processed.</xsl:message>
      </xsl:when>
      <!-- do not process any part that starts with http:, ftp:, https:, mailto: -->
      <xsl:when
        test="starts-with($href, 'http:') or starts-with($href, 'ftp:') or starts-with($href, 'https:') or starts-with($href, 'mailto:') or starts-with($href, 'www.')">
        <xsl:message terminate="no">topicref points to a URL and it will not be
          processed.</xsl:message>
      </xsl:when>
      <!-- ignore part that point to HTML files -->
      <xsl:when test="@format='html'">
        <xsl:message terminate="no">topicref points to an html (format=html) file and it will not be
          processed.</xsl:message>
      </xsl:when>
      <!-- ignore empty part files -->
      <xsl:when test="count(.) = 0">
        <xsl:message terminate="no">topicref points to an empty file and it will not be
          processed.</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="process-expanded-ref-with-attrs">
          <xsl:with-param name="nodes" select="."/>
          <xsl:with-param name="platform" select="@platform"/>
          <xsl:with-param name="otherprops" select="@otherprops"/>
          <xsl:with-param name="product" select="@product"/>
          <xsl:with-param name="audience" select="@audience"/>
          <xsl:with-param name="props" select="@props"/>
          <xsl:with-param name="baseref" select="@href"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="final"
    match="abbrevlist|bibliolist|booklist|figurelist|glossarylist|
  					indexlist|tablelist|toc|trademarklist">
    <xsl:value-of select="$newline"/>
    <xsl:processing-instruction name="FM">Document <xsl:value-of select="name(.)"/>.fm</xsl:processing-instruction>
    <xsl:value-of select="$newline"/>
    <fm-ditafile xsl:exclude-result-prefixes="ditaarch">
      <xsl:attribute name="mapelemtype">
       <xsl:call-template name="getMapElemType">
         <xsl:with-param name="nodename" select="."/>
       </xsl:call-template>
      </xsl:attribute>
      <xsl:attribute name="format">
        <xsl:value-of select="@format"/>
      </xsl:attribute>
      <xsl:attribute name="outputclass">
        <xsl:value-of select="@outputclass"/>
      </xsl:attribute>
      <xsl:element name="topic">
        <xsl:attribute name="id">
          <xsl:text>id</xsl:text>
	  <xsl:value-of select="name(.)"/>
        </xsl:attribute>
        <title>
          <xsl:value-of select="name(.)"/>
        </title>
      </xsl:element>
      <xsl:value-of select="$newline"/>
    </fm-ditafile>
  </xsl:template>


  <!-- ************************************************************************ -->
  <!-- process part. Parts get unwrapped and go into their own separate FM      -->
  <!-- documents. For example,                            			-->
  <!-- <part>                                     				-->
  <!--   chapter>                                 				-->
  <!--   chapter>                                 				-->
  <!-- </part>                                   				-->
  <!-- creates                                    				-->
  <!--  +part                                     				-->
  <!--  +chapter                                  				-->
  <!--  +chapter                                  				-->
  <!-- ***********************************************************************  -->
  
  <xsl:template mode="final" match="part">
    <xsl:variable name="href">
      <xsl:call-template name="string.subst">
        <xsl:with-param name="string" select="@href"/>
        <xsl:with-param name="target" select="' '"/>
        <xsl:with-param name="replacement" select="'%20'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <!-- do not process any part when href is empty -->
      <xsl:when test="$href=''">
        <xsl:message terminate="no">The href attribute has no value and the topicref will not be
          processed.</xsl:message>
      </xsl:when>
      <!-- do not process any part that starts with http:, ftp:, https:, mailto: -->
      <xsl:when
        test="starts-with($href, 'http:') or starts-with($href, 'ftp:') or starts-with($href, 'https:') or starts-with($href, 'mailto:') or starts-with($href, 'www.')">
        <xsl:message terminate="no">topicref points to a URL and it will not be
          processed.</xsl:message>
      </xsl:when>
      <!-- ignore part that point to HTML files -->
      <xsl:when test="@format='html'">
        <xsl:message terminate="no">topicref points to an html (format=html) file and it will not be
          processed.</xsl:message>
      </xsl:when>
      <!-- ignore empty part files -->
      <xsl:when test="count(.) = 0">
        <xsl:message terminate="no">topicref points to an empty file and it will not be
          processed.</xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="process-expanded-part-with-attrs">
          <xsl:with-param name="nodes" select="."/>
          <xsl:with-param name="platform" select="@platform"/>
          <xsl:with-param name="otherprops" select="@otherprops"/>
          <xsl:with-param name="product" select="@product"/>
          <xsl:with-param name="audience" select="@audience"/>
          <xsl:with-param name="props" select="@props"/>
          <xsl:with-param name="baseref" select="@href"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- ***********************************************************************  -->
  <!-- copy the result tree for these elements                    -->
  <!-- ***********************************************************************  -->
  
  <xsl:template mode="final" match="topic|task|reference|concept|glossary">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <!-- ************************************************************************	-->
  <!-- add a exclude-result-prefixes for dita to avoid parser warning and just 	-->
  <!-- copy the result tree. We might want to just unwrap the dita element in 	-->
  <!-- future									-->
  <!-- ************************************************************************	-->
  
  <xsl:template mode="final" match="dita">
    <dita xsl:exclude-result-prefixes="ditaarch">
     <xsl:copy-of select="*"/>
    </dita>
  </xsl:template>

  <!-- ************************************************************************** -->
  <!-- process part. Parts get unwrapped and go into their own separate FM        -->
  <!-- documents. For example,                            -->
  <!-- <part>                                     -->
  <!--   chapter>                                 -->
  <!--   chapter>                                 -->
  <!-- </part>                                    -->
  <!-- creates                                    -->
  <!--  +part                                     -->
  <!--  +chapter                                  -->
  <!--  +chapter                                  -->
  <!--                                        -->
  <!-- ***********************************************************************    -->
  
  <xsl:template name="process-expanded-part-with-attrs">
    <xsl:param name="nodes"/>
    <xsl:param name="platform"/>
    <xsl:param name="otherprops"/>
    <xsl:param name="product"/>
    <xsl:param name="audience"/>
    <xsl:param name="props"/>
    <xsl:param name="baseref"/>
    <xsl:variable name="href">
      <xsl:call-template name="string.subst">
        <xsl:with-param name="string" select="@href"/>
        <xsl:with-param name="target" select="' '"/>
        <xsl:with-param name="replacement" select="'%20'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="href_value">
      <xsl:call-template name="make_href">
        <xsl:with-param name="node" select="."/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="vplatform">
      <xsl:choose>
        <xsl:when test="@platform != ''">
          <xsl:value-of select="@platform"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$platform"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vprops">
      <xsl:choose>
        <xsl:when test="@props != ''">
          <xsl:value-of select="@props"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$props"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vproduct">
      <xsl:choose>
        <xsl:when test="@product != ''">
          <xsl:value-of select="@product"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$product"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="vaudience">
      <xsl:choose>
        <xsl:when test="@audience != ''">
          <xsl:value-of select="@audience"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$audience"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="votherprops">
      <xsl:choose>
        <xsl:when test="@otherprops != ''">
          <xsl:value-of select="@otherprops"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$otherprops"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dirname">
      <xsl:call-template name="dirname">
        <xsl:with-param name="path" select="@href"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="vbaseref">
      <xsl:value-of select="concat($baseref, $dirname)"/>
    </xsl:variable>
    <xsl:variable name="vfilename">
      <xsl:call-template name="filename">
        <xsl:with-param name="path" select="@href"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="parent::bookmap">
        <xsl:variable name="fmfile">
                  <xsl:value-of select="translate($href, '\:/#.', '_____')"/>
        </xsl:variable>
        <!-- write the PI so that FM knows to start a new book component -->
        <xsl:value-of select="$newline"/>
        <xsl:processing-instruction name="FM">Document <xsl:value-of select="$fmfile"/>.fm</xsl:processing-instruction>
        <xsl:value-of select="$newline"/>
        <fm-ditafile>
          <xsl:attribute name="href">
            <xsl:value-of select="$href_value"/>
          </xsl:attribute>
          <xsl:attribute name="format">
            <xsl:value-of select="@format"/>
          </xsl:attribute>
          <xsl:attribute name="mapelemtype">
            <xsl:call-template name="getMapElemType">
	       <xsl:with-param name="nodename" select="."/>
            </xsl:call-template>
          </xsl:attribute>
          <xsl:apply-templates mode="final" select="child::*[1]"/>
          <xsl:value-of select="$newline"/>
        <xsl:value-of select="$newline"/>
        </fm-ditafile>
        <xsl:value-of select="$newline"/>
        <!-- process any topicref and chapter in the part into their own FM Document -->
        <xsl:for-each select="topicref|chapter|appendix|preface|glossref">
          <xsl:apply-templates mode="final" select="."/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="final"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ************************************************************************** -->
  <!-- drop these elements completely 						  -->
  <!-- ************************************************************************** -->

  <xsl:template match="reltable|topicmeta|bookmeta|navref|anchor|keydef">
    <!-- ignore them completely -->
  </xsl:template>

  <!-- ***********************************************************************  -->
  <!-- drop these elements in maps, but leave them in topics  			-->
  <!-- ***********************************************************************  -->
  <xsl:template mode="final" match="map/data | bookmap/data | map/data-about | bookmap/data-about">
    <!-- ignore them completely -->
  </xsl:template>
 
  <!-- ***********************************************************************    -->
  <!-- drop these elements completely since we handle them separately -->
  <!-- ***********************************************************************    -->
  
  <xsl:template mode="final" match="map/title | bookmap/title | bookmap/booktitle">
    <!-- ignore them completely -->
  </xsl:template>
  
  <!-- ***********************************************************************    -->
  <!-- drop these elements completely since we handle them separately -->
  <!-- ***********************************************************************    -->
  
  <xsl:template mode="final" match="title">
    <xsl:element name="{name()}">
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="final"/>
    </xsl:element>
  </xsl:template>
  
  <!-- ***********************************************************************  -->
  <!-- unwrap these elements                      -->
  <!-- ***********************************************************************  -->
  
  <xsl:template mode="final" match="frontmatter | backmatter | booklists | topicgroup | topichead">
    <xsl:apply-templates mode="final"/>
  </xsl:template>
  
  <!-- Default postprocessing is just copying of nodes -->
  <xsl:template match="@*|*|text()" mode="final">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|text()" mode="final"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@*|*|text()" mode="expanded">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|text()" mode="expanded"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:transform>
