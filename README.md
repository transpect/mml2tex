# mml2tex

mml2tex is an XProc/XSLT-library to convert MathML to LaTeX.

It should currently support MathML 2 and 3 presentation markup. Content markup and some MathML 1 elements are not supported.

You may either invoke mml2tex standalone or include it as library in your XSLT or XProc project. The LaTeX code is wrapped in processing instructions named `mml2tex`.

This library is also used in [docx2tex](https://github.com/transpect/docx2tex) that converts Word docx files with OOMML (= new equation editor) formulas to LaTeX.

Consider this XML input file …

```xml
<?xml version="1.0" encoding="UTF-8"?>
<article xmlns="http://docbook.org/ns/docbook" version="5.0">
  <title>Area enclosed by a circle</title>
  <equation>
    <mml:math xmlns:mml="http://www.w3.org/1998/Math/MathML">
      <mml:mi>A</mml:mi>
      <mml:mo>=</mml:mo>
      <mml:mi>π</mml:mi>
      <mml:msup>
        <mml:mrow>
          <mml:mi>r</mml:mi>
        </mml:mrow>
        <mml:mrow>
          <mml:mn>2</mml:mn>
        </mml:mrow>
      </mml:msup>
    </mml:math>
  </equation>
</article>

```

… you should get this output:
```xml
<?xml version="1.0" encoding="UTF-8"?><article xmlns="http://docbook.org/ns/docbook" version="5.0">
  <title>Area enclosed by a circle</title>
  <equation>
    <?mml2tex A=\pi r^{2}?>
  </equation>
</article>
```


## Invoke standalone

There is a simple frontend XSLT to invoke mml2tex. You may use Saxon to apply the stylesheet to your input XML file.

```
$ java -jar saxon9he.jar -s:example.xml -xsl:mml2tex/xsl/invoke-mml2tex.xsl
```


## Include as XSLT library

You have to import `mml2tex.xsl` in your XSLT stylesheet and create a template that matches on the MathML equations. The MathML markup must be processed within the `mathml2tex` mode. You can take `xsl/mml2tex.xsl` as example:

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" 
  xmlns:saxon="http://saxon.sf.net/" 
  xmlns:tr="http://transpect.io"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  exclude-result-prefixes="saxon tr fn mml xs">
  
  <xsl:import href="mml2tex.xsl"/>
  
  <xsl:output method="xml" encoding="UTF-8"/>
  
  <xsl:preserve-space elements="mml:mn mml:mi mml:mtext mml:mo mml:ms"/>
  
  <xsl:param name="debug" select="'no'"/>
  <xsl:param name="debug-dir-uri" select="'debug'"/>
  
  <xsl:template match="mml:math">
    <xsl:processing-instruction name="mml2tex">
      <xsl:apply-templates select="." mode="mathml2tex"/>
    </xsl:processing-instruction>
  </xsl:template>
  
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
```

*Note:* You may omit the `xsl:processing-instruction`. Then the LaTeX code will be issued as plain text. This method is not recommended, because subsequent text replacements may break your LaTeX code. It's better to leave the LaTeX code within the processing instruction and resolve it as last step.

## Include as XProc library

### Get dependencies

Running mml2tex requires an XProc processor, the libary store-debug.xpl and of course mml2tex. To facilitate the invocation of the XProc pipeline, we recommend to use our patched calabash-frontend. You can checkout the repositories with Git or SVN.

#### Git

```
$ git clone https://github.com/transpect/calabash-frontend calabash
$ git clone https://github.com/transpect/calabash-distro calabash/distro
$ git clone https://github.com/transpect/mml2tex
$ git clone https://github.com/transpect/xproc-util
```

#### SVN

```
$ svn co https://github.com/transpect/calabash-frontend/trunk calabash
$ svn co https://github.com/transpect/calabash-distro/trunk calabash/distro
$ svn co https://github.com/transpect/mml2tex/trunk mml2tex
$ svn co https://github.com/transpect/xproc-util/trunk xproc-util
```

### Create an XML catalog

As a convention, our calabash frontend looks after an XML catalog file under `xmlcatalog/catalog.xml`. Therefore you have to create the directory and the file. 
```
$ mkdir xmlcatalog
$ touch xmlcatalog/catalog.xml
```
The catalog is necessary to resolve canonical URIs in import statements, such as `http://transpect.io/mml2tex/xpl/mml2tex.xpl`. Therefore, you have to edit the file `catalog.xml` and add appropriate `rewriteURI` statements for your dependencies.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<catalog xmlns="urn:oasis:names:tc:entity:xmlns:xml:catalog">
  
  <nextCatalog catalog="../mml2tex/xmlcatalog/catalog.xml"/>  
  <nextCatalog catalog="../xproc-util/xmlcatalog/catalog.xml"/>
  
</catalog>
```

### Include mml2tex in your XProc pipeline

The step `mml2tex:convert` facilitates the use of the mml2tex library in your XProc pipeline. As prerequisites, you must add the namespace  `http://transpect.io/mml2tex` and a `p:import` statement. A sample `test.xpl` may look like this:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:mml2tex="http://transpect.io/mml2tex"
  version="1.0">
  
  <p:input port="source">
    <p:inline>
      <article xmlns="http://docbook.org/ns/docbook" version="5.0">
        <title>Area enclosed by a circle</title>
        <equation>
          <mml:math xmlns:mml="http://www.w3.org/1998/Math/MathML"><mml:mi>A</mml:mi><mml:mo>=</mml:mo><mml:mi>π</mml:mi><mml:msup><mml:mrow><mml:mi>r</mml:mi></mml:mrow><mml:mrow><mml:mn>2</mml:mn></mml:mrow></mml:msup></mml:math>     
        </equation>
      </article>
    </p:inline>
  </p:input>
  
  <p:output port="result"/>
  
  <p:option name="debug"         select="'no'"/>   <!-- store debug files: yes | no -->
  <p:option name="debug-dir-uri" select="'debug'"/><!-- store debug files to this URI -->
  
  <p:import href="http://transpect.io/mml2tex/xpl/mml2tex.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <mml2tex:convert>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </mml2tex:convert>
  
</p:declare-step>
```
### Run the pipeline

We provide frontend scripts for XML Calabash which look after the XML catalogs, make some paths suitable for XProc and add some Java libraries to the class path. There is a Bash script for Unix-like operating systems as well as an Batch file for Windows. You can find them in the calabash directory. 
```
$ ./calabash/calabash.sh test.xpl
```
