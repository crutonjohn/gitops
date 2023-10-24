<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" encoding="UTF-8" />

<xsl:template match="/">
  <html>
    <head>
      <title>Icecast2 Status</title>
      <style type="text/css">
        body { font-family: Arial, sans-serif; }
        h1 { color: #369; }
        table { border-collapse: collapse; width: 100%; }
        th, td { text-align: left; padding: 8px; }
        th { background-color: #369; color: #fff; }
        tr:nth-child(even) { background-color: #f2f2f2; }
      </style>
    </head>
    <body>
      <h1>Icecast2 Server Status</h1>
      <table>
        <tr>
          <th>Stream Name</th>
          <th>Mount Point</th>
          <th>Current Listeners</th>
          <th>Bitrate (kbps)</th>
        </tr>
        <xsl:for-each select="icestats/source">
          <tr>
            <td><xsl:value-of select="server_name" /></td>
            <td><xsl:value-of select="mount" /></td>
            <td><xsl:value-of select="listeners" /></td>
            <td><xsl:value-of select="listenurl/bitrate" /></td>
          </tr>
        </xsl:for-each>
      </table>
    </body>
  </html>
</xsl:template>
</xsl:stylesheet>
