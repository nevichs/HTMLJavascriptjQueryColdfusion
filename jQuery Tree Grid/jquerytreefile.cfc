<cfcomponent>
<!----------------------------------------------------------------------------------->
<!----------------------------------------------------------------------------------->
<cffunction name="getpbaselinetree" access="remote" returntype="any" returnformat="plain" output="no">
    <!--- These are the values passed from the grid when the user pages --->
    <cfargument name="page" type="numeric" default="1">
    <cfargument name="rows" type="numeric" default="10">
    <cfargument name="sidx" type="string" default="docno">
    <cfargument name="sord" type="string" default="asc">
    <cfargument name="doctype" type="string" default="">
    <cfargument name="filters" type="string" default="">
	<cfargument name="nodeid" type="string" default="">
	<cfargument name="parentid" type="string" default="">
	<cfargument name="n_level" type="string" default="0">
	<cfargument name="parentunid" type="string" default="">
	<cfargument name="showme" type="string" default="Base">
	<cfargument name="expanded" type="string" default="false">
	<cfargument name="_search" type="string" default="false">
	<cfset var result = structnew()>
    <cfset var z      = StructNew()>
	<cfif null(arguments.n_level)>
		<cfset arguments.n_level = 0>
	</cfif>
	<cfif arguments.expanded>
		<cfset arguments.filters = "">
	</cfif>
	
    <cfset z.where    = "">
	<cfset z.savefound = false>
	<cfset z.expnodelist = "">
    <cfset z.where = makeWhereClause(arguments.filters)>
		
	<!--- This code only fires when it is the first time or the "reset" button is pushed. --->
	<cfif arguments.n_level eq 0 and null(z.where)>
		<cfquery name="z.toplevel" datasource="#session.sv.ds#">
            select unid from tree
			where indentlevel = '001'
        </cfquery>
        <cfset arguments.nodeid = z.toplevel.unid>		
        <cfquery name="z.getsavedsettings" datasource="#session.sv.ds#">
			select * from treesettings
		</cfquery>
		<cfif notnull(z.getsavedsettings.expnodelist)>
			<cfset z.savefound = true>
		</cfif>
		<cfif ListFind(z.getsavedsettings.expnodelist,arguments.nodeid) eq 0>
			<cfset z.expnodelist = arguments.nodeid & "," & z.getsavedsettings.expnodelist>
		<cfelse>
			<cfset z.expnodelist = z.getsavedsettings.expnodelist>
		</cfif>
		<cfif arguments._search eq false>
			<cfset arguments.showme = z.getsavedsettings.showtype>
			<cfif z.getsavedsettings.fullyexpandedflag eq "Y">
				<cfset arguments.expanded = true>
			<cfelse>
				<cfset arguments.expanded = false>
			</cfif>
		</cfif>
	</cfif>
		
    <cfquery name="z.q1" datasource="#session.sv.ds#">
        select distinct unid,indentcode,indentlevel,partno,description
        from tree
		<!--- If the search is empty or the fully expanded option is selected --->
		<cfif null(z.where) or arguments.expanded>
			<!--- This part of the where clause only selects the "B" level --->
			<cfif not arguments.expanded>
				<cfif z.savefound>
					and nexthigherunidno in (<cfqueryparam cfsqltype="cf_sql_varchar" value="#z.expnodelist#" list="true">)
				<cfelse>
					and nexthigherunidno = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.nodeid#">
				</cfif>
			</cfif>
			<!--- Make sure we don't get the "A" level twice since we union it later in the query --->
			and unid != <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.nodeid#">
		<!--- If there is search parameters first look for all the unids that meet the search parameters.
		We then loop backwards up the tree using the connect by prior function --->
		<cfelse>
			start with unid in( select unid from tree
            where #PreserveSingleQuotes(z.where)#)
			connect by nocycle prior  nexthigherunidno = unid
		</cfif>
		<!--- Union it with top level so it always shows --->
		<cfif arguments.n_level eq 0 and null(z.where)>
			union
			select unid,indentcode,indentlevel,partno,description from tree
            where and indentlevel = '001'
		</cfif>
		order by indentlevel
    </cfquery>
	<!--- Return Code here --->
</cffunction>
</cfcomponent>