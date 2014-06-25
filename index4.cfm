<!DOCTYPE HTML>
<html lang="en-US">	 
<head>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-51496341-1', 'bestwordplay.com');
  ga('send', 'pageview');

</script>
<link rel="icon" href="favicon.ico" type="image/x-icon" />

<!--- DataTables/jQuery CSS --->
<link rel="stylesheet" type="text/css" href="https://code.jquery.com/ui/1.10.4/themes/smoothness/jquery-ui.css">
<link rel="stylesheet" type="text/css" href="http://cdn.datatables.net/1.10.0/css/jquery.dataTables.css"> 
<!--- <link rel="stylesheet" type="text/css" href="http://datatables.net/release-datatables/extensions/ColVis/css/dataTables.colVis.css"> --->

<!--- Local CSS --->
<link rel="stylesheet" type="text/css" href="kbtbc.css">

<!--- jQuery --->
<script type="text/javascript" charset="utf8" src="http://code.jquery.com/jquery-2.1.1.min.js"></script> 
<script type="text/javascript" charset="utf8" src="http://code.jquery.com/ui/1.10.4/jquery-ui.min.js"></script> 
<!---<script src="http://cdn.jquerytools.org/1.2.7/full/jquery.tools.min.js"></script>--->

 <!--- DataTables --->
<script type="text/javascript" charset="utf8" src="http://cdn.datatables.net/1.10.0/js/jquery.dataTables.js"></script>
<!--- <script type="text/javascript" charset="utf8" src="http://datatables.net/release-datatables/extensions/ColVis/js/dataTables.colVis.js"></script> --->
<script type="text/javascript" charset="utf8" src="http://cdn.datatables.net/plug-ins/be7019ee387/integration/jqueryui/dataTables.jqueryui.js"></script>

<script type="text/javascript"><!--- Datatables --->
$(document).ready(function() {
	$('#wordList').dataTable({
	  "paging": false,
	    "order": [[ 3, "desc" ]],
	 "columns": [  { "orderable": false }, null,  { "orderable": false },  null   ], 
	"searching": false
    	} );
  $('.tooltip').tooltipster({
                contentAsHTML: true,
                maxWidth: 400,
                position: 'left', 
                interactive: true
                 } );
 } );
</script>

<!--- Tooltips --->
 <script type="text/javascript" src="jquery.tooltipster.min.js"></script>
<link rel="stylesheet" type="text/css" href="tooltipster.css" />

				
        <title>Most Common Ruzzle Words - by kbtbc</title>
</head>
	<cfsilent>
	<cfparam name="RequestTimeout" default ="5000">
	
	<cfparam name="topcount" default="10"><cfif topcount gt 30><cfset topcount =30></cfif>
	<cfparam name="Minwordlength" default="2">
	<cfparam name="Maxwordlength" default="12">
	<cfparam name="prefix" default =""> <cfset prefix = #UCase(REReplace(prefix,"[^A-Za-z/, ]", "", "all"))#> 
	<cfparam name="suffix" default =""> <cfset suffix = #UCase (REReplace(suffix,"[^A-Za-z/, ]","","all"))#> 
	<cfparam name="contains1" default =""> <cfset contains1 = #UCase(REReplace(contains1,"[^A-Za-z ]","","all"))#> 
	<cfparam name="reversal" default ="no">
	<cfparam name="semor" default ="no">
	<cfparam name="palin" default ="no">
	<cfparam name="taut" default ="no">
	<cfparam name="SupDef" default = "no">
	<cfparam name="anagram" default = "no">
	<cfparam name="FrontHooksInfo" default = "">
	<cfparam name="BackHooksInfo" default = "">
	<cfparam name="AnagramContainsKey" default = "">
		
	<!--- If Contains Anywhere is selected, create AnagramContainsKey --->
		<cfif contains1 neq "" AND anagram eq "yes">
			<!--- Create an array of all the letters ---> 
			<cfset letters = reMatchNoCase("\w", contains1) /> 
			<!--- Create a stucture to count the letters --->
			<cfset letterCount = StructNew()> 
			<cfloop index="letter" array="#letters#"> 
				<cfif structKeyExists(letterCount, letter)>
				<cfset letterCount[letter]++> 
				<cfelse>       
				<cfset letterCount[letter] = 1>
				</cfif>
			</cfloop>
			<!--- Set Anagram Key --->
			<cfloop list="#listSort(structKeyList(letterCount),"text")#" index="key">
				<cfloop from="1" to="#letterCount[key]#" index =i>
					<cfset AnagramContainsKey = listAppend(AnagramContainsKey,'#key##i#') >
				</cfloop>
			</cfloop>			
		 </cfif>

<!--- put all words into memeory, cached for one hour --->
    <cfquery name="AllWords" datasource="ruzzle" cachedwithin="#CreateTimeSpan(0,1,0,0)#">
	SELECT RuzzleWords.Word, RuzzleWords.Frequency, RuzzleWords.AnagramKey, Ruzzlewords.WordLength FROM RuzzleWords;
	</cfquery>

	


     <cfquery name="Top100" datasource="ruzzle">
		SELECT Top #topcount#  RuzzleWords.Word, RuzzleWords.Frequency, RuzzleWords.OWLDef, RuzzleWords.FrontHooks, RuzzleWords.BackHooks, RuzzleWords.InnerHooks, RuzzleWords.AnagramKey, RuzzleWords.Nearby
		FROM Ruzzlewords
		WHERE <cfif (MaxWordLength - MinWordLength) eq 10> 1=1 <cfelse> ((Len([RuzzleWords.Word])) BETWEEN (#MinWordLength#) AND (#MaxWordLength#)) </cfif>
		<cfif prefix neq ""><cfoutput> AND RuzzleWords.Word LIKE '#prefix#%' </cfoutput> </cfif>
		<cfif suffix neq ""><cfoutput> AND RuzzleWords.Word LIKE '%#suffix#' </cfoutput> </cfif>
		<cfif contains1 neq "" AND reversal eq "no" AND anagram eq "no"><cfoutput> AND RuzzleWords.Word LIKE '%#contains1#%' </cfoutput> </cfif>
		<cfif contains1 neq "" AND reversal eq "yes"><cfoutput> AND ((RuzzleWords.Word LIKE '%#contains1#%') OR (RuzzleWords.Word LIKE '%#Reverse(contains1)#%')) </cfoutput> </cfif>
		<cfif contains1 neq "" AND anagram eq "yes"><cfloop list="#AnagramContainsKey#" index ="key"><cfoutput> AND (RuzzleWords.AnagramKey LIKE '%#key#%')</cfoutput></cfloop> </cfif>
		<cfif semor eq "yes">AND IsSemordnilap = true</cfif>
		<cfif palin eq "yes">AND IsPalindrome = true</cfif>
		<cfif taut eq "yes">AND IsTautonym = true</cfif>
		ORDER BY RuzzleWords.Frequency DESC;
      </cfquery>
	  
	  
	</cfsilent>
    <body >

		<cfif ReFind(#prefix#,",")>  Comma <cfelse> No Comma 
	
</cfif><hr>
	
	<div class="container">
		<section>
		<table align=center cellspacing=10 >
		<tr><td align=left valign=top> 
		<img src="logo.gif">
	  	<p align="center"><span><b>Improve your game by learning <br>the most common Ruzzle words!</b></span>
	 	 <br>&nbsp;<br>
	    
	    <form action = "/" METHOD="POST" >
	
		<table >	<tr><td colspan=2><i>Options:</i>	</td></tr>
		<tr><td> # of Words to Return: </td>
		<td> <input type="text" name="topcount" value="<cfoutput>#topcount#</cfoutput>" default="30" size=4> </td> </tr>
		
		<tr><td> Min Word Length:</td>
		
		<td> 	
		<select name="MinWordLength" >
			<cfloop from="2" to="12" index="WordCnt"> <option value="<cfoutput>#WordCnt#</cfoutput>" <cfif MinWordLength EQ WordCnt>selected="selected"</cfif> >
			<cfoutput>#WordCnt#</cfoutput></option></cfloop>
		</select> </td> </tr>
		<tr><td> Max Word Length:</td>
		
		<td> 	
		<select name="MaxWordLength" >
			<cfloop from="2" to="12" index="WordCnt">  <option value="<cfoutput>#WordCnt#</cfoutput>" <cfif MaxWordLength EQ WordCnt>selected="selected"</cfif> >
			<cfoutput>#WordCnt#</cfoutput></option></cfloop>
		</select></td> </tr>
		
		<tr><td> Prefix: </td><td> <input type="text" name="prefix" value="<cfoutput>#prefix#</cfoutput>" default ="" size=6> </td> </tr>
		<tr><td> Suffix: </td><td> <input type="text" name="suffix" value="<cfoutput>#suffix#</cfoutput>" default ="" size=6> </td> </tr>
		<tr><td> Contains:</td><td> <input type="text" name="contains1" value="<cfoutput>#contains1#</cfoutput>" default ="" size=6>
		 </td> </tr>		
		 <tr> <td colspan=2 align=center><button type="submit" value="Submit">Get Words!</button></td></tr>
		 	<tr><td colspan=2 >&nbsp;<br> 	</td></tr>
				<tr><td colspan=2><i>More Options:</i>	</td></tr>
		 <tr><td>Match Contains Reversed</td>
		 <td><input type="checkbox" name="reversal" value="yes" <cfif reversal eq "yes">checked</cfif> > </td></tr>
		 <tr><td>Match Contains Anywhere</td>
		 <td><input type="checkbox" name="anagram" value="yes" <cfif anagram eq "yes">checked</cfif> > </td></tr>
			<tr><td>Semordnilaps</td>
		 <td> <input type="checkbox" name="semor" value="yes" <cfif semor eq "yes">checked</cfif> > </td></tr>
		 	 <tr><td>Palindromes</td>
		 <td> <input type="checkbox" name="palin" value="yes" <cfif palin eq "yes">checked</cfif> > </td></tr>
		 	 <tr><td>Tautonyms</td>
		 <td> <input type="checkbox" name="taut" value="yes" <cfif taut eq "yes">checked</cfif> > </td></tr>
		 <tr><td><a href="/"><p>Reset Form</a></td></tr>

		<input type="hidden" name="qtype" value="topwords"> </form>
			
		</table>		
	</td> 
	
	<td>
	<p>&nbsp;</p>
	<table>		
	    <tr><td >	
		<cfoutput>
		<cfif prefix neq "">Prefix:&nbsp;&nbsp;#UCase(prefix)#- &nbsp;&nbsp;&nbsp;</cfif>
		<cfif suffix neq "">Suffix:&nbsp;&nbsp;-#UCase(suffix)# &nbsp;&nbsp;&nbsp; </cfif>
		<cfif contains1 neq "">Contains:&nbsp;&nbsp;#UCase(contains1)#
			<cfif reversal eq "yes">, #UCase(Reverse(contains1))#</cfif>
			<cfif anagram eq "yes"> (anywhere in word)</cfif>
			&nbsp;&nbsp;&nbsp;</cfif>
		<cfif prefix eq "" AND suffix eq "" AND contains1 eq ""><cfelse><br></cfif>
	Showing the top #Top100.RecordCount# 
	<cfif semor eq "yes"> semordnilaps </cfif>
	<cfif palin eq "yes"> palindromes </cfif>	
	<cfif taut eq "yes"> tautonyms </cfif>
	<cfif semor eq "no" AND palin eq "no" AND taut eq "no"> words </cfif> 
	
	<cfif (MaxWordLength - MinWordLength) eq 10> of any length.
		<cfelseif Maxwordlength eq MinWordLength> #MaxWordLength# characters long. 
		<cfelse> between #MinWordLength# and #MaxWordLength# characters long.</cfif>
		</cfoutput>

		<table id="wordList" class="display" cellspacing="0" width="100%">
			<thead>
			    <th>Front</th>
				<th>Word</th>
				<th>Back</th>
				<!--- <th>Definition</th> --->
				<th>Freq</th>
			</thead>
			<tbody>
			
			<cfloop query="Top100"> <!--- Output Words! ---->
					<tr height="25">
						<td align=right><cfoutput>#UCase(FrontHooks)#</cfoutput></td>
										
	<!--- Find Anagrams --->
			<!--- Create Anagram Key --->
		<cfset AllAnagrams = "" >
		<cfset WordAnagramArray = ListToArray(AnagramKey) /> <!--- Convert Word Key to Array --->
		
		<cfif len(word) eq 2 OR len(word) eq 3 > <cfset loopstart = 2> <!--- Subanagrams up to two word lengths down --->
		<cfelse> <cfset loopstart = '#(len(word)-2)#' >
		</cfif>

		<cfloop from="#loopstart#" to="#len(word)#" index="i">  
		
			 <cfquery name="FindAnagrams" dbtype="query" >
				SELECT AllWords.Word, AllWords.AnagramKey
					FROM AllWords
					WHERE AllWords.WordLength = #i#
			 </cfquery>
			     
			 <cfset AnagramList =""> 
				 <cfloop query="FindAnagrams">
				 <cfif WordAnagramArray.containsAll(ListToArray ( #AnagramKey# ))> 
				 <cfset AnagramList = listAppend(AnagramList, '#Word#')> 
				 </cfif>
				 </cfloop>
			 
			 <cfset AnagramListSorted = listSort(AnagramList, "text")>
			 <cfset AllAnagrams = listPrepend(AllAnagrams, '#AnagramListSorted#', '|')>
			 
		 </cfloop>

			 <!---- Start setting tooltip Content --->

			<cfset wordinfo = "&lt;b&gt;#Word#&lt;/b&gt; - &lt;i&gt; #OWLDef#&lt;/i&gt;&nbsp;&nbsp;#HTMLEditFormat ("<a target=""_blank"" href=""http://www.google.com/search?q=define+#lCase(Word)#"">&raquo;</a>")# " >
			
			<cfset wordinfo = wordinfo & "&lt;p&gt; Nearby: ">
			<cfloop list="#Nearby#" index="NearbyWord">
				<cfset wordinfo = wordinfo & "#NearbyWord# ">
			</cfloop>

			<cfset wordinfo = wordinfo & " &lt;p&gt; Anagrams: ">
			 <cfloop from="1" to="#listlen(AllAnagrams,'|')#"  index="i">
				 <cfif i eq 1 >
				 	<cfloop list="#ListGetAt(AllAnagrams, i ,'|')#" index = "Anaword"> 
				 		<cfset wordinfo = wordinfo & "#AnaWord# ">
				 	</cfloop>
				 <cfelseif i eq 2> <cfset wordinfo = wordinfo & "&lt;p&gt; Subliminals: ">
				 	<cfloop list="#ListGetAt(AllAnagrams, i ,'|')#" index = "Anaword"> 
				 		<cfset wordinfo = wordinfo & "#AnaWord# ">
				 	</cfloop>
				 <cfelse> 
				 	<cfloop list="#ListGetAt(AllAnagrams, i ,'|')#" index = "Anaword"> 
				 		<cfset wordinfo = wordinfo & "#AnaWord# ">
				 	</cfloop>
				 </cfif>
			</cfloop>

			 <cfsilent>
			
			 <!--- Get words that Start, Ends and contains word  --->
     <cfquery name="TopStartWith" dbtype="query" maxrows="15">
		SELECT AllWords.Word
		FROM AllWords
		WHERE AllWords.Word LIKE '#Word#%'
		AND AllWords.Word <> '#Word#'
		ORDER BY AllWords.Frequency DESC;
      </cfquery>

      <cfset wordinfo = wordinfo & " &lt;p&gt; As prefix: ">
      <cfloop query = "TopStartWith">
      	<cfset wordinfo = wordinfo & "#TopStartWith.Word# ">
      </cfloop>

     <cfquery name="TopEndsWith" dbtype="query" maxrows="15">
		SELECT AllWords.Word, AllWords.Frequency
		FROM AllWords
		WHERE AllWords.Word LIKE '%#Word#'
		AND AllWords.Word <> '#Word#'
		ORDER BY AllWords.Frequency DESC;
      </cfquery>

      <cfset wordinfo = wordinfo & " &lt;p&gt; As suffix: ">
      <cfloop query = "TopEndsWith">
      	<cfset wordinfo = wordinfo & "#TopEndsWith.Word# ">
      </cfloop>

     <cfquery name="TopContains" dbtype="query" maxrows="30" >
		SELECT AllWords.Word, AllWords.Frequency
		FROM AllWords
		WHERE AllWords.Word LIKE '%#Word#%' 
		AND AllWords.Word <> '#Word#'
		ORDER BY AllWords.Frequency DESC;
      </cfquery>

      <cfset wordinfo = wordinfo & " &lt;p&gt; Contained in: ">
      <cfloop query = "TopContains"> 
       <cfif reFind('#Word#', "#wordinfo#") eq False>
 		<cfset wordinfo = wordinfo & "#TopContains.Word# "> </cfif>
      </cfloop>

     <cfquery name="TopReversals" dbtype="query" maxrows="15" >
		SELECT AllWords.Word, AllWords.Frequency
		FROM AllWords
		WHERE AllWords.Word LIKE '%#Reverse(Word)#%'
		AND AllWords.Word <> '#Word#'
		ORDER BY AllWords.Frequency DESC;
      </cfquery>

      <cfset wordinfo = wordinfo & " &lt;p&gt; Reversed in: ">
      <cfloop query = "TopReversals"> 
       <cfif reFind('#Word#', "#wordinfo#") eq False >
       	<cfset wordinfo = wordinfo & "#TopReversals.Word# "> </cfif>
      </cfloop>
       --->
	
			 </cfsilent>

					<td align=center><cfoutput>
						<a class="tooltip" href="?anagram=yes&MaxWordLength=#MaxWordLength#&topcount=#topcount#&MinWordLength=#MinWordLength#&contains1=#Word#"
						title="#wordinfo#">#InnerHooks#</a>						
						</cfoutput></td>
						<td><cfoutput>#UCase(BackHooks)#</cfoutput></td>
						<!--- <td><cfoutput>#OWLDef#</cfoutput></td> --->
						<td><cfoutput>#NumberFormat(Frequency * 100, '99.99')#</cfoutput>%</td>
					</tr>  
				</cfloop>
			</tbody>
		</table>

	 </td></tr>
	 </table>


</td></tr>	
<tr><td>&nbsp;<p></p></td></tr>
 <tr ><td colspan =2 align="center">
 <table  style="border:1px solid #eee;border-collapse:collapse;" > <tr><td style="padding:10px;">
 <p style="text-align:center;">Instructions</p>  The results show the most common Ruzzle words, sorted by frequency of appearance.    You can simply begin exploring words by hovering over any word for more information or clicking any word to build into other words.   <p>

 The filters on the left will control the data results.  All filters are optional, and less filters will return more results.  <p>
 First try only changing the Min Word Length to '5' and also Max Word Length to '5' and leave the rest of the fields blank -- this will show you the most frequent 5 letter Ruzzle words only.   To show the top 5 letter words that start with 'S', run the same query with 'S' entered as a Prefix.  To show all words of 5 characters <i>or longer</i>, change the Max Word Length to 12 (so far the longest Ruzzle words are 12 characters long), and this will return all words 5 characters or longer. <p>
 
 The 'Match Contains Reversed' option will also match words that have the reversal of whatever is entered into the 'Contains' field.   For example, if you enter 'ART' in the Contains field and select 'Include Reverse Contains' (leave the other fields blank), you will get back words that contain both 'ART' and 'TRA' in them.  <p>
 
  The 'Match Contains Anywhere' option will match words that have all letters entered into the 'Contains' field anywhere in the word.  For example, to find all the words that contains two 'A's anywhere in the word, enter 'AA' in the Contains field, and select this option.   Also, clicking on any word in the results list will automatically reload the database with these options using the letters from the word selected.<p>

 The Semordnilaps option will restrict the results to only words that are Semordnilaps (ie. TRAM <--> MART).  Likewiese for the Palindrome and Tautonym options.  (These options are best used without other filters.) <p>
 
 Thanks for stopping by! <p> <font size="1"> BestWordPlay.com was created by Ruzzle player <b>kbtbc</b> and is based on the statistics from just over 6000 games as published by the <a href="http://www.ruzzleleague.com/">Ruzzle League</a>. </font>
 </td></tr></table>
	 </td></tr>
</table>


</body>
</head>
</html>
	
