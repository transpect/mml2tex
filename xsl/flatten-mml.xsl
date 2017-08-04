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
  
  <!-- wrapper element -->
  <xsl:param name="wrapper" as="element()?">
    <phrase role="flattened-mml" xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>
  <!-- create elements for different styles. You may override this in your 
       importing stylesheet to satisfy other XML schemas -->
  <xsl:param name="superscript" as="element()">
    <superscript xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>
  <xsl:param name="subscript" as="element()">
    <subscript xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>
  <xsl:param name="bold" as="element()">
    <phrase role="bold" xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>
  <xsl:param name="italic" as="element()">
    <phrase role="italic" xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>
  <xsl:param name="bold-italic" as="element()">
    <phrase role="bold-italic" xmlns="http://docbook.org/ns/docbook"/>
  </xsl:param>
  
  <!-- if the number of operators exceed this limit, the equation will not be flattened -->
  <xsl:param name="operator-limit"   select="1"             as="xs:integer"/>

  <xsl:template match="math[every $i in .//*
                            satisfies (string-length(normalize-space($i)) eq 0 and not($i/@*))]" mode="mml2tex-preprocess">
    <xsl:message select="'[WARNING] empty equation removed:&#xa;', ."/>
  </xsl:template>

  <xsl:template match="math[tr:flatten-mml-boolean(.)]">
    <xsl:choose>
      <xsl:when test="$wrapper">
        <xsl:element name="{$wrapper/local-name()}" namespace="{$wrapper/namespace-uri()}">
          <xsl:apply-templates select="$wrapper/@*" mode="#default"/>
          <xsl:apply-templates mode="flatten-mml"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="flatten-mml"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template match="*" mode="flatten-mml">
    <xsl:apply-templates mode="flatten-mml"/>
  </xsl:template>
  
  <xsl:template match="msub|msup" mode="flatten-mml">
    <xsl:variable name="element" select="if(local-name() eq 'msub') then $subscript else $superscript" as="element()"/>
    <xsl:apply-templates select="*[1]" mode="flatten-mml"/>
    <xsl:element name="{$element/local-name()}" namespace="{$element/namespace-uri()}">
      <xsl:apply-templates select="$element/@*" mode="#default"/>
      <xsl:apply-templates select="*[2]" mode="flatten-mml"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="mi[string-length() eq 1 and not(@mathvariant) or @mathvariant = ('italic', '')]" mode="flatten-mml">
    <xsl:element name="{$italic/local-name()}" namespace="{$italic/namespace-uri()}">
      <xsl:apply-templates select="$italic/@*" mode="#default"/>
      <xsl:apply-templates select="node()" mode="flatten-mml"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*[local-name() = ('mi', 'mo', 'mn', 'mtext')][@mathvariant = ('italic', 'bold', 'bold-italic')]" mode="flatten-mml">
    <xsl:variable name="element" select="if(@mathvariant eq 'italic') then $italic
                                         else if(@mathvariant eq 'bold') then $bold 
                                         else $bold-italic" as="element()"/>
    <xsl:element name="{$element/local-name()}" namespace="{$element/namespace-uri()}">
      <xsl:apply-templates select="$element/@*" mode="#default"/>
      <xsl:apply-templates select="node()" mode="flatten-mml"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="*[local-name() = ('mi', 'mo', 'mn', 'mtext')][@mathvariant = ('fraktur', 
                                                                                     'script', 
                                                                                     'double-struck', 
                                                                                     'bold-fraktur', 
                                                                                     'bold-script', 
                                                                                     'sans-serif', 
                                                                                     'sans-serif-bold', 
                                                                                     'sans-serif-italic', 
                                                                                     'sans-serif-bold-italic', 
                                                                                     'monospace')]" mode="flatten-mml">
    <xsl:variable name="style" select="@mathvariant" as="attribute(mathvariant)"/>
    <xsl:variable name="math-alphabets" as="element()+">
      <alphabets>
        <alphabet name="fraktur">𝔄𝔅ℭ𝔇𝔈𝔉𝔊ℌℑ𝔍𝔎𝔏𝔐𝔑𝔒𝔓𝔔ℜ𝔖𝔗𝔘𝔙𝔚𝔛𝔜ℨ𝔞𝔟𝔠𝔡𝔢𝔣𝔤𝔥𝔦𝔧𝔨𝔩𝔪𝔫𝔬𝔭𝔮𝔯𝔰𝔱𝔲𝔳𝔴𝔵𝔶𝔷</alphabet>
        <alphabet name="script">𝒜ℬ𝒞𝒟ℰℱ𝒢ℋℐ𝒥𝒦ℒℳ𝒩𝒪𝒫𝒬ℛ𝒮𝒯𝒰𝒱𝒲𝒳𝒴𝒵𝒶𝒷𝒸𝒹ℯ𝒻ℊ𝒽𝒾𝒿𝓀ℓ𝓁𝓂𝓃𝓅𝓆𝓇𝓈𝓉𝓊𝓋𝓌𝓍𝓎𝓏</alphabet>
        <alphabet name="double-struck">𝔸𝔹ℂ𝔻𝔼𝔽𝔾ℍ𝕀𝕁𝕂𝕃𝕄ℕ𝕆ℙℚℝ𝕊𝕋𝕌𝕍𝕎𝕏𝕐ℤ𝕒𝕓𝕔𝕕𝕖𝕗𝕘𝕙𝕚𝕛𝕜𝕝𝕞𝕟𝕠𝕡𝕢𝕣𝕤𝕥𝕦𝕧𝕨𝕩𝕪𝕫</alphabet>
        <alphabet name="bold-fraktur">𝕬𝕭𝕮𝕯𝕰𝕱𝕲𝕳𝕴𝕵𝕶𝕷𝕸𝕹𝕺𝕻𝕼𝕽𝕾𝕿𝖀𝖁𝖂𝖃𝖄𝖅𝖆𝖇𝖈𝖉𝖊𝖋𝖌𝖍𝖎𝖏𝖐𝖑𝖒𝖓𝖔𝖕𝖖𝖗𝖘𝖙𝖚𝖛𝖜𝖝𝖞𝖟</alphabet>
        <alphabet name="bold-script">𝓐𝓑𝓒𝓓𝓔𝓕𝓖𝓗𝓘𝓙𝓚𝓛𝓜𝓝𝓞𝓟𝓠𝓡𝓢𝓣𝓤𝓥𝓦𝓧𝓨𝓩𝓪𝓫𝓬𝓭𝓮𝓯𝓰𝓱𝓲𝓳𝓴𝓵𝓶𝓷𝓸𝓹𝓺𝓻𝓼𝓽𝓾𝓿𝔀𝔁𝔂𝔃</alphabet>
        <alphabet name="sans-serif">𝖠𝖡𝖢𝖣𝖤𝖥𝖦𝖧𝖨𝖩𝖪𝖫𝖬𝖭𝖮𝖯𝖰𝖱𝖲𝖳𝖴𝖵𝖶𝖷𝖸𝖹𝖺𝖻𝖼𝖽𝖾𝖿𝗀𝗁𝗂𝗃𝗄𝗅𝗆𝗇𝗈𝗉𝗊𝗋𝗌𝗍𝗎𝗏𝗐𝗑𝗒𝗓</alphabet>
        <alphabet name="sans-serif-bold">𝗔𝗕𝗖𝗗𝗘𝗙𝗚𝗛𝗜𝗝𝗞𝗟𝗠𝗡𝗢𝗣𝗤𝗥𝗦𝗧𝗨𝗩𝗪𝗫𝗬𝗭𝗮𝗯𝗰𝗱𝗲𝗳𝗴𝗵𝗶𝗷𝗸𝗹𝗺𝗻𝗼𝗽𝗾𝗿𝘀𝘁𝘂𝘃𝘄𝘅𝘆𝘇</alphabet>
        <alphabet name="sans-serif-italic">𝘈𝘉𝘊𝘋𝘌𝘍𝘎𝘏𝘐𝘑𝘒𝘓𝘔𝘕𝘖𝘗𝘘𝘙𝘚𝘛𝘜𝘝𝘞𝘟𝘠𝘡𝘢𝘣𝘤𝘥𝘦𝘧𝘨𝘩𝘪𝘫𝘬𝘭𝘮𝘯𝘰𝘱𝘲𝘳𝘴𝘵𝘶𝘷𝘸𝘹𝘺𝘻</alphabet>
        <alphabet name="sans-serif-bold-italic">𝘼𝘽𝘾𝘿𝙀𝙁𝙂𝙃𝙄𝙅𝙆𝙇𝙈𝙉𝙊𝙋𝙌𝙍𝙎𝙏𝙐𝙑𝙒𝙓𝙔𝙕𝙖𝙗𝙘𝙙𝙚𝙛𝙜𝙝𝙞𝙟𝙠𝙡𝙢𝙣𝙤𝙥𝙦𝙧𝙨𝙩𝙪𝙫𝙬𝙭𝙮𝙯</alphabet>
        <alphabet name="monospace">𝙰𝙱𝙲𝙳𝙴𝙵𝙶𝙷𝙸𝙹𝙺𝙻𝙼𝙽𝙾𝙿𝚀𝚁𝚂𝚃𝚄𝚅𝚆𝚇𝚈𝚉𝚊𝚋𝚌𝚍𝚎𝚏𝚐𝚑𝚒𝚓𝚔𝚕𝚖𝚗𝚘𝚙𝚚𝚛𝚜𝚝𝚞𝚟𝚠𝚡𝚢𝚣</alphabet>
      </alphabets>
    </xsl:variable>
    <xsl:value-of select="translate(., 
                                    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz', 
                                    $math-alphabets/*:alphabet[@name eq $style])"/>
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
