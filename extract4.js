const fs = require('fs');
const html = fs.readFileSync('d:\\ihateb\\profile_ihatebaselines.html', 'utf8');
const index = html.toLowerCase().indexOf('clasament global');
if (index !== -1) {
    console.log(html.substring(index - 50, index + 200));
} else {
    console.log('not found clasament global');
}
