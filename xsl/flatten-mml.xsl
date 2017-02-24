<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:mml="http://www.w3.org/1998/Math/MathML"
                xmlns:tr="http://transpect.io"
                exclude-result-prefixes="xs" 
                xpath-default-namespace="http://www.w3.org/1998/Math/MathML"
                version="2.0">
    
  <!-- This stylesheet is used to convert simple MathML expressions to plain text,
       e.g. "a+2", "a²", "+3".
       
       This could be useful if you want to reduce the number of equations 
       in your output, for instance to decrease page load time.
  
       Invoke on command line with saxon:
       $ saxon -xsl:xsl/flatten-mml.xsl -s:source.xml -o:output.xml
  -->
  
  <xsl:strip-space elements="mml:*"/>
  
  <!-- names of elements to be generated for superscript and subscript -->
  <xsl:param name="superscript-name" select="'superscript'" as="xs:string"/>
  <xsl:param name="subscript-name"   select="'subscript'"   as="xs:string"/>
  <xsl:param name="namespace"   select="'http://docbook.org/ns/docbook'"   as="xs:string"/>
  <!-- if the number of operators exceed this limit, the equation will not be flattened -->
  <xsl:param name="operator-limit"   select="1"             as="xs:integer"/>

  <xsl:template match="math[every $i in .//*
                            satisfies (string-length(normalize-space($i)) eq 0 and not($i/@*))]" mode="mml2tex-preprocess">
    <xsl:message select="'[WARNING] empty equation removed:&#xa;', ."/>
  </xsl:template>

  <xsl:template match="math[tr:flatten-mml-boolean(.)]">
    <xsl:apply-templates mode="flatten-mml"/>
  </xsl:template>
  
  <xsl:template match="*" mode="flatten-mml">
    <xsl:apply-templates mode="flatten-mml"/>
  </xsl:template>
  
  <xsl:template match="msub|msup" mode="flatten-mml">
    <xsl:apply-templates select="*[1]" mode="flatten-mml"/>
    <xsl:element name="{if(local-name() eq 'msub') then $subscript-name else $superscript-name}" namespace="{$namespace}">
      <xsl:apply-templates select="*[2]" mode="flatten-mml"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="mspace" mode="flatten-mml">
    <xsl:variable name="width" select="xs:decimal(replace(@width, '[a-z]+', ''))" as="xs:decimal"/>
    <xsl:variable name="mu-width" select="$width * 18" as="xs:decimal"/>
    <!-- 1 mu = 1/18em, MathML authors are encouraged to use em as unit here -->
    <xsl:variable name="text-mwidth" 
                  select="if($mu-width &gt;= 36)  then '&#x2003;&#x2003;' (: twice of \quad (= 36 mu):)
                          else if($mu-width &gt;= 18)  then '&#x2003;'    (: 1 mu :)
                          else if($mu-width &gt;= 9)   then '&#x20;'      (: equivalent of space in normal text :)
                          else if($mu-width &gt;= 5)   then '&#x2004;'    (: 5/18 of \quad (= 5 mu) :)
                          else if($mu-width &gt;= 4)   then '&#x2005;'    (: 4/18 of \quad (= 3 mu) :)
                          else if($mu-width &lt; 4)    then '&#x2009;'    (: 3/18 of \quad (= 3 mu) :)
                                                       else '&#x20;'"/>
    <xsl:value-of select="$text-mwidth"/>
  </xsl:template>
  
  <xsl:template match="mo" mode="flatten-mml">
    <xsl:value-of select="translate(., '-/', '&#x2212;&#x2215;')"/>
  </xsl:template>
  
  <xsl:function name="tr:flatten-mml-boolean" as="xs:boolean">
    <xsl:param name="math" as="element(math)"/>
    <xsl:value-of select="if(count($math//mo) le $operator-limit
                             and not(   $math//mfrac 
                                     or $math//mroot
                                     or $math//msqrt
                                     or $math//mtable
                                     or $math//mmultiscripts
                                     or $math//mphantom
                                     or $math//mstyle
                                     or $math//mover
                                     or $math//munder
                                     or $math//munderover
                                     or $math//munderover
                                     or $math//msubsup
                                     or $math//menclose
                                     or $math//merror
                                     or $math//maction
                                     or $math//mglyph
                                     or $math//mlongdiv
                                     or $math//msup[.//msub|.//msup]
                                     or $math//msub[.//msub|.//msup]
                                     or $math/msup[not(matches(., '[&#x0009;-&#x007f;]'))]
                                     or $math/msub[not(matches(., '[&#x0009;-&#x007f;]'))]
                                     )
                             )
                          then true()
                          else false()"/>
  </xsl:function>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template> 
  
</xsl:stylesheet>
