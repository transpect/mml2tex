<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML" 
  xmlns:tr="http://transpect.io"
  version="2.0"
  exclude-result-prefixes="tr mml xs">

  <xsl:import href="mml2tex.xsl"/>
  <xsl:import href="http://transpect.io/mml-normalize/xsl/mml-normalize.xsl"/>

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:strip-space elements="*"/>

  <xsl:preserve-space elements="mml:mn mml:mi mml:mtext mml:mo mml:ms"/>

  <xsl:param name="mml-preprocessing" select="mml_preprocessing"/>

  <xsl:variable name="mml2tex-grouping">
    <xsl:apply-templates select="/" mode="mml2tex-grouping"/>
  </xsl:variable>
  
  <xsl:variable name="mml2tex-preprocess">
    <xsl:apply-templates select="$mml2tex-grouping" mode="mml2tex-preprocess"/>
  </xsl:variable>

  <xsl:template name="main">
    <xsl:text>
\documentclass{scrbook}
\usepackage[T1]{fontenc}
\usepackage[utf8]{inputenc}
\usepackage{amsmath}
\usepackage{amssymb}
\usepackage{amsfonts}
\usepackage{amsxtra}
\usepackage{wasysym}
\usepackage{isomath}
\usepackage{mathtools}
\usepackage{txfonts}
\usepackage[ngerman]{babel}
\begin{document}
    </xsl:text>

    <xsl:choose>
      <xsl:when test="true()">
        <xsl:text>$</xsl:text>
     	<xsl:for-each select="$mml2tex-preprocess//mml:math">
     	  <xsl:apply-templates select="." mode="mathml2tex"/>
     	</xsl:for-each>
        <xsl:text>$</xsl:text>
      </xsl:when>
      <xsl:otherwise>
     	<xsl:for-each select="//mml:math">
     	  <xsl:apply-templates select="." mode="mathml2tex"/>
     	</xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
<xsl:text>
\end{document}
</xsl:text>
  </xsl:template>

</xsl:stylesheet>
