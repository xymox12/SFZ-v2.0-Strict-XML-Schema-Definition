<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:exslt="http://exslt.org/common"
                xmlns:functx="http://www.functx.com"
                exclude-result-prefixes="#all"
                expand-text="yes"
                version="3.0">
    <xsl:output indent="yes"/>
    <xsl:strip-space elements="*"/>
    <xsl:mode on-no-match="shallow-copy" />
    <!-- xslt3 "-xsl:.\src\stylesheets\sfz2xml_stylesheet_experimental.xsl" "-it:sfz2xml" "-o:.\temp\test.xml"  , rem - PS quotes -->
    
    <xsl:variable name="uparsedtxt" select="unparsed-text('../../temp/test.txt', 'utf-8')"/>    
    <!-- Remove sfz comments before normalizing -->
    <xsl:variable name="commenttxt" select="replace($uparsedtxt, '(.*?)//.*', '$1')"/>
    <!--#define variables -->
    <xsl:variable name="vartxt">
        <xsl:call-template name="vartemp"/> 
    </xsl:variable>
    <!-- normalize whitespace -->
    <xsl:variable name="txt" select="normalize-space($vartxt)" />
    
    <!-- ToDo: check if whitespace around '=' causes errors -->
    
    <xsl:template name="vartemp">
        <xsl:analyze-string select="$commenttxt" regex="#define\s+(\$.+?)\s+(-?\d\d*)" >  
            <xsl:matching-substring>
                <xsl:variable name="regexgrp0" select="functx:escape-for-regex(regex-group(0))"/>              
                <xsl:variable name="regexgrp1" select="functx:escape-for-regex(regex-group(1))"/> 
                <xsl:variable name="test0" select="replace($commenttxt, $regexgrp0, '')"/>
                <xsl:variable name="test" select="replace($test0, $regexgrp1, regex-group(2))"/> 
                <xsl:choose>
                    <xsl:when test="matches($commenttxt, '#define\s+(\$.+?)\s+(-?\d\d*)')">
                        <xsl:call-template name="vartemp"/> 
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$test"/>
                    </xsl:otherwise>
                </xsl:choose>
                
            </xsl:matching-substring>
        </xsl:analyze-string>
        
        
    </xsl:template>
    
    <!-- Initial template called by command line -->
    <xsl:template name="sfz2xml">   
        <!-- SFZ string to basic 'flat' xml -->
        <xsl:variable name="vrtfPass1">
            <xsl:call-template name="main"/>  
        </xsl:variable>
        <xsl:message terminate="no">
            <xsl:copy-of select="$vrtfPass1" />
        </xsl:message> 
        <!--  Output processed  XML -->
        <sfz>
            <xsl:apply-templates select="exslt:node-set($vrtfPass1)" />  
        </sfz>  
    </xsl:template>
    
    
    
    
    <xsl:template name="main">
        <xsl:analyze-string select="$txt" regex="([a-zA-Z0-9]*)&gt;(.*?)(&lt;|$)">
            <xsl:matching-substring>
                <xsl:variable name="header" select="regex-group(1)"/>         
                <xsl:element name="{$header}">
                    <xsl:call-template name="headercontent"/>
                </xsl:element>   
            </xsl:matching-substring>
        </xsl:analyze-string>   
    </xsl:template>
    
    
    <xsl:template name="headercontent">
        <!-- Regex currently requires Saxon's -j flag. TODO - explore if can remove need for -j -->
        <xsl:analyze-string select="regex-group(2)" regex="(\s?#?([a-zA-Z_0-9]*)\s*=\s*)(.+?)(?=(\s(#?[-a-zA-Z_0-9$]*)=|$))" flags="j">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="matches(regex-group(2), '^(?:[^\d]*)(\d+)')">
                        <xsl:call-template name="opcattr">
                            <xsl:with-param name="opcode" select="normalize-space(regex-group(2))" />
                            <xsl:with-param name="opcval" select="normalize-space(regex-group(3))" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="opcode" select="regex-group(2)"/>
                        <xsl:variable name="opcval" select="regex-group(3)"/>
                        <xsl:element name="{$opcode}">{normalize-space($opcval)}</xsl:element>  
                    </xsl:otherwise>
                </xsl:choose>   
            </xsl:matching-substring>                    
        </xsl:analyze-string>     
    </xsl:template>
    
    <!-- Group items under group opcodes -->
    
    <xsl:key name="item" match="region" use="generate-id(preceding-sibling::group[1])" />
    
    <xsl:template match="region" />
    
    <xsl:template match="group">
        <xsl:element name="group">
            <xsl:copy-of select="self::group/*" />
            <!-- <xsl:copy-of select="following-sibling::*[self::region][*]"/> -->
            <xsl:for-each select="key('item', generate-id())">     
                <xsl:copy-of select="." />               
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    
    <!-- Process opcodes with attributes -->
    
    <xsl:template match="//*[matches(name(.), '^(?:[^\d]*)(\d+)')]">
        <xsl:call-template name="opcattr">
            <xsl:with-param name="opcode" select="name(.)" />
            <xsl:with-param name="opcval" select="." />
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="opcattr"> 
        <xsl:param name="opcode" />
        <xsl:param name="i" select="1" />
        <xsl:param name="patts" select="()" />
        <xsl:param name="opcval" />
        <!-- Sequence of attributes for opcodes -->
        <xsl:variable name="nXY" select="('N','X','Y','Z')" />
        <!-- Test if opcode name contains a number -->
        <xsl:analyze-string select="$opcode" regex="^(?:[^\d]*)(\d+)" >  
            <xsl:matching-substring>
                <xsl:variable name="opc" select="functx:replace-first($opcode, regex-group(1), $nXY[$i])" /> 
                <xsl:variable name="atts" as="element(item)*" >
                    <xsl:sequence select="$patts"/>
                    <item><xsl:value-of select="regex-group(1)" /></item>
                </xsl:variable>
                <xsl:choose>
                    <!-- recursive call if more attributes found in opcode -->
                    <xsl:when test="matches($opc,'^(?:[^\d]*)(\d+)')">
                        <xsl:call-template name="opcattr">
                            <xsl:with-param name="opcode" select="$opc" />
                            <xsl:with-param name="i" select="$i+1" />
                            <xsl:with-param name="patts" select="$atts" />
                            <xsl:with-param name="opcval" select="$opcval" />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="{$opc}" >
                            <xsl:for-each select="$atts">
                                <xsl:if test="position()">
                                    <xsl:variable name="temppos" select="position()"></xsl:variable>
                                    <xsl:attribute name="{lower-case($nXY[$temppos])}">
                                        <xsl:value-of select="$atts[$temppos]" />
                                    </xsl:attribute>
                                </xsl:if>
                            </xsl:for-each>
                            <xsl:value-of select="$opcval" />
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
        </xsl:analyze-string>  
    </xsl:template>
    
    
    <!-- Helper functions -->
    
    <xsl:function name="functx:replace-first" as="xs:string"
                  xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:param name="pattern" as="xs:string"/>
        <xsl:param name="replacement" as="xs:string"/>
        <xsl:sequence select="
            replace($arg, concat('(^.*?)', $pattern),
                concat('$1',$replacement))" />
    </xsl:function>
    
    <xsl:function name="functx:precedes-not-ancestor" as="xs:boolean"
                  xmlns:functx="http://www.functx.com">
        <xsl:param name="a" as="node()?"/>
        <xsl:param name="b" as="node()?"/>       
        <xsl:sequence select="$a &lt;&lt; $b and empty($a intersect $b/ancestor::node())"/>      
    </xsl:function>
    
    <xsl:function name="functx:escape-for-regex" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/>
        
        <xsl:sequence
            select=" 
                replace($arg,
                    '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
            "
            />
    </xsl:function>
    
</xsl:stylesheet>
