<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:mml="http://www.w3.org/1998/Math/MathML"
  xmlns:mml2tex="http://transpect.io/mml2tex"
  xmlns:tr="http://transpect.io"
  name="mml2tex"
  type="mml2tex:convert"
  version="1.0">

  <p:input port="source" primary="true">
    <p:documentation>
      Expects an XML document.
    </p:documentation>
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
  
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <tr:store-debug pipeline-step="mml2tex/01.mml2tex-input">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:xslt name="preprocess" initial-mode="mml2tex-preprocess">
    <p:documentation>Grouping of MathML elements.</p:documentation>
    <p:input port="stylesheet">
      <p:document href="../xsl/preprocess-mml.xsl"/>
    </p:input>
    <p:with-param name="debug" select="''"/>
    <p:with-param name="debug-dir-uri" select="''"/>
  </p:xslt>
  
  <tr:store-debug pipeline-step="mml2tex/02.mml2tex-preprocess">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>
  
  <p:xslt name="invoke">
    <p:documentation>MathML equations are converted to "mml2tex" processing instructions.</p:documentation>    
    <p:input port="source">
      <p:pipe port="result" step="preprocess"/>
      <p:pipe port="conf" step="mml2tex"/>
    </p:input>
    <p:input port="stylesheet">
      <p:document href="../xsl/invoke-mml2tex.xsl"/>
    </p:input>
    <p:with-param name="debug" select="''"/>
    <p:with-param name="debug-dir-uri" select="''"/>
  </p:xslt>
  
  <tr:store-debug pipeline-step="mml2tex/03.mml2tex-post">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

</p:declare-step>