<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:mml2tex="http://transpect.io/mml2tex"
  xmlns:tr="http://transpect.io"
  name="mml2tex"
  type="mml2tex:convert"
  version="1.0">

  <p:documentation>
    Takes an XML file as input and generates processing
    instructions from MathML equations.
  </p:documentation>    

  <p:input port="source" primary="true">
    <p:documentation>
      Expects an XML document.
    </p:documentation>
  </p:input>
  
  <p:input port="paths" primary="false">
    <p:inline>
      <c:param-set/>
    </p:inline>
  </p:input>

  <p:input port="conf" primary="false">
    <p:documentation>
      Expects a character map for mapping from Unicode to TeX.
    </p:documentation>
    <p:document href="../texmap/texmap.xml"/>
  </p:input>
  
  <p:output port="result">
    <p:documentation>
      Provides the XML document with mml2tex processing instructions.
    </p:documentation>
  </p:output>
  
  <p:option name="preprocessing" select="'yes'">
    <p:documentation>
      Switch XSLT optimizations for MathML on or off.
    </p:documentation>
  </p:option>
  
  <p:option name="debug" select="'yes'">
    <p:documentation>
      Used to switch debug mode on or off. Pass 'yes' to enable debug mode.
    </p:documentation>
  </p:option> 
  
  <p:option name="debug-dir-uri" select="'debug'">
    <p:documentation>
      Expects a file URI of the directory that should be used to store debug information. 
    </p:documentation>
  </p:option>
  
  <p:option name="fail-on-error" select="'yes'">
    <p:documentation>
      Whether to recover from some errors or not 
    </p:documentation>
  </p:option>
  
  <p:option name="texmap-uri" select="'../texmap/texmap.xml'">
    <p:documentation>
      uri to texmap
    </p:documentation>
  </p:option>
  
  <p:option name="texmap-upgreek-uri" select="'../texmap/texmap-upgreek.xml'">
    <p:documentation>
      uri to texmap for upgreek chars
    </p:documentation>
  </p:option>
  
  <p:option name="set-math-style" select="'no'">
    <p:documentation>
      [yes|no] Whether to output \textstyle or \displaystyle when math/@display is set
    </p:documentation>
  </p:option>

  <p:option name="always-use-left-right" select="'auto'">
    <p:documentation>
      [yes|no] Whether to always use \left and \right for ([{}]) etc.
    </p:documentation>
  </p:option>

  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/xproc-util/xslt-mode/xpl/xslt-mode.xpl"/>
  
  <p:choose name="preprocess-output">
    <p:when test="$preprocessing eq 'yes'">
      <p:output port="result"/>
      
      <tr:load-cascaded name="load-preprocess-mml-xsl" filename="mml-normalize/mml-normalize.xsl">
        <p:with-option name="fallback" select="'http://transpect.io/mml-normalize/xsl/mml-normalize.xsl'"/>
        <p:input port="paths">
          <p:pipe port="paths" step="mml2tex"/>
        </p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
      </tr:load-cascaded>
      
      <p:sink/>

      <tr:xslt-mode msg="yes" mode="mml2tex-grouping" name="grouping" prefix="mml2tex/01">
        <p:input port="source">
          <p:pipe port="source" step="mml2tex"/>
        </p:input>
        <p:input port="stylesheet">
          <p:pipe port="result" step="load-preprocess-mml-xsl"/>
        </p:input>
        <p:input port="parameters">
          <p:pipe port="paths" step="mml2tex"/>
        </p:input>
        <p:input port="models"><p:empty/></p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
      </tr:xslt-mode>
      
      <tr:xslt-mode msg="yes" mode="mml2tex-preprocess" name="preprocess" prefix="mml2tex/05">
        <p:input port="stylesheet">
          <p:pipe port="result" step="load-preprocess-mml-xsl"/>
        </p:input>
        <p:input port="parameters">
          <p:empty/>
        </p:input>
        <p:input port="models"><p:empty/></p:input>
        <p:with-option name="debug" select="$debug"/>
        <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
        <p:with-option name="fail-on-error" select="$fail-on-error"/>
      </tr:xslt-mode>

    </p:when>
    <p:otherwise>
      <p:output port="result"/>
      <p:identity/>
    </p:otherwise>
  </p:choose>
  
  <p:sink/>
  
  <tr:load-cascaded name="load-mml2tex" filename="mml2tex/load-mml2tex.xsl">
    <p:with-option name="fallback" select="resolve-uri('../xsl/invoke-mml2tex.xsl')"/>
    <p:input port="paths">
      <p:pipe port="paths" step="mml2tex"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:load-cascaded>
  
  <p:sink/>
  
  <p:xslt name="invoke">
    <p:documentation>MathML equations are converted to "mml2tex" processing instructions.</p:documentation>    
    <p:input port="source">
      <p:pipe port="result" step="preprocess-output"/>
      <p:pipe port="conf" step="mml2tex"/>
    </p:input>
    <p:input port="stylesheet">
      <p:pipe port="result" step="load-mml2tex"/>
    </p:input>
    <p:with-param name="texmap-uri" select="$texmap-uri"/>
    <p:with-param name="texmap-upgreek-uri" select="$texmap-upgreek-uri"/>
    <p:with-param name="debug" select="''"/>
    <p:with-param name="debug-dir-uri" select="''"/>
    <p:with-param name="set-math-style" select="$set-math-style"/>
    <p:with-param name="always-use-left-right" select="$always-use-left-right"/>
  </p:xslt>
  
  <tr:store-debug pipeline-step="mml2tex/10.mml2tex-main">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

</p:declare-step>
