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
  
  <p:option name="debug"         select="'no'"/>                 <!-- store debug files: yes | no -->
  <p:option name="debug-dir-uri" select="'debug'"/> <!-- URI to location where debug files are stored -->
  
  <p:import href="http://transpect.io/mml2tex/xpl/mml2tex.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  
  <mml2tex:convert>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </mml2tex:convert>
  
</p:declare-step>