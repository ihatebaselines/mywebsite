const fs = require('fs');
const html = fs.readFileSync('d:\\ihateb\\profile_ihatebaselines.html', 'utf8');
const index = html.indexOf('>14<');
console.log(html.substring(index - 150, index + 100));
