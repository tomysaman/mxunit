<!---
 Extends the base Assertions ... assertEquals and AssertTrue ...
 --->
<cfcomponent displayname="MXUnitAssertionExtensions" extends="Assert" output="false" hint="Extends core mxunit assertions.">

	<cfparam name="request.__mxunitInheritanceTree__" type="string" default="" />

	<cffunction name="assertIsXMLDoc" access="public" returntype="boolean">
		<cfargument name="xml" required="yes" type="any" />
		<cfargument name="message" required="no" default="The test result is not a valid ColdFusion XML DOC object." type="string">

		<cfset assertTrue(isXMLDoc(arguments.xml),arguments.message)>

		<cfreturn true>

	</cffunction>

	<cffunction name="assertIsEmptyArray" access="public" returntype="boolean">
		<cfargument name="a" required="yes" type="any" />
		<cfargument name="message" required="no" default="The test result is NOT an empty ARRAY. It has #ArrayLen(arguments.a)# elements" type="string">

		<cfset assertEquals(0,ArrayLen(arguments.a),arguments.message)>

		<cfreturn true>

	</cffunction>

	<cffunction name="assertIsArray" access="public" returntype="boolean">
		<cfargument name="a" required="yes" type="any" />
		<cfargument name="message" type="string" required="false" default="The test result is not a valid ColdFusion ARRAY."/>

		<cfset assertTrue(isArray(arguments.a),arguments.message)>

		<cfreturn true>

	</cffunction>

	<cffunction name="assertIsEmptyQuery" access="public" returntype="boolean">
		<cfargument name="q" required="yes" type="any" />
		<cfargument name="message" type="string" required="false" default="There should be 0 records returned but there were #arguments.q.recordcount#"/>

		<cfset assertEquals(0,arguments.q.recordcount,arguments.message)>

		<cfreturn true>

	</cffunction>

	<cffunction name="assertIsQuery" access="public" returntype="boolean">
		<cfargument name="q" required="yes" type="any" />
		<cfargument name="message" type="string" required="false" default="The test result is not a valid ColdFusion QUERY."/>

		<cfset assertTrue(isQuery(arguments.q),arguments.message)>

		<cfreturn true>

	</cffunction>

	<cffunction name="assertIsStruct" access="public" returntype="boolean">
		<cfargument name="struct" required="yes" type="any" />
		<cfargument name="message" type="string" required="false" default="The test result is not a valid ColdFusion STRUCTURE."/>

		<cfset assertTrue(isStruct(arguments.struct),arguments.message)>

		<cfreturn true>

	</cffunction>

	<cffunction name="assertIsEmptyStruct" access="public" returntype="boolean">
		<cfargument name="struct" required="yes" type="any" />
		<cfargument name="message" type="string" required="false" default="The test result is NOT an empty STRUCTURE. It has #StructCount(arguments.struct)# top-level keys"/>

		<cfset assertEquals(0,StructCount(arguments.Struct),arguments.message)>

		<cfreturn true>

	</cffunction>

	<cffunction name="assertIsEmpty" access="public" returntype="boolean">
		<cfargument name="o" required="yes" type="String" />
		<cfargument name="message" type="string" required="false" default="The test result is NOT EMPTY. It is [#o#]"/>

		<cfset assertEquals("",o,arguments.message)>

		<cfreturn true>

	</cffunction>

	<cffunction name="assertIsDefined" access="public" returntype="boolean">
		<cfargument name="o" required="yes" type="any" />
		<cfargument name="message" type="string" required="false" default="The value [#arguments.o#] is NOT DEFINED"/>

		<cfset assertTrue( isDefined(evaluate("arguments.o")) , arguments.message )>

		<cfreturn true>

	</cffunction>

	<cffunction name="assertIsTypeOf" access="public" returntype="boolean" hint="returns true if 'type' argument matches the object's type or if the object is in the inheritance tree of the type.">
		<cfargument name="o" required="yes" type="any" />
		<cfargument name="type" required="yes" type="string" />

		<cfset var md = getMetaData(o)>
		<cfset var oType = md.name>
		<cfset var ancestry = buildInheritanceTree(md) />

		<cfset var message = "The object [#oType#] is not of type #arguments.type#. Searched inheritance tree: [#ancestry#]">
		<cfif listFindNoCase(ancestry,arguments.type) eq 0>
			<cfset fail(message)>
		</cfif>

		<cfreturn true>

	</cffunction>

	<cffunction name="assertIsExactTypeOf" output="false" access="public" returntype="boolean" hint="returns true if 'type' argument matches exactly the object's type. inheritance tree is not considered">
		<cfargument name="o" required="yes" type="any" />
		<cfargument name="type" required="yes" type="string" />

		<cfset var oType = getMetaData(o).name>

		<cfif oType neq arguments.type>
			<cfset failNotEquals(arguments.type,oType,"The object [#oType#] is not of exact type #arguments.type#")>
		</cfif>

		<cfreturn true>

	</cffunction>

	<cffunction name="assertEqualsWithTolerance" access="public" returntype="boolean" output="false" hint="returns true of actual and expected are within a certain tolerance(epsilon) of each other. good for comparing floating point values.">
		<cfargument name="expected" type="any" required="yes" hint="The expected object to compare." />
		<cfargument name="actual" type="any" required="yes" hint="The actual object to compare." />
		<cfargument name="tolerance" type="numeric" required="yes" hint="">
		<cfargument name="message" type="string" required="false" default="" hint="Optional custom message to display if comparison fails." />

		<cfset var err = 0 />

		<cfif isNumeric(arguments.expected) and isNumeric(arguments.actual)>
			<cfset err = ABS(arguments.expected - arguments.actual) />
			<cfif err gt arguments.tolerance>
				<cfset failNotEquals(arguments.expected, arguments.actual, arguments.message) />
			</cfif>
		</cfif>

		<cfreturn true />

	</cffunction>

	<cffunction name="assertQueryEquals" access="public" output="false" returntype="void" description="compares 2 queries, cell by cell, and fails if differences exist">
    	<cfargument name="expected" type="query" required="true"/>
    	<cfargument name="actual" type="query" required="true"/>

		<cfset var colName = "">
		<cfset var row = 1>
		<cfset var col = 1>
		<cfset var numRows = expected.RecordCount>
		<cfset var numCols = listLen(expected.ColumnList)>

		<cfset var expectedColumnList = listSort(expected.ColumnList, "textnocase", "asc")>
		<cfset var actualColumnList = listSort(actual.ColumnList, "textnocase", "asc")>

		<cfset assertEquals( expectedColumnList, actualColumnList, "Expected and actual Column lists did not match" )>
		<cfset assertEquals( expected.RecordCount, actual.RecordCount, "Expected and actual RecordCount did not match" )>

		<cfset expectedColumnList = listToArray(expectedColumnList)>
		<cfloop from="1" to="#expected.RecordCount#" index="row">
			<cfloop from="1" to="#numCols#" index="col">
				<cfset colName = expectedColumnList[col]>
				<cfset assertEquals( expected[colName][row], actual[colName][row], "Expected Row #row#, Column named #colName# to be equal"  )>
			</cfloop>
		</cfloop>

    </cffunction>

    <cffunction name="assertStructEquals" output="false" access="public" returntype="any" hint="compares two structures, key by key, and fails if differences exist">
    	<cfargument name="expected" type="struct" required="true"/>
    	<cfargument name="actual" type="struct" required="true"/>
		<cfargument name="path" type="string" required="false" default="" hint="don't touch this, sucker"/>
		<cfset var key = "">
		<cfset var currentExpectedValue = "">
		<cfset var currentActualValue = "">
		<cfset var expectedKeyArray = arraySort( structKeyArray( expected ), "textnocase", "asc" )>
		<cfset var actualKeyArray = arraySort( structKeyArray( actual ), "textnocase", "asc" )>
		<cfset var thisPath = arguments.path>

		<cfset assertEquals( expectedKeyArray, actualKeyArray, "Expected and actual key lists do not match" )>

		<cfloop collection="#expected#" item="key">
			<cfset thisPath = thisPath & "[ ""#key#"" ]">
			<cfset currentExpectedValue = expected[key]>
			<cfset currentActualValue = actual[key]>

			<cfif isSimpleValue( currentExpectedValue ) AND isSimpleValue( currentActualValue )>
				<cfset assertEquals( currentExpectedValue, currentActualValue, "Structure Key Mismatch at path: #thisPath#" )>
			<cfelseif isQuery( currentExpectedValue ) AND isQuery( currentActualValue )>
				<cfset assertQueryEquals( currentExpectedValue, currentActualValue )>
			<cfelseif isStruct( currentExpectedValue ) AND isStruct( currentActualValue )>
				<cfset assertStructEquals( currentExpectedValue, currentActualValue, thisPath )>
			<cfelse>
				<cfset fail("Not sure how to compare these datatypes at path #thisPath#. File a big with a patch")>
			</cfif>
			<cfset thisPath = arguments.path>
		</cfloop>

    </cffunction>

	<cffunction name="buildInheritanceTree" access="public" returntype="string">
		<cfargument name="metaData" type="struct" />
		<cfargument name="accumulator" type="string" required="false" default=""/>

		<cfscript>
			var key = "";

			if( structKeyExists(arguments.metadata,"name") AND listFindNoCase(accumulator,arguments.metaData.name) eq 0 ){
				accumulator =  accumulator & arguments.metaData.name & ",";
			}

			if(structKeyExists(arguments.metaData,"extends")){
				//why, oh why, is the structure different for interfaces vs. extends? For F**k's sake!
				if( structKeyExists( metadata.extends, "name" ) ){
					accumulator = buildInheritanceTree(metaData.extends, accumulator);
				}else{
					accumulator = buildInheritanceTree(metadata.extends[ structKeyList(metadata.extends) ], accumulator);
				}
			}

			if(structKeyExists(arguments.metaData,"implements")){
				for(key in arguments.metadata.implements){
					accumulator = buildInheritanceTree(metaData.implements[ key ], accumulator);
				}
			}

			return  accumulator;
		</cfscript>

	</cffunction>

</cfcomponent>