<script>
let recordID = 255;

$.ajax({
    type: 'POST',
    url: `api/form/new`,
    data: {
        CSRFToken: '<!--{$CSRFToken}-->',
        1901: {
            cells: [
                        [ // row 1
                            'row 1 start date', // col 1
                            'row 1 end date',   // col 2
                            'row 1 number of days',
                            'Morning'
                        ],
                        [ // row 2
                            'row 2 start date',
                            'row 2 end date',
                            'row 2 number of days',
                            'Afternoon'
                        ]
                    ],
            columns: [
                'col_2beb',
                'col_213a',
                'col_16fb',
                'col_887d'
            ]
        }
    },
});

</script>
