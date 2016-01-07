<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  version="2.0"
  exclude-result-prefixes="mml xs">
  
  <!--  *
        * group adjacent mi tags with equivalent attributes
        * -->
  
  <xsl:template match="mml:*[count(mml:mi) gt 1]">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      
      <xsl:for-each-group select="*" 
        group-adjacent="concat(
                               name(), 
                               string-join(for $i in @* return concat($i/local-name(), $i), '-')
                              )">
          <xsl:choose>
            <xsl:when test="current-group()/local-name() = 'mi'">
              <xsl:copy>
                <xsl:apply-templates select="current-group()/@*"/>
                <xsl:apply-templates select="current-group()/node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="current-group()"/>
            </xsl:otherwise>
          </xsl:choose>
        
      </xsl:for-each-group>
      
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="mml:mi/text()[matches(., '^\s+$')][not(parent::mi/preceding-sibling::*[1][local-name() eq 'mi'] or parent::mi/following-sibling::*[1][local-name() eq 'mi'])]"/>
  
  <xsl:template match="*|@*|processing-instruction()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>