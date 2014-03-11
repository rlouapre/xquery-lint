<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:lint="http://github.com/robwhitby/xquery-lint"
                xmlns:error="http://marklogic.com/xdmp/error"
                xmlns:xdmp="http://marklogic.com/xdmp"
                xmlns:lint-json="http://github.com/robwhitby/xquery-lint/json"
                xmlns:json="http://json.org/"
                exclude-result-prefixes="xdmp"
                extension-element-prefixes="xdmp"
                version="2.0">

  <xdmp:import-module href="json.xqy" namespace="http://github.com/robwhitby/xquery-lint/json"/>

  <xsl:template match="lint:lints">
    <xsl:value-of select="lint-json:to-json(.)"/>
  </xsl:template>

</xsl:stylesheet>
