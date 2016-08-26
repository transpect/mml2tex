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
  <xsl:param name="superscript-name" select="'Superscript'" as="xs:string"/>
  <xsl:param name="subscript-name"   select="'Subscript'"   as="xs:string"/>
  <xsl:param name="namespace"   select="'bogo'"   as="xs:string"/>
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
    <xsl:element name="{if(local-name() eq 'msub') then $superscript-name else $subscript-name}" namespace="{$namespace}">
      <xsl:apply-templates select="*[2]" mode="flatten-mml"/>
    </xsl:element>
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

  <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template> 
  
</xsl:stylesheet>