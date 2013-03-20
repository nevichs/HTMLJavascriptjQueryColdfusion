

<script>
    jQuery(function()
    {
        jQuery( "#tabs").tabs({
        	show:function(event,ui){
        		if(ui.index == 1)drawGrid();
        		}
        });
        jQuery( "#tabs2" ).tabs();
        jQuery( "#tabs3" ).tabs();
		j = new recipientObj();	  
    	divs = jQuery("div[id$='ListDiv']").toArray();
    	myJSONText = "";
    	charcount(document.emailfrom.body,'numspan1',3500);
    });
    function getGroupsUsers(f, groupName)
	{
		groupunid = f.value.split(";");
		jQuery.ajax({
            async:false,
            cache:false,
            url: 'jqueryfile.cfc?method=GetGroupUsers&type=' + groupName + '&groupunid=' + groupunid[0],
            success: function(myResult)
            {
            	if(myResult == "FAIL")
            	{
            		alert("An unexpected error occured. Contact your system adminstator.")
            	}
            	else eval(myResult);
            }
        });
	}
    function switchList(f)
	  {			
			// Hide or show the neccissary div
			for(var i = 0;i<divs.length;i++)
			{
				divname = f.value + "ListDiv";
				if(divs[i].id == divname)
				{
					showdiv(divs[i].id);
				}
				else hidediv(divs[i].id);
			}
	  }
    function checkEnter(e)
	{
		var characterCode; //literal character code will be stored in this variable

		if(e && e.which){ //if which property of event object is supported (NN4)
	    e = e
			characterCode = e.which //character code is contained in NN4's which property
		}
		else{
			e = e
			characterCode = e.keyCode //character code is contained in IE's keyCode property
		}
		if(characterCode == 13){ //if generated character code is equal to ascii 13 (if enter key)
			j.addFromInputBox();
			return false
		}
		else{
			return true
		}
	}
	function checkEnterUser(e,value)
	{
		var characterCode; //literal character code will be stored in this variable

		if(e && e.which){ //if which property of event object is supported (NN4)
	    e = e
			characterCode = e.which //character code is contained in NN4's which property
		}
		else{
			e = e
			characterCode = e.keyCode //character code is contained in IE's keyCode property
		}
		if(characterCode == 13){ //if generated character code is equal to ascii 13 (if enter key)
			addUserTo(value);
			return false
		}
		else{
			return true
		}
	}
	function checkEnterGroup(e,type,value)
	{
		var characterCode; //literal character code will be stored in this variable

		if(e && e.which){ //if which property of event object is supported (NN4)
	    e = e
			characterCode = e.which //character code is contained in NN4's which property
		}
		else{
			e = e
			characterCode = e.keyCode //character code is contained in IE's keyCode property
		}
		if(characterCode == 13){ //if generated character code is equal to ascii 13 (if enter key)
			addGroupTo(type,value);
			return false
		}
		else{
			return true
		}
	}
	function addUserTo(value)
	{
		infoarray = value.split(';');
		//No email provided
		if(infoarray[1] == undefined)
		{
			infoarray[1] = "";
		}
		ttotype = jQuery("#totype").val();
		if(value == "ALL ACTIVE USERS")
			j.addRecipient('ALLACTIVEUSERS','',infoarray[0],infoarray[1],"to");
		else if(value == "ALL USERS LOGGED IN")
			j.addRecipient('ALLLOGGEDINUSERS','',infoarray[0],infoarray[1],"to");
		else
			j.addRecipient('USER','',infoarray[0],infoarray[1],"to");
	}
	function addGroupTo(type,value)
	{
		infoarray = value.split(';');
		//No email provided
		if(infoarray[1] == undefined)
		{
			infoarray[1] = "";
		}
		j.addRecipient(type,infoarray[0],type + ":" + infoarray[1],"","to");
	}
    function recipientObj()
    {
        this.recipientCount = 0;
        this.rs             = new Array(); //rs is just short for recipients
        this.addRecipient = function()
        {
            rowNumber = this.rs.length;
            //alert('Number of rs: '+rowNumber);
            //alert('Number of arguments: '+arguments.length);
            totype = "";
            toselectbox = "";
            this.rs[rowNumber]={type:arguments[0],id:arguments[1],email:arguments[3],totype:arguments[4]};
            if(arguments[4] == "to")
            {
            	toselectbox = '<select id="totype' + rowNumber + '" name="totype' + rowNumber + '" onchange="j.changetotype('+ rowNumber +')"><option value="to" selected>To:</option><option value="cc">Cc:</option><!--- <option value="bcc">Bcc:</option> ---></select>';
            }
            else if(arguments[4] == "cc")
            {
            	toselectbox = '<select id="totype' + rowNumber + '" name="totype' + rowNumber + '" onchange="j.changetotype('+ rowNumber +')"><option value="to">To:</option><option value="cc" selected>Cc:</option><!--- <option value="bcc">Bcc:</option> ---></select>';
            }
            else
            {
            	toselectbox = '<select id="totype' + rowNumber + '" name="totype' + rowNumber + '" onchange="j.changetotype('+ rowNumber +')"><option value="to">To:</option><option value="cc">Cc:</option><option value="bcc" selected>Bcc:</option></select>';
            }
            if (arguments[3] != '')
                jQuery('#inputtr').before('<tr id="to'+rowNumber+'"><td style="width:65px; text-align:right; vertical-align:top;">'+toselectbox+'</td><td>'+arguments[2]+' &lt;'+arguments[3]+'&gt; <a id="removerec'+rowNumber+'" href="javascript:j.delRecipient('+rowNumber+');">Remove</a></td></tr>');
            else
                jQuery('#inputtr').before('<tr id="to'+rowNumber+'"><td style="width:65px; text-align:right; vertical-align:top;">'+toselectbox+'</td><td>'+arguments[2]+' <a id="removerec'+rowNumber+'" href="javascript:j.delRecipient('+rowNumber+');">Remove</a></td></tr>');
            this.recipientCount++;
            this.rebuildJSON();
        }
        this.delRecipient = function()
        {
            this.rs.splice(arguments[0],1);
            jQuery('#to'+arguments[0]).remove();
            <!--- for(i = arguments[0] + 1;i<=this.recipientCount;i++)
            {
            	newnum = i - 1;
            	jQuery('#to'+i).attr("id","to" + newnum);
            	jQuery('#totype'+i).attr("onchange","j.changetotype(" + newnum + ")");
            	jQuery('#totype'+i).attr("id","totype" + newnum);
            	jQuery('#totype'+i).attr("name","totype" + newnum);
            	jQuery("#removerec"+i).attr("href","javascript:j.delRecipient(" + newnum + ")");
            	jQuery("#removerec"+i).attr("id","removerec" + newnum);
            } --->
            this.recipientCount--;
            this.rebuildJSON();
        }
        this.rebuildJSON = function()
        {
            myJSONText = jQuery.toJSON(this);
            myJSONText = myJSONText.replace(/#/g,'[!CMPRO_POUND!]');
            //jQuery('#jsonArea').html(myJSONText);
            //jQuery.dump(this.rs);
        }
        this.addFromInputBox = function()
        {
        	if(jQuery('#inputtr #newOne').val().indexOf("@") < 0)
        	{
        		alert("The entered email address is not valid.");
        	}
        	else
        	{
	            //NEED TO VALIDATE IT IS A E-MAIL AND PROPERLY FORMATTED
	            j.addRecipient('RANDOM EMAIL','','',jQuery('#inputtr #newOne').val(),jQuery('#totype').val());
	            jQuery('#inputtr').remove();
	            this.drawBottomInput();
	        }
        }
        this.drawBottomInput = function()
        {
            jQuery('#subjecttr').before('<tr id="inputtr"><td style="width:65px; text-align:right; vertical-align:top;"><select id="totype" name="totype"><option value="to" selected>To:</option><option value="cc">Cc:</option><!--- <option value="bcc">Bcc:</option> ---></select></td><td><input type="text" name="newOne" id="newOne" size="90" onkeydown="checkEnter(event)"></td></tr>');
            jQuery('#inputtr #newOne').focus();
        }
        this.changetotype = function(num)
        {
        	this.rs[num].totype = jQuery('#totype' + num).val();
        	this.rebuildJSON();
        }
        this.addRecipientnoinput = function()
        {
            rowNumber = this.rs.length;
            this.rs[rowNumber]={type:arguments[0],id:arguments[1],email:arguments[3],totype:arguments[4]};
            this.recipientCount++;
            this.rebuildJSON();
        }
    }
    function sendemail()
    {
    	//Check to input box to see if they put in an email without hitting enter
    	if(trim(jQuery('#inputtr #newOne').val()) != "")
    	{
    		if(jQuery('#inputtr #newOne').val().indexOf("@") < 0)
        	{
        		alert("The entered email address is not valid.");
        		return false;
        	}
        	else
        	{
        		j.addRecipientnoinput('RANDOM EMAIL','','',jQuery('#inputtr #newOne').val(),jQuery('#totype').val());
        	}
    	}
    	//Check to make sure there is a message
    	if(trim(jQuery("#body").val()) == "")
    	{
    		alert("A message is required.");
    		jQuery("#body").focus();
        	return false;
    	}
    	//Check to make sure the message isn't too long
    	if(document.emailfrom.body.value.length > 3500)
    	{
    		alert("Message exceeds the maximum length.");
    		jQuery("#body").focus();
        	return false;
    	}
    	//Check to make sure there is a recipient
    	if(trim(jQuery('#inputtr #newOne').val()) == "" && myJSONText == "")
    	{
    		alert("A recipient is required.");
    		jQuery("#newOne").focus();
        	return false;
    	}
    	//Check to make sure there is actually a "to" recipient
    	var hastorec = false;
    	for(i=0;i<j.recipientCount;i++)
    	{
    		if(j.rs[i].totype == "to")
    		{
    			hastorec = true;
    			break;
    		}
    	}
    	if(!hastorec)
    	{
    		alert('A "To" recipient is required.');
    		return false;
    	}
    	if(trim(jQuery("#subject").val()) == "")
    	{
    		alert('A subject is required.');
    		return false;
    	}
   		jQuery.ajax({
            async:false,
            cache:false,
            type:'POST',
            url: 'jquery.cfc?method=sendMassEmail&subject=' + jQuery("#subject").val() + '&from=' + jQuery("#from").val() + '&priority=' + jQuery("#priority").val(),
            data: {json: myJSONText, body: jQuery("#body").val()},
            error: function(jqXHR, textStatus, errorThrown)
			{
				//jQuery.dump(jqXHR); jQuery.dump(textStatus); jQuery.dump(errorThrown); jQuery.dump(myJSONText);
				jQuery.gritter.add({title:'Error!',text:'E-mail process failed. Please contact your system administrator.'});
				jQuery("#agendacreatebtn").button("option", "disabled", false);
				jQuery("#agendacreatebtn").button("option", "label", "Add to E-BA Agenda");
			},
	        success: function(data)
	        {
				result = jQuery.parseJSON(data);
            	if(result.success)
            	{
            		jQuery.gritter.add({title:'Success!',text:'E-mail sent.'});
            		for(i = j.recipientCount-1;i>=0;i--)
            		{
            			j.delRecipient(i);
            		}
            		jQuery('#inputtr #newOne').val("");
            		jQuery('#inputtr #totype').val("to");
            		//This is to make sure that all reciepents are removed
            		jQuery('tr[id^="to"]').each(function(){jQuery(this).remove();});
            	}
            	else if(result.data.msg == "FAILCC")
            	{
            	    jQuery.gritter.add({title:'Fail!',text:'The maximum number of "Cc" recipients allowed has been exceeded.'});
            	}
            	else if(result.data.msg == "FAILBCC")
            	{
            	    jQuery.gritter.add({title:'Fail!',text:'The maximum number of "Bcc" recipients allowed has been exceeded.'});
            	}
            	else
            	{
            	    //jQuery.dump(myJSONText);
            	    jQuery.gritter.add({title:'Fail!',text:'An unexpected error occured. Please contact your system adminstrator.'});
            	}
            }
        });
    }
</script>

<body>
	<table>
	<cfoutput>
        <tr>
            <td style="vertical-align:top; width:100%">
				<table cellspacing="0" width="100%"><tr><td>
                <div id="tabs">
                    <ul>
                        <li><a href="##tabs-1">Send E-mail</a></li>
                    </ul>
                    <div id="tabs-1">
                        <form name="emailfrom" action="jqueryfile.cfc" method="post" onsubmit="return false">
                            <input type="hidden" name="method" id="method" value="sendEmail">
                            <input type="hidden" name="toEmails" id="toEmails" value="">
                            <input type="hidden" name="toUNIDs" id="toUNIDs" value="">
                            <input type="hidden" name="cc" id="cc" value="">
                            <input type="hidden" name="bcc" id="bcc" value="">
							<table cellspacing="0">
								<tr>
									<td valign="top">
										<div id=tabs2>
											<ul>
			                                    <li><a href="##tabs2">Select Recipient</a></li>
			                                </ul>
											<table width="100%">
												<tr>
													<td align="right">Search:</td>
													<td><input type="text" name="regexp" id="regexp" size="18" maxlength="30" style="width:140px;"></td>
												</tr>
												<tr>
													<td align="right">List:</td>
													<td>
														<select name="listselect" id="listselect" onfocus="this.oldvalue=this.value;" onchange="switchList(this);" style="width:150px;">
															<option value="user" selected>Users</option>
															<option value="udGroup">User Defined Groups</option>															
														</select>
													</td>
												</tr>
												<tr>
													<td colspan="2">
														<div id="userListDiv" style="visibility:visible; display:block;">
															<select name="userList" id="userList" size="25" ondblclick="addUserTo(this.value)" onChange="selectedUserGroupList='';" onKeyPress="checkEnterUser(event, this.value)" style="width:205px;">
																<option value="ALL ACTIVE USERS" selected>ALL ACTIVE USERS</option>
																<option value="ALL USERS LOGGED IN">ALL USERS LOGGED IN</option>
																<cfloop query="users">
																	<option value="#users.fullname#;#users.emailaddress#">#users.fullname#</option>
																</cfloop>
															</select>
														</div>

														<!--- UD Groups --->
														<cfset firstUnid = "">
														<div id="udGroupListDiv" style="visibility:hidden; display:none;">
															<select name"udGroupList" id="udGroupList" size="20" ondblclick="addGroupTo('UDG',this.value)"  onKeyPress="checkEnterGroup(event,'UDG',this.value)" onchange="selectedUserGroupList=''; getGroupsUsers(this, 'udGroupList')" style="width:205px;">
																<cfloop query="q_udGroup">
																	<option value="#uniqueid#;#groupname#" <cfif currentrow eq 1>SELECTED <cfset firstUnid = "#uniqueid#"></cfif>>#groupname#</option>
																</cfloop>
															</select>
															<cfquery name="q_udGroupUser" datasource="#session.sv.ds#">
																select fullname,emailaddress
																  from groups, users
															</cfquery>
															<br style="line-height:2px">Users in Group:<br>
															<select name="udGroupUserList" id="udGroupUserList" size="10" ondblclick="addUserTo(this.value)"  onKeyPress="checkEnterUser(event, this.value)"  onChange="selectedUserGroupList='udGroupUserList';" style="width:205px;">
																<cfloop query="q_udGroupUser">
																	<option value="#fullname#;#emailaddress#">#fullname#</option>
																</cfloop>
															</select>
														</div>														
													</td>
												</tr>
											</table>
										</div>
									</td>
									<td width="100%" valign="top">
										<div id=tabs3>
											 <ul>
			                                    <li><a href="##tabs3">E-mail</a></li>
			                                </ul>
											<table border="0" style="width: 100%;">
				                                <tr id="fromtr">
				                                    <td style="width:65px; text-align:right;">From:</td>
				                                    <td colspan="2">
				                                        <select name="from" id="from">
				                                            <option value="USER" selected>You: #email# (#username#)</option>
				                                        </select>
				                                    </td>
				                                </tr>
				                                <tr id="inputtr">
				                                    <td style="width:65px; text-align:right; vertical-align:top;"><select id="totype" name="totype"><option value="to" selected>To:</option><option value="cc">Cc:</option><!--- <option value="bcc">Bcc:</option> ---></select></td>
				                                    <td colspan="2">
				                                       <input type="text" name="newOne" id="newOne" size="70" onkeydown="checkEnter(event)">
				                                    </td>
				                                </tr>
				                                <tr id="subjecttr">
				                                    <!--- <td style="width:65px; text-align:right; vertical-align:top;"><button class="getDataButton" style="width:75px;">Subject:</button></td> --->
				                                    <td style="width:65px; text-align:right; vertical-align:top;">Subject:</td>
				                                    <td colspan="2"><textarea name="subject" id="subject" rows="2" style="width:100%" cols="125"></textarea>
					                                    <!--- <input type="text" name="subject" id="subject" maxlength="2000" value="" style="width:100%;"> ---></td>
				                                </tr>
				                                <tr>
													<td></td>
													<td>
														<cf_t_jov queryname="q_comments" orderby="comments" id="commentsLov" linktext="My Common Comments" jsfunction="charcount(document.emailfrom.body,'numspan1',3500)">
										                    <cf_t_jovitem name="sel" 		label="" islink="true">
										                    <cf_t_jovitem name="comments" 	label="Comments" searchable="true" returnId="body" ignorecase="true">
										                </cf_t_jov>&nbsp;
													 	<cf_t_jov queryname="q_emailtemplate" orderby="templatename" id="templateLov" linktext="E-mail Templates" width="950" jsfunction="charcount(document.emailfrom.body,'numspan1',3500)">
										                    <cf_t_jovitem name="templatename"  	label="Template Name"   searchable="true" islink="true">
										                    <cf_t_jovitem name="subject"  		label="Subject"      	searchable="true" returnId="subject" ignorecase="true">
											                <cf_t_jovitem name="message"  		label="Message"      	searchable="true" returnId="body" ignorecase="true">
										                </cf_t_jov>
													</td>
													<td align="right"><span id="numspan1">#3500#</span> char. left</td>
												</tr>
				                                <tr>
				                                    <!--- <td style="width:65px; text-align:right; vertical-align:top;"><button class="getDataButton" style="width:75px;">Body:</button></td> --->
				                                    <td style="width:65px; text-align:right; vertical-align:top;">Body:</td>
				                                    <td colspan="2"><textarea name="body" id="body" rows="20" cols="125" style="width:100%" onKeydown="charcount(this,'numspan1',3500);" onKeyup="charcount(this,'numspan1',3500);"></textarea></td>
				                                </tr>
				                                <!--- Todo: Signature --->
				                                <!--- <tr>
				                                    <td></td>
				                                    <td colspan="1">
				                                        <div id="signature">
				                                            vr,<br>
				                                            CMPRO Support<br>
				                                            555.555.1234<br>
				                                        </div>
				                                    </td>
				                                </tr> --->
				                                <tr>
													<td style="width:65px; text-align:right; vertical-align:top;">Priority:</td>
													<td colspan="2">
														<select name="priority" id="priority">
															<option value="high" style="color:darkred">High</option>
															<option value="normal" selected>Normal </option>
															<option value="low" style="color:darkgreen">Low</option>
														</select>
													</td>
												</tr>
				                                <tr>
				                                    <td></td>
				                                    <td colspan="2" style="padding-top:10px;"><input type="button" id="sendBtn" value="Send" onclick="sendemail()"></td>
				                                </tr>
				                            </table>
				                    	</div>
									</td>
								</tr>
							</table>
                        </form>
                    </div>                   
                </div>
				</td></tr></table>
            </td>
        </tr>
	</cfoutput>
</table>
</body>