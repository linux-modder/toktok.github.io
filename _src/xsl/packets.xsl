<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

  <xsl:key name="target" match="h1|h2|h3|h4" use="@id"/>

  <xsl:template match="@*|node()" mode="thead-recurse"><xsl:copy><xsl:apply-templates select="@*|node()"/></xsl:copy></xsl:template>

  <xsl:template match="thead[tr/th/a = 'Contents']" mode="thead-recurse">
    <xsl:for-each select="key('target', substring(tr/th/a/@href, 2))">
      <xsl:apply-templates select="following-sibling::table[1]/thead" mode="thead-recurse"/>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="@*|node()" mode="tbody-recurse">
    <xsl:param name="payload"/>
    <xsl:param name="packet-kind"/>

    <xsl:copy>
      <xsl:apply-templates select="@*|node()" mode="tbody-recurse">
        <xsl:with-param name="payload" select="$payload"/>
        <xsl:with-param name="packet-kind" select="$packet-kind"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="td[preceding-sibling::td[1] = 'Message Kind']" mode="tbody-recurse">
    <xsl:param name="payload"/>
    <xsl:param name="packet-kind"/>

    <xsl:copy>
      <xsl:apply-templates select="@*" mode="tbody-recurse"/>
      <xsl:value-of select="concat(concat(., concat(': &quot;', substring-after(translate($packet-kind, ' -', ''), 'Test:'))), '&quot;')"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="td[following-sibling::td[1] = 'Message Kind']/code" mode="tbody-recurse">
    <xsl:param name="payload"/>
    <xsl:param name="packet-kind"/>

    <xsl:copy>
      <xsl:apply-templates select="@*" mode="tbody-recurse"/>
      <xsl:value-of select="string-length(substring-after(translate($packet-kind, ' -', ''), 'Test:'))"/>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="td[preceding-sibling::td[1] = 'Packet Kind']" mode="tbody-recurse">
    <xsl:param name="payload"/>
    <xsl:param name="packet-kind"/>

    <xsl:choose>
      <xsl:when test="$payload and contains($packet-kind, '(0x')">
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="tbody-recurse"/>
          <xsl:value-of select="concat(., concat(': 0x', substring-before(substring-after($packet-kind, '(0x'), ')')))"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" mode="tbody-recurse"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tr[td[3] = 'Payload']" mode="tbody-recurse">
    <xsl:param name="payload"/>
    <xsl:param name="packet-kind"/>

    <xsl:choose>
      <xsl:when test="$payload">
        <xsl:copy-of select="$payload"/>
      </xsl:when>
      <xsl:otherwise>
        <tr class="packet-row">
          <xsl:apply-templates mode="tbody-recurse">
            <xsl:with-param name="payload" select="$payload"/>
            <xsl:with-param name="packet-kind" select="$packet-kind"/>
          </xsl:apply-templates>
        </tr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tr[td[3] = 'Encrypted payload']" mode="tbody-recurse">
    <xsl:param name="payload"/>
    <xsl:param name="packet-kind"/>

    <xsl:choose>
      <xsl:when test="$payload">
        <tr>
          <td colspan="3" style="text-align: center">Start encrypted payload</td>
        </tr>
        <xsl:copy-of select="$payload"/>
        <tr>
          <td colspan="3" style="text-align: center">End encrypted payload</td>
        </tr>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@*|node()" mode="tbody-recurse">
            <xsl:with-param name="payload" select="$payload"/>
            <xsl:with-param name="packet-kind" select="$packet-kind"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tr" mode="tbody-recurse">
    <xsl:param name="payload"/>
    <xsl:param name="packet-kind"/>

    <xsl:choose>
      <xsl:when test="$payload">
        <tr class="packet-row outer-layer">
          <xsl:apply-templates mode="tbody-recurse">
            <xsl:with-param name="payload" select="$payload"/>
            <xsl:with-param name="packet-kind" select="$packet-kind"/>
          </xsl:apply-templates>
        </tr>
      </xsl:when>
      <xsl:otherwise>
        <tr class="packet-row">
          <xsl:apply-templates select="node()" mode="tbody-recurse">
            <xsl:with-param name="payload" select="$payload"/>
            <xsl:with-param name="packet-kind" select="$packet-kind"/>
          </xsl:apply-templates>
        </tr>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tbody" mode="tbody-recurse">
    <xsl:param name="payload"/>
    <xsl:param name="packet-kind"/>

    <xsl:choose>

      <xsl:when test="substring(preceding-sibling::thead/tr/th/a/@href, 2)">
        <xsl:apply-templates select="key('target', substring(preceding-sibling::thead/tr/th/a/@href, 2))/following-sibling::table[1]/tbody" mode="tbody-recurse">
          <xsl:with-param name="payload">
            <xsl:apply-templates select="tr" mode="tbody-recurse">
              <xsl:with-param name="payload" select="$payload"/>
              <xsl:with-param name="packet-kind" select="$packet-kind"/>
            </xsl:apply-templates>
          </xsl:with-param>
          <xsl:with-param name="packet-kind" select="$packet-kind"/>
        </xsl:apply-templates>
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates select="tr" mode="tbody-recurse">
          <xsl:with-param name="payload" select="$payload"/>
          <xsl:with-param name="packet-kind" select="$packet-kind"/>
        </xsl:apply-templates>
      </xsl:otherwise>

    </xsl:choose>

  </xsl:template>


  <!-- Entry point for recursive expansion. -->
  <xsl:template match="table[thead/tr/th/a = 'Contents']">
    <table>
      <xsl:apply-templates select="thead" mode="thead-recurse"/>
      <tbody>
        <xsl:apply-templates select="tbody" mode="tbody-recurse">
          <xsl:with-param name="packet-kind" select="(preceding-sibling::h1|preceding-sibling::h2|preceding-sibling::h3|preceding-sibling::h4|preceding-sibling::h5|preceding-sibling::h6)[last()]"/>
        </xsl:apply-templates>
      </tbody>
    </table>
  </xsl:template>

</xsl:stylesheet>
