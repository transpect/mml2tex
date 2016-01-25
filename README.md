# mml2tex

mml2tex is an XProc/XSLT-library which converts MathML to LaTeX.

## Invoke standalone

There is a simple frontend XSLT to invoke mml2tex. For example, you can use Saxon to apply the stylesheet to your input XML file.

```
$ java -jar saxon9he.jar -s:example.xml -xsl:mml2tex/xsl/test-mml.xsl
```

## Include mml2tex as XProc library

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

As a convention, our calabash frontend looks after an XML catalog file under `xmlcatalog/catalog.xml`.
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

### Invoke mml2tex in your pipeline

The step `mml2tex:convert` is provided to 

To include mml2tex in your pipeline, we provide the step `mml2tex:convert`. As prerequisites, you must add the namespace  `http://transpect.io/mml2tex` and a `p:import` statement.

```xml
<?xml version="1.0" encoding="UTF-8"?>
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
