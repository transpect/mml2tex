<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:tr="http://transpect.io"
  version="2.0"
  exclude-result-prefixes="tr mml xs">

  <xsl:import href="mml2tex.xsl"/>

  <xsl:output method="text" encoding="UTF-8"/>

  <xsl:strip-space elements="*"/>

  <xsl:preserve-space elements="mml:mn mml:mi mml:mtext mml:mo mml:ms"/>

  <xsl:template name="main">
    <xsl:text>\documentclass{scrbook}  
\usepackage{graphicx} 
\usepackage{hyperref} 
\usepackage{multirow} 
\usepackage{amsmath} 
\usepackage{amssymb} 
\usepackage{amsfonts} 
\usepackage{wasysym} 
\usepackage{isomath} 
\usepackage{upgreek} 
\usepackage{enumerate} 
\usepackage[ngerman]{babel} 
  
\begin{document}
</xsl:text>
    <xsl:for-each select="//mml:math">
      <xsl:variable name="tex">
        <xsl:apply-templates select="." mode="mathml2tex"/>
      </xsl:variable>
      <xsl:text>
\begin{equation}
      </xsl:text><xsl:apply-templates select="." mode="mathml2tex"/>
      <xsl:text>
\end{equation}&#xa;
      </xsl:text>
    </xsl:for-each>
    <xsl:text>
      \end{document}
    </xsl:text>
  </xsl:template>

</xsl:stylesheet>
