	<!--- First loop the query results --->
	<cfloop query="q11">
		<!--- Next loop through the list of columns made above --->		
		<cfloop list="#tcolumnlist#" index="j">		
			<!--- Finally loop through the keywords put into the "Find" search input --->
			<cfloop list="#sfilterval#" delimiters="|" index="i">
				<!--- The except cases for xtitle,xdocno,statussummary,and status are because we edit the data of it to highlight the keywords found in q11 --->
				<cfif j eq "xtitle">					
					<!--- Look for any occurances of the current keyword in the column --->
					<!--- Need to make sure we don't have any false positives because of the html code we inserted. --->
					<cfset tcolval = replace(q11.xtitle,"<font style='background-color:##00a400;color:##ffffff'><strong>","","ALL")>
					<cfset tcolval = replace(tcolval,"</strong></font>","","ALL")>					
					<cfif FindNoCase(i,tcolval) gt 0>
						<!--- If found increment the appropriate tnum variable by 1 --->
						<cfset tnumxtitle = tnumxtitle + 1>
						<!--- This loop is to make sure that we highlight all of the occurances of the keyword instead of just the first one.
						Therefore we loop untill there is no longer any occurances of the keyword --->
						<cfloop condition="FindNoCase(i,q11.xtitle,tpos) gt 0">
							<!--- The first part of the highlighting is inserting the appropriate html code before the occurance of the keyword.
							Thats why the position has a - 1 --->	
							<cfset currentposition = FindNoCase(i,q11.xtitle,tpos)>		
							<!--- Make sure the result we are finding is not html code we previously put in --->
							<cfif currentposition lt Find("<font",q11.xtitle,tpos) or Find("</font>",q11.xtitle,tpos) eq 0>
								<cfset q11.xtitle[q11.currentrow] =  insert("<font style='background-color:##00a400;color:##ffffff'><strong>",q11.xtitle[q11.currentrow], currentposition - 1)>
								<!--- Next we put the closing tags after the keyword by starting at the position after the length of the keyword 
								and the inserted hmtl, hence len(i) + 60--->
								<cfset q11.xtitle[q11.currentrow] =  insert("</strong></font>",q11.xtitle[q11.currentrow], currentposition + len(i) + 60)>
								<!--- Make sure to increment the tpos variable so we don't get stuck in an infinite loop --->
								<cfset tpos = currentposition + len(i) + 76>
							<cfelse>
								<!--- If the first thing we find is the html we inserted then we increment the tpos to after the html code --->
								<cfset tpos = Find("</font>",q11.xtitle,tpos) + 7>
							</cfif>							
						</cfloop>
						<!--- Make sure to reset the tpos variable so that the next keyword searched for starts at position 0 of the column --->
						<cfset tpos = 0>
					</cfif>
				<cfelseif j eq "xdocno">			
					<cfset tcolval = replace(q11.xdocno,"<font style='background-color:##00a400;color:##ffffff'><strong>","","ALL")>
					<cfset tcolval = replace(tcolval,"</strong></font>","","ALL")>			
					<cfif FindNoCase(i,tcolval) gt 0>						
						<cfset tnumxdocno = tnumxdocno + 1>
						<cfloop condition="FindNoCase(i,q11.xdocno,tpos) gt 0">
							<cfset currentposition = FindNoCase(i,q11.xdocno,tpos)>	
							<cfif currentposition lt Find("<font",q11.xdocno,tpos) or Find("</font>",q11.xdocno,tpos) eq 0>
								<cfset q11.xdocno[q11.currentrow] =  insert("<font style='background-color:##00a400;color:##ffffff'><strong>",q11.xdocno[q11.currentrow], currentposition - 1)>
								<cfset q11.xdocno[q11.currentrow] =  insert("</strong></font>",q11.xdocno[q11.currentrow], currentposition + len(i) + 60)>
								<cfset tpos = currentposition + len(i) + 76>
							<cfelse>
								<cfset tpos = Find("</font>",q11.xdocno,tpos) + 7>
							</cfif>							
						</cfloop>
						<cfset tpos = 0>
					</cfif>				
				<!--- This is the general case for all the columns we don't highlight words in. Here and above we increment the value
				tnum#listelement# by one for each keyword found in the column. --->
				<cfelse>
					<cfif FindNoCase(i,evaluate("q11.#j#")) gt 0>
						<cfset "tnum#j#" = evaluate("tnum#j#") + 1>
					</cfif>
				</cfif>
			</cfloop>
		</cfloop>
		<!--- Now we loop through all the columsn and assign tnummax based on what has the highest value. The highest possible value is the number of keywords --->
		<cfloop list="#tcolumnlist#" index="i">			
			<cfif tnummax lt evaluate("tnum#i#")>
				<cfset tnummax = evaluate("tnum#i#")>
			</cfif>
		</cfloop>
		<!--- Now we assign the dummy column tnum defined in q11 the highest value, tnummax, divided by the total number of keywords. The max value here is 1 --->
		<cfset q11.tnum[q11.currentrow] = tnummax/ ListLen(sfilterval,"|")>	
		<!--- After this we reset all the tnum#columnnames# back to zero --->
		<cfloop list="#tcolumnlist#" index="i">
			<cfset "tnum#i#" = 0>
		</cfloop>
		<cfset tnummax = 0>
	</cfloop>
	<!--- Finally we do a query of the a query so we can reorder the results based upon "tnum" which is essentially the relevance column --->
	<cfquery dbtype="query" name="q1">
		select * from q11 
		order by tnum desc
	</cfquery>