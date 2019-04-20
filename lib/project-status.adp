<div id="@diagram_id@" style="height: @diagram_height@px; width: @diagram_width@px"></div>
<script type='text/javascript'>
Ext.require(['Ext.chart.*', 'Ext.Window', 'Ext.fx.target.Sprite', 'Ext.layout.container.Fit']);
Ext.onReady(function () {

    var statusStore = Ext.create('Ext.data.Store', {
        fields: @header_json;noquote@,
	autoLoad: true,
	proxy: {
            type: 'rest',
            url: '/intranet-portfolio-management/project-status.json',
            extraParams: {					// Parameters to the data-source
		diagram_interval: '@diagram_default_interval@',	//
		diagram_program_id: '@diagram_program_id@'	//
            },
            reader: { type: 'json', root: 'data' }
	},
	data: [
	    {'Date': new Date('@axis_to_date@'), '@first_status@': 0.00 }
	]
    });

    var intervalStore = Ext.create('Ext.data.Store', {
        fields: ['display', 'value'],
        data: [
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.All_Time "All Time"]%>", "value":"all_time"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Two_Years "Last Two Year"]%>", "value":"last_two_years"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Year "Last Year"]%>", "value":"last_year"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Last_Quarter "Last Quarter"]%>", "value":"last_quarter"}
        ]
    });

    var factsStore = Ext.create('Ext.data.Store', {
        fields: ['display', 'value'],
        data: [
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Number "Number"]%>", "value":"number"},
            {"display":"<%=[lang::message::lookup "" intranet-reporting-dashboard.Volume "Volume"]%>", "value":"volume"}
        ]
    });

    var chart = Ext.create('Ext.chart.Chart',{
        animate: false,
        shadow: true,
        store: statusStore,
        legend: { position: 'right' },
        axes: [{
            type: 'Numeric',
            position: 'left',
            fields: @status_list_json;noquote@,
            title: false,
            grid: false,
	    decimals: 1,
	    constrain: true,
            label: { 
		// renderer: function(v) { return String(v).replace(/(.)00000$/, '.$1M'); } 
	    }
        }, {
            title: false,
            type: 'Category',
            position: 'bottom',
            fields: ['Date'],
	    label: {
		rotate: {degrees: 315},
                renderer: function(v) {
		    return Ext.Date.format(v, 'M y'); 
                }
	    }
        }],
        series: [{
            type: 'column',
            axis: ['bottom'],
            gutter: 80,
            xField: 'Date',
            yField: @status_list_json;noquote@,
            stacked: true,
            tips: {
                trackMouse: true,
                width: 150,
                height: 55,
                renderer: function(storeItem, item) {
		    var date = storeItem.get('Date');
		    var dateIso = date.toISOString().substring(0,10);
		    var statusField = item.yField;
		    var storeValue = storeItem.get(statusField);
                    this.setTitle(
			'Date: '+dateIso+'<br>\n'+
			'Status: '+statusField+'<br>\n'+
			'#Projects: '+item.value[1]+'<br>\n'
		    );
                }
            }
        }]
    });

    var panel = Ext.create('widget.panel', {
        width: @diagram_width@,
        height: @diagram_height@,
        title: '@diagram_title@',
        renderTo: '@diagram_id@',
        layout: 'fit',
        header: false,
        tbar: [
            {
                xtype: 'combo',
                editable: false,
                fieldLabel: '<%=[lang::message::lookup "" intranet-reporting-dashboard.Interval Interval]%>',
                store: intervalStore,
                mode: 'local',
                displayField: 'display',
                valueField: 'value',
                triggerAction: 'all',
                width: 250,
                forceSelection: true,
                value: '@diagram_default_interval@',
                listeners:{select:{fn:function(combo, comboValues) {
                    var value = comboValues[0].data.value;
                    var extraParams = statusStore.getProxy().extraParams;
                    extraParams.diagram_interval = value;
                    statusStore.load();
                }}}
            }, '->', 
            {
                xtype: 'combo',
                editable: false,
                fieldLabel: '<%=[lang::message::lookup "" intranet-reporting-dashboard.Fact_Dimension "Fact Dimension"]%>',
                store: factsStore,
                mode: 'local',
                displayField: 'display',
                valueField: 'value',
                triggerAction: 'all',
                width: 250,
                forceSelection: true,
                value: '@diagram_default_fact@',
                listeners:{select:{fn:function(combo, comboValues) {
                    var value = comboValues[0].data.value;
                    var extraParams = statusStore.getProxy().extraParams;
                    extraParams.diagram_fact = value;
                    statusStore.load();
                }}}
            }
        ],
        items: chart
    });

    statusStore.load();
});
</script>

