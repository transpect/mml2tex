<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:mml2tex="http://transpect.io/mml2tex"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <xsl:variable name="mml2tex:function-names" as="xs:string+" 
                select="('arccos',
                         'arcsin',
                         'arctan',
                         'arg',
                         'cos',
                         'cosh',
                         'cot',
                         'coth',
                         'csc',
                         'deg',
                         'det',
                         'dim',
                         'exp',
                         'gcd',
                         'hom',
                         'inf',
                         'ker', 
                         'lg',
                         'lim', 
                         'liminf', 
                         'limsup', 
                         'ln', 
                         'log', 
                         'max', 
                         'min', 
                         'Pr', 
                         'sec', 
                         'sin',
                         'sinh', 
                         'sup', 
                         'tan', 
                         'tanh'
                         )"/>
  
  <xsl:variable name="mml2tex:functions-names-regex" select="concat('(', string-join($mml2tex:function-names, '|'), ')')" as="xs:string"/>
  
</xsl:stylesheet>