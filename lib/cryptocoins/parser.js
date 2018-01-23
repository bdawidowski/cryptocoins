var page = require('webpage').create(),
    system = require('system'), address;

url = system.args[1];
page.open(url, function(status) {
    if (status !== 'success') {
        console.log('FAIL');
    } else {
        var json_response = page.evaluate(function() {
            var rows = document.getElementById("markets-table").querySelector('tbody').querySelectorAll('tr');
            var data = {
                markets: []
            };
            for(var i = 0; i < rows.length; i++){
                var row = rows[i];
                var items = row.querySelectorAll('td')
                data.markets.push({
                    rank: items[0],
                    name: items[1]
                })
            }
            return data;
        });
    }
    console.log(json_response['markets'][0]['name'])
    phantom.exit();
});