const fs = require('fs');
const html = fs.readFileSync('d:\\ihateb\\profile_ihatebaselines.html', 'utf8');
const index = html.indexOf('8.144,77');
console.log(html.substring(index - 100, index + 100));
