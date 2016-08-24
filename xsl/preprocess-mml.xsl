<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  version="2.0"
  exclude-result-prefixes="mml xs" 
  xpath-default-namespace="http://www.w3.org/1998/Math/MathML">
  
  <!--  *
        * remove empty equation objects
        * -->
  
  <xsl:template match="mml:math[every $i in .//mml:* 
                                satisfies (string-length(normalize-space($i)) eq 0 and not($i/@*))]
                       |//processing-instruction('mathtype')[string-length(normalize-space(replace(., '\$', ''))) eq 0]" mode="mml2tex-preprocess">
    <xsl:message select="'[WARNING] empty equation removed:&#xa;', ."/>
    <xsl:processing-instruction name="latex" select="'% empty equation removed. ', replace(., '[\n&#xa;]+', '')"/>
  </xsl:template>
  
  <!--  *
        * group adjacent mi tags with equivalent attributes
        * -->
  
  <xsl:template match="*[count(mi) gt 1]" mode="mml2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      
      <xsl:for-each-group select="*" 
        group-adjacent="concat(
                               name(), 
                               string-join(for $i in @* return concat($i/local-name(), $i), '-')
                              )">
          <xsl:choose>
            <!-- some MathML elements expect a certain order of arguments -->
            <xsl:when test="current-group()/local-name() = 'mi' and not(parent::msup or parent::msub or parent::msubsup or parent::mfrac or parent::mroot or parent::mmultiscripts)">
              <xsl:copy>
                <xsl:apply-templates select="current-group()/@*, current-group()/node()" mode="#current"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="current-group()" mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>
        
      </xsl:for-each-group>
      
    </xsl:copy>
  </xsl:template>
  
  <!-- resolve msubsup if superscript and subscript is empty -->
  
  <xsl:template match="msubsup[every $i in (*[2], *[3]) satisfies matches($i,'^[&#x2001;-&#x200b;]+$') or not(exists($i/node()))]" priority="10" mode="mml2tex-preprocess">
    <xsl:apply-templates select="*[1]" mode="#current"/>
  </xsl:template>
  
  <!-- convert msubsup to msub if superscript is empty -->
  
  <xsl:template match="msubsup[exists(*[2]/node()) and (matches(*[3],'^[&#x2001;-&#x200b;]+$') or not(exists(*[3]/node())))]" mode="mml2tex-preprocess">
    <msub xmlns="http://www.w3.org/1998/Math/MathML">
      <xsl:apply-templates select="@*, node() except *[3]" mode="#current"/>
    </msub>
  </xsl:template>
  
  <!-- convert msubsup to msup if subscript is empty -->
  
  <xsl:template match="msubsup[exists(*[3]/node()) and (matches(*[2],'^[&#x2001;-&#x200b;]+$') or not(exists(*[2]/node())))]" mode="mml2tex-preprocess">
    <msup xmlns="http://www.w3.org/1998/Math/MathML">
      <xsl:apply-templates select="@*, node() except *[2]" mode="#current"/>
    </msup>
  </xsl:template>
  
  <!-- resolve msub/msup with empty argument -->
  
  <xsl:template match="msub[matches(*[2],'^[&#x2001;-&#x200b;]+$') or not(exists(*[2]/node()))]
                       |msup[matches(*[2],'^[&#x2001;-&#x200b;]+$') or not(exists(*[2]/node()))]" mode="mml2tex-preprocess">
    <xsl:apply-templates select="*[1]" mode="#current"/>
  </xsl:template>
  
  <!-- resolve nested mmultiscripts when authors put tensors in the base of tensors by accident (MS Word equation editor) -->
  
  <xsl:template match="mmultiscripts/mrow[mmultiscripts]" mode="mml2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*, *[1]" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mmultiscripts[mrow/mmultiscripts]" mode="mml2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
    <xsl:apply-templates select="mrow/*[position() gt 1]" mode="#current"/>
  </xsl:template>
  
  <!-- identity template -->
  
  <xsl:template match="*|@*|processing-instruction()" mode="mml2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/" mode="mml2tex-preprocess">
    <xsl:copy>
      <xsl:apply-templates mode="mml2tex-preprocess"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
