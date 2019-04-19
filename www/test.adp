<master>


<% im_sencha_extjs_load_libraries %>

<script>
Ext.require('Ext.chart.*');
Ext.require(['Ext.layout.container.Fit', 'Ext.window.MessageBox']);

Ext.onReady(function () {
    var store = Ext.create('Ext.data.JsonStore', {
        fields: ['year', 'comedy', 'action', 'drama', 'thriller'],
        data: [
                {year: new Date('2005-01-01'), comedy: 34000000, action: 23890000, drama: 18450000, thriller: 20060000},
                {year: new Date('2005-02-01'), comedy: 56703000, action: 38900000, drama: 12650000, thriller: 21000000},
                {year: new Date('2005-03-01'), comedy: 42100000, action: 50410000, drama: 25780000, thriller: 23040000},
                {year: new Date('2005-04-01'), comedy: 38910000, action: 56070000, drama: 24810000, thriller: 26940000},
                {year: new Date('2005-05-01'), comedy: 34000000, action: 23890000, drama: 18450000, thriller: 20060000},
                {year: new Date('2005-06-01'), comedy: 56703000, action: 38900000, drama: 12650000, thriller: 21000000},
                {year: new Date('2005-07-01'), comedy: 42100000, action: 50410000, drama: 25780000, thriller: 23040000},
                {year: new Date('2005-08-01'), comedy: 38910000, action: 56070000, drama: 24810000, thriller: 26940000}
              ]
    });

    var chart = Ext.create('Ext.chart.Chart',{
            animate: true,
            shadow: true,
            store: store,
            legend: {
                position: 'right'
            },
            axes: [{
                type: 'Numeric',
                position: 'left',
                fields: ['comedy', 'action', 'drama', 'thriller'],
                title: false,
                grid: true,
                label: {
                    renderer: function(v) {
                        return String(v).replace(/(.)00000$/, '.$1M');
                    }
                }
            }, {
                type: 'Time',
                position: 'bottom',
                fields: ['year'],
                title: false,
		dateFormat: 'M y',
		constraint: false,
		step: [Ext.Date.MONTH, 2],
		label: {rotate: {degrees: 315}}
            }],
            series: [{
                type: 'column',
                axis: ['bottom'],
                gutter: 80,
                xField: 'year',
                yField: ['comedy', 'action', 'drama', 'thriller'],
                stacked: true,
                tips: {
                     trackMouse: true,
                     width: 65,
                     height: 28,
                     renderer: function(storeItem, item) {
                         this.setTitle(String(item.value[1] / 1000000) + 'M');
                     }
                 }
            }]
        });


    var panel1 = Ext.create('widget.panel', {
        width: 800,
        height: 400,
        title: 'Stacked Bar Chart - Movies by Genre',
        renderTo: Ext.getBody(),
        layout: 'fit',
        tbar: [{
            text: 'Save Chart',
            handler: function() {
                Ext.MessageBox.confirm('Confirm Download', 'Would you like to download the chart as an image?', function(choice){
                    if(choice == 'yes'){
                        chart.save({
                            type: 'image/png'
                        });
                    }
                });
            }
        }],
        items: chart
    });
});

</script>
