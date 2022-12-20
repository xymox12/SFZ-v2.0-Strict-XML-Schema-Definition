<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">
    
    <xsl:output method="text" encoding="UTF-8" indent="yes"/>
    <xsl:mode on-no-match="shallow-skip"/>
    
    <xsl:template match="/sfz">      
        <xsl:text>&#xd;</xsl:text>
        <xsl:apply-templates select="*" />
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>
    
    <xsl:template match="control">      
        <xsl:text>&lt;control&gt;</xsl:text> 
        <xsl:text>&#xd;</xsl:text>
        <xsl:apply-templates select="*" />
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>

    <xsl:template match="group">
        <xsl:text>&lt;group</xsl:text>
        <xsl:text>&gt;</xsl:text> 
        <xsl:apply-templates select="@*" />
        <xsl:text>&#xd;</xsl:text>
        <xsl:apply-templates select="region" />
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>
    
    <xsl:template match="control/* | global/*">
        <xsl:value-of select="local-name()"/>=<xsl:value-of select="."/>
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>
    
    <xsl:template match="control/define">      
        <xsl:value-of select="concat('#',local-name())"/>=<xsl:value-of select="." />
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>
    
    <xsl:template match="global">      
        <xsl:text>&lt;global&gt;</xsl:text> 
        <xsl:text>&#xd;</xsl:text>
        <xsl:apply-templates select="*" />
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>
          
    <xsl:template match="region">
        <xsl:text>&lt;region&gt;</xsl:text> 
        <xsl:apply-templates select="*" />
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>
    
    <xsl:template match="region/*">      
        <xsl:value-of select="concat(' ',local-name())"/>=<xsl:value-of select="." />
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="curve">      
        <xsl:text>&lt;curve&gt;</xsl:text> 
        <xsl:text>&#xd;</xsl:text>
        <xsl:apply-templates select="*" />
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>
    
    <xsl:template match="curve/*">
        <xsl:apply-templates select="vN[@n]" />      
        <xsl:value-of select="local-name()"/>=<xsl:value-of select="." />
        <xsl:text>&#xd;</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="@*">      
        <xsl:value-of select="concat(' ',local-name())"/>=<xsl:value-of select="." />
    </xsl:template>
    
    <xsl:template match="vN[@n]" priority="3">  
        <xsl:variable name="nval" select="format-number(@n,'000')" />
        <xsl:value-of select="replace(local-name(),'N',$nval)"/>=<xsl:value-of select="format-number(., '0.0')" />
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>
    
    <xsl:template match="*[@n]"  priority="2">  
        <xsl:variable name="nval" select="@n" />
        <xsl:value-of select="replace(local-name(),'N',$nval)"/>=<xsl:value-of select="." />
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>
    
    <xsl:template match="*[@n and @x]">  
        <xsl:variable name="nval" select="@n" />
        <xsl:variable name="xval" select="@x" />
        <xsl:value-of select="replace(replace(local-name(),'N',$nval), 'X', $xval)"/>=<xsl:value-of select="." />
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>
    
    <xsl:template match="*[@n and @x-value and @y]">  
        <xsl:variable name="nval" select="@n" />
        <xsl:variable name="xval" select="@x" />
        <xsl:variable name="yval" select="@y" />
        <xsl:value-of select="replace(replace(replace(local-name(),'N',$nval), 'X', $xval), 'Y', $yval)"/>=<xsl:value-of select="." />
        <xsl:text>&#xd;</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>
