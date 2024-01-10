<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"  
  xmlns:xs="http://www.w3.org/2001/XMLSchema"  
  xmlns:tr="http://transpect.io"
  xmlns:mml="http://www.w3.org/1998/Math/MathML" 
  xmlns:mml2tex="http://transpect.io/mml2tex"
  xmlns:xml2tex="http://transpect.io/xml2tex"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:functx="http://www.functx.com"
  exclude-result-prefixes="tr mml xs mml2tex functx html xml2tex" 
  version="2.0">

  <xsl:import href="http://transpect.io/unwrap-mml/xsl/unwrap-mml-xhtml.xsl"/>
  <xsl:import href="mml2tex.xsl"/>
  <xsl:import href="http://transpect.io/mml-normalize/xsl/mml-normalize.xsl"/>

  <xsl:param name="use-upgreek-map" as="xs:boolean" select="false()"/>
  <xsl:param name="remove-mspace-next-to-operator-treshold-em" select="0.21" as="xs:decimal"/>
  <xsl:param name="unwrap-mml" as="xs:string" select="'no'"/>
  <xsl:param name="katex" select="'yes'"/>
  <xsl:param name="debug-katex" select="'no'"/>
  <xsl:param name="texmap-uri" select="'http://transpect.io/mml2tex/texmap/katexmap.xml'" as="xs:string"/>
  
  <!--<xsl:variable name="mi-regex" as="xs:string" 
                select="concat('((', 
                               $mml2tex:functions-names-regex, 
                               ')|([a-zA-Z&#x391;-&#x3f6;])'
                               ,')')"/>-->

  <xsl:variable name="mml2tex:text-char-regex" as="xs:string" 
                select="concat('[',
                               '\p{L}', 
                               '&#x2013;-&#x2014;',
                               '&#x201c;-&#x201f;',
                               '&#xc0;-&#xd6;', 
                               '&#xd9;-&#xf6;',
                               '&#xf9;-&#x1fd;',
                               ']')">
    <!-- added: any letter (\p{L})
      In order not to convert <mml:mtext>mit</mml:mtext> to
      <mml:mi mathvariant="normal">mit</mml:mi> 
      in 18599.5/20111200.x1ca73b2, eq. (28) -->
  </xsl:variable>

  <xsl:variable name="katex-css-link" as="element(html:link)">
    <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" 
      href="https://cdn.jsdelivr.net/npm/katex@0.16.8/dist/katex.min.css" 
      integrity="sha384-GvrOXuhMATgEsSwCs4smul74iXGOixntILdUW9XmUC6+HX0sLNAK3q71HotJqlAn" 
      crossorigin="anonymous"/>
  </xsl:variable>
  
  <xsl:param name="katex-css-overrides" as="xs:string" select="'http://transpect.io/mml2tex/css/katex-overrides.css'"/>
  <xsl:variable name="katex-css-overrides-link" as="element(html:link)?">
    <!-- Needs to be resolved by a catalog resolver or made relative. 
         The retrieved text file content may be embedded into the HTML page in a style element. 
         Therefore you need to avoid &lt; in this CSS file. -->
    <xsl:if test="normalize-space($katex-css-overrides)">
      <link xmlns="http://www.w3.org/1999/xhtml" rel="stylesheet" type="text/css" href="{$katex-css-overrides}"/>  
    </xsl:if>
  </xsl:variable>

  <xsl:variable name="display-formula-local-names" as="xs:string+" select="('disp-formula', 'equation', 'dformula')"/>
  
  <xsl:template name="mml:katexify">
    <xsl:param name="wrapper" as="xs:string" select="if(local-name(..) = $display-formula-local-names) 
                                                     then 'div' else 'span'"/>
    <xsl:variable name="mml2tex-grouping" as="element(mml:math)">
      <xsl:apply-templates select="." mode="mml2tex-grouping"/>
    </xsl:variable>
<!--    <xsl:if test="matches(., 'προ')">
      <xsl:message select="'IIIIIIIIIIII ', ."/>
    </xsl:if>
    <xsl:if test="matches(., 'προ')">
      <xsl:message select="'GGGGGGGGGGGG ', $mml2tex-grouping"/>
    </xsl:if>-->
    <xsl:variable name="mml2tex-preprocess" as="element(mml:math)">
      <xsl:apply-templates select="$mml2tex-grouping" mode="mml2tex-preprocess"/>
    </xsl:variable>
    <!--<xsl:if test="matches(., '^\s*3\s*$')">
      <xsl:message select="'PPPPPPPPPPPPP ', $mml2tex-preprocess"/>
    </xsl:if>-->
    <xsl:element name="{$wrapper}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:attribute name="class" select="$katex-class"/>
      <xsl:if test="$debug-katex = 'yes'">
        <grouping xmlns="http://www.w3.org/1999/xhtml">
          <xsl:sequence select="$mml2tex-grouping"/>
        </grouping>
        <preprocess xmlns="http://www.w3.org/1999/xhtml">
          <xsl:sequence select="$mml2tex-preprocess"/>
        </preprocess>
        <xsl:text>&#xa;&#xa;&#xa;</xsl:text>
      </xsl:if>
      <xsl:apply-templates select="$mml2tex-preprocess" mode="mathml2tex">
        <xsl:with-param name="katexify-context" as="element(*)?" select=".." tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:element>
  </xsl:template>
  
   <xsl:template match="mml:mtext[matches(., '.[&#x300;-&#x36f;&#x2d9;]')]" mode="mml2tex-grouping">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  
    <!--<xsl:template match="mml:mtext[not(matches(.,concat('^[', $whitespace-regex, ']+$')))]
                                [not(matches(., concat('^', $mml2tex:functions-names-regex, '$')))]
                                [not(matches(., '^\p{No}+$'))](: vulgar fractions, superscripts, etc.:)
                                [empty(processing-instruction())]" 
                mode="mml2tex-preprocess_">
    <!-\- Too much magic in the original template. It converts <mml:mtext>mit</mml:mtext> to
      <mml:mi mathvariant="normal">mit</mml:mi> in 18599.5/20111200.x1ca73b2, eq. (28) -\->
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>-->
  
  <xsl:template match="mml:mi[empty(@mathvariant | @style | parent::mml:mstyle/(@mathvariant | @style))]
                             [matches(., '^\p{L}{3}$')]
                             [not(. = $mml2tex:function-names)]" mode="mml2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="mathvariant" select="'italic'"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:function name="mml:text-mathvariant-map" as="xs:string">
    <xsl:param name="mtext" as="element(mml:mtext)"/>
    <xsl:choose>
      <xsl:when test="empty($mtext/(@style | @mathvariant))">
        <xsl:sequence select="'text'"/>
      </xsl:when>
      <xsl:when test="$mtext/@mathvariant = 'sans-serif'">
        <xsl:sequence select="'textsf'"/>
      </xsl:when>
      <xsl:when test="$mtext/@mathvariant = 'italic'">
        <xsl:sequence select="'textit'"/>
      </xsl:when>
      <xsl:when test="$mtext/@mathvariant = 'bold'">
        <xsl:sequence select="'textbf'"/>
      </xsl:when>
      <xsl:when test="$mtext/@mathvariant = 'monospace'">
        <xsl:sequence select="'texttt'"/>
      </xsl:when>
      <xsl:when test="normalize-space($mtext/@style) = 'font-variant:small-caps'">
        <xsl:sequence select="'text'"/><!-- textsc not supported yet, https://github.com/KaTeX/KaTeX/pull/3085 -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'text'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:template match="mml:mstyle[@mathvariant | @style][count(*) = 1][mml:mtext]" mode="mml2tex-grouping">
    <mtext xmlns="http://www.w3.org/1998/Math/MathML">
      <xsl:apply-templates select="@*, mml:mtext/(@* | node())" mode="#current"/>
    </mtext>
  </xsl:template>
  
  <xsl:template match="mml:mtext[mml:text-mathvariant-map(.)]
                                [not(matches(., concat('^\s*', $mi-regex, '\s*$')))]" mode="mml2tex-preprocess" priority="1">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mml:mtext[mml:text-mathvariant-map(.)]" mode="mathml2tex">
    <xsl:text>\htmlClass{override-</xsl:text>
    <xsl:value-of select="mml:text-mathvariant-map(.)"/>
    <xsl:text>}{\text{</xsl:text>
    <xsl:apply-templates mode="#current"/>
    <xsl:text>}}</xsl:text>
  </xsl:template>
  
  <!--<xsl:template match="mml:msubsup|mml:munderover[*[1] = $integrals-sums-and-limits]/mml:mtext[matches(., '^\p{L}{2,}$')]
                                                                                              [. is ../*[1]]
                                                                                              [empty(@mathvariant | @style)]" 
                mode="mml2tex-preprocess">
    <!-\- treat text as multi-letter math operator because otherwise \htmlClass{…}{\lim}\limits won’t work in -\-> 
    <mi xmlns="http://www.w3.org/1998/Math/MathML">
      <xsl:apply-templates select="@* | node()" mode="#current"/>
    </mi>
  </xsl:template>-->
  
  <xsl:template match="mml:math/node()[last()]" mode="mathml2tex" priority="2">
    <xsl:param name="katexify-context" as="element(*)?" tunnel="yes"/>
    <xsl:next-match/>
    <!-- JATS-specific: -->
    <xsl:apply-templates select="$katexify-context/label" mode="#current"/>
  </xsl:template>
  
  <xsl:template match="label" mode="mathml2tex">
    <!-- for JATS -->
    <xsl:text>\tag{</xsl:text>
    <xsl:value-of select="."/>
    <xsl:text>}</xsl:text>
  </xsl:template>

  <xsl:template match="mml:munder/*[. = '&#xb8;']" mode="mathml2tex-accent-pre">
    <xsl:text>\text{[cedil]}</xsl:text>
  </xsl:template>
  <xsl:template match="mml:munder/*[. = '&#xb8;']" mode="mathml2tex-accent-post"/>


  <xsl:template match="mml:mo[not(normalize-space(.)) and not(processing-instruction())]
                       | mml:mtext[not(normalize-space(.)) and not(processing-instruction())]" mode="mml2tex-preprocess">
    <!-- Otherwise, the empty mo in 
      <mml:msup><mml:mo/><mml:mstyle mathvariant="sans-serif"><mml:mtext>3</mml:mtext></mml:mstyle></mml:msup> 
      that originates from 
      <formula alphabet="latin" notation="iso12083">
        <post post="phantom" style="single"/>
        <sup arrange="compact" location="post"><sansser>3</sansser></sup>
      </formula>
      would be removed, resulting in an error (only 1 arg left in msup) -->
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  

</xsl:stylesheet>
