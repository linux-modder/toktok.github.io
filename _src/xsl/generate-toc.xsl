<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:template match="main">
    <nav id="toc">
      <ul>
        <xsl:apply-templates select="h1" mode="toc"/>
      </ul>
    </nav>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="li/p">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="p">
    <xsl:variable name="number" select="count(preceding-sibling::p) - count(preceding-sibling::*[@id][1]/preceding-sibling::p) + 1"/>
    <xsl:variable name="link" select="concat(preceding-sibling::*[@id][1]/@id, '-', $number)"/>
    <xsl:copy>
      <a id="{$link}" href="#{$link}" class="paragraph"><xsl:value-of select="$number"/></a>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="h1[@id]|h2[@id]|h3[@id]|h4[@id]">
    <a href="#{@id}">
      <xsl:copy>
        <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
    </a>
  </xsl:template>


  <xsl:template match="h1" mode="toc">
    <xsl:variable name="myId">
      <xsl:value-of select="generate-id(.)"/>
    </xsl:variable>
    <li>
      <a id="toc-{@id}" href="#{@id}">
        <xsl:apply-templates select="node()"/>
      </a>
      <xsl:if test="following::h2[1][preceding::h1[1]]">
        <ul>
          <xsl:apply-templates select="following::h2[preceding::h1[1][generate-id() = $myId]]" mode="toc"/>
        </ul>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="h2" mode="toc">
    <li>
      <a id="toc-{@id}" href="#{@id}">
        <xsl:apply-templates select="node()"/>
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>
