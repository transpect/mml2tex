<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML" 
  xmlns:tr="http://transpect.io"
  version="2.0"
  exclude-result-prefixes="tr mml xs">

  <xsl:import href="mml2tex.xsl"/>
  <xsl:import href="preprocess-mml.xsl"/>

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:strip-space elements="*"/>

  <xsl:preserve-space elements="mml:mn mml:mi mml:mtext mml:mo mml:ms"/>
  
  <xsl:variable name="mml2tex-preprocess">
    <xsl:apply-templates select="/" mode="mml2tex-preprocess"/>
  </xsl:variable>

  <xsl:template name="main">
    <xsl:for-each select="$mml2tex-preprocess//mml:math">
      <xsl:apply-templates select="." mode="mathml2tex"/>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
