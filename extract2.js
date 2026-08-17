const fs = require('fs');
const html = fs.readFileSync('d:\\ihateb\\profile_ihatebaselines.html', 'utf8');
const scriptMatch = html.match(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/);
if (scriptMatch) {
  console.log(scriptMatch[1]);
} else {
  console.log('No JSON-LD');
}
