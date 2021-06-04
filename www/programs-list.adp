<master>
<property name="doc(title)">@page_title;literal@</property>
<property name="context">#intranet-core.context#</property>
<property name="main_navbar_label">portfolio</property>
<property name="left_navbar">@left_navbar_html;literal@</property>

<!-- Show calendar on start- and end-date -->
<script type="text/javascript" <if @::__csp_nonce@ not nil>nonce="@::__csp_nonce;literal@"</if>>
window.addEventListener('load', function() { 
     document.getElementById('start_date_calendar').addEventListener('click', function() { showCalendar('start_date', 'y-m-d'); });
     document.getElementById('end_date_calendar').addEventListener('click', function() { showCalendar('end_date', 'y-m-d'); });
});
</script>

@program_table_html;noquote@

<table cellpadding="0" cellspacing="0" border="0" width="100%">
<tr>
  <td valign="top" width="50%">
    <%= [im_component_bay left] %>
  </td>

  <td width=2>&nbsp;</td>
  <td valign="top">
    <%= [im_component_bay right] %>
  </td>
</tr>
</table><br>

<table cellpadding="0" cellspacing="0" border="0">
<tr><td>
  <%= [im_component_bay bottom] %>
</td></tr>
</table>
